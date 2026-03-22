import Foundation

public class SwiftAuditEngine {
    private let rules: [AuditRule] = [
        ImageAccessibilityRule(),
        ColorContrastRule(),
        TouchTargetSizeRule(),
        HeadingStructureRule(),
        FormLabelsRule(),
        KeyboardAccessRule(),
        FocusManagementRule(),
        DynamicTypeRule(),
        ColorOnlyIndicatorsRule(),
        AccessibilityOrderRule()
    ]

    public init() {}

    public func audit(source: String, fileExtension: String = "swift") -> [AuditResult] {
        rules.flatMap { $0.audit(source: source, fileExtension: fileExtension) }
    }

    public func auditWithSummary(source: String, filePath: String, fileExtension: String = "swift") -> AuditSummary {
        let results = audit(source: source, fileExtension: fileExtension)
        return AuditSummary(filePath: filePath, timestamp: Date(), results: results)
    }
}
