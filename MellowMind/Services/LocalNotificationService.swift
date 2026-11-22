import Foundation
import Combine
import UserNotifications

// MARK: - Permission framework: sealed-wish reminders
// Notification permission is requested only when the user opts in; declining does not affect any core feature.

@MainActor
final class LocalNotificationService: ObservableObject {
    static let shared = LocalNotificationService()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {}

    func refreshStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            authorizationStatus = settings.authorizationStatus
            return true
        }
        if settings.authorizationStatus == .denied {
            authorizationStatus = .denied
            return false
        }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshStatus()
            return granted
        } catch {
            await refreshStatus()
            return false
        }
    }

    func scheduleSealUnlock(id: UUID, unlockAt: Date, theme: WishTheme) {
        guard unlockAt > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "A sealed wish is ready to revisit"
        content.body = "Your \(theme.rawValue) wish is ready to look back on. Return to Mellow Mind and meet the version of yourself who wrote it."
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: unlockAt)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "seal-\(id.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelSealUnlock(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["seal-\(id.uuidString)"])
    }

    func cancelAllSealReminders() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { $0.hasPrefix("seal-") }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}