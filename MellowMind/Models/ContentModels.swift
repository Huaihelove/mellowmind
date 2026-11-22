import Foundation

// MARK: - Daily personality adaptation (Modules 1 and 4)

struct DailyPersonalityInsight: Hashable {
    let date: Date
    let advantageTitle: String
    let advantage: String
    let guide: [String]
    let affirmation: String
    let signature: String
}

struct StarCalendar: Hashable {
    let date: Date
    let relaxationIndex: Int
    let frictionGuide: String
    let smallTasks: [String]
    let chineseReminder: String
    let strengthSuggestion: String
    let bloodTip: String
    let keyword: String
    let premiumReport: PremiumReport

    var dateKey: String { DateKey.string(from: date) }
}

struct PremiumReport: Hashable {
    let title: String
    let opening: String
    let sections: [PremiumReportSection]
    let eveningRitual: String
    let reflectionPrompt: String
}

struct PremiumReportSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let body: String
}

// MARK: - Emotional tarot (Module 2; three fixed reflection sections, no future judgment)

struct TarotCard: Identifiable, Hashable {
    let id: String
    let name: String
    let glyph: String
    let theme: String
    let primaryHex: String
    let secondaryHex: String
    let emotionCore: String
    let thoughtCore: String
    let adviceCore: String
    let keywords: [String]
}

struct TarotReading: Hashable {
    let card: TarotCard
    let emotionState: String
    let ignoredThought: String
    let gentleAdvice: String
    let fusionNote: String
    let keyword: String
    let affirmation: String
}

// MARK: - Healing wish slips (Module 3)

enum WishTheme: String, CaseIterable, Codable, Identifiable, Hashable {
    case calm = "Calm"
    case heal = "Heal"
    case ease = "Ease"
    case flow = "Flow"
    case tender = "Tender"

    var id: String { rawValue }

    var glyph: String {
        switch self {
        case .calm: return "☾"
        case .heal: return "❋"
        case .ease: return "☁"
        case .flow: return "〰"
        case .tender: return "♡"
        }
    }

    var subtitle: String {
        switch self {
        case .calm: return "Bring your heart gently back to now"
        case .heal: return "Allow yourself to recover a little at a time"
        case .ease: return "Leave a little space around the tension"
        case .flow: return "Move forward at your own pace"
        case .tender: return "Say one kind thing to yourself"
        }
    }

    var accentHex: String {
        switch self {
        case .calm: return "9FB8C8"
        case .heal: return "A7C3B0"
        case .ease: return "C8B8D9"
        case .flow: return "D5C3A4"
        case .tender: return "D7B6C4"
        }
    }
}

struct WishReading: Hashable {
    let theme: WishTheme
    let title: String
    let verse: String
    let interpretation: String
    let gentleAction: String
    let keyword: String
    let signature: String
}

// MARK: - Mood records and healing space (Modules 3 and 5)

enum EmotionMood: String, CaseIterable, Codable, Identifiable, Hashable {
    case calm = "Calm"
    case heavy = "Low"
    case anxious = "Tense"
    case numb = "Numb"
    case hopeful = "Hopeful"
    case tired = "Tired"

    var id: String { rawValue }

    var glyph: String {
        switch self {
        case .calm: return "☾"
        case .heavy: return "☂"
        case .anxious: return "≈"
        case .numb: return "○"
        case .hopeful: return "✧"
        case .tired: return "☁"
        }
    }
}

enum CollectionKind: String, CaseIterable, Codable, Identifiable, Hashable {
    case tarot
    case wish
    case star
    case anxiety
    case companion

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tarot: return "Mood Card"
        case .wish: return "Healing Wish"
        case .star: return "Mood Almanac"
        case .anxiety: return "Anxiety Sorter"
        case .companion: return "Tree Hollow Reply"
        }
    }

    var glyph: String {
        switch self {
        case .tarot: return "rectangle.portrait.on.rectangle.portrait"
        case .wish: return "leaf"
        case .star: return "sparkles"
        case .anxiety: return "point.3.connected.trianglepath.dotted"
        case .companion: return "bubble.left.and.bubble.right"
        }
    }
}

struct WishComment: Identifiable, Codable, Hashable {
    let id: UUID
    let author: String
    let content: String
    let createdAt: Date

    init(id: UUID = UUID(), author: String, content: String, createdAt: Date = Date()) {
        self.id = id
        self.author = author
        self.content = content
        self.createdAt = createdAt
    }
}

struct AudioTrack: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let fileName: String
    let glyph: String
    let accentHex: String
}

struct AnxietyRoot: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
}

struct AnxietyAnalysis: Hashable {
    let worry: String
    let currentState: String
    let roots: [AnxietyRoot]
    let gentleExplanation: String
    let actionPlan: [String]
    let grounding: String
    let affirmation: String
    let keyword: String
    let signature: String
}

enum ChatRole: String, Codable, Hashable {
    case user
    case companion
}

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let role: ChatRole
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), role: ChatRole, text: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

struct LocalCompanionReply: Hashable {
    let text: String
    let followUp: String
    let keyword: String
}

// MARK: - Skin system and growth path

enum SkinKind: String, Codable, Identifiable, Hashable {
    case tarot
    case wishTube

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tarot: return "Mood Cards"
        case .wishTube: return "Wish Tube"
        }
    }
}

enum SkinGrowthMetric: String, Codable, Hashable {
    case checkIns
    case wishes
}

enum SkinAccess: String, Codable, Hashable {
    case free
    case growth
    case purchase
}

struct MellowSkin: Identifiable, Hashable {
    let id: String
    let kind: SkinKind
    let name: String
    let subtitle: String
    let primaryHex: String
    let secondaryHex: String
    let symbol: String
    let access: SkinAccess
    let requiredCount: Int
    let growthMetric: SkinGrowthMetric
    let productID: String?
}

// MARK: - Stable date keys and random seeds

enum DateKey {
    static func string(from date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    static func dayNumber(from date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        return Int(start.timeIntervalSince1970 / 86_400)
    }
}