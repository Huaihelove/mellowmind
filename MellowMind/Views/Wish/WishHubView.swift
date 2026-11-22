import SwiftUI
import SwiftData

struct WishHubView: View {
    let profile: UserProfile
    let settings: AppSettings

    @EnvironmentObject private var router: AppRouter
    @Query(sort: \Wish.createdAt, order: .reverse) private var wishes: [Wish]
    @Query(sort: \SealedWish.createdAt, order: .reverse) private var seals: [SealedWish]
    @Query(sort: \CheckInRecord.createdAt, order: .reverse) private var checkIns: [CheckInRecord]

    private var realWishCount: Int {
        wishes.filter { !$0.isSeed && !$0.isHidden }.count
    }

    private var checkedInToday: Bool {
        checkIns.contains(where: { $0.dateKey == DateKey.string(from: Date()) })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                hero
                featureGrid
                gentleNote
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Wishes & Echoes")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
            Text("A wish is a gentle promise to this moment, not a forecast of the future.")
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)
            HStack(spacing: 7) {
                MellowPill(text: "\(realWishCount) wishes", glyph: "leaf.fill", tint: AppTheme.lavenderDeep)
                MellowPill(text: "\(seals.count) sealed", glyph: "lock.fill", tint: AppTheme.milkBlueDeep)
                MellowPill(text: checkedInToday ? "Checked in today" : "Waiting for today's echo", glyph: "checkmark.circle", tint: checkedInToday ? AppTheme.success : AppTheme.warning)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("A wish for today")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text("May you settle your heart first,\nthen walk slowly toward where you want to go.")
                        .font(.system(size: 23, weight: .semibold, design: .serif))
                        .foregroundStyle(AppTheme.primaryText)
                        .lineSpacing(4)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [AppTheme.lavender.opacity(0.28), AppTheme.milkBlue.opacity(0.30)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 72, height: 72)
                    Text("Wish")
                        .font(.system(size: 27, weight: .light, design: .serif))
                        .foregroundStyle(AppTheme.lavenderDeep)
                }
            }
            Button {
                router.push(.wishTube)
            } label: {
                HStack {
                    Label("Draw a healing wish slip", systemImage: "leaf")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(MellowPrimaryButtonStyle())
        }
        .mellowCard()
    }

    private var featureGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Four gentle things to do", subtitle: "No entry point requires you to perform perfectly")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                featureCard(title: "Healing wish slips", subtitle: "Set an intention · Shake · Draw by hand", glyph: "leaf.fill", tint: Color(hex: 0x8BA58D), badge: "5 themes") {
                    router.push(.wishTube)
                }
                featureCard(title: "Wish wall", subtitle: "Leave a wish anonymously or by name", glyph: "heart.text.square.fill", tint: AppTheme.lavenderDeep, badge: "Local warmth") {
                    router.push(.wishWall)
                }
                featureCard(title: "Sealed wishes", subtitle: "Write encrypted words; revisit in 7 or 30 days", glyph: "lock.square.stack", tint: AppTheme.milkBlueDeep, badge: "\(seals.count) sealed") {
                    router.push(.wishSeal)
                }
                featureCard(title: "Daily echo", subtitle: "Check in with a small achievement", glyph: "checkmark.seal.fill", tint: AppTheme.warning, badge: checkedInToday ? "Complete" : "Check in") {
                    router.push(.checkIn)
                }
            }
        }
    }

    private func featureCard(title: String, subtitle: String, glyph: String, tint: Color, badge: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticManager.shared.softTap()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    IconBadge(systemName: glyph, tint: tint, size: 40)
                    Spacer()
                    Text(badge)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(tint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(tint.opacity(0.10), in: Capsule())
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background(AppTheme.surface.opacity(0.74), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var gentleNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("About the wish wall", systemImage: "person.2.wave.2")
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text("The current wish wall runs on this device, and sample wishes are marked 'Sample warmth'. You can post, like, comment, report, and hide content; nothing is uploaded to a server.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)
        }
        .mellowCard()
    }
}