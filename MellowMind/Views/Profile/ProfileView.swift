import SwiftUI
import SwiftData

struct ProfileView: View {
    let profile: UserProfile
    let settings: AppSettings

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var storeManager: StoreKitManager
    @Query(sort: \CheckInRecord.createdAt, order: .reverse) private var checkIns: [CheckInRecord]
    @Query(sort: \CollectItem.createdAt, order: .reverse) private var collectItems: [CollectItem]
    @Query(sort: \Wish.createdAt, order: .reverse) private var wishes: [Wish]
    @Query(sort: \UnlockedSkin.unlockedAt, order: .reverse) private var unlockedSkins: [UnlockedSkin]

    private var streak: Int {
        GrowthEngine.checkInStreak(records: checkIns)
    }

    private var myWishCount: Int {
        wishes.filter { !$0.isSeed && !$0.isHidden }.count
    }

    private var tarotSkin: MellowSkin {
        SkinCatalog.tarotSkin(id: settings.selectedTarotSkinID)
    }

    private var tubeSkin: MellowSkin {
        SkinCatalog.tubeSkin(id: settings.selectedTubeSkinID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                identityHeader
                statsCard
                growthCard
                dossierEntry
                menuCard
                footerNote
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }

    private var identityHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [AppTheme.lavender.opacity(0.45), AppTheme.milkBlue.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 74, height: 74)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(AppTheme.lavenderDeep)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(profile.displayName)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(profile.birthdayText)
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                    HStack(spacing: 5) {
                        MellowPill(text: "\(profile.bloodType.displayName)", tint: Color(hexString: profile.bloodType.accentHex))
                        MellowPill(text: profile.westernZodiac.displayName, tint: AppTheme.lavenderDeep)
                        MellowPill(text: "Chinese zodiac: \(profile.chineseZodiac.displayName)", tint: AppTheme.milkBlueDeep)
                    }
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Button {
                    router.push(.editProfile)
                } label: {
                    Label("Edit profile", systemImage: "pencil")
                }
                .buttonStyle(MellowSecondaryButtonStyle())

                Button {
                    router.push(.personalityDossier)
                } label: {
                    Label("Personality profile", systemImage: "person.text.rectangle")
                }
                .buttonStyle(MellowSecondaryButtonStyle())
            }
        }
        .mellowCard()
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(streak)", label: "Day streak", tint: AppTheme.lavenderDeep)
            DividerSoft().frame(width: 1, height: 44)
            statItem(value: "\(collectItems.count)", label: "Saved healing cards", tint: AppTheme.milkBlueDeep)
            DividerSoft().frame(width: 1, height: 44)
            statItem(value: "\(myWishCount)", label: "Wishes collected", tint: AppTheme.warning)
        }
        .mellowCard(padding: 16)
    }

    private func statItem(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
            Text(label)
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var growthCard: some View {
        let growthSkins = SkinCatalog.all.filter { $0.access == .growth }
        let unlockedIDs = Set(unlockedSkins.map(\.skinID))
        let nextSkin = growthSkins.first(where: { !unlockedIDs.contains($0.id) })
        let current = nextSkin.map { $0.growthMetric == .checkIns ? checkIns.count : myWishCount } ?? 0
        let required = max(nextSkin?.requiredCount ?? 1, 1)
        let progress = min(Double(current) / Double(required), 1)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Healing growth & skins", systemImage: "sparkles")
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Button("View all") {
                    router.push(.skinStore)
                }
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.lavenderDeep)
            }
            HStack(spacing: 8) {
                MellowPill(text: "Cards · \(tarotSkin.name)", glyph: tarotSkin.symbol, tint: AppTheme.lavenderDeep)
                MellowPill(text: "Wish tube · \(tubeSkin.name)", glyph: tubeSkin.symbol, tint: AppTheme.milkBlueDeep)
            }
            if let nextSkin {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text("Next: \(nextSkin.name)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                        Spacer()
                        Text("\(current)/\(required)")
                            .font(.mellowCaption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    GeometryReader { proxy in
                        Capsule()
                            .fill(AppTheme.separator)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(LinearGradient(colors: [AppTheme.lavender, AppTheme.milkBlueDeep], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: proxy.size.width * progress)
                            }
                    }
                    .frame(height: 6)
                }
            } else {
                Text("All growth skins are unlocked. Premium skin packs are available in the skin store.")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .mellowCard()
    }

    private var dossierEntry: some View {
        Button {
            router.push(.personalityDossier)
        } label: {
            HStack(spacing: 13) {
                IconBadge(systemName: "person.text.rectangle", tint: AppTheme.lavenderDeep)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Your three-dimensional personality profile")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Explore your Chinese-zodiac foundation, friction sources, and hidden blood-type traits")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .mellowCard(padding: 15, cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    private var menuCard: some View {
        VStack(spacing: 0) {
            menuRow(icon: "heart.text.square", title: "Saved healing cards", subtitle: "Browse or delete saved reflections") {
                router.push(.collection)
            }
            DividerSoft()
            menuRow(icon: "paintpalette", title: "Healing skin store", subtitle: "Free · Growth unlocks · Premium skins") {
                router.push(.skinStore)
            }
            DividerSoft()
            menuRow(icon: "gearshape", title: "Settings & privacy", subtitle: "Profile, permissions, legal, and data clearing") {
                router.push(.settings)
            }
            DividerSoft()
            menuRow(icon: "info.circle", title: "About Mellow Mind", subtitle: "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")") {
                router.push(.about)
            }
        }
        .mellowCard(padding: 0)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }

    private func menuRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticManager.shared.softTap()
        } label: {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, tint: AppTheme.lavenderDeep, size: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(subtitle)
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var footerNote: some View {
        VStack(spacing: 6) {
            Text("\(AppTheme.appName) · Core features free · No splash ads · No pop-up ads")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
            Text("Mental-wellness and everyday stress-relief tool. It does not provide medical diagnosis.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}