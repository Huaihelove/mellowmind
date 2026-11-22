import SwiftUI
import SwiftData

struct MainShellView: View {
    let profile: UserProfile

    @EnvironmentObject private var storeManager: StoreKitManager
    @Query(sort: \AppSettings.createdAt, order: .forward) private var settingsList: [AppSettings]
    @StateObject private var router = AppRouter()

    private var settings: AppSettings? { settingsList.first }

    var body: some View {
        Group {
            if let settings {
                NavigationStack(path: $router.path) {
                    VStack(spacing: 0) {
                        Group {
                            tabContent(settings: settings)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        MellowTabBar(selectedTab: $router.selectedTab) { tab in
                            router.select(tab)
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route, settings: settings)
                            .navigationTitle(route.title)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.visible, for: .navigationBar)
                            .navigationBarBackButtonHidden(false)
                            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                    }
                }
                .tint(AppTheme.lavenderDeep)
                .environmentObject(router)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(AppTheme.lavenderDeep)
                    Text("Preparing your calm space...")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @ViewBuilder
    private func tabContent(settings: AppSettings) -> some View {
        switch router.selectedTab {
        case .home:
            HomeView(profile: profile, settings: settings)
        case .tarot:
            TarotFlowView(profile: profile, settings: settings)
        case .wish:
            WishHubView(profile: profile, settings: settings)
        case .space:
            HealingSpaceView(profile: profile, settings: settings)
        case .profile:
            ProfileView(profile: profile, settings: settings)
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute, settings: AppSettings) -> some View {
        switch route {
        case .starCalendar:
            StarCalendarView(profile: profile, settings: settings)
        case .premiumReport:
            PremiumReportView(profile: profile, settings: settings)
        case .personalityDossier:
            PersonalityDossierView(profile: profile)
        case .editProfile:
            EditProfileView(profile: profile)
        case .tarotFlow:
            TarotFlowView(profile: profile, settings: settings)
        case .wishTube:
            WishTubeView(profile: profile, settings: settings)
        case .wishWall:
            WishWallView(profile: profile, settings: settings)
        case .wishSeal:
            WishSealView(profile: profile, settings: settings)
        case .checkIn:
            CheckInView(profile: profile, settings: settings)
        case .treeHole:
            TreeHoleView(profile: profile, settings: settings)
        case .anxietyDissector:
            AnxietyDissectorView(profile: profile, settings: settings)
        case .audioTherapy:
            AudioTherapyView(profile: profile, settings: settings)
        case .collection:
            CollectionView(profile: profile, settings: settings)
        case .skinStore:
            SkinStoreView(profile: profile, settings: settings)
        case .settings:
            SettingsView(profile: profile, settings: settings)
        case .permissionCenter:
            PermissionCenterView(profile: profile, settings: settings)
        case .privacyPolicy:
            PrivacyPolicyView()
        case .terms:
            TermsView()
        case .disclaimer:
            DisclaimerView()
        case .about:
            AboutView()
        }
    }
}

struct MellowTabBar: View {
    @Binding var selectedTab: AppTab
    let onSelect: (AppTab) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 18, weight: selectedTab == tab ? .semibold : .regular))
                            .symbolVariant(selectedTab == tab ? .fill : .none)
                        Text(tab.title)
                            .font(.system(size: 9.5, weight: selectedTab == tab ? .semibold : .regular, design: .rounded))
                    }
                    .foregroundStyle(selectedTab == tab ? AppTheme.lavenderDeep : AppTheme.secondaryText.opacity(0.72))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(AppTheme.lavender.opacity(0.14))
                                .padding(.horizontal, 8)
                                .matchedGeometryEffect(id: "selectedTab", in: tabNamespace)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 4)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.separator)
                .frame(height: 0.5)
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.8), value: selectedTab)
    }

    @Namespace private var tabNamespace
}