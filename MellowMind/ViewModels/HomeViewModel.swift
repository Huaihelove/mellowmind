import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var insight: DailyPersonalityInsight?
    @Published private(set) var calendar: StarCalendar?
    @Published private(set) var streak: Int = 0
    @Published private(set) var currentDate = Date()

    func load(profile: UserProfile, checkIns: [CheckInRecord], date: Date = Date()) {
        currentDate = date
        insight = PersonalityEngine.dailyInsight(for: profile, date: date)
        calendar = DailyContentEngine.starCalendar(for: profile, date: date)
        streak = GrowthEngine.checkInStreak(records: checkIns)
    }

    func refreshIfNeeded(profile: UserProfile, checkIns: [CheckInRecord]) {
        if !Calendar.current.isDate(currentDate, inSameDayAs: Date()) {
            load(profile: profile, checkIns: checkIns)
        } else {
            streak = GrowthEngine.checkInStreak(records: checkIns)
        }
    }
}