import SwiftUI
import SwiftData

@main
struct MellowMindApp: App {
    let container: ModelContainer
    @StateObject private var storeManager = StoreKitManager()

    init() {
        let schema = Schema([
            UserProfile.self,
            AppSettings.self,
            CollectItem.self,
            Wish.self,
            SealedWish.self,
            CheckInRecord.self,
            EmotionJournalEntry.self,
            UnlockedSkin.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                container = try ModelContainer(for: schema, configurations: [fallback])
            } catch {
                fatalError("SwiftData container initialization failed: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(container)
                .environmentObject(storeManager)
                .task {
                    storeManager.start()
                }
        }
    }
}