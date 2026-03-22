import Foundation

public struct TouchTargetSizeRule: AuditRule {
    public let id = "touch-target-size"
    public let name = "Touch Target Size"
    public let wcagCriterion = "2.5.8"
    public let wcagLevel = "AA"

    private let interactiveElements = ["Button", "Link", "NavigationLink", "Toggle"]
    private let minimumSize: Double = 44.0

    public init() {}

    public func audit(source: String, fileExtension: String) -> [AuditResult] {
        var results: [AuditResult] = []
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.contains(".frame(") && (trimmed.contains("width:") || trimmed.contains("height:")) {
                let windowStart = max(0, index - 5)
                let window = lines[windowStart...index].joined(separator: "\n")

                let isInteractive = interactiveElements.contains { window.contains($0) }
                guard isInteractive else { continue }

                if let sizes = extractFrameSizes(from: trimmed) {
                    let (width, height) = sizes
                    var tooSmall = false
                    var dimension = ""

                    if let w = width, w < minimumSize {
                        tooSmall = true
                        dimension = "width (\(Int(w))pt)"
                    }
                    if let h = height, h < minimumSize {
                        tooSmall = true
                        dimension += dimension.isEmpty ? "height (\(Int(h))pt)" : " and height (\(Int(h))pt)"
                    }

                    if tooSmall {
                        results.append(AuditResult(
                            ruleId: id,
                            ruleName: name,
                            severity: .warning,
                            message: "Interactive element \(dimension) is below the 44pt minimum touch target size",
                            line: index + 1,
                            element: "Button",
                            wcagCriterion: wcagCriterion,
                            wcagLevel: wcagLevel,
                            fixSuggestion: "Use .frame(minWidth: 44, minHeight: 44) or .contentShape(Rectangle()) with adequate size"
                        ))
                    }
                }
            }
        }

        return results
    }

    private func extractFrameSizes(from line: String) -> (Double?, Double?)? {
        var width: Double? = nil
        var height: Double? = nil

        if let widthMatch = line.range(of: #"width:\s*(\d+(?:\.\d+)?)"#, options: .regularExpression) {
            let substring = String(line[widthMatch])
            if let numStr = substring.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).filter({ !$0.isEmpty }).first {
                width = Double(numStr)
            }
        }

        if let heightMatch = line.range(of: #"height:\s*(\d+(?:\.\d+)?)"#, options: .regularExpression) {
            let substring = String(line[heightMatch])
            if let numStr = substring.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).filter({ !$0.isEmpty }).first {
                height = Double(numStr)
            }
        }

        guard width != nil || height != nil else { return nil }
        return (width, height)
    }
}
