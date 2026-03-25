import SwiftUI

@main
struct ParlanceApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("Parlance", image: "LogoMark") {
            MenuBarView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
