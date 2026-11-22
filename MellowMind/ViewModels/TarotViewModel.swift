import Foundation
import SwiftData
import Combine

enum TarotPhase: String {
    case charge
    case shuffle
    case spread
    case reveal
    case complete
}

@MainActor
final class TarotViewModel: ObservableObject {
    @Published private(set) var phase: TarotPhase = .charge
    @Published private(set) var shuffleCount = 0
    @Published private(set) var spreadCards: [TarotCard] = []
    @Published private(set) var selectedCard: TarotCard?
    @Published private(set) var reading: TarotReading?
    @Published private(set) var isFlipped = false
    @Published private(set) var sootheProgress: Double = 0
    @Published private(set) var keyword = ""
    @Published private(set) var collectionSaved = false
    @Published var errorMessage: String?

    let targetShuffles = 6
    private var profile: UserProfile?
    private var lastRubHapticAt = Date.distantPast

    var shuffleInstruction: String {
        if shuffleCount >= targetShuffles {
            return "The cards are ready"
        }
        return "Swipe left or right to shuffle · \(shuffleCount)/\(targetShuffles)"
    }

    func configure(profile: UserProfile) {
        self.profile = profile
        if spreadCards.isEmpty {
            spreadCards = TarotDeck.spread(count: 9)
        }
    }

    func completeCharge(profile: UserProfile) {
        self.profile = profile
        phase = .shuffle
        HapticManager.shared.success()
    }

    func registerShuffleStep() {
        guard phase == .shuffle else { return }
        guard shuffleCount < targetShuffles else {
            phase = .spread
            return
        }
        shuffleCount += 1
        HapticManager.shared.selection()
        if shuffleCount >= targetShuffles {
            HapticManager.shared.mediumTap()
            withAnimation(AppTheme.slowSpring) {
                phase = .spread
            }
        }
    }

    func choose(card: TarotCard, profile: UserProfile) {
        guard phase == .spread, selectedCard == nil else { return }
        self.profile = profile
        selectedCard = card
        reading = TarotReadingComposer.reading(card: card, profile: profile)
        phase = .reveal
        HapticManager.shared.heavyTap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.82, dampingFraction: 0.78)) {
                self.isFlipped = true
            }
        }
    }

    func rub(delta: CGFloat) {
        guard phase == .reveal || phase == .complete, let reading else { return }
        let addition = Double(abs(delta)) / 380.0
        sootheProgress = min(1, sootheProgress + addition)
        if Date().timeIntervalSince(lastRubHapticAt) > 0.07 {
            HapticManager.shared.softTap()
            lastRubHapticAt = Date()
        }
        if sootheProgress >= 1, phase != .complete {
            phase = .complete
            keyword = "\(reading.keyword) · \(profile?.bloodType.shortTrait ?? "Gentle")"
            HapticManager.shared.success()
        }
    }

    @discardableResult
    func collect(context: ModelContext) -> Bool {
        guard let reading else { return false }
        guard !collectionSaved else { return true }
        let body = "Your present emotional state:\n\(reading.emotionState)\n\nA thought you may be overlooking:\n\(reading.ignoredThought)\n\nA gentle way to soothe yourself:\n\(reading.gentleAdvice)"
        let detail = "\(reading.fusionNote)\n\nToday's self-reconciliation note: \(reading.affirmation)"
        let item = CollectItem(
            kind: .tarot,
            title: reading.card.name,
            subtitle: "Reflection Card · \(reading.card.theme)",
            body: body,
            detail: detail,
            keyword: keyword.isEmpty ? reading.keyword : keyword,
            signature: reading.card.id
        )
        context.insert(item)
        do {
            try context.save()
            collectionSaved = true
            HapticManager.shared.success()
            return true
        } catch {
            errorMessage = "The reflection could not be saved. Please try again."
            return false
        }
    }

    func reset() {
        phase = .charge
        shuffleCount = 0
        spreadCards = TarotDeck.spread(count: 9)
        selectedCard = nil
        reading = nil
        isFlipped = false
        sootheProgress = 0
        keyword = ""
        collectionSaved = false
        errorMessage = nil
    }
}