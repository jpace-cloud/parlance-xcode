import Foundation

public protocol AuditRule {
    var id: String { get }
    var name: String { get }
    var wcagCriterion: String { get }
    var wcagLevel: String { get }
    func audit(source: String, fileExtension: String) -> [AuditResult]
}
