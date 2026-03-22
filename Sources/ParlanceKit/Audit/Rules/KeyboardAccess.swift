import Foundation

struct KeyboardAccessRule: AuditRule {
    let id = "keyboard-access"
    let name = "Keyboard Accessibility"
    let wcagCriterion = "2.1.1"
    let wcagLevel = "A"

    func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            guard trimmed.contains(".onTapGesture") else { continue }

            // Look for accessibilityAction in a nearby window
            let windowStart = max(0, index - 3)
            let windowEnd = min(index + 5, lines.count - 1)
            let window = lines[windowStart...windowEnd].joined(separator: "\n")

            let hasKeyboardEquivalent = window.contains(".accessibilityAction(") ||
                                        window.contains(".onKeyPress(") ||
                                        window.contains("Button(")

            if !hasKeyboardEquivalent {
                results.append(AuditResult(
                    ruleId: id,
                    ruleName: name,
                    severity: .warning,
                    message: ".onTapGesture without a keyboard equivalent — keyboard and switch access users cannot trigger this interaction",
                    line: index + 1,
                    element: "View",
                    wcagCriterion: wcagCriterion,
                    wcagLevel: wcagLevel,
                    fixSuggestion: "Use a Button instead of .onTapGesture, or add .accessibilityAction(named: \"Action name\") { } alongside the gesture"
                ))
            }
        }

        return results
    }
}
