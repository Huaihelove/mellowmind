import Foundation

// MARK: - App-wide growth path and skin system
// Base skins are free; growth skins unlock through check-ins and wishes; premium skins unlock through StoreKit 2 entitlements.

enum SkinCatalog {
    static let baseTarot = MellowSkin(
        id: "tarot.base.cloud",
        kind: .tarot,
        name: "Cloud White",
        subtitle: "Moonlight white and soft lilac card back",
        primaryHex: "D8D0EA",
        secondaryHex: "F7F3FC",
        symbol: "cloud.moon",
        access: .free,
        requiredCount: 0,
        growthMetric: .checkIns,
        productID: nil
    )

    static let baseTube = MellowSkin(
        id: "tube.base.bamboo",
        kind: .wishTube,
        name: "Bamboo Shadow",
        subtitle: "Green bamboo and milky-blue base wish tube",
        primaryHex: "A7BFA9",
        secondaryHex: "E7F0E9",
        symbol: "leaf",
        access: .free,
        requiredCount: 0,
        growthMetric: .wishes,
        productID: nil
    )

    static let all: [MellowSkin] = [
        baseTarot,
        baseTube,
        MellowSkin(id: "tarot.growth.mist", kind: .tarot, name: "Mist Glow", subtitle: "Unlock after 3 total check-ins", primaryHex: "B2B8D4", secondaryHex: "EDF0F9", symbol: "cloud.fog", access: .growth, requiredCount: 3, growthMetric: .checkIns, productID: nil),
        MellowSkin(id: "tube.growth.porcelain", kind: .wishTube, name: "Porcelain Moon", subtitle: "Unlock by leaving 5 wishes on the wall", primaryHex: "B9D0D8", secondaryHex: "F2F8FA", symbol: "moon.stars", access: .growth, requiredCount: 5, growthMetric: .wishes, productID: nil),
        MellowSkin(id: "tarot.growth.blossom", kind: .tarot, name: "Flower Letter", subtitle: "Unlock after 7 total check-ins", primaryHex: "D8B7C2", secondaryHex: "F9EDF1", symbol: "camera.macro", access: .growth, requiredCount: 7, growthMetric: .checkIns, productID: nil),
        MellowSkin(id: "tarot.paid.moonlit", kind: .tarot, name: "Moon Tide", subtitle: "Premium card-face skin pack", primaryHex: "7F87B7", secondaryHex: "E8E8FA", symbol: "moon.haze", access: .purchase, requiredCount: 0, growthMetric: .checkIns, productID: StoreProductIDs.tarotSkinPack),
        MellowSkin(id: "tarot.paid.aurora", kind: .tarot, name: "Starlight", subtitle: "Premium card-face skin pack", primaryHex: "85B7B8", secondaryHex: "E1F3EF", symbol: "sparkles", access: .purchase, requiredCount: 0, growthMetric: .checkIns, productID: StoreProductIDs.tarotSkinPack),
        MellowSkin(id: "tube.paid.jade", kind: .wishTube, name: "Jade", subtitle: "Premium wish-tube skin pack", primaryHex: "87B5A2", secondaryHex: "E5F2EB", symbol: "leaf.circle", access: .purchase, requiredCount: 0, growthMetric: .wishes, productID: StoreProductIDs.tubeSkinPack),
        MellowSkin(id: "tube.paid.sakura", kind: .wishTube, name: "Sakura Snow", subtitle: "Premium wish-tube skin pack", primaryHex: "D8B2BE", secondaryHex: "F9ECF0", symbol: "snowflake", access: .purchase, requiredCount: 0, growthMetric: .wishes, productID: StoreProductIDs.tubeSkinPack)
    ]

    static func skin(id: String) -> MellowSkin {
        all.first(where: { $0.id == id }) ?? baseTarot
    }

    static func skins(for kind: SkinKind) -> [MellowSkin] {
        all.filter { $0.kind == kind }
    }

    static func tarotSkin(id: String) -> MellowSkin {
        all.first(where: { $0.id == id && $0.kind == .tarot }) ?? baseTarot
    }

    static func tubeSkin(id: String) -> MellowSkin {
        all.first(where: { $0.id == id && $0.kind == .wishTube }) ?? baseTube
    }

    static func accessLabel(for skin: MellowSkin, unlocked: Bool) -> String {
        if unlocked { return "Unlocked" }
        switch skin.access {
        case .free: return "Free"
        case .growth: return "\(skin.requiredCount) \(skin.growthMetric == .checkIns ? "check-ins" : "wishes")"
        case .purchase: return "Premium unlock"
        }
    }
}