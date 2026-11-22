import SwiftUI
import Combine

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case tarot
    case wish
    case space
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Today"
        case .tarot: return "Cards"
        case .wish: return "Wishes"
        case .space: return "Healing"
        case .profile: return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "sun.max"
        case .tarot: return "rectangle.portrait.on.rectangle.portrait"
        case .wish: return "leaf"
        case .space: return "heart.text.square"
        case .profile: return "person.crop.circle"
        }
    }
}

enum AppRoute: Hashable, Identifiable {
    case starCalendar
    case premiumReport
    case personalityDossier
    case editProfile
    case tarotFlow
    case wishTube
    case wishWall
    case wishSeal
    case checkIn
    case treeHole
    case anxietyDissector
    case audioTherapy
    case collection
    case skinStore
    case settings
    case permissionCenter
    case privacyPolicy
    case terms
    case disclaimer
    case about

    var id: String {
        switch self {
        case .starCalendar: return "starCalendar"
        case .premiumReport: return "premiumReport"
        case .personalityDossier: return "personalityDossier"
        case .editProfile: return "editProfile"
        case .tarotFlow: return "tarotFlow"
        case .wishTube: return "wishTube"
        case .wishWall: return "wishWall"
        case .wishSeal: return "wishSeal"
        case .checkIn: return "checkIn"
        case .treeHole: return "treeHole"
        case .anxietyDissector: return "anxietyDissector"
        case .audioTherapy: return "audioTherapy"
        case .collection: return "collection"
        case .skinStore: return "skinStore"
        case .settings: return "settings"
        case .permissionCenter: return "permissionCenter"
        case .privacyPolicy: return "privacyPolicy"
        case .terms: return "terms"
        case .disclaimer: return "disclaimer"
        case .about: return "about"
        }
    }

    var title: String {
        switch self {
        case .starCalendar: return "Daily Emotional Almanac"
        case .premiumReport: return "Deep Emotional Report"
        case .personalityDossier: return "Personality Profile"
        case .editProfile: return "Edit Profile"
        case .tarotFlow: return "Reflection Cards"
        case .wishTube: return "Gentle Wish Ritual"
        case .wishWall: return "Wish Wall"
        case .wishSeal: return "Sealed Wishes"
        case .checkIn: return "Daily Check-in"
        case .treeHole: return "Quiet Room"
        case .anxietyDissector: return "Anxiety Sorter"
        case .audioTherapy: return "Sound Therapy"
        case .collection: return "Saved Reflections"
        case .skinStore: return "Skin Shop"
        case .settings: return "Settings"
        case .permissionCenter: return "Permissions & Experience"
        case .privacyPolicy: return "Privacy Policy"
        case .terms: return "Terms of Use"
        case .disclaimer: return "Disclaimer"
        case .about: return "About Us"
        }
    }
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var path = NavigationPath()

    func select(_ tab: AppTab) {
        if selectedTab == tab {
            path = NavigationPath()
        } else {
            selectedTab = tab
            path = NavigationPath()
        }
        HapticManager.shared.selection()
    }

    func push(_ route: AppRoute) {
        path.append(route)
        HapticManager.shared.softTap()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}