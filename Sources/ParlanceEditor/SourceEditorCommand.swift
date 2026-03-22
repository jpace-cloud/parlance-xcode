import XcodeKit
import ParlanceKit

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

        let client = ParlanceAPIClient(apiKey: apiKey)

        guard let projectId = KeychainHelper.getSelectedProjectId(), !projectId.isEmpty else {
            invocation.buffer.lines.insert("// PARLANCE: No project selected. Open the Parlance menu bar app and choose a project.\n", at: 0)
            completionHandler(nil)
            return
        }

        Task {
            do {
                let count = try await client.pushAuditResults(projectId: projectId, results: results, filePath: "xcode-file")
                invocation.buffer.lines.insert("// PARLANCE: \(count) result(s) pushed to dashboard.\n", at: 0)
            } catch {
                invocation.buffer.lines.insert("// PARLANCE: Push failed — \(error.localizedDescription)\n", at: 0)
            }
            completionHandler(nil)
        }
    }
}
