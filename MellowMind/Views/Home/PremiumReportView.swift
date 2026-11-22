import SwiftUI
import UIKit

struct PremiumReportView: View {
    let profile: UserProfile
    let settings: AppSettings

    @EnvironmentObject private var storeManager: StoreKitManager
    @EnvironmentObject private var router: AppRouter
    @State private var calendar: StarCalendar?
    @State private var isPurchasing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if storeManager.hasPremiumDailyReport, let report = calendar?.premiumReport {
                    unlockedReport(report)
                } else {
                    paywall
                }
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .task {
            calendar = DailyContentEngine.starCalendar(for: profile)
            await storeManager.refreshEntitlements()
        }
        .alert("Notice", isPresented: Binding(
            get: { storeManager.errorMessage != nil },
            set: { if !$0 { storeManager.errorMessage = nil } }
        )) {
            Button("Got it", role: .cancel) { storeManager.errorMessage = nil }
        } message: {
            Text(storeManager.errorMessage ?? "")
        }
    }

    private func unlockedReport(_ report: PremiumReport) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text(report.title)
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.primaryText)
                Text(DailyContentEngine.dateTitle())
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                Text(report.opening)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(5)
            }
            .mellowCard()

            ForEach(report.sections) { section in
                VStack(alignment: .leading, spacing: 9) {
                    Text(section.title)
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text(section.body)
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(5)
                }
                .mellowCard()
            }

            VStack(alignment: .leading, spacing: 12) {
                Label("Evening close", systemImage: "moon.stars")
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
                Text(report.eveningRitual)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(5)
                DividerSoft()
                Text("A question to keep for yourself")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.lavenderDeep)
                Text(report.reflectionPrompt)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .lineSpacing(4)
            }
            .mellowCard()

            Text("This report is an emotional self-care reference and does not constitute psychological diagnosis or medical advice. If distress continues, please seek support from a qualified professional.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.horizontal, 4)

            Button {
                router.push(.audioTherapy)
            } label: {
                Label("Open relaxation audio", systemImage: "waveform")
            }
            .buttonStyle(MellowPrimaryButtonStyle())
        }
    }

    private var paywall: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's Premium Emotional Care Book")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.primaryText)
                Text("Go deeper into today's personality combination and almanac with a closer look at emotional layers, relationship boundaries, and practical care.")
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(5)
                HStack(spacing: 8) {
                    MellowPill(text: "Updated daily", glyph: "sun.max.fill", tint: AppTheme.lavenderDeep)
                    MellowPill(text: "No ads", glyph: "hand.raised.fill", tint: AppTheme.success)
                    MellowPill(text: "Cancel anytime", glyph: "xmark.circle", tint: AppTheme.milkBlueDeep)
                }
            }
            .mellowCard()

            if let report = calendar?.premiumReport {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's report includes")
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    ForEach(report.sections.prefix(3)) { section in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.success)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(section.title)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                Text(section.body)
                                    .font(.mellowCaption)
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                .mellowCard()
            }

            VStack(alignment: .leading, spacing: 14) {
                SectionHeading(title: "Subscription details", subtitle: "Secure billing through the App Store")
                if let product = storeManager.product(for: StoreProductIDs.premiumDailyReport) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(product.displayName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.primaryText)
                            Text("Auto-renewing subscription · \(product.displayPrice) / month")
                                .font(.mellowCaption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        Spacer()
                        MellowPill(text: "Monthly", tint: AppTheme.lavenderDeep)
                    }
                } else {
                    Text("Product information is temporarily unavailable. Price and renewal period are governed by the App Store purchase page.")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Text("The subscription renews automatically unless canceled at least 24 hours before the end of the current period. Payment is handled by your Apple account. The current period is not prorated after use; you can manage or cancel in App Store account settings.")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(3)

                Button {
                    Task { @MainActor in
                        isPurchasing = true
                        _ = await storeManager.purchase(productID: StoreProductIDs.premiumDailyReport)
                        isPurchasing = false
                    }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text("Unlock the daily premium report")
                            Image(systemName: "arrow.right")
                        }
                    }
                }
                .buttonStyle(MellowPrimaryButtonStyle())
                .disabled(isPurchasing)

                HStack(spacing: 10) {
                    Button("Restore Purchases") {
                        Task { await storeManager.restorePurchases() }
                    }
                    Spacer()
                    Button("Manage Subscription") {
                        if let url = storeManager.manageSubscriptionsURL() {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.lavenderDeep)

                HStack(spacing: 12) {
                    Button("Privacy Policy") { router.push(.privacyPolicy) }
                    Button("Terms of Use") { router.push(.terms) }
                    Button("Disclaimer") { router.push(.disclaimer) }
                }
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
            }
            .mellowCard()
        }
    }
}