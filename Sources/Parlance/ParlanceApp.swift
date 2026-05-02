import SwiftUI

@main
struct ParlanceApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("Parlance", image: "Parlance_Icon_Dark") {
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
