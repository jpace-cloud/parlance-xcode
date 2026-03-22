import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return [
            [
                .classNameKey: "ParlanceEditor.AuditCommand",
                .identifierKey: "business.parlance.xcode.audit",
                .nameKey: "Run Accessibility Audit"
            ],
            [
                .classNameKey: "ParlanceEditor.PushResultsCommand",
                .identifierKey: "business.parlance.xcode.push",
                .nameKey: "Audit and Push to Parlance"
            ]
        ]
    }
}
