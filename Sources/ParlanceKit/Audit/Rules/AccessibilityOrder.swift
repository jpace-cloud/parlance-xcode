import Foundation

public struct AccessibilityOrderRule: AuditRule {
    public let id = "accessibility-order"
    public let name = "Accessibility Order"
    public let wcagCriterion = "1.3.2"
    public let wcagLevel = "A"

    public init() {}

    public func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.contains(".accessibilitySortPriority(") {
                results.append(AuditResult(
                    ruleId: id,
                    ruleName: name,
                    severity: .info,
                    message: "Custom accessibilitySortPriority detected — verify the resulting focus order is logical and matches the visual layout",
                    line: index + 1,
                    element: "View",
                    wcagCriterion: wcagCriterion,
                    wcagLevel: wcagLevel,
                    fixSuggestion: "Test with VoiceOver to confirm the reading order is intuitive. Higher priority values are read first. Remove if the default layout order is already correct."
                ))
            }
        }

        return results
    }
}
