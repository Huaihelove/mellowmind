import SwiftUI
import SwiftData
import UIKit

struct SkinStoreView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var storeManager: StoreKitManager
    @Query(sort: \UnlockedSkin.unlockedAt, order: .reverse) private var unlockedSkins: [UnlockedSkin]
    @StateObject private var viewModel = SkinStoreViewModel()
    @State private var isPurchasingPack = false

    private var skins: [MellowSkin] {
        SkinCatalog.skins(for: viewModel.selectedKind)
    }

    private var selectedSkinID: String {
        viewModel.selectedKind == .tarot ? settings.selectedTarotSkinID : settings.selectedTubeSkinID
    }

    private var packProductID: String {
        viewModel.selectedKind == .tarot ? StoreProductIDs.tarotSkinPack : StoreProductIDs.tubeSkinPack
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                kindPicker
                packCard
                skinGrid
                selectionNote
                restoreAndLegal
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .task {
            await storeManager.refreshEntitlements()
            if storeManager.products.isEmpty {
                await storeManager.loadProducts()
            }
            viewModel.syncEntitlements(store: storeManager, context: context)
        }
        .alert("Notice", isPresented: Binding(
            get: { viewModel.feedback != nil },
            set: { if !$0 { viewModel.feedback = nil } }
        )) {
            Button("Got it", role: .cancel) { viewModel.feedback = nil }
        } message: {
            Text(viewModel.feedback ?? "")
        }
        .alert("StoreKit notice", isPresented: Binding(
            get: { storeManager.errorMessage != nil },
            set: { if !$0 { storeManager.errorMessage = nil } }
        )) {
            Button("Got it", role: .cancel) { storeManager.errorMessage = nil }
        } message: {
            Text(storeManager.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Healing Skins")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Let your mood cards and wish tube grow into a style you love.")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                IconBadge(systemName: "paintpalette.fill", tint: AppTheme.lavenderDeep, size: 46)
            }
            HStack(spacing: 7) {
                MellowPill(text: "Base skins free", glyph: "gift", tint: AppTheme.success)
                MellowPill(text: "Growth unlocks", glyph: "sparkles", tint: AppTheme.lavenderDeep)
                MellowPill(text: "No ads", glyph: "hand.raised.fill", tint: AppTheme.milkBlueDeep)
            }
        }
    }

    private var kindPicker: some View {
        HStack(spacing: 0) {
            ForEach([SkinKind.tarot, SkinKind.wishTube], id: \.id) { kind in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.selectedKind = kind
                    }
                    HapticManager.shared.selection()
                } label: {
                    Text(kind.displayName)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(viewModel.selectedKind == kind ? Color.white : AppTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(viewModel.selectedKind == kind ? AppTheme.lavenderDeep : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(AppTheme.surface.opacity(0.72), in: Capsule())
    }

    private var packCard: some View {
        let product = storeManager.product(for: packProductID)
        let isOwned = storeManager.isOwned(packProductID)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.selectedKind == .tarot ? "Premium card-skin pack" : "Premium wish-tube skin pack")
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text(viewModel.selectedKind == .tarot ? "Unlock Moon Tide and Starlight card backs" : "Unlock Jade and Sakura Snow wish tubes")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                if isOwned {
                    MellowPill(text: "Owned", glyph: "checkmark", tint: AppTheme.success)
                } else if let product {
                    Text(product.displayPrice)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                }
            }

            if !isOwned {
                Button {
                    Task { @MainActor in
                        isPurchasingPack = true
                        let purchased = await storeManager.purchase(productID: packProductID)
                        if purchased {
                            try? GrowthEngine.persistPurchaseEntitlements(storeManager.ownedProductIDs, context: context)
                            viewModel.feedback = "The skin pack is unlocked. You can apply it below."
                        }
                        isPurchasingPack = false
                    }
                } label: {
                    HStack {
                        if isPurchasingPack {
                            ProgressView().tint(.white)
                        } else {
                            Text(product == nil ? "Product unavailable" : "Unlock skin pack")
                            Image(systemName: "bag.fill")
                        }
                    }
                }
                .buttonStyle(MellowPrimaryButtonStyle())
                .disabled(isPurchasingPack || product == nil)
            }

            Text("One-time purchase, not a subscription, and it will not auto-renew. Skins change only the local appearance and do not affect any feature.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .mellowCard()
    }

    private var skinGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "All skins", subtitle: "Currently using: \(SkinCatalog.skin(id: selectedSkinID).name)")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(skins) { skin in
                    skinCard(skin)
                }
            }
        }
    }

    private func skinCard(_ skin: MellowSkin) -> some View {
        let unlocked = viewModel.isUnlocked(skin, unlocked: unlockedSkins, store: storeManager)
        let selected = selectedSkinID == skin.id
        return VStack(alignment: .leading, spacing: 10) {
            SkinPreview(skin: skin)
                .frame(height: 138)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(skin.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(skin.subtitle)
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
            }
            HStack(spacing: 6) {
                if selected {
                    MellowPill(text: "In use", glyph: "checkmark", tint: AppTheme.success)
                } else if unlocked {
                    Button {
                        Task {
                            _ = await viewModel.select(
                                skin: skin,
                                profile: profile,
                                settings: settings,
                                unlocked: unlockedSkins,
                                store: storeManager,
                                context: context
                            )
                        }
                    } label: {
                        Text("Apply")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(AppTheme.lavenderDeep, in: Capsule())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        Task {
                            _ = await viewModel.select(
                                skin: skin,
                                profile: profile,
                                settings: settings,
                                unlocked: unlockedSkins,
                                store: storeManager,
                                context: context
                            )
                        }
                    } label: {
                        Text(SkinCatalog.accessLabel(for: skin, unlocked: false))
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(skin.access == .growth ? AppTheme.secondaryText : AppTheme.lavenderDeep)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(AppTheme.surface.opacity(0.75), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(selected ? AppTheme.lavenderDeep.opacity(0.55) : AppTheme.separator, lineWidth: selected ? 1.5 : 1)
        )
    }

    private var selectionNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Growth unlock rules", systemImage: "sparkles")
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text("3 cumulative daily echoes unlock Mist Glow, 7 unlock Flower Letter, and 5 wishes posted on the wall unlock Porcelain Moon. Growth skins are never revoked when a streak breaks.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)
        }
        .mellowCard()
    }

    private var restoreAndLegal: some View {
        VStack(spacing: 12) {
            Button {
                Task { @MainActor in
                    await storeManager.restorePurchases()
                    try? GrowthEngine.persistPurchaseEntitlements(storeManager.ownedProductIDs, context: context)
                    if storeManager.errorMessage == nil {
                        viewModel.feedback = "Purchases refreshed."
                    }
                }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
            .buttonStyle(MellowSecondaryButtonStyle())

            HStack(spacing: 14) {
                Button("Privacy Policy") {
                    if let url = URL(string: AppTheme.privacyURL) { UIApplication.shared.open(url) }
                }
                Button("Terms of Use") {
                    if let url = URL(string: AppTheme.termsURL) { UIApplication.shared.open(url) }
                }
                Button("Manage Subscription") {
                    if let url = storeManager.manageSubscriptionsURL() { UIApplication.shared.open(url) }
                }
            }
            .font(.mellowMicro)
            .foregroundStyle(AppTheme.secondaryText)

            Text("Skins and entitlements are handled by Apple StoreKit, and the app does not collect payment information. Restore Purchases can re-enable non-consumable entitlements on devices using the same Apple ID.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SkinPreview: View {
    let skin: MellowSkin

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(colors: [Color(hexString: skin.primaryHex), Color(hexString: skin.secondaryHex)], startPoint: .topLeading, endPoint: .bottomTrailing))
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.48), lineWidth: 1)
                .padding(6)
            if skin.kind == .tarot {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .padding(24)
                Image(systemName: skin.symbol)
                    .font(.system(size: 28, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.9))
                VStack {
                    Spacer()
                    Text("Wishes")
                        .font(.system(size: 9, weight: .medium, design: .serif))
                        .tracking(3)
                        .foregroundStyle(Color.white.opacity(0.62))
                        .padding(.bottom, 11)
                }
            } else {
                VStack(spacing: -6) {
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { _ in
                            Capsule()
                                .fill(Color.white.opacity(0.48))
                                .frame(width: 4, height: 40)
                        }
                    }
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 72, height: 72)
                        .overlay(Image(systemName: skin.symbol).font(.system(size: 20, weight: .light)).foregroundStyle(Color.white.opacity(0.88)))
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: skin.access == .purchase ? "bag.fill" : skin.access == .growth ? "sparkles" : "gift.fill")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(AppTheme.softInk)
                .padding(6)
                .background(Color.white.opacity(0.58), in: Circle())
                .padding(7)
        }
    }
}