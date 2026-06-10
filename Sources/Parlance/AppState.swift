import Foundation
import SwiftUI
import ParlanceKit
import ParlanceSDK

@MainActor
class AppState: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedProject: Project? = nil
    @Published var projects: [Project] = []
    @Published var contracts: [ContractSummary] = []
    @Published var glossaryTerms: [GlossaryTerm] = []
    @Published var lastSyncDate: Date? = nil
    @Published var latestAuditSummary: AuditSummary? = nil

    private var refreshTimer: Timer?
    private var client: ParlanceClient? = nil

    var apiKey: String? {
        get { KeychainHelper.getAPIKey() }
    }

    init() {
        if let key = KeychainHelper.getAPIKey(), !key.isEmpty {
            client = ParlanceClientProvider.make(apiKey: key)
            Task { await connect() }
        }
        startAutoRefresh()
    }

    func connect() async {
        guard let key = KeychainHelper.getAPIKey(), !key.isEmpty else {
            isConnected = false
            return
        }
        isLoading = true
        errorMessage = nil
        let c = ParlanceClientProvider.make(apiKey: key)
        do {
            _ = try await c.testConnection()
            client = c
            isConnected = true
            await loadProjects()
        } catch {
            isConnected = false
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func disconnect() {
        try? KeychainHelper.deleteAPIKey()
        client = nil
        isConnected = false
        selectedProject = nil
        projects = []
        contracts = []
        glossaryTerms = []
    }

    func saveAPIKey(_ key: String) async {
        try? KeychainHelper.saveAPIKey(key)
        await connect()
    }

    func selectProject(_ project: Project) {
        selectedProject = project
        KeychainHelper.saveSelectedProjectId(project.id)
        Task { await syncData() }
    }

    func syncData() async {
        guard let project = selectedProject else { return }
        await refreshContracts(projectId: project.id)
        await refreshGlossary(projectId: project.id)
        lastSyncDate = Date()
    }

    func loadProjects() async {
        guard let client else { return }
        do {
            let fetched = try await client.listProjects()
            projects = fetched
            // Restore previously selected project from Keychain
            if let savedId = KeychainHelper.getSelectedProjectId(),
               let match = fetched.first(where: { $0.id == savedId }) {
                selectedProject = match
                await syncData()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshContracts(projectId: String? = nil) async {
        let id = projectId ?? selectedProject?.id
        guard let id, let client else { return }
        do {
            contracts = try await client.getContracts(projectId: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshGlossary(projectId: String? = nil) async {
        let id = projectId ?? selectedProject?.id
        guard let id, let client else { return }
        do {
            glossaryTerms = try await client.getGlossary(projectId: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Maps local AuditResult findings → SDK AuditResultInput, then returns the inserted count.
    func pushAuditSummary(_ summary: AuditSummary) async throws -> Int {
        guard let client else { throw ParlanceError.unauthorized }
        guard let project = selectedProject else { throw ParlanceError.api(status: 0, message: "No project selected") }

        let items: [ParlanceSDK.AuditResultItem] = summary.results.map { r in
            ParlanceSDK.AuditResultItem(
                ruleId: r.ruleId,
                severity: mapSeverity(r.severity),
                message: r.message,
                filePath: summary.filePath
            )
        }
        let input = ParlanceSDK.AuditResultInput(results: items)
        let response: ParlanceSDK.AuditResult = try await client.pushAuditResults(
            projectId: project.id,
            input: input
        )
        return response.inserted
    }

    func runAuditOnClipboard() {
        guard let text = NSPasteboard.general.string(forType: .string) else {
            errorMessage = "No text in clipboard. Copy Swift source code first."
            return
        }
        let engine = SwiftAuditEngine()
        let summary = engine.auditWithSummary(source: text, filePath: "clipboard")
        latestAuditSummary = summary
    }

    // MARK: - Private helpers

    private func mapSeverity(_ s: Severity) -> ParlanceSDK.AuditSeverity {
        switch s {
        case .error:   return .error
        case .warning: return .warning
        case .info:    return .info
        }
    }

    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                guard self.isConnected else { return }
                await self.syncData()
            }
        }
    }
}
