import SwiftUI
import SwiftData
import UIKit

struct WishSealView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var storeManager: StoreKitManager
    @Query(sort: \SealedWish.createdAt, order: .reverse) private var seals: [SealedWish]
    @StateObject private var viewModel = WishSealViewModel()
    @State private var showComposer = false
    @State private var showUpgrade = false
    @State private var activeSeal: SealedWish?
    @State private var lockedMessage: String?

    private var premiumUnlocked: Bool { storeManager.hasUnlimitedSeals }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                header
                if !premiumUnlocked {
                    upgradeBanner
                }
                if seals.isEmpty {
                    WarmEmptyState(
                        title: "No sealed wishes yet",
                        message: "Write something only your future self will see. It is encrypted on this device and ready to read when the time comes.",
                        systemImage: "lock.square.stack"
                    )
                    .mellowCard()
                } else {
                    ForEach(seals, id: \.id) { seal in
                        sealCard(seal)
                    }
                }
                privacyNote
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    attemptCreate()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create a sealed wish")
            }
        }
        .sheet(isPresented: $showComposer) {
            SealComposerSheet(
                viewModel: viewModel,
                profile: profile,
                settings: settings,
                context: context,
                premiumUnlocked: premiumUnlocked,
                existing: seals
            )
        }
        .sheet(isPresented: $showUpgrade) {
            SealUpgradeSheet()
        }
        .sheet(isPresented: Binding(
            get: { activeSeal != nil },
            set: { if !$0 { activeSeal = nil } }
        )) {
            if let seal = activeSeal {
                SealOpenSheet(seal: seal, viewModel: viewModel, context: context)
            }
        }
        .alert("Notice", isPresented: Binding(
            get: { lockedMessage != nil },
            set: { if !$0 { lockedMessage = nil } }
        )) {
            Button("Got it", role: .cancel) { lockedMessage = nil }
        } message: {
            Text(lockedMessage ?? "")
        }
        .alert("Notice", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Got it", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Sealed Wishes")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Entrust this moment to time, then meet yourself gently when it opens.")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                PrivacyBadge(text: "AES-256 local encryption")
            }
            HStack(spacing: 7) {
                MellowPill(text: "\(seals.count) sealed", glyph: "lock.fill", tint: AppTheme.lavenderDeep)
                MellowPill(text: "Revisit in 7 / 30 days", glyph: "calendar", tint: AppTheme.milkBlueDeep)
                MellowPill(text: premiumUnlocked ? "Unlimited seals unlocked" : "Free: \(viewModel.freeSealLimit)", glyph: "infinity", tint: premiumUnlocked ? AppTheme.success : AppTheme.warning)
            }
            Button {
                attemptCreate()
            } label: {
                Label("Seal a new wish", systemImage: "lock.badge.plus")
            }
            .buttonStyle(MellowPrimaryButtonStyle())
        }
    }

    private var upgradeBanner: some View {
        Button {
            showUpgrade = true
        } label: {
            HStack(spacing: 12) {
                IconBadge(systemName: "infinity", tint: AppTheme.lavenderDeep, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Unlock unlimited seals")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Keep unlimited wishes and archive sealed history permanently")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .mellowCard(padding: 14, cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func sealCard(_ seal: SealedWish) -> some View {
        Button {
            guard seal.isReadyToOpen else {
                lockedMessage = seal.remainingText
                HapticManager.shared.warning()
                return
            }
            activeSeal = seal
            HapticManager.shared.softTap()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 7) {
                        Text(seal.theme.glyph)
                            .font(.system(size: 17))
                        Text(seal.theme.rawValue)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                    }
                    Spacer()
                    Image(systemName: seal.isReadyToOpen ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(seal.isReadyToOpen ? AppTheme.success : AppTheme.secondaryText)
                }

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(seal.isReadyToOpen ? "Ready to revisit" : "A sealed wish")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(seal.remainingText)
                            .font(.mellowCaption)
                            .foregroundStyle(seal.isReadyToOpen ? AppTheme.success : AppTheme.secondaryText)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Sealed on")
                            .font(.mellowMicro)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(seal.createdAt.formatted(.dateTime.month().day()))
                            .font(.mellowCaption)
                            .foregroundStyle(AppTheme.primaryText)
                    }
                }

                if let openedAt = seal.openedAt {
                    DividerSoft()
                    Text("Revisited on \(openedAt.formatted(.dateTime.month().day().hour().minute())) · Felt \(seal.moodBefore.rawValue) then; \(seal.moodAfter?.rawValue ?? "not recorded") now")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .mellowCard()
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.delete(seal, context: context)
            } label: {
                Label("Delete this sealed wish", systemImage: "trash")
            }
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "lock.shield")
                .foregroundStyle(AppTheme.lavenderDeep)
            Text("Sealed content is encrypted with AES-GCM and written to the local database; the key is stored in Keychain. After clearing wish data or all local data, the content cannot be recovered.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)
        }
        .padding(14)
        .background(AppTheme.lavender.opacity(0.07), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func attemptCreate() {
        if !premiumUnlocked && seals.count >= viewModel.freeSealLimit {
            showUpgrade = true
            HapticManager.shared.warning()
        } else {
            showComposer = true
            HapticManager.shared.softTap()
        }
    }
}

private struct SealComposerSheet: View {
    @ObservedObject var viewModel: WishSealViewModel
    let profile: UserProfile
    let settings: AppSettings
    let context: ModelContext
    let premiumUnlocked: Bool
    let existing: [SealedWish]

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Seal a wish for your future self")
                            .font(.mellowTitle)
                            .foregroundStyle(AppTheme.primaryText)
                        Text("The content will be encrypted on this device.")
                            .font(.mellowMicro)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    Spacer()
                    Button("Close") { dismiss() }
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                ZStack(alignment: .topLeading) {
                    if viewModel.draft.isEmpty {
                        Text("Write what you feel now, something for your future self, or one small promise...")
                            .font(.mellowBody)
                            .foregroundStyle(AppTheme.secondaryText.opacity(0.7))
                            .padding(15)
                    }
                    TextEditor(text: $viewModel.draft)
                        .focused($focused)
                        .font(.mellowBody)
                        .scrollContentBackground(.hidden)
                        .padding(9)
                        .frame(minHeight: 190)
                }
                .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                HStack {
                    Text("\(viewModel.draft.count)/800")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                    Spacer()
                    PrivacyBadge()
                }

                SectionHeading(title: "How you feel now")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EmotionMood.allCases) { mood in
                            Button {
                                viewModel.selectedMood = mood
                                HapticManager.shared.selection()
                            } label: {
                                MoodChip(mood: mood, isSelected: viewModel.selectedMood == mood)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                SectionHeading(title: "Wish theme")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(WishTheme.allCases) { theme in
                        Button {
                            viewModel.selectedTheme = theme
                            HapticManager.shared.selection()
                        } label: {
                            HStack(spacing: 6) {
                                Text(theme.glyph)
                                Text(theme.rawValue)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                Spacer()
                            }
                            .foregroundStyle(viewModel.selectedTheme == theme ? Color.white : AppTheme.secondaryText)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 10)
                            .background(viewModel.selectedTheme == theme ? Color(hexString: theme.accentHex) : AppTheme.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                SectionHeading(title: "When to revisit")
                HStack(spacing: 10) {
                    ForEach([7, 30], id: \.self) { days in
                        Button {
                            viewModel.durationDays = days
                            HapticManager.shared.selection()
                        } label: {
                            VStack(spacing: 3) {
                                Text("\(days) days")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                Text(days == 7 ? "Look back in one week" : "Look back in one month")
                                    .font(.mellowMicro)
                            }
                            .foregroundStyle(viewModel.durationDays == days ? Color.white : AppTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(viewModel.durationDays == days ? AppTheme.lavenderDeep : AppTheme.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.warning)
                }

                Button {
                    if viewModel.create(
                        profile: profile,
                        context: context,
                        existing: existing,
                        premiumUnlocked: premiumUnlocked,
                        notificationsEnabled: settings.notificationsEnabled
                    ) != nil {
                        dismiss()
                    }
                } label: {
                    Label("Encrypt and seal", systemImage: "lock.fill")
                }
                .buttonStyle(MellowPrimaryButtonStyle())

                Text("Sealed content is never uploaded. Readiness reminders can be enabled in Settings; even with reminders off, you can revisit when it is time.")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 22)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(MellowBackground())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComplianceFooter()
        }
        .onAppear { focused = true }
    }
}

private struct SealOpenSheet: View {
    let seal: SealedWish
    @ObservedObject var viewModel: WishSealViewModel
    let context: ModelContext

    @Environment(\.dismiss) private var dismiss
    @State private var isRevealed = false
    @State private var decryptedText = ""
    @State private var moodAfter: EmotionMood = .calm
    @State private var reflection = ""
    @State private var didLoad = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("A letter to your past self")
                            .font(.mellowTitle)
                            .foregroundStyle(AppTheme.primaryText)
                        Text("Sealed on \(seal.createdAt.formatted(.dateTime.year().month().day()))")
                            .font(.mellowMicro)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    Spacer()
                    Button("Close") { dismiss() }
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                HStack(spacing: 8) {
                    MellowPill(text: seal.theme.rawValue, glyph: seal.theme.glyph, tint: Color(hexString: seal.theme.accentHex))
                    MellowPill(text: "Then: \(seal.moodBefore.rawValue)", glyph: seal.moodBefore.glyph, tint: AppTheme.milkBlueDeep)
                    MellowPill(text: "\(seal.durationDays) days", glyph: "calendar", tint: AppTheme.lavenderDeep)
                }

                if !isRevealed {
                    VStack(spacing: 15) {
                        Image(systemName: "envelope.open")
                            .font(.system(size: 44, weight: .light))
                            .foregroundStyle(AppTheme.lavenderDeep)
                        Text("This letter is ready to open")
                            .font(.mellowHeadline)
                            .foregroundStyle(AppTheme.primaryText)
                        Text("It records who you were then. You do not have to match that person now.")
                            .font(.mellowBody)
                            .foregroundStyle(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                        Button {
                            reveal()
                        } label: {
                            Label("Open sealed wish", systemImage: "lock.open")
                        }
                        .buttonStyle(MellowPrimaryButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 34)
                    .padding(.horizontal, 20)
                    .mellowCard()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What you wrote then")
                            .font(.mellowCaption)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(decryptedText)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                            .lineSpacing(6)
                            .textSelection(.enabled)
                    }
                    .mellowCard()

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeading(title: "How you feel now", subtitle: "Record this moment without comparing it to the past")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(EmotionMood.allCases) { mood in
                                    Button {
                                        moodAfter = mood
                                        HapticManager.shared.selection()
                                    } label: {
                                        MoodChip(mood: mood, isSelected: moodAfter == mood)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        TextField("What would you like to say to yourself now?", text: $reflection, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.mellowBody)
                            .padding(12)
                            .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        Button {
                            viewModel.markOpened(seal, moodAfter: moodAfter, reflection: reflection, context: context)
                            HapticManager.shared.softTap()
                            dismiss()
                        } label: {
                            Label("Save emotional change", systemImage: "checkmark")
                        }
                        .buttonStyle(MellowPrimaryButtonStyle())
                    }
                    .mellowCard()
                }

                if let openedAt = seal.openedAt, !seal.reflection.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Last revisit · \(openedAt.formatted(.dateTime.month().day().hour().minute()))")
                            .font(.mellowMicro)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(seal.reflection)
                            .font(.mellowBody)
                            .foregroundStyle(AppTheme.primaryText)
                    }
                    .mellowCard()
                }
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 22)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(MellowBackground())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComplianceFooter()
        }
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            moodAfter = seal.moodBefore
            reflection = seal.reflection
            if seal.openedAt != nil {
                isRevealed = true
                decryptedText = viewModel.decrypt(seal) ?? "This sealed wish cannot be read right now."
            }
        }
    }

    private func reveal() {
        if decryptedText.isEmpty {
            decryptedText = viewModel.decrypt(seal) ?? "This sealed wish cannot be read right now."
        }
        withAnimation(.spring(response: 0.58, dampingFraction: 0.84)) {
            isRevealed = true
        }
        HapticManager.shared.success()
    }
}

private struct SealUpgradeSheet: View {
    @EnvironmentObject private var storeManager: StoreKitManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Unlimited Sealed Wishes")
                        .font(.mellowTitle)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("One purchase · Permanent entitlement")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Button("Close") { dismiss() }
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            VStack(alignment: .leading, spacing: 12) {
                benefit("Unlimited quantity", "No longer limited to 3 wishes in the free version", "infinity")
                benefit("Permanent archive", "Keep sealed history indefinitely", "archivebox.fill")
                benefit("Local encryption", "Content still stays only on your device", "lock.shield.fill")
            }

            if let product = storeManager.product(for: StoreProductIDs.unlimitedWishSeals) {
                HStack {
                    Text(product.displayName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    Spacer()
                    Text(product.displayPrice)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(AppTheme.primaryText)
                Text("One-time purchase, not a subscription. It will not auto-renew.")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
            } else {
                Text("Product information is temporarily unavailable. Price is governed by the App Store purchase page.")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Button {
                Task { @MainActor in
                    isPurchasing = true
                    let purchased = await storeManager.purchase(productID: StoreProductIDs.unlimitedWishSeals)
                    if purchased {
                        try? GrowthEngine.persistPurchaseEntitlements(storeManager.ownedProductIDs, context: context)
                        dismiss()
                    }
                    isPurchasing = false
                }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text("Unlock permanent entitlement")
                        Image(systemName: "arrow.right")
                    }
                }
            }
            .buttonStyle(MellowPrimaryButtonStyle())
            .disabled(isPurchasing)

            HStack(spacing: 12) {
                Button("Restore Purchases") {
                    Task { await storeManager.restorePurchases() }
                }
                Spacer()
                Button("Privacy Policy") {
                    if let url = URL(string: AppTheme.privacyURL) { UIApplication.shared.open(url) }
                }
                Button("Terms of Use") {
                    if let url = URL(string: AppTheme.termsURL) { UIApplication.shared.open(url) }
                }
            }
            .font(.mellowMicro)
            .foregroundStyle(AppTheme.secondaryText)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.top, 22)
        .padding(.bottom, 16)
        .background(MellowBackground())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComplianceFooter()
        }
    }

    private func benefit(_ title: String, _ subtitle: String, _ icon: String) -> some View {
        HStack(spacing: 11) {
            IconBadge(systemName: icon, tint: AppTheme.lavenderDeep, size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }
}