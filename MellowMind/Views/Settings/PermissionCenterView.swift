import SwiftUI
import SwiftData
import UIKit
import UserNotifications

struct PermissionCenterView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = SettingsViewModel()
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showExplainer = false
    @State private var showSettingsAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                header
                hapticsCard
                notificationCard
                audioCard
                motionCard
                privacySummary
                Button {
                    showExplainer = true
                } label: {
                    Label("See how permissions are used", systemImage: "info.circle")
                }
                .buttonStyle(MellowSecondaryButtonStyle())
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .task {
            await refreshNotificationStatus()
        }
        .sheet(isPresented: $showExplainer) {
            PermissionExplainerSheet {
                showExplainer = false
            }
        }
        .alert("System settings required", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Later", role: .cancel) {}
        } message: {
            Text("Notification permission is turned off in system settings. You can still use every core feature, and you can re-enable reminders in Settings.")
        }
        .alert("Notice", isPresented: Binding(
            get: { viewModel.feedback != nil },
            set: { if !$0 { viewModel.feedback = nil } }
        )) {
            Button("Got it", role: .cancel) { viewModel.feedback = nil }
        } message: {
            Text(viewModel.feedback ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Permissions & Experience")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
            Text("We request only what is truly needed. Declining any permission leaves the core emotional tools available.")
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var hapticsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconBadge(systemName: "iphone.radiowaves.left.and.right", tint: AppTheme.lavenderDeep, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Haptic feedback")
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Uses the iOS haptic feedback engine and never records motion data.")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            Toggle(isOn: Binding(
                get: { profile.hapticsEnabled },
                set: { newValue in
                    profile.hapticsEnabled = newValue
                    HapticManager.shared.setEnabled(newValue)
                    viewModel.savePreferences(profile: profile, context: context)
                    if newValue { HapticManager.shared.lightTap() }
                }
            )) {
                Text("Provides touch feedback for card draws, wish slips, wishes, and interactions")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .tint(AppTheme.lavenderDeep)
            Text("Haptics are part of the in-app experience, require no separate system permission, and can be turned off anytime.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .mellowCard()
    }

    private var notificationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconBadge(systemName: "bell.badge", tint: AppTheme.milkBlueDeep, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sealed-wish reminders")
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text(notificationStatusText)
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
            }
            Toggle(isOn: Binding(
                get: { settings.notificationsEnabled && authorizationStatus != .denied },
                set: { newValue in
                    if !newValue {
                        settings.notificationsEnabled = false
                        LocalNotificationService.shared.cancelAllSealReminders()
                        try? context.save()
                        return
                    }
                    Task {
                        if authorizationStatus == .denied {
                            showSettingsAlert = true
                            return
                        }
                        await viewModel.setNotifications(enabled: true, settings: settings, context: context)
                        await refreshNotificationStatus()
                    }
                }
            )) {
                Text("Remind me to revisit a sealed wish when it is ready")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .tint(AppTheme.lavenderDeep)

            if authorizationStatus == .denied {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open system settings", systemImage: "gear")
                }
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.lavenderDeep)
            }

            Text("Notification permission is requested only when you opt in. If declined, sealed wishes can still be revisited when they are ready.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .mellowCard()
    }

    private var audioCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconBadge(systemName: "speaker.wave.2", tint: Color(hex: 0xC49C82), size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Audio playback")
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Plays local white-noise and light-meditation audio without needing microphone or media-library permission.")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            HStack(spacing: 8) {
                Image(systemName: "speaker.wave.1")
                Slider(value: Binding(
                    get: { profile.audioVolume },
                    set: { newValue in
                        profile.audioVolume = min(max(newValue, 0), 1)
                        viewModel.savePreferences(profile: profile, context: context)
                    }
                ), in: 0...1)
                .tint(AppTheme.lavenderDeep)
                Image(systemName: "speaker.wave.3")
            }
            .font(.system(size: 12))
            .foregroundStyle(AppTheme.secondaryText)
            Text("The app does not record audio or read your music library. Audio therapy is for everyday relaxation only.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .mellowCard()
    }

    private var motionCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                IconBadge(systemName: "gyroscope", tint: AppTheme.lavenderDeep, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Shaking the wish tube")
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Reads acceleration only on the wish-tube screen to trigger the shaking animation.")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            Text("Motion data is never saved, uploaded, or used for advertising. If your device cannot be shaken, the wish-tube screen provides an assistive shake button.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .mellowCard()
    }

    private var privacySummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Permissions we do not request", systemImage: "hand.raised.fill")
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text("The app does not request camera, microphone, contacts, location, photo library, or advertising-identifier permission. It contains no ad SDK and does not track across apps.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)
        }
        .mellowCard()
    }

    private var notificationStatusText: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "System notifications are allowed. You can receive sealed-wish reminders."
        case .denied:
            return "System notifications are off. You can re-enable them in Settings."
        case .notDetermined:
            return "Notification permission has not been requested."
        @unknown default:
            return "Notification status is unknown."
        }
    }

    private func refreshNotificationStatus() async {
        await LocalNotificationService.shared.refreshStatus()
        authorizationStatus = LocalNotificationService.shared.authorizationStatus
    }
}

private struct PermissionExplainerSheet: View {
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("How Permissions Are Used")
                        .font(.mellowTitle)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("An explanation before you decide")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Button("Close", action: onClose)
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            explainerRow(icon: "iphone.radiowaves.left.and.right", title: "Haptic feedback", body: "Physical feedback for cards, wish slips, and wishes, provided by iOS without collecting motion data.")
            explainerRow(icon: "speaker.wave.2", title: "Audio playback", body: "Plays local white-noise and light-meditation audio. No microphone access and no media-library reading.")
            explainerRow(icon: "gyroscope", title: "Shaking the wish tube", body: "Briefly reads acceleration only on the wish-slip screen for the interaction animation. No motion history is saved.")
            explainerRow(icon: "bell", title: "Wish reminders", body: "Notification permission is requested only when you opt in, for sealed-wish reminders.")

            Text("No permission is required to use the core features. You can adjust them here or in system settings at any time.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)

            Button("Got it", action: onClose)
                .buttonStyle(MellowPrimaryButtonStyle())

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.top, 22)
        .padding(.bottom, 16)
        .background(MellowBackground())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComplianceFooter()
        }
    }

    private func explainerRow(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            IconBadge(systemName: icon, tint: AppTheme.lavenderDeep, size: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text(body)
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(2)
            }
        }
    }
}