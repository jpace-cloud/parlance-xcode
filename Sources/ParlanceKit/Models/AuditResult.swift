import Foundation

enum Severity: String, Codable {
    case error, warning, info
}

struct AuditResult: Codable, Identifiable {
    let id: UUID
    let ruleId: String
    let ruleName: String
    let severity: Severity
    let message: String
    let line: Int?
    let column: Int?
    let element: String?
    let wcagCriterion: String
    let wcagLevel: String
    let fixSuggestion: String

    init(ruleId: String, ruleName: String, severity: Severity, message: String, line: Int? = nil, column: Int? = nil, element: String? = nil, wcagCriterion: String, wcagLevel: String, fixSuggestion: String) {
        self.id = UUID()
        self.ruleId = ruleId
        self.ruleName = ruleName
        self.severity = severity
        self.message = message
        self.line = line
        self.column = column
        self.element = element
        self.wcagCriterion = wcagCriterion
        self.wcagLevel = wcagLevel
        self.fixSuggestion = fixSuggestion
    }
}

struct AuditSummary: Codable {
    let filePath: String
    let timestamp: Date
    let results: [AuditResult]

    var errors: Int { results.filter { $0.severity == .error }.count }
    var warnings: Int { results.filter { $0.severity == .warning }.count }
    var passed: Int { max(0, 10 - errors - warnings) }
    var score: Int {
        let total = errors + warnings + passed
        guard total > 0 else { return 100 }
        return Int((Double(passed) / Double(total)) * 100)
    }
}
