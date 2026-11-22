import UIKit

// MARK: - App-wide physical feedback
// Uses UIKit feedback generators for card draws, wish slips, wish rituals, and other interactions.

@MainActor
final class HapticManager {
    static let shared = HapticManager()

    private var isEnabled = true
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepare()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if enabled { prepare() }
    }

    func prepare() {
        soft.prepare()
        light.prepare()
        medium.prepare()
        heavy.prepare()
        selectionGenerator.prepare()
        notification.prepare()
    }

    func softTap() {
        guard isEnabled else { return }
        soft.impactOccurred(intensity: 0.55)
        soft.prepare()
    }

    func lightTap() {
        guard isEnabled else { return }
        light.impactOccurred(intensity: 0.7)
        light.prepare()
    }

    func mediumTap() {
        guard isEnabled else { return }
        medium.impactOccurred(intensity: 0.8)
        medium.prepare()
    }

    func heavyTap() {
        guard isEnabled else { return }
        heavy.impactOccurred(intensity: 0.92)
        heavy.prepare()
    }

    func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    func success() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    func warning() {
        guard isEnabled else { return }
        notification.notificationOccurred(.warning)
        notification.prepare()
    }

    func error() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
        notification.prepare()
    }
}