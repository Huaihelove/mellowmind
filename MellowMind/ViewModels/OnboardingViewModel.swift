import Foundation
import SwiftData
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var step = 0
    @Published var bloodType: BloodType?
    @Published var birthDate: Date
    @Published var displayName = ""
    @Published var isSaving = false
    @Published var errorMessage: String?

    let stepTitles = ["Blood Type", "Birth Details", "First Impression"]

    init() {
        birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    }

    var westernZodiac: WesternZodiac { ZodiacCalculator.westernZodiac(for: birthDate) }
    var chineseZodiac: ChineseZodiac { ZodiacCalculator.chineseZodiac(for: birthDate) }
    var canAdvance: Bool {
        switch step {
        case 0: return bloodType != nil
        case 1: return birthDate <= Date()
        default: return true
        }
    }

    func next() {
        guard canAdvance, step < 2 else { return }
        step += 1
        HapticManager.shared.mediumTap()
    }

    func back() {
        guard step > 0 else { return }
        step -= 1
        HapticManager.shared.selection()
    }

    func selectBloodType(_ type: BloodType) {
        bloodType = type
        HapticManager.shared.selection()
    }

    func complete(context: ModelContext) -> Bool {
        guard let bloodType else {
            errorMessage = "Please select a blood type first."
            return false
        }
        guard !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }

        let profile = UserProfile(
            displayName: displayName,
            bloodType: bloodType,
            birthDate: birthDate
        )
        context.insert(profile)
        let settings = AppSettings()
        context.insert(settings)
        do {
            try context.save()
            HapticManager.shared.success()
            return true
        } catch {
            context.delete(profile)
            context.delete(settings)
            errorMessage = "Your profile could not be saved. Please try again."
            return false
        }
    }
}