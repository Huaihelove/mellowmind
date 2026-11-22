import Foundation
import SwiftData
import Combine

enum WishTubePhase: String {
    case prayer
    case shaking
    case drawing
    case result
}

@MainActor
final class WishTubeViewModel: ObservableObject {
    @Published private(set) var phase: WishTubePhase = .prayer
    @Published private(set) var shakeCount = 0
    @Published private(set) var reading: WishReading?
    @Published private(set) var selectedTheme: WishTheme?
    @Published private(set) var collectionSaved = false
    @Published var errorMessage: String?

    let requiredShakes = 3

    func beginShaking() {
        guard phase == .prayer else { return }
        phase = .shaking
        HapticManager.shared.success()
    }

    func registerShake() {
        guard phase == .shaking else { return }
        shakeCount += 1
        if shakeCount >= requiredShakes {
            phase = .drawing
            HapticManager.shared.heavyTap()
        }
    }

    func draw(theme: WishTheme, profile: UserProfile) {
        guard phase == .drawing else { return }
        selectedTheme = theme
        reading = WishOracleEngine.reading(theme: theme, profile: profile)
        phase = .result
        HapticManager.shared.success()
    }

    @discardableResult
    func collect(profile: UserProfile, context: ModelContext) -> Bool {
        guard let reading else { return false }
        guard !collectionSaved else { return true }
        let body = "\(reading.verse)\n\n\(reading.interpretation)\n\nGentle action: \(reading.gentleAction)"
        let item = CollectItem(
            kind: .wish,
            title: reading.title,
            subtitle: reading.theme.rawValue,
            body: body,
            detail: "Today's emotional keyword: \(reading.keyword)",
            keyword: reading.keyword,
            signature: reading.signature
        )
        context.insert(item)
        do {
            try context.save()
            collectionSaved = true
            HapticManager.shared.success()
            return true
        } catch {
            errorMessage = "The saved wish could not be stored. Please try again."
            return false
        }
    }

    func reset() {
        phase = .prayer
        shakeCount = 0
        reading = nil
        selectedTheme = nil
        collectionSaved = false
        errorMessage = nil
    }
}

@MainActor
final class WishWallViewModel: ObservableObject {
    @Published var draft = ""
    @Published var isAnonymous = true
    @Published var commentDraft = ""
    @Published var feedback: String?
    @Published var isComposerPresented = false
    @Published var commentWishID: UUID?
    private var didConfigure = false

    func configure(profile: UserProfile) {
        guard !didConfigure else { return }
        isAnonymous = profile.anonymousByDefault
        didConfigure = true
    }

    @discardableResult
    func post(profile: UserProfile, context: ModelContext) -> Bool {
        do {
            let content = try ContentModerationService.validateWish(draft)
            let name = try ContentModerationService.validateName(profile.displayName)
            let wish = Wish(
                authorName: name,
                isAnonymous: isAnonymous,
                content: content,
                theme: guessedTheme(for: content)
            )
            context.insert(wish)
            try context.save()
            try GrowthEngine.refreshUnlocks(context: context)
            draft = ""
            feedback = "Your wish is now on the wall."
            isComposerPresented = false
            HapticManager.shared.success()
            return true
        } catch {
            feedback = error.localizedDescription
            HapticManager.shared.warning()
            return false
        }
    }

    func toggleLike(_ wish: Wish, context: ModelContext) {
        wish.toggleLike()
        try? context.save()
        HapticManager.shared.softTap()
    }

    @discardableResult
    func addComment(to wish: Wish, profile: UserProfile, context: ModelContext) -> Bool {
        do {
            let content = try ContentModerationService.validateComment(commentDraft)
            let author = profile.anonymousByDefault ? "Anonymous Star Friend" : profile.displayName
            var comments = wish.comments
            comments.append(WishComment(author: author, content: content))
            wish.comments = comments
            try context.save()
            commentDraft = ""
            HapticManager.shared.success()
            return true
        } catch {
            feedback = error.localizedDescription
            HapticManager.shared.warning()
            return false
        }
    }

    func report(_ wish: Wish, context: ModelContext) {
        wish.reportCount += 1
        wish.isHidden = true
        try? context.save()
        feedback = "This post is hidden. Thank you for helping keep this space gentle."
        HapticManager.shared.warning()
    }

    private func guessedTheme(for text: String) -> WishTheme {
        if text.contains("sleep") || text.contains("calm") { return .calm }
        if text.contains("tired") || text.contains("recover") { return .heal }
        if text.contains("relax") || text.contains("rest") { return .ease }
        if text.contains("work") || text.contains("exam") || text.contains("move forward") { return .flow }
        return .tender
    }
}

@MainActor
final class WishSealViewModel: ObservableObject {
    @Published var draft = ""
    @Published var selectedTheme: WishTheme = .calm
    @Published var selectedMood: EmotionMood = .calm
    @Published var durationDays = 7
    @Published var errorMessage: String?
    @Published var isCreating = false

    let freeSealLimit = 3

    @discardableResult
    func create(
        profile: UserProfile,
        context: ModelContext,
        existing: [SealedWish],
        premiumUnlocked: Bool,
        notificationsEnabled: Bool
    ) -> SealedWish? {
        guard !isCreating else { return nil }
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Write a message to your future self first."
            return nil
        }
        guard trimmed.count <= 800 else {
            errorMessage = "Keep the sealed message within 800 characters."
            return nil
        }
        if !premiumUnlocked, existing.count >= freeSealLimit {
            errorMessage = "The free version allows \(freeSealLimit) sealed wishes. Unlock unlimited seals to continue."
            return nil
        }

        isCreating = true
        defer { isCreating = false }
        do {
            let ciphertext = try EncryptionService.shared.encrypt(trimmed)
            let unlockDate = Calendar.current.date(byAdding: .day, value: durationDays, to: Date()) ?? Date().addingTimeInterval(TimeInterval(durationDays * 86_400))
            let seal = SealedWish(
                theme: selectedTheme,
                encryptedPayload: ciphertext,
                unlockAt: unlockDate,
                durationDays: durationDays,
                moodBefore: selectedMood,
                signature: profile.snapshot.signature
            )
            context.insert(seal)
            try context.save()
            if notificationsEnabled {
                LocalNotificationService.shared.scheduleSealUnlock(id: seal.id, unlockAt: seal.unlockAt, theme: seal.theme)
            }
            draft = ""
            errorMessage = nil
            HapticManager.shared.success()
            return seal
        } catch {
            errorMessage = error.localizedDescription
            HapticManager.shared.error()
            return nil
        }
    }

    func decrypt(_ seal: SealedWish) -> String? {
        do {
            return try EncryptionService.shared.decrypt(seal.encryptedPayload)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func markOpened(_ seal: SealedWish, moodAfter: EmotionMood, reflection: String, context: ModelContext) {
        seal.moodAfterRaw = moodAfter.rawValue
        seal.reflection = reflection.trimmingCharacters(in: .whitespacesAndNewlines)
        seal.openedAt = Date()
        try? context.save()
        LocalNotificationService.shared.cancelSealUnlock(id: seal.id)
        HapticManager.shared.success()
    }

    func delete(_ seal: SealedWish, context: ModelContext) {
        LocalNotificationService.shared.cancelSealUnlock(id: seal.id)
        context.delete(seal)
        try? context.save()
        HapticManager.shared.warning()
    }
}

@MainActor
final class CheckInViewModel: ObservableObject {
    @Published var selectedAchievement = "Take 3 deep breaths"
    @Published var note = ""
    @Published var feedback: String?
    @Published var unlockedSkinName: String?

    let achievements = [
        "Take 3 deep breaths",
        "Drink a glass of warm water",
        "Walk for 10 minutes",
        "Write down one small joy",
        "Go to bed 30 minutes earlier",
        "Step away from screens for 10 minutes"
    ]

    @discardableResult
    func checkIn(profile: UserProfile, records: [CheckInRecord], context: ModelContext) -> Bool {
        let todayKey = DateKey.string(from: Date())
        guard !records.contains(where: { $0.dateKey == todayKey }) else {
            feedback = "You have already checked in today."
            HapticManager.shared.warning()
            return false
        }
        let record = CheckInRecord(
            dateKey: todayKey,
            achievement: selectedAchievement,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(record)
        do {
            try context.save()
            let unlocks = try GrowthEngine.refreshUnlocks(context: context)
            if let skin = unlocks.first {
                unlockedSkinName = skin.name
                feedback = "Today's check-in is saved, and you unlocked the \(skin.name) skin."
            } else {
            feedback = "Today's check-in is saved. Small consistency deserves to be seen."
            }
            note = ""
            HapticManager.shared.success()
            return true
        } catch {
            feedback = "The check-in could not be saved. Please try again."
            HapticManager.shared.error()
            return false
        }
    }
}