import SwiftUI
import ParlanceKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var apiKeyInput: String = ""
    @State private var isTesting: Bool = false
    @State private var testResult: TestResult? = nil

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
                SecureField("Paste your Parlance API key…", text: $apiKeyInput)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 8) {
                    Button("Save & Connect") {
                        Task { await saveAndConnect() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(parlancePurple)
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
                                .foregroundStyle(.green)
                        case .failure(let msg):
                            Label(msg, systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
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
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image("Parlance_Icon_Dark")
                .resizable()
                .frame(width: 64, height: 64)
                .cornerRadius(14)

            Text("Parlance")
                .font(.system(size: 17, weight: .bold))

            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("The single source of agreement between design and development.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let url = URL(string: "https://parlance.business") {
                Link("parlance.business", destination: url)
                    .font(.caption)
                    .foregroundStyle(parlancePurple)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func saveAndConnect() async {
        await appState.saveAPIKey(apiKeyInput)
        testResult = appState.isConnected ? .success : .failure(appState.errorMessage ?? "Connection failed")
    }

    private func testConnection() async {
        isTesting = true
        testResult = nil
        let key = apiKeyInput
        let client = ParlanceAPIClient(apiKey: key)
        do {
            _ = try await client.testConnection()
            testResult = .success
        } catch {
            testResult = .failure(error.localizedDescription)
        }
        isTesting = false
    }
}
