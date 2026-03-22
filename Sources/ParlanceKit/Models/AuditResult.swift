import Foundation

public enum Severity: String, Codable {
    case error, warning, info
}

public struct AuditResult: Codable, Identifiable {
    public let id: UUID
    public let ruleId: String
    public let ruleName: String
    public let severity: Severity
    public let message: String
    public let line: Int?
    public let column: Int?
    public let element: String?
    public let wcagCriterion: String
    public let wcagLevel: String
    public let fixSuggestion: String

    public init(ruleId: String, ruleName: String, severity: Severity, message: String, line: Int? = nil, column: Int? = nil, element: String? = nil, wcagCriterion: String, wcagLevel: String, fixSuggestion: String) {
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

public struct AuditSummary: Codable {
    public let filePath: String
    public let timestamp: Date
    public let results: [AuditResult]

    public init(filePath: String, timestamp: Date, results: [AuditResult]) {
        self.filePath = filePath
        self.timestamp = timestamp
        self.results = results
    }

    public var errors: Int { results.filter { $0.severity == .error }.count }
    public var warnings: Int { results.filter { $0.severity == .warning }.count }
    public var passed: Int { max(0, 10 - errors - warnings) }
    public var score: Int {
        let total = errors + warnings + passed
        guard total > 0 else { return 100 }
        return Int((Double(passed) / Double(total)) * 100)
    }
}
