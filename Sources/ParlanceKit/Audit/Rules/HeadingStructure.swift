import Foundation

public struct HeadingStructureRule: AuditRule {
    public let id = "heading-structure"
    public let name = "Heading Structure"
    public let wcagCriterion = "1.3.1"
    public let wcagLevel = "A"

    private let headingFontStyles = [
        ".largeTitle", ".title", ".title2", ".title3",
        "size: 2", "size: 3",
        ".bold", ".heavy", ".semibold"
    ]

    public init() {}

    public func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            guard trimmed.hasPrefix("Text(") || trimmed.contains(" Text(") else { continue }

            let windowEnd = min(index + 4, lines.count - 1)
            let window = lines[index...windowEnd].joined(separator: "\n")

            let looksLikeHeading = headingFontStyles.contains { window.contains($0) }
            guard looksLikeHeading else { continue }

            let hasHeadingTrait = window.contains(".isHeader") || window.contains("accessibilityAddTraits(.isHeader)")
            if !hasHeadingTrait {
                let hasLargeFont = [".largeTitle", ".title", ".title2", ".title3"].contains { window.contains($0) }
                if hasLargeFont {
                    results.append(AuditResult(
                        ruleId: id,
                        ruleName: name,
                        severity: .warning,
                        message: "Text with heading-style font is missing the .isHeader accessibility trait",
                        line: index + 1,
                        element: "Text",
                        wcagCriterion: wcagCriterion,
                        wcagLevel: wcagLevel,
                        fixSuggestion: "Add .accessibilityAddTraits(.isHeader) to convey heading semantics to assistive technologies"
                    ))
                }
            }
        }

        return results
    }
}
