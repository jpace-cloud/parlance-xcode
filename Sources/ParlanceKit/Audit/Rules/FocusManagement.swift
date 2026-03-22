import Foundation

public struct FocusManagementRule: AuditRule {
    public let id = "focus-management"
    public let name = "Focus Management"
    public let wcagCriterion = "2.4.7"
    public let wcagLevel = "AA"

    public init() {}

    public func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        let inputFields = ["TextField", "SecureField"]
        var inputCount = 0
        var firstInputLine = 0

        for (index, line) in lines.enumerated() {
            if inputFields.contains(where: { line.contains($0 + "(") }) {
                inputCount += 1
                if inputCount == 1 { firstInputLine = index + 1 }
            }
        }

        guard inputCount >= 2 else { return results }

        let hasFocusState = source.contains("@FocusState") || source.contains("@FocusedValue")
        if !hasFocusState {
            results.append(AuditResult(
                ruleId: id,
                ruleName: name,
                severity: .warning,
                message: "Form with \(inputCount) input fields has no @FocusState — keyboard users cannot navigate between fields",
                line: firstInputLine,
                element: "Form",
                wcagCriterion: wcagCriterion,
                wcagLevel: wcagLevel,
                fixSuggestion: "Declare @FocusState var focusedField: Field? and use .focused($focusedField, equals: .fieldName) on each input. Submit action on the last field should advance focus or dismiss the keyboard."
            ))
        }

        return results
    }
}
