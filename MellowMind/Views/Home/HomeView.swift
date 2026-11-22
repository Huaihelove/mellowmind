import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    let profile: UserProfile
    let settings: AppSettings

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var storeManager: StoreKitManager
    @Query(sort: \CheckInRecord.createdAt, order: .reverse) private var checkIns: [CheckInRecord]
    @StateObject private var viewModel = HomeViewModel()

    private var checkedInToday: Bool {
        checkIns.contains(where: { $0.dateKey == DateKey.string(from: Date()) })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                greetingHeader
                if let calendar = viewModel.calendar, let insight = viewModel.insight {
                    dailyOverview(calendar)
                    personalityAdvantage(insight)
                    quickActions
                    checkInStrip
                    premiumTeaser(calendar)
                } else {
                    ProgressView()
                        .tint(AppTheme.lavenderDeep)
                        .frame(maxWidth: .infinity)
                        .padding(40)
                }
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .task(id: profile.updatedAt) {
            viewModel.load(profile: profile, checkIns: checkIns)
        }
        .onChange(of: checkIns.count) { _, _ in
            viewModel.refreshIfNeeded(profile: profile, checkIns: checkIns)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            viewModel.load(profile: profile, checkIns: checkIns)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.refreshIfNeeded(profile: profile, checkIns: checkIns)
        }
        .refreshable {
            try? await Task.sleep(nanoseconds: 350_000_000)
            viewModel.load(profile: profile, checkIns: checkIns)
        }
    }

    private var greetingHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(DailyContentEngine.dateTitle(for: viewModel.currentDate))
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                Text("\(profile.displayName), let's take it slowly today.")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 7) {
                    MellowPill(text: profile.bloodType.displayName, tint: Color(hexString: profile.bloodType.accentHex))
                    MellowPill(text: profile.westernZodiac.displayName, tint: AppTheme.lavenderDeep)
                    MellowPill(text: "Chinese zodiac: \(profile.chineseZodiac.displayName)", tint: AppTheme.milkBlueDeep)
                }
            }
            Spacer(minLength: 10)
            Button {
                router.push(.settings)
            } label: {
                ZStack {
                    Circle()
                        .fill(AppTheme.surface.opacity(0.78))
                        .frame(width: 42, height: 42)
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
    }

    private func dailyOverview(_ calendar: StarCalendar) -> some View {
        Button {
            router.push(.starCalendar)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today's Mood Almanac")
                            .font(.mellowCaption)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(calendar.keyword)
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(AppTheme.primaryText)
                        Text("A reference for today's rhythm, not a psychological assessment")
                            .font(.mellowMicro)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    Spacer()
                    MetricRing(value: calendar.relaxationIndex, caption: "Relaxation Index")
                }

                Text(calendar.frictionGuide)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(3)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    Text("View full almanac")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.lavenderDeep)
            }
            .mellowCard()
        }
        .buttonStyle(.plain)
    }

    private func personalityAdvantage(_ insight: DailyPersonalityInsight) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(title: "Your personality strength today", subtitle: "Generated daily from your blood type + Western zodiac + Chinese zodiac")
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: "sparkles", tint: AppTheme.lavenderDeep)
                VStack(alignment: .leading, spacing: 8) {
                    Text(insight.advantageTitle)
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(insight.advantage)
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(3)
                    Text(insight.affirmation)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.lavenderDeep)
                        .padding(.top, 2)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Label("Personalized emotional self-care guide", systemImage: "heart.text.square")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.lavenderDeep)
                ForEach(Array(insight.guide.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 9) {
                        Text("\(index + 1)")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.lavenderDeep)
                            .frame(width: 20, height: 20)
                            .background(AppTheme.lavender.opacity(0.12), in: Circle())
                        Text(item)
                            .font(.mellowCaption)
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            DividerSoft()
            HStack {
                Button {
                    router.push(.personalityDossier)
                } label: {
                    Label("View three-layer profile", systemImage: "person.text.rectangle")
                }
                .buttonStyle(MellowSecondaryButtonStyle())
            }
        }
        .mellowCard()
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "What would you like to do now?", subtitle: "Choose a low-pressure entry point")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                quickAction(title: "Draw a mood card", subtitle: "See how this moment feels", glyph: "rectangle.portrait.on.rectangle.portrait", tint: AppTheme.lavenderDeep) {
                    router.select(.tarot)
                }
                quickAction(title: "Draw a wish slip", subtitle: "Set anxiety down gently", glyph: "leaf.fill", tint: Color(hex: 0x8BA58D)) {
                    router.push(.wishTube)
                }
                quickAction(title: "Tree Hollow", subtitle: "Write without judgment", glyph: "bubble.left.and.bubble.right.fill", tint: AppTheme.milkBlueDeep) {
                    router.push(.treeHole)
                }
                quickAction(title: "Relaxation audio", subtitle: "Settle yourself with sound", glyph: "waveform", tint: Color(hex: 0xC49C82)) {
                    router.push(.audioTherapy)
                }
            }
        }
    }

    private var checkInStrip: some View {
        Button {
            router.push(.checkIn)
        } label: {
            HStack(spacing: 14) {
                IconBadge(systemName: checkedInToday ? "checkmark.seal.fill" : "circle.dotted", tint: checkedInToday ? AppTheme.success : AppTheme.warning, size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(checkedInToday ? "Today's check-in is complete" : "Where is today's small achievement?")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("\(viewModel.streak)-day streak · Check-ins unlock healing skins")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .mellowCard(padding: 15, cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    private func premiumTeaser(_ calendar: StarCalendar) -> some View {
        Button {
            router.push(.premiumReport)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(LinearGradient(colors: [AppTheme.lavender.opacity(0.24), AppTheme.milkBlue.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 54, height: 54)
                    Image(systemName: storeManager.hasPremiumDailyReport ? "book.closed.fill" : "lock.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppTheme.lavenderDeep)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Today's Premium Emotional Care Book")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                        if storeManager.hasPremiumDailyReport {
                            MellowPill(text: "Unlocked", tint: AppTheme.success)
                        }
                    }
                    Text(storeManager.hasPremiumDailyReport ? "Lay out today's three emotional layers" : "A deeper look at relationships, boundaries, and evening closure")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .mellowCard(padding: 15, cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    private func quickAction(title: String, subtitle: String, glyph: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticManager.shared.softTap()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                IconBadge(systemName: glyph, tint: tint, size: 38)
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background(AppTheme.surface.opacity(0.72), in: RoundedRectangle(cornerRadius: 19, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .stroke(AppTheme.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}