import XCTest
@testable import ParlanceKit

/// Tests for the scoring model in `Sources/ParlanceKit/Models/AuditResult.swift`.
///
/// `AuditSummary` derives `errors`, `warnings`, `passed` and `score` from a
/// flat list of `AuditResult`. The score is:
///
///     passed = max(0, 10 - errors - warnings)
///     score  = round(passed / (errors + warnings + passed) * 100)
///
/// with a special case of 100 when the denominator is zero.
final class AuditSummaryTests: XCTestCase {

    /// Builds an `AuditResult` of a given severity. Only `severity` matters to
    /// the scoring maths, but the other fields are populated realistically.
    private func makeResult(_ severity: Severity, ruleId: String = "test-rule") -> AuditResult {
        AuditResult(
            ruleId: ruleId,
            ruleName: "Test Rule",
            severity: severity,
            message: "test",
            wcagCriterion: "1.1.1",
            wcagLevel: "A",
            fixSuggestion: "fix it"
        )
    }

    private func summary(_ results: [AuditResult]) -> AuditSummary {
        AuditSummary(filePath: "Demo.swift", timestamp: Date(), results: results)
    }

    func testScore_noViolations_isPerfect() {
        let summary = summary([])
        XCTAssertEqual(summary.errors, 0)
        XCTAssertEqual(summary.warnings, 0)
        XCTAssertEqual(summary.passed, 10)
        XCTAssertEqual(summary.score, 100)
    }

    func testScore_oneErrorOneWarning() {
        let summary = summary([makeResult(.error), makeResult(.warning)])
        XCTAssertEqual(summary.errors, 1)
        XCTAssertEqual(summary.warnings, 1)
        // passed = 10 - 2 = 8; total = 1 + 1 + 8 = 10; score = 80.
        XCTAssertEqual(summary.passed, 8)
        XCTAssertEqual(summary.score, 80)
    }

    func testScore_twoErrorsOneWarning() {
        let summary = summary([makeResult(.error), makeResult(.error), makeResult(.warning)])
        XCTAssertEqual(summary.errors, 2)
        XCTAssertEqual(summary.warnings, 1)
        // passed = 10 - 3 = 7; total = 10; score = 70.
        XCTAssertEqual(summary.passed, 7)
        XCTAssertEqual(summary.score, 70)
    }

    func testScore_infoSeverityDoesNotReduceScore() {
        // Info results are advisory: they are neither errors nor warnings and
        // must not pull the score below 100 on their own.
        let summary = summary([makeResult(.info), makeResult(.info)])
        XCTAssertEqual(summary.errors, 0)
        XCTAssertEqual(summary.warnings, 0)
        XCTAssertEqual(summary.passed, 10)
        XCTAssertEqual(summary.score, 100)
    }

    func testScore_floorsAtZeroWhenOverwhelmed() {
        // 12 violations exceed the 10 notional checks; passed clamps to 0.
        let results = Array(repeating: makeResult(.error), count: 6)
            + Array(repeating: makeResult(.warning), count: 6)
        let summary = summary(results)
        XCTAssertEqual(summary.errors, 6)
        XCTAssertEqual(summary.warnings, 6)
        XCTAssertEqual(summary.passed, 0, "passed must not go negative")
        // total = 6 + 6 + 0 = 12; score = 0/12 = 0.
        XCTAssertEqual(summary.score, 0)
    }

    func testScore_decreasesMonotonicallyWithMoreViolations() {
        let clean = summary([]).score
        let oneWarning = summary([makeResult(.warning)]).score
        let oneError = summary([makeResult(.error)]).score
        // A single warning and a single error both deduct one "passed" check.
        XCTAssertGreaterThan(clean, oneWarning)
        XCTAssertEqual(oneWarning, oneError, "errors and warnings weigh equally in the score")
        XCTAssertEqual(oneWarning, 90, "9 passed / 10 total = 90")
    }
}
