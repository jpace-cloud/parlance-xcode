import XCTest
@testable import ParlanceKit

/// Tests for `SwiftAuditEngine` in `Sources/ParlanceKit/Audit/SwiftAuditEngine.swift`.
///
/// The engine simply fans a source string out across all ten rules and
/// flattens the results. These tests verify that aggregation is complete
/// (nothing is dropped or duplicated relative to running the rules directly),
/// that a realistic non-compliant view surfaces the expected rule ids, and
/// that a fully compliant view produces a perfect score.
final class SwiftAuditEngineTests: XCTestCase {

    /// A SwiftUI view that deliberately violates several rules at once, spaced
    /// so each rule's line window stays independent.
    private let badSource = """
    Image("logo")

    Text("Welcome back")
        .font(.system(size: 28))

    Button("Submit") { submit() }
        .frame(width: 30, height: 20)

    Text("Open the terms of service")
        .onTapGesture { openTerms() }

    Text("Reorder me")
        .accessibilitySortPriority(5)
    """

    /// A fully compliant SwiftUI view — every interactive element is labelled,
    /// sized and keyboard-reachable, images carry alt text or are hidden.
    private let cleanSource = """
    VStack {
        Text("Search products")
            .font(.title)
            .accessibilityAddTraits(.isHeader)

        Image("decorative-divider")
            .accessibilityHidden(true)

        Button(action: { add() }) {
            Text("Add to cart")
        }
        .frame(minWidth: 44, minHeight: 44)

        Text("Body copy that uses a semantic style")
            .font(.body)
    }
    """

    func testEngine_aggregatesAllRulesWithoutLoss() {
        let engine = SwiftAuditEngine()
        let aggregated = engine.audit(source: badSource)

        // Independently run each rule and concatenate. The engine result must
        // be exactly this set — proving it neither drops nor duplicates rules.
        let rules: [AuditRule] = [
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
        let expected = rules.flatMap { $0.audit(source: badSource, fileExtension: "swift") }

        XCTAssertEqual(aggregated.count, expected.count,
                       "engine result count must equal the sum of all rules")

        // Compare as a multiset of (ruleId, message) — order-independent.
        let key: (AuditResult) -> String = { "\($0.ruleId)|\($0.message)" }
        XCTAssertEqual(
            aggregated.map(key).sorted(),
            expected.map(key).sorted(),
            "engine must surface exactly the union of every rule's findings"
        )
    }

    func testEngine_surfacesExpectedRuleIdsForBadSource() {
        let engine = SwiftAuditEngine()
        let ids = Set(engine.audit(source: badSource).map(\.ruleId))

        // These specific violations are present in `badSource`.
        for expected in ["image-accessibility", "dynamic-type", "touch-target-size",
                         "keyboard-access", "accessibility-order"] {
            XCTAssertTrue(ids.contains(expected), "expected \(expected) in \(ids)")
        }
    }

    func testEngine_cleanSourceHasNoFindings() {
        let engine = SwiftAuditEngine()
        let results = engine.audit(source: cleanSource)
        XCTAssertEqual(results.count, 0,
                       "a compliant view must produce no findings, got: \(results.map(\.ruleId))")
    }

    func testEngine_cleanSourceScoresPerfect() {
        let engine = SwiftAuditEngine()
        let summary = engine.auditWithSummary(source: cleanSource, filePath: "Clean.swift")
        XCTAssertEqual(summary.results.count, 0, "a compliant view must produce no findings")
        XCTAssertEqual(summary.errors, 0)
        XCTAssertEqual(summary.warnings, 0)
        XCTAssertEqual(summary.score, 100)
        XCTAssertEqual(summary.filePath, "Clean.swift")
    }

    func testEngine_summaryReflectsAggregatedSeverities() {
        let engine = SwiftAuditEngine()
        let summary = engine.auditWithSummary(source: badSource, filePath: "Bad.swift")
        // The bad source contains at least one error (image) and several
        // warnings, so the score must be well below perfect.
        XCTAssertGreaterThan(summary.errors, 0)
        XCTAssertGreaterThan(summary.warnings, 0)
        XCTAssertLessThan(summary.score, 100)
        XCTAssertEqual(summary.results.count, engine.audit(source: badSource).count)
    }
}
