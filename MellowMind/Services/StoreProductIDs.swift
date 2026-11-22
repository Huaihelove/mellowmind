import Foundation

enum StoreProductIDs {
    static let tarotSkinPack = "com.mellowmind.iap.tarot.skinpack"
    static let tubeSkinPack = "com.mellowmind.iap.tube.skinpack"
    static let unlimitedWishSeals = "com.mellowmind.iap.unlimited.wishseals"
    static let premiumDailyReport = "com.mellowmind.iap.dailyreport.monthly"

    static let all: Set<String> = [
        tarotSkinPack,
        tubeSkinPack,
        unlimitedWishSeals,
        premiumDailyReport
    ]

    static let nonConsumables: [String] = [
        tarotSkinPack,
        tubeSkinPack,
        unlimitedWishSeals
    ]

    static let subscription: String = premiumDailyReport
}