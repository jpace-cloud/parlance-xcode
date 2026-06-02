import XcodeKit
import ParlanceKit
import ParlanceSDK

class AuditCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let source = invocation.buffer.completeBuffer
        let engine = SwiftAuditEngine()
        let results = engine.audit(source: source, fileExtension: "swift")

        let errorCount = results.filter { $0.severity == .error }.count
        let warningCount = results.filter { $0.severity == .warning }.count

        var lines = ["// ╔══════════════════════════════════════════════════════════════╗\n"]
        lines.append("// ║  PARLANCE ACCESSIBILITY AUDIT                                ║\n")
        lines.append("// ║  \(errorCount) error(s)  ·  \(warningCount) warning(s)  ·  \(results.filter { $0.severity == .info }.count) info\n")
        lines.append("// ╚══════════════════════════════════════════════════════════════╝\n")

        if results.isEmpty {
            lines.append("// ✓ No issues found — great work!\n")
        } else {
            for result in results {
                let lineRef = result.line.map { "Line \($0): " } ?? ""
                let icon: String
                switch result.severity {
                case .error:   icon = "✗"
                case .warning: icon = "⚠"
                case .info:    icon = "ℹ"
                }
                lines.append("// \(icon) [\(result.wcagCriterion)] \(lineRef)\(result.ruleName)\n")
                lines.append("//   \(result.message)\n")
                lines.append("//   Fix: \(result.fixSuggestion)\n")
            }
        }
        lines.append("// ── End of Parlance audit ──────────────────────────────────────\n\n")

        let combined = lines.joined()
        invocation.buffer.lines.insert(combined, at: 0)
        completionHandler(nil)
    }
}

class PushResultsCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let source = invocation.buffer.completeBuffer
        let engine = SwiftAuditEngine()
        let results = engine.audit(source: source, fileExtension: "swift")

        guard let apiKey = KeychainHelper.getAPIKey() else {
            invocation.buffer.lines.insert("// PARLANCE: No API key configured. Open the Parlance menu bar app to set up.\n", at: 0)
            completionHandler(nil)
            return
        }

        let client = ParlanceClientProvider.make(apiKey: apiKey)

        guard let projectId = KeychainHelper.getSelectedProjectId(), !projectId.isEmpty else {
            invocation.buffer.lines.insert("// PARLANCE: No project selected. Open the Parlance menu bar app and choose a project.\n", at: 0)
            completionHandler(nil)
            return
        }

        Task {
            do {
                let items: [ParlanceSDK.AuditResultItem] = results.map { r in
                    ParlanceSDK.AuditResultItem(
                        ruleId: r.ruleId,
                        severity: mapSeverity(r.severity),
                        message: r.message,
                        filePath: "xcode-file"
                    )
                }
                let input = ParlanceSDK.AuditResultInput(results: items)
                let response: ParlanceSDK.AuditResult = try await client.pushAuditResults(
                    projectId: projectId,
                    input: input
                )
                invocation.buffer.lines.insert("// PARLANCE: \(response.inserted) result(s) pushed to dashboard.\n", at: 0)
            } catch {
                invocation.buffer.lines.insert("// PARLANCE: Push failed — \(error.localizedDescription)\n", at: 0)
            }
            completionHandler(nil)
        }
    }

    private func mapSeverity(_ s: Severity) -> ParlanceSDK.AuditSeverity {
        switch s {
        case .error:   return .error
        case .warning: return .warning
        case .info:    return .info
        }
    }
}
