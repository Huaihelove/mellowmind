import Foundation
import StoreKit
import Combine

// MARK: - StoreKit 2 purchase framework
// Products: card-skin pack, wish-tube skin pack, unlimited seals, and the daily premium emotional-care report.
// No advertising SDK. Restore Purchases and Manage Subscriptions are visible on both the settings and store screens.

@MainActor
final class StoreKitManager: ObservableObject {
    static let displayOrder = [
        StoreProductIDs.tarotSkinPack,
        StoreProductIDs.tubeSkinPack,
        StoreProductIDs.unlimitedWishSeals,
        StoreProductIDs.premiumDailyReport
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var ownedProductIDs: Set<String> = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?
    private var hasStarted = false

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                await self.handleTransactionUpdate(result)
            }
        }
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let loaded = try await Product.products(for: StoreProductIDs.displayOrder)
            let order = Dictionary(uniqueKeysWithValues: StoreProductIDs.displayOrder.enumerated().map { ($0.element, $0.offset) })
            products = loaded.sorted { (order[$0.id] ?? Int.max) < (order[$1.id] ?? Int.max) }
            errorMessage = nil
        } catch {
            errorMessage = "Products cannot load right now. Please try again shortly."
        }
    }

    func product(for productID: String) -> Product? {
        products.first(where: { $0.id == productID })
    }

    func isOwned(_ productID: String) -> Bool {
        ownedProductIDs.contains(productID)
    }

    var hasUnlimitedSeals: Bool {
        isOwned(StoreProductIDs.unlimitedWishSeals)
    }

    var hasPremiumDailyReport: Bool {
        isOwned(StoreProductIDs.premiumDailyReport)
    }

    @discardableResult
    func purchase(productID: String) async -> Bool {
        guard let product = product(for: productID) else {
            errorMessage = "Product information is not ready yet. Please try again shortly."
            return false
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await refreshEntitlements()
                    HapticManager.shared.success()
                    return true
                case .unverified(_, _):
                    errorMessage = "The purchase receipt could not be verified. Please try again later or contact support."
                    return false
                }
            case .pending:
                errorMessage = "The purchase is waiting for system confirmation. Please return once it is complete."
                return false
            case .userCancelled:
                return false
            @unknown default:
                errorMessage = "The purchase flow cannot complete right now. Please try again shortly."
                return false
            }
        } catch {
            errorMessage = "Purchase did not complete: \(error.localizedDescription)"
            return false
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if ownedProductIDs.isEmpty {
                errorMessage = "No restorable purchases were found for the current Apple ID."
            } else {
                errorMessage = nil
                HapticManager.shared.success()
            }
        } catch {
            errorMessage = "Restore Purchases failed: \(error.localizedDescription)"
        }
    }

    func refreshEntitlements() async {
        var ids = Set<String>()
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.revocationDate == nil else { continue }
            ids.insert(transaction.productID)
        }
        ownedProductIDs = ids
    }

    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        await transaction.finish()
        await refreshEntitlements()
    }

    func manageSubscriptionsURL() -> URL? {
        URL(string: "https://apps.apple.com/account/subscriptions")
    }
}