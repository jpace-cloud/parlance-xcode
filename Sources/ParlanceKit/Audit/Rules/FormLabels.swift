import Foundation

struct FormLabelsRule: AuditRule {
    let id = "form-labels"
    let name = "Form Labels"
    let wcagCriterion = "1.3.1"
    let wcagLevel = "A"

    private let inputTypes = ["TextField", "SecureField", "TextEditor"]

    func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            guard let inputType = inputTypes.first(where: { trimmed.contains($0 + "(") }) else { continue }

            // Look in a window around this line for associated label or accessibility label
            let windowStart = max(0, index - 4)
            let windowEnd = min(index + 4, lines.count - 1)
            let window = lines[windowStart...windowEnd].joined(separator: "\n")

            let hasAccessibilityLabel = window.contains(".accessibilityLabel(")
            // Check for a Text() label in same VStack/HStack context (within 4 lines)
            let hasTextLabel = windowStart < index && lines[windowStart..<index].contains { l in
                l.trimmingCharacters(in: .whitespaces).hasPrefix("Text(")
            }
            let hasLabelView = window.contains("Label(")

            if !hasAccessibilityLabel && !hasTextLabel && !hasLabelView {
                results.append(AuditResult(
                    ruleId: id,
                    ruleName: name,
                    severity: .error,
                    message: "\(inputType) appears to have no associated label — placeholder text is not a substitute for a visible or accessibility label",
                    line: index + 1,
                    element: inputType,
                    wcagCriterion: wcagCriterion,
                    wcagLevel: wcagLevel,
                    fixSuggestion: "Add a Text() label before the field or apply .accessibilityLabel(\"Field name\") directly"
                ))
            }
        }

        return results
    }
}
