import Foundation

public struct DynamicTypeRule: AuditRule {
    public let id = "dynamic-type"
    public let name = "Dynamic Type Support"
    public let wcagCriterion = "1.4.4"
    public let wcagLevel = "AA"

    public init() {}

    public func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.contains(".font(.system(size:") || trimmed.contains(".font(Font.system(size:") {
                results.append(AuditResult(
                    ruleId: id,
                    ruleName: name,
                    severity: .warning,
                    message: "Hardcoded font size does not scale with the user's Dynamic Type setting",
                    line: index + 1,
                    element: "Text",
                    wcagCriterion: wcagCriterion,
                    wcagLevel: wcagLevel,
                    fixSuggestion: "Replace with a semantic text style like .font(.body), .font(.title), or .font(.headline) to respect the user's preferred text size"
                ))
            }

            if trimmed.contains(".minimumScaleFactor(") {
                let factor = extractScaleFactor(from: trimmed)
                if let f = factor, f < 0.8 {
                    results.append(AuditResult(
                        ruleId: id,
                        ruleName: name,
                        severity: .info,
                        message: "minimumScaleFactor(\(f)) allows text to shrink significantly, which may reduce legibility at larger Dynamic Type sizes",
                        line: index + 1,
                        element: "Text",
                        wcagCriterion: wcagCriterion,
                        wcagLevel: wcagLevel,
                        fixSuggestion: "Consider allowing text to wrap with .fixedSize(horizontal: false, vertical: true) instead of scaling down"
                    ))
                }
            }
        }

        return results
    }

    private func extractScaleFactor(from line: String) -> Double? {
        guard let range = line.range(of: #"minimumScaleFactor\((\d+(?:\.\d+)?)\)"#, options: .regularExpression) else { return nil }
        let match = String(line[range])
        let digits = match.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).filter { !$0.isEmpty }
        return digits.first.flatMap { Double($0) }
    }
}
