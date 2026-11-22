import Foundation
import SwiftData

@MainActor
enum DataSeeder {
    static func bootstrap(context: ModelContext) throws {
        let settings = try context.fetch(FetchDescriptor<AppSettings>())
        let appSettings: AppSettings
        if let existing = settings.first {
            appSettings = existing
        } else {
            let created = AppSettings()
            context.insert(created)
            appSettings = created
        }

        _ = try GrowthEngine.refreshUnlocks(context: context)

        if appSettings.seedVersion < 1 {
            seedWishWall(context: context)
            appSettings.seedVersion = 1
        }
        try context.save()
    }

    private static func seedWishWall(context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Wish>())) ?? []
        guard existing.isEmpty else { return }

        let samples: [(String, Bool, String, WishTheme, Int, Int, [WishComment])] = [
            ("Evening Breeze", true, "I finally learned not to answer work messages after hours. Giving myself a boundary really did make it easier to breathe.", .ease, 18, 2, [
                WishComment(author: "Little Full Moon", content: "I am happy for you. Making room for a boundary is another way of caring for yourself."),
                WishComment(author: "Moon White", content: "This reminded me. I will try logging off a little earlier tonight too.")
            ]),
            ("Orange Soda", false, "I finally booked the health check I had been putting off. It was only a phone call, but it still counts.", .flow, 26, 1, [
                WishComment(author: "Anonymous Star Friend", content: "Small actions are still progress. You did well.")
            ]),
            ("Camellia", true, "I hope I sleep well tomorrow. Lately my mind feels like too many browser tabs are open at once, and I want to close them one by one.", .calm, 31, 4, [
                WishComment(author: "Green Reed", content: "May you have a truly quiet pocket of space tonight."),
                WishComment(author: "Little Island", content: "Closing even one tab is enough.")
            ]),
            ("Paper Airplane", true, "To me while I prepare for exams: I do not have to be efficient every minute. Moving steadily is enough.", .heal, 42, 3, [
                WishComment(author: "Evening Breeze", content: "Keep your own rhythm. You are already trying so hard.")
            ]),
            ("Little Round Moon", false, "Today I told a friend I had not spoken to in a long time that I missed her. She had been waiting for me to reach out too.", .tender, 12, 5, [
                WishComment(author: "Camellia", content: "Some relationships only need one gentle beginning.")
            ]),
            ("Green Reed", true, "I hope I can allow myself to do nothing sometimes, instead of always being the dependable one.", .ease, 8, 2, [
                WishComment(author: "Paper Airplane", content: "Dependable people need to be held too. Hold yourself first today.")
            ])
        ]

        let calendar = Calendar.current
        for (index, item) in samples.enumerated() {
            let date = calendar.date(byAdding: .hour, value: -(index * 7 + 2), to: Date()) ?? Date()
            let wish = Wish(
                authorName: item.0,
                isAnonymous: item.1,
                content: item.2,
                theme: item.3,
                createdAt: date,
                likeCount: item.4,
                comments: item.6,
                isSeed: true
            )
            context.insert(wish)
        }
    }
}