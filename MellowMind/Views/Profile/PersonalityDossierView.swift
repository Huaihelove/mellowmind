import SwiftUI

struct PersonalityDossierView: View {
    let profile: UserProfile
    @EnvironmentObject private var router: AppRouter

    private var dossier: PersonalityDossier {
        PersonalityEngine.dossier(for: profile)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                personaCard(dossier.chinese)
                personaCard(dossier.western)
                personaCard(dossier.blood)
                strengthsCard
                reminderCard
                Text("This content is a playful personality reference and emotional self-care suggestion. It is not psychological diagnosis, fate judgment, or a future prediction.")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.horizontal, 4)
                Button {
                    router.push(.editProfile)
                } label: {
                    Label("Edit my profile", systemImage: "pencil")
                }
                .buttonStyle(MellowSecondaryButtonStyle())
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Three-layer personality fusion")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text("\(profile.bloodType.displayName) · \(profile.westernZodiac.displayName) · Chinese zodiac: \(profile.chineseZodiac.displayName)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [AppTheme.lavender.opacity(0.22), AppTheme.milkBlue.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 66, height: 66)
                    Text(profile.chineseZodiac.glyph)
                        .font(.system(size: 31))
                }
            }
            Text(dossier.fusionSummary)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .lineSpacing(5)
            HStack(spacing: 8) {
                MellowPill(text: profile.birthdayText, glyph: "calendar", tint: AppTheme.milkBlueDeep)
                PrivacyBadge()
            }
        }
        .mellowCard()
    }

    private func personaCard(_ triad: PersonaTriad) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                if triad.glyph.count <= 2 {
                    Text(triad.glyph)
                        .font(.system(size: 24))
                        .frame(width: 36, height: 36)
                } else {
                    IconBadge(systemName: triad.glyph, tint: Color(hexString: triad.accentHex), size: 36)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(triad.category)
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(triad.title)
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                }
                Spacer()
                Text(triad.summary)
                    .font(.mellowMicro)
                    .foregroundStyle(Color(hexString: triad.accentHex))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
            }
            ForEach(triad.rows) { row in
                VStack(alignment: .leading, spacing: 5) {
                    Text(row.label)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hexString: triad.accentHex))
                    Text(row.content)
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(3)
                }
                .padding(.vertical, 2)
            }
        }
        .mellowCard()
    }

    private var strengthsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Your available strengths", subtitle: "You do not need to use them all. Choose one that works today")
            ForEach(Array(dossier.dailyStrengths.prefix(5).enumerated()), id: \.offset) { index, strength in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.lavenderDeep)
                        .frame(width: 22, height: 22)
                        .background(AppTheme.lavender.opacity(0.12), in: Circle())
                    Text(strength)
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.primaryText)
                }
            }
        }
        .mellowCard()
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("A gentle reminder for yourself", systemImage: "heart.text.square")
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text(dossier.gentleReminders.first ?? "You have already done enough.")
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(4)
        }
        .mellowCard()
    }
}