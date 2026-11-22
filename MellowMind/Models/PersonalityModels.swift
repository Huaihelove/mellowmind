import Foundation

// MARK: - Module 1: Multi-dimensional personality profile
// These enums are for personality reflection and emotional support only; they do not judge fate, fortune, or the future.

enum BloodType: String, CaseIterable, Codable, Identifiable, Hashable {
    case a = "A"
    case b = "B"
    case ab = "AB"
    case o = "O"

    var id: String { rawValue }
    var displayName: String { "Type \(rawValue)" }
    var shortTrait: String {
        switch self {
        case .a: return "Sensitive and perceptive"
        case .b: return "Spontaneous and vivid"
        case .ab: return "Rational and gentle"
        case .o: return "Warm and determined"
        }
    }
    var accentHex: String {
        switch self {
        case .a: return "B7A6D4"
        case .b: return "D7B6C4"
        case .ab: return "9FB8C8"
        case .o: return "D5C3A4"
        }
    }
}

enum WesternZodiac: String, CaseIterable, Codable, Identifiable, Hashable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }

    var glyph: String {
        switch self {
        case .aries: return "♈︎"
        case .taurus: return "♉︎"
        case .gemini: return "♊︎"
        case .cancer: return "♋︎"
        case .leo: return "♌︎"
        case .virgo: return "♍︎"
        case .libra: return "♎︎"
        case .scorpio: return "♏︎"
        case .sagittarius: return "♐︎"
        case .capricorn: return "♑︎"
        case .aquarius: return "♒︎"
        case .pisces: return "♓︎"
        }
    }

    var dateRange: String {
        switch self {
        case .aries: return "03.21 – 04.19"
        case .taurus: return "04.20 – 05.20"
        case .gemini: return "05.21 – 06.21"
        case .cancer: return "06.22 – 07.22"
        case .leo: return "07.23 – 08.22"
        case .virgo: return "08.23 – 09.22"
        case .libra: return "09.23 – 10.23"
        case .scorpio: return "10.24 – 11.22"
        case .sagittarius: return "11.23 – 12.21"
        case .capricorn: return "12.22 – 01.19"
        case .aquarius: return "01.20 – 02.18"
        case .pisces: return "02.19 – 03.20"
        }
    }

    var shortTrait: String {
        switch self {
        case .aries: return "Quick to act"
        case .taurus: return "Steady and measured"
        case .gemini: return "Curious and lively"
        case .cancer: return "Empathetic and gentle"
        case .leo: return "Bright and sincere"
        case .virgo: return "Detailed and clear"
        case .libra: return "Balanced and gracious"
        case .scorpio: return "Focused and deep"
        case .sagittarius: return "Free and open"
        case .capricorn: return "Grounded and restrained"
        case .aquarius: return "Independent and lucid"
        case .pisces: return "Soft and abundant"
        }
    }
}

enum ChineseZodiac: String, CaseIterable, Codable, Identifiable, Hashable {
    case rat, ox, tiger, rabbit, dragon, snake
    case horse, goat, monkey, rooster, dog, pig

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rat: return "Rat"
        case .ox: return "Ox"
        case .tiger: return "Tiger"
        case .rabbit: return "Rabbit"
        case .dragon: return "Dragon"
        case .snake: return "Snake"
        case .horse: return "Horse"
        case .goat: return "Goat"
        case .monkey: return "Monkey"
        case .rooster: return "Rooster"
        case .dog: return "Dog"
        case .pig: return "Pig"
        }
    }

    var glyph: String {
        switch self {
        case .rat: return "🐭"
        case .ox: return "🐮"
        case .tiger: return "🐯"
        case .rabbit: return "🐰"
        case .dragon: return "🐲"
        case .snake: return "🐍"
        case .horse: return "🐴"
        case .goat: return "🐑"
        case .monkey: return "🐵"
        case .rooster: return "🐔"
        case .dog: return "🐶"
        case .pig: return "🐷"
        }
    }

    var shortTrait: String {
        switch self {
        case .rat: return "Perceptive and detailed"
        case .ox: return "Quiet and dependable"
        case .tiger: return "Brave and passionate"
        case .rabbit: return "Gentle and attentive"
        case .dragon: return "Confident and expansive"
        case .snake: return "Thoughtful and composed"
        case .horse: return "Bright and forward-moving"
        case .goat: return "Soft and considerate"
        case .monkey: return "Flexible and playful"
        case .rooster: return "Careful and orderly"
        case .dog: return "Loyal and warm"
        case .pig: return "Generous and relaxed"
        }
    }
}

struct PersonaRow: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let content: String
}

struct PersonaTriad: Identifiable, Hashable {
    let id = UUID()
    let category: String
    let title: String
    let glyph: String
    let summary: String
    let rows: [PersonaRow]
    let accentHex: String
}

struct PersonalityDossier: Hashable {
    let chinese: PersonaTriad
    let western: PersonaTriad
    let blood: PersonaTriad
    let fusionSummary: String
    let signature: String
    let dailyStrengths: [String]
    let gentleReminders: [String]
}

struct PersonalitySnapshot: Hashable {
    let bloodType: BloodType
    let westernZodiac: WesternZodiac
    let chineseZodiac: ChineseZodiac
    let birthDate: Date

    var signature: String {
        "\(bloodType.rawValue)-\(westernZodiac.rawValue)-\(chineseZodiac.rawValue)"
    }
}