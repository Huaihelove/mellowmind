import Foundation

enum ZodiacCalculator {
    static func westernZodiac(for date: Date, calendar: Calendar = .current) -> WesternZodiac {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let marker = month * 100 + day

        switch marker {
        case 120...218: return .aquarius
        case 219...320: return .pisces
        case 321...419: return .aries
        case 420...520: return .taurus
        case 521...621: return .gemini
        case 622...722: return .cancer
        case 723...822: return .leo
        case 823...922: return .virgo
        case 923...1023: return .libra
        case 1024...1122: return .scorpio
        case 1123...1221: return .sagittarius
        default: return .capricorn
        }
    }

    /// Uses the Gregorian birth year to derive a Chinese-zodiac personality reference; lunar-solar-term boundaries are not used as fate judgments.
    static func chineseZodiac(forGregorianYear year: Int) -> ChineseZodiac {
        let animals: [ChineseZodiac] = [.rat, .ox, .tiger, .rabbit, .dragon, .snake, .horse, .goat, .monkey, .rooster, .dog, .pig]
        let normalized = ((year - 1900) % 12 + 12) % 12
        return animals[normalized]
    }

    static func chineseZodiac(for date: Date, calendar: Calendar = .current) -> ChineseZodiac {
        chineseZodiac(forGregorianYear: calendar.component(.year, from: date))
    }
}

enum StableDigest {
    static func value(for seed: String) -> UInt64 {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return hash
    }

    static func index(_ seed: String, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return Int(value(for: seed) % UInt64(count))
    }

    static func pick<T>(_ values: [T], seed: String) -> T? {
        guard !values.isEmpty else { return nil }
        return values[index(seed, count: values.count)]
    }
}

enum CalendarMath {
    static func startOfDay(_ date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func daysBetween(_ first: Date, _ second: Date) -> Int {
        let calendar = Calendar.current
        let a = calendar.startOfDay(for: first)
        let b = calendar.startOfDay(for: second)
        return calendar.dateComponents([.day], from: a, to: b).day ?? 0
    }

    static func nextMidnight(after date: Date = Date()) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start) ?? date.addingTimeInterval(86_400)
    }

    static func dateKey(daysFromNow offset: Int, from date: Date = Date()) -> String {
        let target = Calendar.current.date(byAdding: .day, value: offset, to: startOfDay(date)) ?? date
        return DateKey.string(from: target)
    }
}