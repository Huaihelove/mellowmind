import Foundation
import SwiftData

// MARK: - Privacy compliance: one-tap removal of birth details, blood type, wishes, and all local content

@MainActor
enum DataEraser {
    static func eraseAll(context: ModelContext) throws {
        try deleteAll(UserProfile.self, context: context)
        try deleteAll(AppSettings.self, context: context)
        try deleteAll(CollectItem.self, context: context)
        try deleteAll(Wish.self, context: context)
        try deleteAll(SealedWish.self, context: context)
        try deleteAll(CheckInRecord.self, context: context)
        try deleteAll(EmotionJournalEntry.self, context: context)
        try deleteAll(UnlockedSkin.self, context: context)
        try context.save()
        EncryptionService.shared.deleteKey()
    }

    static func eraseWishAndJournalData(context: ModelContext) throws {
        try deleteAll(Wish.self, context: context)
        try deleteAll(SealedWish.self, context: context)
        try deleteAll(EmotionJournalEntry.self, context: context)
        let collections = try context.fetch(FetchDescriptor<CollectItem>())
        for item in collections where item.kind == .wish || item.kind == .companion {
            context.delete(item)
        }
        try context.save()
        EncryptionService.shared.deleteKey()
    }

    private static func deleteAll<T: PersistentModel>(_ type: T.Type, context: ModelContext) throws {
        let items = try context.fetch(FetchDescriptor<T>())
        for item in items {
            context.delete(item)
        }
    }
}