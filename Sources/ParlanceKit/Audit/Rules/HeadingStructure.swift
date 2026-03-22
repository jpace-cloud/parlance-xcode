import Foundation

struct HeadingStructureRule: AuditRule {
    let id = "heading-structure"
    let name = "Heading Structure"
    let wcagCriterion = "1.3.1"
    let wcagLevel = "A"

    // Font styles that typically indicate headings
    private let headingFontStyles = [
        ".largeTitle", ".title", ".title2", ".title3",
        "size: 2", "size: 3",  // catches hardcoded sizes >= 20
        ".bold", ".heavy", ".semibold"
    ]

    func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Look for Text views that appear to be headings
            guard trimmed.hasPrefix("Text(") || trimmed.contains(" Text(") else { continue }

            let windowEnd = min(index + 4, lines.count - 1)
            let window = lines[index...windowEnd].joined(separator: "\n")

            // Check if the text uses heading-like styling
            let looksLikeHeading = headingFontStyles.contains { window.contains($0) }
            guard looksLikeHeading else { continue }

            // Check if heading trait is applied
            let hasHeadingTrait = window.contains(".isHeader") || window.contains("accessibilityAddTraits(.isHeader)")
            if !hasHeadingTrait {
                // Extract potential heading size for context
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
