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
        MenuBarExtra("Parlance", image: "Parlance_Icon_Dark") {
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
