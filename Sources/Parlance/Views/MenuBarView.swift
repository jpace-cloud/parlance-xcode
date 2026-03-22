import SwiftUI
import ParlanceKit

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openSettings) private var openSettings
    @State private var selectedTab: Tab = .contracts
    @State private var glossarySearch = ""
    @State private var selectedContract: Contract? = nil
    @State private var selectedTerm: GlossaryTerm? = nil
    @State private var isPushing = false
    @State private var pushFeedback: PushFeedback? = nil

    enum PushFeedback {
        case success(Int)
        case failure(String)
    }

    enum Tab: String, CaseIterable {
        case contracts = "Contracts"
        case glossary = "Glossary"
        case audit = "Audit"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.3)

            if !appState.isConnected {
                disconnectedView
            } else {
                connectedView
            }
        }
        .frame(width: 320)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(parlancePurple)
                Text("Parlance")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            Spacer()
            Circle()
                .fill(appState.isConnected ? Color.green : Color(NSColor.systemGray))
                .frame(width: 8, height: 8)
            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Disconnected

    private var disconnectedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Not connected")
                .font(.headline)
            Text("Add your Parlance API key in Settings to get started.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Open Settings") {
                openSettings()
            }
            .buttonStyle(ParlanceButtonStyle())
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Connected

    private var connectedView: some View {
        VStack(spacing: 0) {
            // Project name bar
            if let project = appState.selectedProject {
                HStack(spacing: 6) {
                    Circle().fill(Color.green).frame(width: 6, height: 6)
                    Text(project.name)
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
            }

            // Tab bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(tab.rawValue) { selectedTab = tab }
                        .buttonStyle(TabButtonStyle(isSelected: selectedTab == tab))
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            Divider().padding(.top, 6).opacity(0.3)

            // Tab content
            Group {
                switch selectedTab {
                case .contracts: contractsTab
                case .glossary: glossaryTab
                case .audit: auditTab
                }
            }
            .frame(maxHeight: 340)

            Divider().opacity(0.3)
            syncFooter
        }
    }

    // MARK: - Contracts Tab

    private var contractsTab: some View {
        Group {
            if appState.contracts.isEmpty {
                emptyState(icon: "doc.text", message: "No contracts found")
            } else if let contract = selectedContract {
                contractDetail(contract)
            } else {
                contractList
            }
        }
    }

    private var contractList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(appState.contracts) { contract in
                    ContractRow(contract: contract)
                        .onTapGesture { selectedContract = contract }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func contractDetail(_ contract: Contract) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                selectedContract = nil
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .font(.caption)
                    .foregroundStyle(parlancePurple)
            }
            .buttonStyle(.plain)

            Text(contract.name)
                .font(.headline)

            if let desc = contract.description {
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                if let category = contract.category {
                    Badge(text: category, color: .secondary)
                }
                if let status = contract.status {
                    Badge(text: status, color: statusColor(status))
                }
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Glossary Tab

    private var glossaryTab: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary).font(.caption)
                TextField("Search tokens…", text: $glossarySearch)
                    .textFieldStyle(.plain)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
            .padding(8)

            if appState.glossaryTerms.isEmpty {
                emptyState(icon: "textformat.abc", message: "No glossary terms found")
            } else if let term = selectedTerm {
                termDetail(term)
            } else {
                let filtered = glossarySearch.isEmpty
                    ? appState.glossaryTerms
                    : appState.glossaryTerms.filter { $0.name.localizedCaseInsensitiveContains(glossarySearch) }
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(filtered) { term in
                            GlossaryRow(term: term)
                                .onTapGesture { selectedTerm = term }
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
    }

    private func termDetail(_ term: GlossaryTerm) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                selectedTerm = nil
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .font(.caption)
                    .foregroundStyle(parlancePurple)
            }
            .buttonStyle(.plain)

            Text(term.name).font(.headline)
            if let raw = term.rawValue {
                Text(raw).font(.caption.monospaced()).foregroundStyle(.secondary)
            }
            if let translations = term.translations, !translations.isEmpty {
                Text("Translations").font(.caption).fontWeight(.semibold).padding(.top, 4)
                ForEach(Array(translations.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key).font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text(translations[key] ?? "").font(.caption)
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Audit Tab

    private var auditTab: some View {
        VStack(spacing: 12) {
            VStack(spacing: 6) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 24))
                    .foregroundStyle(parlancePurple)
                Text("Audit from Clipboard")
                    .font(.subheadline).fontWeight(.medium)
                Text("Copy Swift source code, then tap Audit.")
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Run Audit on Clipboard") {
                    appState.runAuditOnClipboard()
                }
                .buttonStyle(ParlanceButtonStyle())
            }
            .padding(.top, 16)

            if let summary = appState.latestAuditSummary {
                Divider().opacity(0.3)
                auditResults(summary)
            }

            if let err = appState.errorMessage {
                Text(err).font(.caption).foregroundStyle(.red)
                    .padding(.horizontal, 12)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
    }

    private func auditResults(_ summary: AuditSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Score chips
            HStack {
                scoreChip(label: "Errors", count: summary.errors, color: .red)
                scoreChip(label: "Warnings", count: summary.warnings, color: .orange)
                scoreChip(label: "Score", count: summary.score, color: parlancePurple)
            }

            // Findings list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(summary.results) { result in
                        AuditResultRow(result: result)
                    }
                }
            }
            .frame(maxHeight: 120)

            // Export / Push actions
            HStack(spacing: 6) {
                Button {
                    AuditExporter.exportCSV(summary: summary)
                } label: {
                    Label("CSV", systemImage: "tablecells")
                }
                .buttonStyle(ExportButtonStyle())

                Button {
                    AuditExporter.exportPDF(summary: summary)
                } label: {
                    Label("PDF", systemImage: "doc.richtext")
                }
                .buttonStyle(ExportButtonStyle())

                Spacer()

                Button {
                    Task { await pushResults(summary) }
                } label: {
                    if isPushing {
                        HStack(spacing: 4) {
                            ProgressView().scaleEffect(0.6).frame(width: 10, height: 10)
                            Text("Pushing…")
                        }
                    } else {
                        Label("Push", systemImage: "arrow.up.circle")
                    }
                }
                .buttonStyle(ParlanceButtonStyle(compact: true))
                .disabled(!canPush)
                .help(canPush ? "Push results to Parlance dashboard" : "Connect to Parlance first")
            }
            .font(.caption2)

            // Push feedback — fades out on success after 3 s
            if let feedback = pushFeedback {
                HStack(spacing: 4) {
                    switch feedback {
                    case .success(let count):
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text("\(count) result\(count == 1 ? "" : "s") pushed successfully")
                            .foregroundStyle(.green)
                    case .failure(let msg):
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                        Text(msg).foregroundStyle(.red).lineLimit(2)
                    }
                }
                .font(.caption2)
                .transition(.opacity)
            }
        }
    }

    private var canPush: Bool {
        appState.isConnected && appState.selectedProject != nil && !isPushing
    }

    private func pushResults(_ summary: AuditSummary) async {
        isPushing = true
        defer { isPushing = false }
        pushFeedback = nil
        do {
            let count = try await appState.pushAuditSummary(summary)
            withAnimation { pushFeedback = .success(count) }
            try? await Task.sleep(for: .seconds(3))
            withAnimation {
                if case .success = pushFeedback { pushFeedback = nil }
            }
        } catch {
            withAnimation { pushFeedback = .failure(error.localizedDescription) }
        }
    }

    private func scoreChip(label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)").font(.headline).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }

    // MARK: - Sync Footer

    private var syncFooter: some View {
        HStack {
            if let date = appState.lastSyncDate {
                Text("Synced \(date, style: .relative) ago")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Never synced")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Sync now") {
                Task { await appState.syncData() }
            }
            .font(.caption2)
            .buttonStyle(.plain)
            .foregroundStyle(parlancePurple)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 28)).foregroundStyle(.secondary)
            Text(message).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "agreed": return .green
        case "proposed": return .orange
        case "divergent": return .red
        default: return .secondary
        }
    }
}

// MARK: - Subviews

struct ContractRow: View {
    let contract: Contract

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(contract.name).font(.caption).fontWeight(.medium)
                if let category = contract.category {
                    Text(category).font(.caption2).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let status = contract.status {
                Badge(text: status, color: statusColor(status))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .contentShape(Rectangle())
        .hoverEffect()
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "agreed": return .green
        case "proposed": return .orange
        case "divergent": return .red
        default: return .secondary
        }
    }
}

struct GlossaryRow: View {
    let term: GlossaryTerm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(term.name).font(.caption).fontWeight(.medium)
                if let raw = term.rawValue {
                    Text(raw).font(.caption2.monospaced()).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let category = term.category {
                Badge(text: category, color: .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct AuditResultRow: View {
    let result: AuditResult

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: severityIcon)
                .foregroundStyle(severityColor)
                .font(.caption)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(result.ruleName).font(.caption).fontWeight(.medium)
                    if let line = result.line {
                        Text("L\(line)").font(.caption2.monospaced()).foregroundStyle(.secondary)
                    }
                }
                Text(result.message).font(.caption2).foregroundStyle(.secondary).lineLimit(2)
            }
        }
    }

    private var severityIcon: String {
        switch result.severity {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private var severityColor: Color {
        switch result.severity {
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .cornerRadius(4)
    }
}

// MARK: - Button Styles

struct ParlanceButtonStyle: ButtonStyle {
    var compact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .caption2 : .caption)
            .fontWeight(.medium)
            .padding(.horizontal, compact ? 10 : 14)
            .padding(.vertical, compact ? 5 : 7)
            .background(parlancePurple.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundStyle(.white)
            .cornerRadius(6)
    }
}

struct ExportButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(NSColor.controlBackgroundColor))
            .foregroundStyle(.primary)
            .cornerRadius(5)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct TabButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? parlancePurple.opacity(0.15) : Color.clear)
            .foregroundStyle(isSelected ? parlancePurple : Color.secondary)
            .cornerRadius(5)
    }
}

// MARK: - Hover effect helper

extension View {
    func hoverEffect() -> some View {
        self.onHover { _ in }
    }
}

// MARK: - Shared color

let parlancePurple = Color(red: 0.498, green: 0.467, blue: 0.867)
