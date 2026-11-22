import SwiftUI

struct LegalSectionItem: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct LegalPageLayout: View {
    let title: String
    let subtitle: String
    let updatedAt: String
    let sections: [LegalSectionItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(subtitle)
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(3)
                    Text("Updated: \(updatedAt)")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .mellowCard()

                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.mellowHeadline)
                            .foregroundStyle(AppTheme.primaryText)
                        Text(section.body)
                            .font(.mellowBody)
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineSpacing(5)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mellowCard()
                }

                Text("If you have questions, contact \(AppTheme.supportEmail).")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }
}

struct PrivacyPolicyView: View {
    private let sections = [
        LegalSectionItem(
            title: "1. Local-first",
            body: "Mellow Mind is designed local-first. Your personality profile, wishes, sealed messages, Tree Hollow entries, check-ins, saved cards, and skin choices are stored only on your device by default. This version requires no account and does not upload that content to a remote server."
        ),
        LegalSectionItem(
            title: "2. Information we process",
            body: "To provide the features, the app processes the following locally on your device: the name you enter, birth date, and blood type; the Western- and Chinese-zodiac personality references derived from your birth date; wish-wall posts and comments; encrypted sealed wishes; Tree Hollow text and locally generated replies; daily check-ins and saved cards; and skin choices and local unlock records.\n\nPurchases are handled by Apple StoreKit. The app does not receive or store your card number, billing address, or full payment credentials."
        ),
        LegalSectionItem(
            title: "3. Storage and security",
            body: "Structured data is stored using Apple SwiftData. Sealed-wish content is encrypted with AES-GCM before being written to the local database; the 256-bit key is stored in the iOS Keychain and restricted to this device.\n\nNo storage method can guarantee absolute security. Risk may remain if a device is jailbroken, unlocked by another person, or compromised at the system level."
        ),
        LegalSectionItem(
            title: "4. Notifications, haptics, and motion",
            body: "Notification permission is requested only when you opt in, to remind you when a sealed wish is ready to revisit. You can turn it off anytime.\n\nCard draws, wish slips, and wish rituals use system haptic feedback; the wish-tube screen briefly reads device acceleration to recognize shaking. The app does not save or upload motion history and does not use motion data for advertising."
        ),
        LegalSectionItem(
            title: "5. Audio and device permissions",
            body: "The audio-therapy player reads audio bundled inside the app. It does not request microphone permission or read your media library. The app does not request camera, contacts, location, photo-library, or advertising-identifier permission."
        ),
        LegalSectionItem(
            title: "6. Third parties, advertising, and tracking",
            body: "This version contains no advertising SDK, third-party analytics SDK, or cross-app tracking. The app does not sell personal data. App Store purchases and subscriptions are handled by Apple under its privacy policy."
        ),
        LegalSectionItem(
            title: "7. Deletion and retention",
            body: "You can delete your birth details, blood type, personality profile, wishes, seals, Tree Hollow entries, saved cards, check-ins, and skin records from Settings → Clear all local data. This also deletes your local sealing key; the action cannot be undone.\n\nYou can also clear only wishes, seals, Tree Hollow entries, and related saved cards while keeping your personality profile and check-ins. Uninstalling the app usually removes local data, though whether Keychain data remains depends on iOS behavior."
        ),
        LegalSectionItem(
            title: "8. Children and age rating",
            body: "Mellow Mind provides emotional self-care and playful personality references for a general audience. The App Store age rating is 4+. The app does not knowingly collect personal information from children or serve personalized advertising. Guardians can manage device and purchase permissions for minors."
        ),
        LegalSectionItem(
            title: "9. Non-medical and non-predictive",
            body: "Mellow Mind is an emotional-support, personality-reflection, and everyday stress-relief tool. It is not a medical provider, psychological-diagnosis tool, divination tool, or fate-judgment service. No content constitutes medical, psychological, legal, or financial advice, and it is not used to predict the future, fortune, wealth, romantic outcomes, or luck.\n\nIf you are experiencing persistent severe distress, crisis, or a health problem, contact a qualified medical or mental-health professional or local emergency services."
        ),
        LegalSectionItem(
            title: "10. Policy updates and contact",
            body: "We may update this policy when features or compliance requirements change and will show the new version in the app. Continued use means you have read the updated policy.\n\nSupport email: \(AppTheme.supportEmail)\nPrivacy policy URL: \(AppTheme.privacyURL)"
        )
    ]

    var body: some View {
        LegalPageLayout(
            title: "Privacy Policy",
            subtitle: "We collect as little as possible, keep data local where we can, and put deletion in your hands.",
            updatedAt: "November 22, 2026",
            sections: sections
        )
    }
}

struct TermsView: View {
    private let sections = [
        LegalSectionItem(
            title: "1. Scope of service",
            body: "Mellow Mind provides self-care tools including playful multi-dimensional personality references, emotional card reflections, healing wish slips, a daily mood almanac, Tree Hollow journaling, an anxiety sorter, relaxation audio, sealed wishes, check-ins, and saved cards.\n\nThe service does not provide fortune-telling, divination, fate judgment, future prediction, medical diagnosis, or psychological treatment. All content is for self-care, emotional reflection, and entertainment."
        ),
        LegalSectionItem(
            title: "2. Eligibility and devices",
            body: "You should have lawful use of the Apple device and Apple ID you use with the app. Some features depend on iOS 17 or later, system notifications, StoreKit, haptic feedback, and local storage. Where a device does not support a particular interaction, the app provides an alternative entry point whenever possible."
        ),
        LegalSectionItem(
            title: "3. Your content",
            body: "You are responsible for what you write in the wish wall, Tree Hollow, and sealed wishes. This version is a local community, and content is not published to other real users by default. Do not post illegal, hateful, harassing, harmful, infringing, or impersonating content.\n\nThe app provides length limits, gentle-language filtering, reporting, and local hiding. If a real multi-user community is added in the future, server-side moderation and reporting workflows will be added first."
        ),
        LegalSectionItem(
            title: "4. Purchases and subscriptions",
            body: "The card-skin pack, wish-tube skin pack, and unlimited-seal entitlement are one-time non-consumable purchases. The daily premium emotional-care report is an auto-renewing subscription. Price, period, and availability are governed by the App Store purchase page.\n\nThe subscription renews automatically unless canceled at least 24 hours before the end of the current period. Payment is handled by your Apple account. You can manage or cancel in App Store account settings. Refunds are handled by Apple under its policy. Non-consumable entitlements can be restored with Restore Purchases."
        ),
        LegalSectionItem(
            title: "5. Free core features",
            body: "The core personality profile, daily almanac, mood cards, healing wish slips, Tree Hollow, anxiety sorter, audio therapy, saved cards, and base skins are free to use. The app has no splash ads or pop-up ads.\n\nThe free version can retain up to 3 sealed wishes at a time; the unlimited-seal entitlement removes that limit. Existing history is not actively deleted because you have not purchased."
        ),
        LegalSectionItem(
            title: "6. Prohibited uses",
            body: "You may not use the app for illegal activity, harassment, hateful or harmful content, intellectual-property infringement, circumvention of purchase entitlements, reverse engineering, or interference with normal operation. Do not use the content for medical diagnosis, fate judgment, or any purpose requiring professional qualifications."
        ),
        LegalSectionItem(
            title: "7. Intellectual property",
            body: "Rights in the app's interface, copy, code, cards, and audio resources belong to the developer or the relevant rights holders. You may use and share self-care copy you have saved on your personal device, but may not bulk-copy or resell it or use it in a competing product."
        ),
        LegalSectionItem(
            title: "8. Availability and changes",
            body: "We may update, adjust, or discontinue some features to fix issues, improve the experience, or meet platform requirements. We will try to avoid harming purchases you have already made, but changes in iOS, StoreKit, or the device environment mean uninterrupted service cannot be guaranteed."
        ),
        LegalSectionItem(
            title: "9. Limitation of liability",
            body: "To the extent permitted by applicable law, the app is provided as is. We are not liable beyond what applicable law requires for losses caused by device failure, system updates, data loss, third-party payment processing, or data you choose to clear.\n\nNothing in these terms excludes or limits consumer rights that cannot legally be excluded."
        ),
        LegalSectionItem(
            title: "10. Contact",
            body: "For questions about these terms, contact: \(AppTheme.supportEmail)\nTerms URL: \(AppTheme.termsURL)\n\nApple's standard end-user license agreement also applies where relevant."
        )
    ]

    var body: some View {
        LegalPageLayout(
            title: "Terms of Use",
            subtitle: "Clear boundaries help gentle companionship last longer.",
            updatedAt: "November 22, 2026",
            sections: sections
        )
    }
}

struct DisclaimerView: View {
    private let sections = [
        LegalSectionItem(
            title: "Fixed compliance notice",
            body: AppTheme.complianceFooter
        ),
        LegalSectionItem(
            title: "Not a future prediction",
            body: "The Western-zodiac, Chinese-zodiac, blood-type, card, and wish-slip content in this app is defined as self-personality reference, present-moment emotional comfort, positive psychological suggestion, and everyday stress-relief guidance.\n\nIt is not used to predict fate, judge good or bad fortune, assess wealth or romantic outcomes, or indicate the result of any future event."
        ),
        LegalSectionItem(
            title: "Not medical or psychological diagnosis",
            body: "Tree Hollow, the anxiety sorter, the mood almanac, and the premium report provide emotional companionship and self-reflection only. They do not constitute psychological diagnosis, a treatment plan, or medical advice. The app does not replace a doctor, therapist, crisis service, or other qualified professional."
        ),
        LegalSectionItem(
            title: "When professional support is needed",
            body: "If you continue to experience intense anxiety, depression, insomnia, or significant disruption to daily life, seek a qualified medical or mental-health professional. If you or someone else is in immediate danger, contact local emergency services or a crisis line, or ask someone you trust to stay with you."
        ),
        LegalSectionItem(
            title: "About interactions and content",
            body: "Tarot-inspired cards, wish slips, and wish rituals are interactive self-observation exercises, not verdicts about the future. Today's indices, keywords, and suggestions are interactive reference values and not psychological measurements. Use them rationally and keep your own judgment."
        ),
        LegalSectionItem(
            title: "Age and category",
            body: "The App Store age rating is 4+; the product category is Lifestyle / Mental Wellness / Stress Relief. The app is not a fortune-telling or divination product and contains no fatalistic or superstitious claims."
        )
    ]

    var body: some View {
        LegalPageLayout(
            title: "Disclaimer",
            subtitle: "A gentle ritual is a way to observe yourself, not a verdict on your life.",
            updatedAt: "November 22, 2026",
            sections: sections
        )
    }
}

struct AboutView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AppTheme.lavender.opacity(0.45), AppTheme.milkBlue.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 94, height: 94)
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(AppTheme.lavenderDeep)
                    }
                    Text(AppTheme.appName)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(AppTheme.slogan)
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .mellowCard()

                aboutSection(
                    title: "What we want to offer",
                    body: "In days filled with pressure, mental fatigue, and information overload, we want to offer a low-pressure space you can return to anytime. It does not decide your life for you; it helps bring your attention back to your body, feelings, and the present."
                )
                aboutSection(
                    title: "Boundaries we keep",
                    body: "We do not predict fate, judge fortune, manufacture anxiety, or compare people. Western zodiac, Chinese zodiac, blood type, cards, and wish slips are playful personality references and positive psychological suggestions for self-observation and emotional relief."
                )
                aboutSection(
                    title: "Local-first",
                    body: "Birth details, blood type, wishes, Tree Hollow entries, and saved cards are stored on this device by default. Sealed wishes use AES-GCM encryption with a key in Keychain. You can clear all local data in Settings."
                )
                aboutSection(
                    title: "How the app is supported",
                    body: "Core features are free. Premium skins, unlimited seals, and the daily premium report are offered through StoreKit 2. There are no splash ads, pop-up ads, or ad SDKs, and we do not sell your data."
                )
                aboutSection(
                    title: "Contact us",
                    body: "Support email: \(AppTheme.supportEmail)\nPrivacy policy: \(AppTheme.privacyURL)\nTerms of Use: \(AppTheme.termsURL)"
                )

                HStack(spacing: 10) {
                    Button("Privacy Policy") { router.push(.privacyPolicy) }
                        .buttonStyle(MellowSecondaryButtonStyle())
                    Button("Terms of Use") { router.push(.terms) }
                        .buttonStyle(MellowSecondaryButtonStyle())
                    Button("Disclaimer") { router.push(.disclaimer) }
                        .buttonStyle(MellowSecondaryButtonStyle())
                }

                Text("This app is an emotional-wellness and everyday stress-relief tool, not a prediction service or psychological diagnosis.")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }

    private func aboutSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text(body)
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mellowCard()
    }
}