import Foundation
import SwiftData

// MARK: - Collection (Module 5)

@Model
final class CollectItem {
    @Attribute(.unique) var id: UUID
    var kindRaw: String
    var title: String
    var subtitle: String
    var body: String
    var detail: String
    var keyword: String
    var signature: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        kind: CollectionKind,
        title: String,
        subtitle: String = "",
        body: String,
        detail: String = "",
        keyword: String = "",
        signature: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kindRaw = kind.rawValue
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.detail = detail
        self.keyword = keyword
        self.signature = signature
        self.createdAt = createdAt
    }

    var kind: CollectionKind {
        CollectionKind(rawValue: kindRaw) ?? .tarot
    }
}

// MARK: - Wish wall (Module 3; local, lightweight community)

@Model
final class Wish {
    @Attribute(.unique) var id: UUID
    var authorName: String
    var isAnonymous: Bool
    var content: String
    var themeRaw: String
    var createdAt: Date
    var likeCount: Int
    var likedByMe: Bool
    var commentsData: Data
    var isHidden: Bool
    var reportCount: Int
    var isSeed: Bool

    init(
        id: UUID = UUID(),
        authorName: String,
        isAnonymous: Bool,
        content: String,
        theme: WishTheme,
        createdAt: Date = Date(),
        likeCount: Int = 0,
        comments: [WishComment] = [],
        isSeed: Bool = false
    ) {
        self.id = id
        self.authorName = authorName
        self.isAnonymous = isAnonymous
        self.content = content
        self.themeRaw = theme.rawValue
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.likedByMe = false
        self.commentsData = (try? JSONEncoder().encode(comments)) ?? Data()
        self.isHidden = false
        self.reportCount = 0
        self.isSeed = isSeed
    }

    var theme: WishTheme {
        WishTheme(rawValue: themeRaw) ?? .calm
    }

    var displayAuthor: String {
        isAnonymous ? "Anonymous Star Friend" : authorName
    }

    var comments: [WishComment] {
        get {
            (try? JSONDecoder().decode([WishComment].self, from: commentsData)) ?? []
        }
        set {
            commentsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    func toggleLike() {
        likedByMe.toggle()
        likeCount = max(0, likeCount + (likedByMe ? 1 : -1))
    }
}

// MARK: - Sealed wishes (Module 3; local AES-GCM encryption)

@Model
final class SealedWish {
    @Attribute(.unique) var id: UUID
    var themeRaw: String
    var encryptedPayload: Data
    var createdAt: Date
    var unlockAt: Date
    var durationDays: Int
    var moodBeforeRaw: String
    var moodAfterRaw: String?
    var reflection: String
    var openedAt: Date?
    var createdAtSignature: String

    init(
        id: UUID = UUID(),
        theme: WishTheme,
        encryptedPayload: Data,
        createdAt: Date = Date(),
        unlockAt: Date,
        durationDays: Int,
        moodBefore: EmotionMood,
        signature: String
    ) {
        self.id = id
        self.themeRaw = theme.rawValue
        self.encryptedPayload = encryptedPayload
        self.createdAt = createdAt
        self.unlockAt = unlockAt
        self.durationDays = durationDays
        self.moodBeforeRaw = moodBefore.rawValue
        self.moodAfterRaw = nil
        self.reflection = ""
        self.openedAt = nil
        self.createdAtSignature = signature
    }

    var theme: WishTheme {
        WishTheme(rawValue: themeRaw) ?? .calm
    }

    var moodBefore: EmotionMood {
        EmotionMood(rawValue: moodBeforeRaw) ?? .calm
    }

    var moodAfter: EmotionMood? {
        guard let moodAfterRaw else { return nil }
        return EmotionMood(rawValue: moodAfterRaw)
    }

    var isReadyToOpen: Bool {
        Date() >= unlockAt
    }

    var remainingText: String {
        guard !isReadyToOpen else { return "Ready to open" }
        let seconds = max(0, unlockAt.timeIntervalSinceNow)
        let days = Int(ceil(seconds / 86_400))
        if days > 1 {
            return "Opens in \(days) days"
        }
        let hours = Int(ceil(seconds / 3_600))
        return "Opens in \(max(hours, 1)) hours"
    }
}

// MARK: - Daily check-ins (Module 3)

@Model
final class CheckInRecord {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var dateKey: String
    var achievement: String
    var note: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        dateKey: String = DateKey.string(from: Date()),
        achievement: String,
        note: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.dateKey = dateKey
        self.achievement = achievement
        self.note = note
        self.createdAt = createdAt
    }
}

// MARK: - Tree Hollow journal entries (Module 5)

@Model
final class EmotionJournalEntry {
    @Attribute(.unique) var id: UUID
    var content: String
    var companionReply: String
    var followUp: String
    var keyword: String
    var createdAt: Date
    var signature: String

    init(
        id: UUID = UUID(),
        content: String,
        companionReply: String,
        followUp: String,
        keyword: String,
        signature: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.companionReply = companionReply
        self.followUp = followUp
        self.keyword = keyword
        self.signature = signature
        self.createdAt = createdAt
    }
}

// MARK: - Skin unlocks (growth system and in-app purchases)

@Model
final class UnlockedSkin {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var skinID: String
    var unlockedAt: Date
    var source: String

    init(
        id: UUID = UUID(),
        skinID: String,
        unlockedAt: Date = Date(),
        source: String
    ) {
        self.id = id
        self.skinID = skinID
        self.unlockedAt = unlockedAt
        self.source = source
    }
}