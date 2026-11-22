import SwiftUI
import SwiftData

struct StarCalendarView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var storeManager: StoreKitManager
    @StateObject private var viewModel = StarCalendarViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let calendar = viewModel.calendar {
                    header(calendar)
                    frictionCard(calendar)
                    tasksCard(calendar)
                    personalityCards(calendar)
                    collectControls(calendar)
                    premiumCard(calendar)
                } else {
                    ProgressView()
                        .tint(AppTheme.lavenderDeep)
                        .frame(maxWidth: .infinity)
                        .padding(60)
                }
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .task(id: profile.updatedAt) {
            viewModel.load(profile: profile)
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

    private func header(_ calendar: StarCalendar) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(DailyContentEngine.dateTitle(for: calendar.date))
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(calendar.keyword)
                        .font(.system(size: 36, weight: .semibold, design: .serif))
                        .foregroundStyle(AppTheme.primaryText)
                    HStack(spacing: 6) {
                        MellowPill(text: profile.bloodType.displayName, glyph: "drop.fill", tint: Color(hexString: profile.bloodType.accentHex))
                        MellowPill(text: profile.westernZodiac.displayName, glyph: "sparkles", tint: AppTheme.lavenderDeep)
                        MellowPill(text: "Chinese zodiac: \(profile.chineseZodiac.displayName)", tint: AppTheme.milkBlueDeep)
                    }
                }
                Spacer()
                MetricRing(value: calendar.relaxationIndex, caption: "Relaxation today")
            }
            Text("The relaxation index is an interactive reference value, not a psychological measurement or assessment.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .mellowCard()
    }

    private func frictionCard(_ calendar: StarCalendar) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Avoiding overthinking", subtitle: "Handle only what can be handled today")
            Text(calendar.frictionGuide)
                .font(.mellowBody)
                .foregroundStyle(AppTheme.primaryText)
                .lineSpacing(5)
        }
        .mellowCard()
    }

    private func tasksCard(_ calendar: StarCalendar) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(title: "Small decompression ideas", subtitle: "Choose one; you do not have to complete them all")
            ForEach(Array(calendar.smallTasks.enumerated()), id: \.offset) { index, task in
                HStack(alignment: .top, spacing: 11) {
                    Text("\(index + 1)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.lavenderDeep)
                        .frame(width: 24, height: 24)
                        .background(AppTheme.lavender.opacity(0.12), in: Circle())
                    Text(task)
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.primaryText)
                        .lineSpacing(3)
                    Spacer(minLength: 0)
                }
            }
        }
        .mellowCard()
    }

    private func personalityCards(_ calendar: StarCalendar) -> some View {
        VStack(spacing: 14) {
            insightRow(systemImage: "tortoise.fill", title: "Chinese-zodiac mindset reminder", body: calendar.chineseReminder, tint: AppTheme.warning)
            insightRow(systemImage: "sparkles", title: "Using your personality strength", body: calendar.strengthSuggestion, tint: AppTheme.lavenderDeep)
            insightRow(systemImage: "drop.fill", title: "Blood-type emotional care tip", body: calendar.bloodTip, tint: AppTheme.milkBlueDeep)
        }
    }

    private func insightRow(systemImage: String, title: String, body: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                IconBadge(systemName: systemImage, tint: tint, size: 32)
                Text(title)
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            Text(body)
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(4)
        }
        .mellowCard()
    }

    private func collectControls(_ calendar: StarCalendar) -> some View {
        HStack(spacing: 12) {
            Button {
                _ = viewModel.collect(profile: profile, context: context)
            } label: {
                Label(viewModel.isSaved ? "Saved" : "Save today's almanac", systemImage: viewModel.isSaved ? "heart.fill" : "heart")
            }
            .buttonStyle(MellowSecondaryButtonStyle())

            Button {
                router.push(.premiumReport)
            } label: {
                Label(storeManager.hasPremiumDailyReport ? "Open premium report" : "Unlock premium report", systemImage: storeManager.hasPremiumDailyReport ? "book.closed.fill" : "lock.fill")
            }
            .buttonStyle(MellowSecondaryButtonStyle())
        }
    }

    private func premiumCard(_ calendar: StarCalendar) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed")
                    .foregroundStyle(AppTheme.lavenderDeep)
                Text("Today's Premium Emotional Care Book")
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            Text(calendar.premiumReport.opening)
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(4)
                .lineLimit(storeManager.hasPremiumDailyReport ? nil : 3)
            Button {
                router.push(.premiumReport)
            } label: {
                Text(storeManager.hasPremiumDailyReport ? "Read the full report" : "View benefits and subscription details")
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(AppTheme.lavenderDeep)
            .padding(.top, 2)
        }
        .mellowCard()
    }
}