import SwiftUI
import ParlanceKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var apiKeyInput: String = ""
    @State private var isTesting: Bool = false
    @State private var testResult: TestResult? = nil

    /// Mirrors the same AppStorage key written by ParlanceApp.
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.dark.rawValue

    enum TestResult {
        case success, failure(String)
    }

    var body: some View {
        TabView {
            accountTab
                .tabItem { Label("Account", systemImage: "person.circle") }

            aboutTab
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 440, height: 340)
        .onAppear {
            apiKeyInput = appState.apiKey ?? ""
        }
    }

    // MARK: - Account Tab

    private var accountTab: some View {
        Form {
            Section("API Key") {
                SecureField("Paste your parlance API key…", text: $apiKeyInput)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 8) {
                    Button("Save & Connect") {
                        Task { await saveAndConnect() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.parlance.primary)
                    .disabled(apiKeyInput.isEmpty)

                    Button("Test Connection") {
                        Task { await testConnection() }
                    }
                    .disabled(apiKeyInput.isEmpty || isTesting)

                    if isTesting {
                        ProgressView().scaleEffect(0.6)
                    }

                    if appState.isConnected {
                        Button("Disconnect", role: .destructive) {
                            appState.disconnect()
                            apiKeyInput = ""
                            testResult = nil
                        }
                    }
                }

                if let result = testResult {
                    Group {
                        switch result {
                        case .success:
                            Label("Connected successfully", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(Color.parlance.pass)
                        case .failure(let msg):
                            Label(msg, systemImage: "xmark.circle.fill")
                                .foregroundStyle(Color.parlance.fail)
                        }
                    }
                    .font(.caption)
                }
            }

            Section("Project") {
                if appState.projects.isEmpty {
                    Text(appState.isConnected ? "No projects found" : "Connect to load projects")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } else {
                    Picker("Active project", selection: Binding(
                        get: { appState.selectedProject?.id ?? "" },
                        set: { id in
                            if let project = appState.projects.first(where: { $0.id == id }) {
                                appState.selectProject(project)
                            }
                        }
                    )) {
                        Text("— None —").tag("")
                        ForEach(appState.projects) { project in
                            Text(project.name).tag(project.id)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Section("Appearance") {
                Picker("Theme", selection: $appearanceModeRaw) {
                    ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                        Label(mode.label, systemImage: mode.systemImage)
                            .tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image("Parlance_Icon_Dark")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.parlance.primary)
                .frame(width: 52, height: 52)
                .background(
                    Color.parlance.primary.opacity(0.08)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                )

            Image("Parlance_Logo_row")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 22)
                .accessibilityLabel("parlance")

            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("The single source of agreement between design and development.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let url = URL(string: "https://parlancelabs.net") {
                Link("parlancelabs.net", destination: url)
                    .font(.caption)
                    .foregroundStyle(Color.parlance.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func saveAndConnect() async {
        await appState.saveAPIKey(apiKeyInput)
        testResult = appState.isConnected
            ? .success
            : .failure(appState.errorMessage ?? "Connection failed")
    }

    private func testConnection() async {
        isTesting = true
        testResult = nil
        let key = apiKeyInput
        let client = ParlanceClientProvider.make(apiKey: key)
        do {
            _ = try await client.testConnection()
            testResult = .success
        } catch {
            testResult = .failure(error.localizedDescription)
        }
        isTesting = false
    }
}
