import SwiftUI

@main
struct ParlanceApp: App {
    @StateObject private var appState = AppState()

    /// Persisted appearance preference — defaults to "dark" (parlance platform default).
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.dark.rawValue

    private var resolvedColorScheme: ColorScheme? {
        AppearanceMode(rawValue: appearanceModeRaw)?.colorScheme ?? .dark
    }

    var body: some Scene {
        // Menu-bar glyph: an SF Symbol, which the system always renders at the
        // correct menu-bar size and as a light/dark-adaptive template. The brand
        // asset (Parlance_Icon_Dark) is 57×48 pt — sized for larger UI — and
        // MenuBarExtra does not honour a .frame() to shrink it, so it rendered
        // oversized. checkmark.shield matches the icon documented in the README.
        MenuBarExtra("Parlance", systemImage: "checkmark.shield") {
            MenuBarView()
                .environmentObject(appState)
                .preferredColorScheme(resolvedColorScheme)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
                .preferredColorScheme(resolvedColorScheme)
        }
    }
}
