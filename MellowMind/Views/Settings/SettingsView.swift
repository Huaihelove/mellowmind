import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var storeManager: StoreKitManager
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                header
                profileSection
                experienceSection
                purchaseSection
                legalSection
                dataSection
                versionFooter
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .overlay {
            if viewModel.isWorking {
                ZStack {
                    Color.black.opacity(0.12).ignoresSafeArea()
                    ProgressView()
                        .tint(AppTheme.lavenderDeep)
                        .padding(22)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
        .alert("Notice", isPresented: Binding(
            get: { viewModel.feedback != nil },
            set: { if !$0 { viewModel.feedback = nil } }
        )) {
            Button("Got it", role: .cancel) { viewModel.feedback = nil }
        } message: {
            Text(viewModel.feedback ?? "")
        }
        .confirmationDialog("Clear all local data?", isPresented: $viewModel.showingClearAllConfirmation, titleVisibility: .visible) {
            Button("Clear and start over", role: .destructive) {
                _ = viewModel.clearAll(context: context)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This deletes your birth date, blood type, personality profile, wishes, sealed wishes, Tree Hollow entries, saved cards, check-ins, and skin records. This cannot be undone.")
        }
        .confirmationDialog("Clear wishes and Tree Hollow?", isPresented: $viewModel.showingClearWishConfirmation, titleVisibility: .visible) {
            Button("Clear wish data", role: .destructive) {
                _ = viewModel.clearWishData(context: context)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This deletes wish-wall posts, encrypted seals, Tree Hollow entries, and related saved cards. Your personality profile and check-ins are kept.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Settings & Privacy")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
            Text("Local-first, optional purchases, and no advertising tracking.")
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var profileSection: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "person.crop.circle", title: "My profile", subtitle: "\(profile.displayName) · \(profile.bloodType.displayName) · \(profile.westernZodiac.displayName)") {
                router.push(.editProfile)
            }
            DividerSoft()
            settingsRow(icon: "person.text.rectangle", title: "Three-layer personality profile", subtitle: "Personality reference and emotional self-care guidance") {
                router.push(.personalityDossier)
            }
            DividerSoft()
            settingsRow(icon: "heart.text.square", title: "Saved healing cards", subtitle: "Browse or delete saved reflections") {
                router.push(.collection)
            }
        }
        .mellowCard(padding: 0)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }

    private var experienceSection: some View {
        VStack(spacing: 0) {
            Toggle(isOn: Binding(
                get: { profile.hapticsEnabled },
                set: { newValue in
                    profile.hapticsEnabled = newValue
                    HapticManager.shared.setEnabled(newValue)
                    viewModel.savePreferences(profile: profile, context: context)
                }
            )) {
                settingsToggleLabel(icon: "iphone.radiowaves.left.and.right", title: "Haptic feedback", subtitle: "Physical feedback for cards, wish slips, and wishes")
            }
            .tint(AppTheme.lavenderDeep)
            .padding(15)

            DividerSoft()

            Toggle(isOn: Binding(
                get: { profile.anonymousByDefault },
                set: { newValue in
                    profile.anonymousByDefault = newValue
                    viewModel.savePreferences(profile: profile, context: context)
                }
            )) {
                settingsToggleLabel(icon: "eye.slash", title: "Anonymous by default on the wish wall", subtitle: "You can still switch each post individually")
            }
            .tint(AppTheme.lavenderDeep)
            .padding(15)

            DividerSoft()

            settingsRow(icon: "checkmark.shield", title: "Permissions & experience", subtitle: "Notifications, haptics, audio, and system settings") {
                router.push(.permissionCenter)
            }
        }
        .mellowCard(padding: 0)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }

    private var purchaseSection: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "paintpalette", title: "Healing skin store", subtitle: "Free, growth, and premium skins") {
                router.push(.skinStore)
            }
            DividerSoft()
            Button {
                Task {
                    await viewModel.restore(store: storeManager, context: context)
                }
            } label: {
                settingsRowLabel(icon: "arrow.clockwise", title: "Restore Purchases", subtitle: "Restore previous entitlements on this Apple ID")
            }
            .buttonStyle(.plain)
            DividerSoft()
            Button {
                if let url = storeManager.manageSubscriptionsURL() {
                    UIApplication.shared.open(url)
                }
            } label: {
                settingsRowLabel(icon: "creditcard", title: "Manage Subscription", subtitle: "View or cancel in App Store account settings")
            }
            .buttonStyle(.plain)
            DividerSoft()
            settingsRow(icon: "book.closed", title: "Daily Premium Emotional Report", subtitle: storeManager.hasPremiumDailyReport ? "Entitlement unlocked" : "View subscription details") {
                router.push(.premiumReport)
            }
        }
        .mellowCard(padding: 0)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }

    private var legalSection: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "hand.raised", title: "Privacy Policy", subtitle: "Local-first storage, data deletion, and third parties") {
                router.push(.privacyPolicy)
            }
            DividerSoft()
            settingsRow(icon: "doc.text", title: "Terms of Use", subtitle: "Scope of service, purchases, and usage rules") {
                router.push(.terms)
            }
            DividerSoft()
            settingsRow(icon: "exclamationmark.shield", title: "Disclaimer", subtitle: "No prediction, no diagnosis; self-care only") {
                router.push(.disclaimer)
            }
            DividerSoft()
            settingsRow(icon: "info.circle", title: "About Us", subtitle: "Product philosophy and support contact") {
                router.push(.about)
            }
        }
        .mellowCard(padding: 0)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }

    private var dataSection: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.showingClearWishConfirmation = true
            } label: {
                settingsRowLabel(icon: "trash", title: "Clear wishes, seals, and Tree Hollow", subtitle: "Keep personality profile and check-ins", destructive: true)
            }
            .buttonStyle(.plain)
            DividerSoft()
            Button {
                viewModel.showingClearAllConfirmation = true
            } label: {
                settingsRowLabel(icon: "externaldrive.badge.xmark", title: "Clear all local data", subtitle: "Birth details, blood type, wishes, saved cards, and all records", destructive: true)
            }
            .buttonStyle(.plain)
        }
        .mellowCard(padding: 0)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }

    private var versionFooter: some View {
        VStack(spacing: 6) {
            Text("\(AppTheme.appName) \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
            Text("Lifestyle · Mental Wellness · Stress Relief")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
            Text("This app does not provide fortune-telling, divination, fate judgment, or future prediction.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func settingsToggleLabel(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 11) {
            IconBadge(systemName: icon, tint: AppTheme.lavenderDeep, size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }

    private func settingsRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticManager.shared.softTap()
        } label: {
            settingsRowLabel(icon: icon, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }

    private func settingsRowLabel(icon: String, title: String, subtitle: String, destructive: Bool = false) -> some View {
        HStack(spacing: 11) {
            IconBadge(systemName: icon, tint: destructive ? Color(hex: 0xB87575) : AppTheme.lavenderDeep, size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(destructive ? Color(hex: 0xB87575) : AppTheme.primaryText)
                Text(subtitle)
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
            if !destructive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}