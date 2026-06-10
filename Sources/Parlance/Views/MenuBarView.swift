import SwiftUI
import ParlanceKit
import ParlanceSDK

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openSettings) private var openSettings
    @State private var selectedTab: Tab = .contracts
    @State private var glossarySearch = ""
    @State private var selectedContract: ContractSummary? = nil
    @State private var selectedTerm: GlossaryTerm? = nil
    enum Tab: String, CaseIterable {
        case contracts = "Contracts"
        case glossary = "Glossary"
        case audit = "Audit"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.15)

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
                Image("Parlance_Icon_Dark")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.parlance.primary)
                    .frame(width: 16, height: 16)
                Text("parlance")
                    .font(.system(size: 13, weight: .semibold))
            }
            Spacer()
            Circle()
                .fill(appState.isConnected ? Color.parlance.pass : Color(NSColor.systemGray))
                .frame(width: 7, height: 7)
            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Disconnected

    private var disconnectedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 28))
                .foregroundStyle(.tertiary)
            Text("Not connected")
                .font(.system(size: 13, weight: .semibold))
            Text("Add your parlance API key in Settings to get started.")
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
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.parlance.pass)
                        .frame(width: 5, height: 5)
                    Text(project.name)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
            }

            // Tab bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(tab.rawValue) { selectedTab = tab }
                        .buttonStyle(TabButtonStyle(isSelected: selectedTab == tab))
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)

            Divider().padding(.top, 6).opacity(0.15)

            // Tab content
            Group {
                switch selectedTab {
                case .contracts: contractsTab
                case .glossary: glossaryTab
                case .audit: auditTab
                }
            }
            .frame(maxHeight: 340)

            Divider().opacity(0.15)
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
            LazyVStack(spacing: 0) {
                ForEach(appState.contracts) { contract in
                    ContractRow(contract: contract)
                        .onTapGesture { selectedContract = contract }
                    Divider().opacity(0.1)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func contractDetail(_ contract: ContractSummary) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                selectedContract = nil
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .font(.caption)
                    .foregroundStyle(Color.parlance.primary)
            }
            .buttonStyle(.plain)

            Text(contract.name)
                .font(.system(size: 13, weight: .semibold))

            if let desc = contract.description {
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                if let category = contract.category {
                    ParlanceBadge(text: category.rawValue, color: .secondary)
                }
                ParlanceBadge(
                    text: contract.status.rawValue,
                    color: contractStatusColor(contract.status.rawValue)
                )
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Glossary Tab

    private var glossaryTab: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
                TextField("Search tokens…", text: $glossarySearch)
                    .textFieldStyle(.plain)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 4)

            if appState.glossaryTerms.isEmpty {
                emptyState(icon: "textformat.abc", message: "No glossary terms found")
            } else if let term = selectedTerm {
                termDetail(term)
            } else {
                let filtered = glossarySearch.isEmpty
                    ? appState.glossaryTerms
                    : appState.glossaryTerms.filter { $0.name.localizedCaseInsensitiveContains(glossarySearch) }
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered) { term in
                            GlossaryRow(term: term)
                                .onTapGesture { selectedTerm = term }
                            Divider().opacity(0.1)
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
                    .foregroundStyle(Color.parlance.primary)
            }
            .buttonStyle(.plain)

            Text(term.name)
                .font(.system(size: 13, weight: .semibold))

            if !term.rawValue.isEmpty {
                Text(term.rawValue)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            if !term.translations.isEmpty {
                Text("Translations")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                ForEach(Array(term.translations.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key).font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text(term.translations[key] ?? "").font(.caption.monospaced())
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
                    .foregroundStyle(Color.parlance.primary)
                Text("Audit from Clipboard")
                    .font(.system(size: 12, weight: .semibold))
                Text("Copy Swift source code, then tap Audit.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Run Audit on Clipboard") {
                    appState.runAuditOnClipboard()
                }
                .buttonStyle(ParlanceButtonStyle())
            }
            .padding(.top, 16)

            if let summary = appState.latestAuditSummary {
                Divider().opacity(0.15)
                auditResults(summary)
            }

            if let err = appState.errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(Color.parlance.fail)
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
            HStack(spacing: 6) {
                scoreChip(label: "Errors",   count: summary.errors,   color: .parlance.fail)
                scoreChip(label: "Warnings", count: summary.warnings, color: .parlance.warning)
                scoreChip(label: "Score",    count: summary.score,    color: .parlance.primary)
            }

            // Findings list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
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
                } label: {
                    Label("Push", systemImage: "arrow.up.circle")
                }
                .buttonStyle(ParlanceButtonStyle(compact: true))
                .disabled(true)
                .opacity(0.4)
                .help("Push to dashboard — coming in v0.2")
            }
            .font(.caption2)
        }
    }

    private func scoreChip(label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    // MARK: - Sync Footer

    private var syncFooter: some View {
        HStack {
            if let date = appState.lastSyncDate {
                Text("Synced \(date, style: .relative) ago")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                Text("Never synced")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Button("Sync now") {
                Task { await appState.syncData() }
            }
            .font(.caption2)
            .buttonStyle(.plain)
            .foregroundStyle(Color.parlance.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundStyle(.tertiary)
            Text(message)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func contractStatusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active":     return .parlance.pass
        case "draft":      return .parlance.warning
        case "deprecated": return .parlance.fail
        case "proposed":   return .parlance.pending
        default:           return .secondary
        }
    }
}

// MARK: - Subviews

struct ContractRow: View {
    let contract: ContractSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(contract.name)
                    .font(.caption)
                    .fontWeight(.medium)
                if let category = contract.category {
                    Text(category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            ParlanceBadge(
                text: contract.status.rawValue,
                color: contractStatusColor(contract.status.rawValue)
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .contentShape(Rectangle())
    }

    private func contractStatusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active":     return .parlance.pass
        case "draft":      return .parlance.warning
        case "deprecated": return .parlance.fail
        case "proposed":   return .parlance.pending
        default:           return .secondary
        }
    }
}

struct GlossaryRow: View {
    let term: GlossaryTerm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(term.name)
                    .font(.caption)
                    .fontWeight(.medium)
                if !term.rawValue.isEmpty {
                    Text(term.rawValue)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if !term.category.isEmpty {
                ParlanceBadge(text: term.category, color: .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct AuditResultRow: View {
    let result: ParlanceKit.AuditResult

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: severityIcon)
                .foregroundStyle(severityColor)
                .font(.caption)
                .frame(width: 12)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(result.ruleName)
                        .font(.caption)
                        .fontWeight(.medium)
                    if let line = result.line {
                        Text("L\(line)")
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
                Text(result.message)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }

    private var severityIcon: String {
        switch result.severity {
        case .error:   return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info:    return "info.circle.fill"
        }
    }

    private var severityColor: Color {
        switch result.severity {
        case .error:   return .parlance.fail
        case .warning: return .parlance.warning
        case .info:    return .parlance.pending
        }
    }
}

// MARK: - Badge

struct ParlanceBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
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
            .background(
                Color.parlance.primary
                    .opacity(configuration.isPressed ? 0.75 : 1)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
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
            .background(
                isSelected
                    ? Color.parlance.primary.opacity(0.12)
                    : Color.clear
            )
            .foregroundStyle(
                isSelected ? Color.parlance.primary : Color.secondary
            )
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
