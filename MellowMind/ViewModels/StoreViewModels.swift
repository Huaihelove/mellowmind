import Foundation
import SwiftData
import Combine

@MainActor
final class SkinStoreViewModel: ObservableObject {
    @Published var selectedKind: SkinKind = .tarot
    @Published var feedback: String?
    @Published private(set) var isBusy = false

    func isUnlocked(_ skin: MellowSkin, unlocked: [UnlockedSkin], store: StoreKitManager) -> Bool {
        switch skin.access {
        case .free:
            return true
        case .growth:
            return unlocked.contains(where: { $0.skinID == skin.id })
        case .purchase:
            guard let productID = skin.productID else { return false }
            return unlocked.contains(where: { $0.skinID == skin.id }) || store.isOwned(productID)
        }
    }

    @discardableResult
    func select(
        skin: MellowSkin,
        profile: UserProfile,
        settings: AppSettings,
        unlocked: [UnlockedSkin],
        store: StoreKitManager,
        context: ModelContext
    ) async -> Bool {
        guard !isBusy else { return false }
        isBusy = true
        defer { isBusy = false }

        if skin.access == .growth, !isUnlocked(skin, unlocked: unlocked, store: store) {
            feedback = "Complete \(skin.requiredCount) more \(skin.growthMetric == .checkIns ? "check-ins" : "wishes") to unlock it."
            return false
        }

        if skin.access == .purchase, !isUnlocked(skin, unlocked: unlocked, store: store) {
            guard let productID = skin.productID else { return false }
            let purchased = await store.purchase(productID: productID)
            guard purchased else {
                feedback = store.errorMessage ?? "Purchase did not complete."
                return false
            }
            try? GrowthEngine.persistPurchaseEntitlements(store.ownedProductIDs, context: context)
        }

        let current = try? context.fetch(FetchDescriptor<UnlockedSkin>())
        if let current, !current.contains(where: { $0.skinID == skin.id }) {
            context.insert(UnlockedSkin(skinID: skin.id, source: skin.access.rawValue))
        }
        switch skin.kind {
        case .tarot:
            settings.selectedTarotSkinID = skin.id
        case .wishTube:
            settings.selectedTubeSkinID = skin.id
        }
        do {
            try context.save()
            feedback = "\(skin.name) is now applied."
            HapticManager.shared.success()
            return true
        } catch {
            feedback = "The skin could not be saved. Please try again."
            return false
        }
    }

    func syncEntitlements(store: StoreKitManager, context: ModelContext) {
        guard !store.ownedProductIDs.isEmpty else { return }
        try? GrowthEngine.persistPurchaseEntitlements(store.ownedProductIDs, context: context)
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var feedback: String?
    @Published var showingClearAllConfirmation = false
    @Published var showingClearWishConfirmation = false
    @Published private(set) var isWorking = false

    func savePreferences(profile: UserProfile, context: ModelContext) {
        profile.updatedAt = Date()
        do {
            try context.save()
            HapticManager.shared.setEnabled(profile.hapticsEnabled)
        } catch {
            feedback = "The setting could not be saved. Please try again."
        }
    }

    func setNotifications(enabled: Bool, settings: AppSettings, context: ModelContext) async {
        if enabled {
            let granted = await LocalNotificationService.shared.requestAuthorizationIfNeeded()
            settings.notificationsEnabled = granted
            if !granted {
                feedback = "System notifications are off. You can still use every core feature, and you can enable reminders later in Settings."
            } else {
                feedback = "Sealed-wish reminders are on."
            }
        } else {
            settings.notificationsEnabled = false
            LocalNotificationService.shared.cancelAllSealReminders()
            feedback = "Sealed-wish reminders are off."
        }
        try? context.save()
    }

    func clearAll(context: ModelContext) -> Bool {
        isWorking = true
        defer { isWorking = false }
        do {
            try DataEraser.eraseAll(context: context)
            HapticManager.shared.warning()
            return true
        } catch {
            feedback = "Local data could not be cleared. Please try again."
            return false
        }
    }

    func clearWishData(context: ModelContext) -> Bool {
        isWorking = true
        defer { isWorking = false }
        do {
            try DataEraser.eraseWishAndJournalData(context: context)
            feedback = "Wishes, sealed wishes, and Tree Hollow entries have been cleared."
            HapticManager.shared.success()
            return true
        } catch {
            feedback = "Wish data could not be cleared. Please try again."
            return false
        }
    }

    func restore(store: StoreKitManager, context: ModelContext) async {
        isWorking = true
        defer { isWorking = false }
        await store.restorePurchases()
        try? GrowthEngine.persistPurchaseEntitlements(store.ownedProductIDs, context: context)
        feedback = store.errorMessage ?? "Purchases refreshed."
    }
}