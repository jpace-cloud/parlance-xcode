import SwiftUI

/// Controls the app-wide colour scheme. Defaults to `.dark` (parlance platform default).
enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    /// Resolved `ColorScheme` to pass to `.preferredColorScheme(_:)`.
    /// `nil` means follow the system.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: return "gearshape"
        case .light:  return "sun.max"
        case .dark:   return "moon"
        }
    }
}
