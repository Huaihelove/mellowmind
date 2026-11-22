import SwiftUI
import SwiftData
import UIKit

struct AppRootView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var storeManager: StoreKitManager
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \UserProfile.createdAt, order: .forward) private var profiles: [UserProfile]
    @State private var bootstrapError: String?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            MellowBackground()
            if let profile {
                MainShellView(profile: profile)
                    .transition(.opacity.combined(with: .scale(scale: 0.985)))
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComplianceFooter()
        }
        .animation(.easeInOut(duration: 0.55), value: profiles.first?.id)
        .task(id: profiles.first?.id) {
            guard profiles.first != nil else { return }
            do {
                try DataSeeder.bootstrap(context: context)
            } catch {
                bootstrapError = "Local setup failed: \(error.localizedDescription)"
            }
        }
        .onAppear {
            if let profile {
                HapticManager.shared.setEnabled(profile.hapticsEnabled)
            }
        }
        .onChange(of: profiles.first?.hapticsEnabled) { _, newValue in
            HapticManager.shared.setEnabled(newValue ?? true)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, profiles.first != nil {
                try? DataSeeder.bootstrap(context: context)
                Task {
                    await LocalNotificationService.shared.refreshStatus()
                    await storeManager.refreshEntitlements()
                }
            }
        }
        .alert("Notice", isPresented: Binding(
            get: { bootstrapError != nil },
            set: { if !$0 { bootstrapError = nil } }
        )) {
            Button("OK", role: .cancel) { bootstrapError = nil }
        } message: {
            Text(bootstrapError ?? "")
        }
    }
}