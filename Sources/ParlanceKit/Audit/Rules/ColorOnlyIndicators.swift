import Foundation

struct ColorOnlyIndicatorsRule: AuditRule {
    let id = "color-only-indicators"
    let name = "Color-Only Indicators"
    let wcagCriterion = "1.4.1"
    let wcagLevel = "A"

    func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Detect ternary color expressions: someCondition ? .red : .green (color-only state)
            let colorTernaryPattern = #"\?\s*\.?(red|green|blue|orange|yellow|pink|purple|Color\.red|Color\.green)\s*:\s*\.?(red|green|blue|orange|yellow|pink|purple|Color\.red|Color\.green)"#
            if trimmed.range(of: colorTernaryPattern, options: .regularExpression) != nil {
                // Check if there's an accompanying text or image indicator in a nearby window
                let windowStart = max(0, index - 3)
                let windowEnd = min(index + 3, lines.count - 1)
                let window = lines[windowStart...windowEnd].joined(separator: "\n")

                let hasTextIndicator = window.contains("Text(") && !window.contains("foregroundColor") && !window.contains("foregroundStyle")
                let hasImageIndicator = window.contains("Image(systemName:")

                // Only flag if the color change appears isolated (no accompanying text/icon nearby)
                if !hasTextIndicator && !hasImageIndicator {
                    results.append(AuditResult(
                        ruleId: id,
                        ruleName: name,
                        severity: .warning,
                        message: "State or status appears to be communicated using color alone",
                        line: index + 1,
                        element: "View",
                        wcagCriterion: wcagCriterion,
                        wcagLevel: wcagLevel,
                        fixSuggestion: "Add a text label or icon alongside the color change. Example: HStack { Image(systemName: isError ? \"xmark.circle\" : \"checkmark.circle\"); Text(isError ? \"Error\" : \"OK\") }"
                    ))
                }
            }

            // Detect Circle/Rectangle/Capsule filled with conditional color (status indicators)
            if (trimmed.contains("Circle()") || trimmed.contains("Rectangle()")) &&
               trimmed.contains(".fill(") {
                let fillLine = trimmed
                let colorTernary = fillLine.range(of: #"\?\s*(Color\.|\.)[a-z]+"#, options: .regularExpression) != nil
                if colorTernary {
                    let windowStart = max(0, index - 2)
                    let windowEnd = min(index + 4, lines.count - 1)
                    let window = lines[windowStart...windowEnd].joined(separator: "\n")
                    let hasTextNearby = window.components(separatedBy: "\n")
                        .filter { $0.trimmingCharacters(in: .whitespaces).hasPrefix("Text(") }
                        .count > 0

                    if !hasTextNearby {
                        results.append(AuditResult(
                            ruleId: id,
                            ruleName: name,
                            severity: .warning,
                            message: "Shape filled with conditional color may convey state using color alone",
                            line: index + 1,
                            element: "Shape",
                            wcagCriterion: wcagCriterion,
                            wcagLevel: wcagLevel,
                            fixSuggestion: "Pair this color indicator with a text label or icon to convey meaning without relying on color"
                        ))
                    }
                }
            }
        }

        return results
    }
}
