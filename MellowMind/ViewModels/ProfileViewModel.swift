import Foundation
import SwiftData
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var bloodType: BloodType = .a
    @Published var birthDate = Date()
    @Published var hapticsEnabled = true
    @Published var anonymousByDefault = true
    @Published var audioVolume = 0.55
    @Published var errorMessage: String?

    func load(profile: UserProfile) {
        displayName = profile.displayName
        bloodType = profile.bloodType
        birthDate = profile.birthDate
        hapticsEnabled = profile.hapticsEnabled
        anonymousByDefault = profile.anonymousByDefault
        audioVolume = profile.audioVolume
    }

    func save(profile: UserProfile, context: ModelContext) -> Bool {
        guard birthDate <= Date() else {
            errorMessage = "Your birth date cannot be later than today."
            return false
        }
        profile.update(
            displayName: displayName,
            bloodType: bloodType,
            birthDate: birthDate,
            hapticsEnabled: hapticsEnabled,
            anonymousByDefault: anonymousByDefault,
            audioVolume: audioVolume
        )
        do {
            try context.save()
            HapticManager.shared.setEnabled(hapticsEnabled)
            HapticManager.shared.success()
            return true
        } catch {
            errorMessage = "Your profile changes could not be saved. Please try again."
            return false
        }
    }
}