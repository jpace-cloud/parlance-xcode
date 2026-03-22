import Foundation

public struct ColorContrastRule: AuditRule {
    public let id = "color-contrast"
    public let name = "Color Contrast"
    public let wcagCriterion = "1.4.3"
    public let wcagLevel = "AA"

    private let lowContrastPairs: [(String, String)] = [
        (".gray", ".white"),
        (".gray", ".background"),
        (".secondary", ".white"),
        (".tertiary", ".white"),
        ("Color.gray", "Color.white"),
        (".lightGray", ".white"),
        (".yellow", ".white"),
        (".white", ".yellow"),
    ]

    public init() {}

    public func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.contains(".foregroundColor(") || trimmed.contains(".foregroundStyle(") {
                let windowStart = max(0, index - 3)
                let windowEnd = min(index + 3, lines.count - 1)
                let window = lines[windowStart...windowEnd].joined(separator: "\n")

                for (fg, bg) in lowContrastPairs {
                    if window.contains(fg) && window.contains(".background(") {
                        if window.contains(bg) || window.contains("Color.white") || window.contains(".white)") {
                            results.append(AuditResult(
                                ruleId: id,
                                ruleName: name,
                                severity: .warning,
                                message: "Potential low-contrast color combination detected (\(fg) on \(bg)). Verify contrast ratio meets 4.5:1 for normal text or 3:1 for large text.",
                                line: index + 1,
                                element: "Text",
                                wcagCriterion: wcagCriterion,
                                wcagLevel: wcagLevel,
                                fixSuggestion: "Use Color.primary or higher-contrast colors. Check with Xcode Accessibility Inspector or a contrast checker tool."
                            ))
                            break
                        }
                    }
                }
            }
        }

        return results
    }
}
