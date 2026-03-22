import Foundation

public struct ImageAccessibilityRule: AuditRule {
    public let id = "image-accessibility"
    public let name = "Image Accessibility"
    public let wcagCriterion = "1.1.1"
    public let wcagLevel = "A"

    public init() {}

    public func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.contains("Image(\"") && !trimmed.contains("systemName:") {
                let windowEnd = min(index + 5, lines.count - 1)
                let window = lines[index...windowEnd].joined(separator: "\n")

                let hasLabel = window.contains(".accessibilityLabel(")
                let isHidden = window.contains(".accessibilityHidden(true)") || window.contains("accessibilityHidden(true)")
                let isDecorative = window.contains(".accessibilityElement(children: .ignore)")

                if !hasLabel && !isHidden && !isDecorative {
                    results.append(AuditResult(
                        ruleId: id,
                        ruleName: name,
                        severity: .error,
                        message: "Image view is missing an accessibility label or decorative marker",
                        line: index + 1,
                        element: "Image",
                        wcagCriterion: wcagCriterion,
                        wcagLevel: wcagLevel,
                        fixSuggestion: "Add .accessibilityLabel(\"Describe the image\") or .accessibilityHidden(true) if purely decorative"
                    ))
                }
            }

            if trimmed.contains("UIImageView") && trimmed.contains("=") {
                let windowEnd = min(index + 8, lines.count - 1)
                let window = lines[index...windowEnd].joined(separator: "\n")
                let hasLabel = window.contains(".accessibilityLabel") || window.contains("isAccessibilityElement = false")
                if !hasLabel {
                    results.append(AuditResult(
                        ruleId: id,
                        ruleName: name,
                        severity: .warning,
                        message: "UIImageView may be missing an accessibility label",
                        line: index + 1,
                        element: "UIImageView",
                        wcagCriterion: wcagCriterion,
                        wcagLevel: wcagLevel,
                        fixSuggestion: "Set imageView.accessibilityLabel = \"...\" or imageView.isAccessibilityElement = false if decorative"
                    ))
                }
            }
        }

        return results
    }
}
