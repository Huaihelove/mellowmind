import Foundation
import SwiftData
import Combine

@MainActor
final class TreeHoleViewModel: ObservableObject {
    @Published var draft = ""
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isTyping = false
    @Published var feedback: String?
    @Published private(set) var lastCompanionReply: LocalCompanionReply?
    @Published private(set) var collectionSaved = false

    private var didLoad = false
    private var pendingTask: Task<Void, Never>?

    func loadHistory(entries: [EmotionJournalEntry]) {
        guard !didLoad else { return }
        didLoad = true
        messages = entries.sorted(by: { $0.createdAt < $1.createdAt }).flatMap { entry in
            [
                ChatMessage(role: .user, text: entry.content, createdAt: entry.createdAt),
                ChatMessage(role: .companion, text: "\(entry.companionReply)\n\nWant to keep talking? \(entry.followUp)", createdAt: entry.createdAt.addingTimeInterval(0.5))
            ]
        }
    }

    func send(profile: UserProfile, context: ModelContext) {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            feedback = "Write a little of what you are feeling right now."
            return
        }
        guard text.count <= 1_000 else {
            feedback = "Keep each entry within 1,000 characters. Take your time."
            return
        }
        guard !isTyping else { return }

        draft = ""
        feedback = nil
        collectionSaved = false
        messages.append(ChatMessage(role: .user, text: text))
        isTyping = true
        HapticManager.shared.lightTap()
        pendingTask?.cancel()
        pendingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 720_000_000)
            guard !Task.isCancelled else { return }
            let reply = LocalAICompanion.reply(to: text, snapshot: profile.snapshot)
            let combined = "\(reply.text)\n\nWant to keep talking? \(reply.followUp)"
            self.messages.append(ChatMessage(role: .companion, text: combined))
            self.lastCompanionReply = reply
            self.isTyping = false
            let entry = EmotionJournalEntry(
                content: text,
                companionReply: reply.text,
                followUp: reply.followUp,
                keyword: reply.keyword,
                signature: profile.snapshot.signature
            )
            context.insert(entry)
            try? context.save()
            HapticManager.shared.softTap()
        }
    }

    @discardableResult
    func collectLastExchange(context: ModelContext) -> Bool {
        guard let reply = lastCompanionReply else { return false }
        guard !collectionSaved else { return true }
        let recentUser = messages.last(where: { $0.role == .user })?.text ?? ""
        let item = CollectItem(
            kind: .companion,
            title: "Tree Hollow Reply · \(reply.keyword)",
            subtitle: "Local emotional companionship",
            body: "What I wrote:\n\(recentUser)\n\nGentle reply:\n\(reply.text)",
            detail: "Want to keep talking? \(reply.followUp)",
            keyword: reply.keyword,
            signature: reply.keyword
        )
        context.insert(item)
        do {
            try context.save()
            collectionSaved = true
            HapticManager.shared.success()
            return true
        } catch {
            feedback = "The reply could not be saved. Please try again."
            return false
        }
    }

    func cancelPending() {
        pendingTask?.cancel()
        pendingTask = nil
        isTyping = false
    }
}

@MainActor
final class AnxietyDissectorViewModel: ObservableObject {
    @Published var worry = ""
    @Published private(set) var analysis: AnxietyAnalysis?
    @Published private(set) var isAnalyzing = false
    @Published private(set) var collectionSaved = false
    @Published var feedback: String?

    private var pendingTask: Task<Void, Never>?

    func analyze(profile: UserProfile) {
        let trimmed = worry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            feedback = "Write down what is troubling you most right now."
            return
        }
        guard trimmed.count <= 1_200 else {
            feedback = "Keep it within 1,200 characters and start with the most important part."
            return
        }
        isAnalyzing = true
        collectionSaved = false
        feedback = nil
        HapticManager.shared.lightTap()
        pendingTask?.cancel()
        pendingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 620_000_000)
            guard !Task.isCancelled else { return }
            self.analysis = AnxietyDissector.analyze(worry: trimmed, profile: profile)
            self.isAnalyzing = false
            HapticManager.shared.success()
        }
    }

    @discardableResult
    func collect(profile: UserProfile, context: ModelContext) -> Bool {
        guard let analysis else { return false }
        guard !collectionSaved else { return true }
        let body = "The worry I wrote down:\n\(analysis.worry)\n\nPresent emotional clues:\n\(analysis.currentState)\n\nFriction sources:\n\(analysis.roots.map { "• \($0.title): \($0.detail)" }.joined(separator: "\n"))\n\nGentle actions:\n\(analysis.actionPlan.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))"
        let item = CollectItem(
            kind: .anxiety,
            title: "Anxiety Sorter · \(analysis.keyword)",
            subtitle: profile.westernZodiac.displayName + " · " + profile.bloodType.displayName,
            body: body,
            detail: "Grounding practice: \(analysis.grounding)\n\nSelf-compassion statement: \(analysis.affirmation)",
            keyword: analysis.keyword,
            signature: analysis.signature
        )
        context.insert(item)
        do {
            try context.save()
            collectionSaved = true
            HapticManager.shared.success()
            return true
        } catch {
            feedback = "The sorter card could not be saved. Please try again."
            return false
        }
    }

    func reset() {
        pendingTask?.cancel()
        worry = ""
        analysis = nil
        isAnalyzing = false
        collectionSaved = false
        feedback = nil
    }
}

@MainActor
final class StarCalendarViewModel: ObservableObject {
    @Published private(set) var calendar: StarCalendar?
    @Published private(set) var isSaved = false
    @Published var feedback: String?

    func load(profile: UserProfile, date: Date = Date()) {
        calendar = DailyContentEngine.starCalendar(for: profile, date: date)
        isSaved = false
    }

    @discardableResult
    func collect(profile: UserProfile, context: ModelContext) -> Bool {
        guard let calendar else { return false }
        guard !isSaved else { return true }
        let tasks = calendar.smallTasks.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        let body = "Today's relaxation index (interactive reference): \(calendar.relaxationIndex)\n\nAvoiding overthinking:\n\(calendar.frictionGuide)\n\nSmall decompression ideas:\n\(tasks)\n\nChinese-zodiac mindset reminder:\n\(calendar.chineseReminder)\n\nUsing your personality strength:\n\(calendar.strengthSuggestion)\n\nBlood-type emotional care:\n\(calendar.bloodTip)"
        let item = CollectItem(
            kind: .star,
            title: "Mood Almanac · \(calendar.keyword)",
            subtitle: DailyContentEngine.dateTitle(for: calendar.date),
            body: body,
            detail: "For self-care and emotional reflection only.",
            keyword: calendar.keyword,
            signature: profile.snapshot.signature
        )
        context.insert(item)
        do {
            try context.save()
            isSaved = true
            HapticManager.shared.success()
            return true
        } catch {
            feedback = "The almanac could not be saved. Please try again."
            return false
        }
    }
}

@MainActor
final class CollectionViewModel: ObservableObject {
    @Published var selectedKind: CollectionKind?
    @Published var feedback: String?

    func filtered(_ items: [CollectItem]) -> [CollectItem] {
        let visible = items.filter { $0.kind != .companion || true }
        guard let selectedKind else { return visible }
        return visible.filter { $0.kind == selectedKind }
    }

    func delete(_ item: CollectItem, context: ModelContext) {
        context.delete(item)
        do {
            try context.save()
            HapticManager.shared.warning()
        } catch {
            feedback = "Delete failed. Please try again."
        }
    }
}