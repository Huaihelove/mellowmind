import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var bloodTypeRaw: String
    var birthDate: Date
    var birthYear: Int
    var createdAt: Date
    var updatedAt: Date
    var hapticsEnabled: Bool
    var anonymousByDefault: Bool
    var audioVolume: Double
    var hasCompletedOnboarding: Bool

    init(
        id: UUID = UUID(),
        displayName: String = "Star Friend",
        bloodType: BloodType = .a,
        birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date(),
        hapticsEnabled: Bool = true,
        anonymousByDefault: Bool = true,
        audioVolume: Double = 0.55
    ) {
        let normalizedDate = Calendar.current.startOfDay(for: birthDate)
        self.id = id
        self.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Star Friend" : displayName
        self.bloodTypeRaw = bloodType.rawValue
        self.birthDate = normalizedDate
        self.birthYear = Calendar.current.component(.year, from: normalizedDate)
        self.createdAt = Date()
        self.updatedAt = Date()
        self.hapticsEnabled = hapticsEnabled
        self.anonymousByDefault = anonymousByDefault
        self.audioVolume = audioVolume
        self.hasCompletedOnboarding = true
    }

    var bloodType: BloodType {
        BloodType(rawValue: bloodTypeRaw) ?? .a
    }

    var westernZodiac: WesternZodiac {
        ZodiacCalculator.westernZodiac(for: birthDate)
    }

    var chineseZodiac: ChineseZodiac {
        ZodiacCalculator.chineseZodiac(forGregorianYear: birthYear)
    }

    var snapshot: PersonalitySnapshot {
        PersonalitySnapshot(
            bloodType: bloodType,
            westernZodiac: westernZodiac,
            chineseZodiac: chineseZodiac,
            birthDate: birthDate
        )
    }

    var birthdayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: birthDate)
    }

    func update(
        displayName: String,
        bloodType: BloodType,
        birthDate: Date,
        hapticsEnabled: Bool,
        anonymousByDefault: Bool,
        audioVolume: Double
    ) {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.displayName = trimmedName.isEmpty ? "Star Friend" : trimmedName
        self.bloodTypeRaw = bloodType.rawValue
        self.birthDate = Calendar.current.startOfDay(for: birthDate)
        self.birthYear = Calendar.current.component(.year, from: birthDate)
        self.hapticsEnabled = hapticsEnabled
        self.anonymousByDefault = anonymousByDefault
        self.audioVolume = min(max(audioVolume, 0), 1)
        self.updatedAt = Date()
    }
}

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var selectedTarotSkinID: String
    var selectedTubeSkinID: String
    var hasSeenHapticsExplainer: Bool
    var notificationsEnabled: Bool
    var seedVersion: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        selectedTarotSkinID: String = SkinCatalog.baseTarot.id,
        selectedTubeSkinID: String = SkinCatalog.baseTube.id
    ) {
        self.id = id
        self.selectedTarotSkinID = selectedTarotSkinID
        self.selectedTubeSkinID = selectedTubeSkinID
        self.hasSeenHapticsExplainer = false
        self.notificationsEnabled = false
        self.seedVersion = 0
        self.createdAt = Date()
    }
}