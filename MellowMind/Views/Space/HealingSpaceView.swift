import SwiftUI
import SwiftData

struct HealingSpaceView: View {
    let profile: UserProfile
    let settings: AppSettings

    @EnvironmentObject private var router: AppRouter
    @Query(sort: \EmotionJournalEntry.createdAt, order: .reverse) private var journals: [EmotionJournalEntry]
    @Query(sort: \CollectItem.createdAt, order: .reverse) private var collections: [CollectItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                hero
                featureGrid
                localAIExplain
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Emotional Healing Space")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("No judgment, no rushing. Just help returning to your own rhythm.")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(AppTheme.lavender)
            }
            HStack(spacing: 7) {
                MellowPill(text: profile.bloodType.displayName, tint: Color(hexString: profile.bloodType.accentHex))
                MellowPill(text: profile.westernZodiac.displayName, tint: AppTheme.lavenderDeep)
                MellowPill(text: "Chinese zodiac: \(profile.chineseZodiac.displayName)", tint: AppTheme.milkBlueDeep)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("You have already\nbeen trying hard enough today.")
                        .font(.system(size: 25, weight: .semibold, design: .serif))
                        .foregroundStyle(AppTheme.primaryText)
                        .lineSpacing(4)
                    Text("Tree Hollow: \(journals.count) · Saved cards: \(collections.count)")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                FloatingOrb(tint: AppTheme.mistRose, size: 130)
            }
            HStack(spacing: 8) {
                Button {
                    router.push(.treeHole)
                } label: {
                    Label("Open Tree Hollow", systemImage: "bubble.left.and.bubble.right")
                }
                .buttonStyle(MellowPrimaryButtonStyle())

                Button {
                    router.push(.audioTherapy)
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.lavenderDeep)
                        .frame(width: 50, height: 46)
                        .background(AppTheme.lavender.opacity(0.12), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open relaxation audio")
            }
        }
        .mellowCard()
    }

    private var featureGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Choose the company you need now", subtitle: "Everything runs locally, without judgment")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                featureCard(title: "Tree Hollow", subtitle: "Write anonymously and receive a local, gentle reply", glyph: "bubble.left.and.bubble.right.fill", tint: AppTheme.lavenderDeep, badge: "\(journals.count)") {
                    router.push(.treeHole)
                }
                featureCard(title: "Anxiety Sorter", subtitle: "Use your three layers of personality to untangle the strain", glyph: "point.3.connected.trianglepath.dotted", tint: AppTheme.milkBlueDeep, badge: "Local analysis") {
                    router.push(.anxietyDissector)
                }
                featureCard(title: "Relaxation audio", subtitle: "Rain, breath, stream, and hearth", glyph: "waveform", tint: Color(hex: 0xC49C82), badge: "4 tracks") {
                    router.push(.audioTherapy)
                }
                featureCard(title: "Saved healing cards", subtitle: "Saved reflections, wish slips, and almanac notes", glyph: "heart.text.square.fill", tint: AppTheme.warning, badge: "\(collections.count)") {
                    router.push(.collection)
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
                        .background(tint.opacity(0.1), in: Capsule())
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

    private var localAIExplain: some View {
        VStack(alignment: .leading, spacing: 9) {
            Label("About local AI support", systemImage: "cpu")
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text("Tree Hollow replies and anxiety sorting are generated locally with built-in rules and personality templates. The app does not connect to the internet or train on your data. It provides emotional companionship and self-reflection, not psychological diagnosis or medical advice.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)
        }
        .mellowCard()
    }
}