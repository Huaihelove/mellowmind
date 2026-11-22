import Foundation
import SwiftData

// MARK: - Growth path: daily check-ins and accumulated wishes unlock skins

@MainActor
enum GrowthEngine {
    @discardableResult
    static func refreshUnlocks(context: ModelContext) throws -> [MellowSkin] {
        let checkIns = try context.fetch(FetchDescriptor<CheckInRecord>())
        let wishes = try context.fetch(FetchDescriptor<Wish>())
        let realWishCount = wishes.filter { !$0.isSeed && !$0.isHidden }.count
        let existing = try context.fetch(FetchDescriptor<UnlockedSkin>())
        var existingIDs = Set(existing.map(\.skinID))
        var newlyUnlocked: [MellowSkin] = []

        func insert(_ skin: MellowSkin, source: String) {
            guard !existingIDs.contains(skin.id) else { return }
            context.insert(UnlockedSkin(skinID: skin.id, source: source))
            existingIDs.insert(skin.id)
            newlyUnlocked.append(skin)
        }

        for skin in SkinCatalog.all {
            switch skin.access {
            case .free:
                insert(skin, source: "base")
            case .growth:
                let count = skin.growthMetric == .checkIns ? checkIns.count : realWishCount
                if count >= skin.requiredCount {
                    insert(skin, source: "growth")
                }
            case .purchase:
                break
            }
        }

        if !newlyUnlocked.isEmpty {
            try context.save()
        }
        return newlyUnlocked
    }

    static func persistPurchaseEntitlements(_ productIDs: Set<String>, context: ModelContext) throws {
        let paidSkins = SkinCatalog.all.filter { skin in
            guard let productID = skin.productID else { return false }
            return productIDs.contains(productID)
        }
        let existing = try context.fetch(FetchDescriptor<UnlockedSkin>())
        var existingIDs = Set(existing.map(\.skinID))
        for skin in paidSkins where !existingIDs.contains(skin.id) {
            context.insert(UnlockedSkin(skinID: skin.id, source: "purchase"))
            existingIDs.insert(skin.id)
        }
        try context.save()
    }

    static func checkInStreak(records: [CheckInRecord], calendar: Calendar = .current) -> Int {
        let keys = Set(records.map(\.dateKey))
        guard !keys.isEmpty else { return 0 }
        var streak = 0
        var date = calendar.startOfDay(for: Date())
        while keys.contains(DateKey.string(from: date)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return streak
    }
}