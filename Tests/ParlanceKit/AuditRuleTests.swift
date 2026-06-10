import XCTest
@testable import ParlanceKit

/// Tests for the ten individual audit rules in
/// `Sources/ParlanceKit/Audit/Rules/`.
///
/// Each rule is a pure function `audit(source:fileExtension:) -> [AuditResult]`.
/// For every rule we assert two things:
///   * a known-BAD SwiftUI snippet triggers exactly the expected violation(s)
///     (count + severity + ruleId + message substring), and
///   * a clean snippet produces zero results.
///
/// Source strings use British English in any prose; the engine itself only
/// matches SwiftUI API tokens, which are fixed by Apple.
final class AuditRuleTests: XCTestCase {

    // MARK: - Helpers

    /// Asserts a single result with the expected severity, ruleId and a
    /// message substring. Returns the matched result for further assertions.
    @discardableResult
    private func assertSingle(
        _ results: [AuditResult],
        ruleId: String,
        severity: Severity,
        messageContains: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> AuditResult? {
        XCTAssertEqual(results.count, 1, "expected exactly one result", file: file, line: line)
        guard let result = results.first else { return nil }
        XCTAssertEqual(result.ruleId, ruleId, "ruleId mismatch", file: file, line: line)
        XCTAssertEqual(result.severity, severity, "severity mismatch", file: file, line: line)
        XCTAssertTrue(
            result.message.contains(messageContains),
            "message did not contain \"\(messageContains)\" — was: \(result.message)",
            file: file,
            line: line
        )
        return result
    }

    // MARK: - ColorContrastRule

    func testColorContrast_grayOnWhite_warns() {
        let source = """
        Text("Subtitle")
            .foregroundColor(.gray)
            .background(Color.white)
        """
        let results = ColorContrastRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "color-contrast",
            severity: .warning,
            messageContains: "low-contrast"
        )
        XCTAssertEqual(result?.wcagCriterion, "1.4.3")
        XCTAssertEqual(result?.wcagLevel, "AA")
        XCTAssertEqual(result?.element, "Text")
    }

    /// Regression: `.foregroundColor(.primary)` on a white background is maximum
    /// contrast and must NOT warn. The rule previously fired on any `Color.white`
    /// in the window regardless of the foreground colour; fixed by requiring the
    /// pair's actual background token (see ColorContrast.swift).
    func testColorContrast_primaryColor_passes() {
        let source = """
        Text("Subtitle")
            .foregroundColor(.primary)
            .background(Color.white)
        """
        let results = ColorContrastRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "primary on white is high contrast and must not warn")
    }

    func testColorContrast_foregroundWithoutBackground_passes() {
        // No `.background(` in the window → rule cannot judge contrast.
        let source = """
        Text("Subtitle")
            .foregroundColor(.gray)
        """
        let results = ColorContrastRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - TouchTargetSizeRule

    func testTouchTarget_tinyButton_warnsWithDimensions() {
        let source = """
        Button("Submit") {
            print("tapped")
        }
        .frame(width: 30, height: 20)
        """
        let results = TouchTargetSizeRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "touch-target-size",
            severity: .warning,
            messageContains: "44pt minimum"
        )
        // The exact failing dimensions must be surfaced to the developer.
        XCTAssertTrue(result?.message.contains("30pt") ?? false, "expected width 30pt in message")
        XCTAssertTrue(result?.message.contains("20pt") ?? false, "expected height 20pt in message")
        XCTAssertEqual(result?.wcagCriterion, "2.5.8")
    }

    func testTouchTarget_adequateButton_passes() {
        let source = """
        Button("Submit") {
            print("tapped")
        }
        .frame(width: 44, height: 44)
        """
        let results = TouchTargetSizeRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "44x44 meets the minimum and must not warn")
    }

    func testTouchTarget_nonInteractiveFrame_passes() {
        // A small frame on a non-interactive view must not warn.
        let source = """
        Rectangle()
            .frame(width: 10, height: 10)
        """
        let results = TouchTargetSizeRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - DynamicTypeRule

    func testDynamicType_hardcodedFontSize_warns() {
        let source = """
        Text("Welcome")
            .font(.system(size: 28))
        """
        let results = DynamicTypeRule().audit(source: source, fileExtension: "swift")
        assertSingle(
            results,
            ruleId: "dynamic-type",
            severity: .warning,
            messageContains: "Hardcoded font size"
        )
    }

    func testDynamicType_lowMinimumScaleFactor_isInfo() {
        let source = """
        Text("Welcome")
            .minimumScaleFactor(0.5)
        """
        let results = DynamicTypeRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "dynamic-type",
            severity: .info,
            messageContains: "minimumScaleFactor"
        )
        XCTAssertEqual(result?.wcagCriterion, "1.4.4")
    }

    func testDynamicType_semanticFont_passes() {
        let source = """
        Text("Welcome")
            .font(.body)
        """
        let results = DynamicTypeRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "a semantic text style scales correctly and must not warn")
    }

    func testDynamicType_highMinimumScaleFactor_passes() {
        // 0.9 >= 0.8 threshold → no info result.
        let source = """
        Text("Welcome")
            .minimumScaleFactor(0.9)
        """
        let results = DynamicTypeRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - FormLabelsRule

    func testFormLabels_unlabelledTextField_isError() {
        let source = """
        VStack {
            TextField("Enter your email", text: .constant(""))
                .padding()
        }
        """
        let results = FormLabelsRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "form-labels",
            severity: .error,
            messageContains: "no associated label"
        )
        XCTAssertEqual(result?.element, "TextField")
        XCTAssertEqual(result?.wcagCriterion, "1.3.1")
        XCTAssertEqual(result?.wcagLevel, "A")
    }

    func testFormLabels_withAccessibilityLabel_passes() {
        let source = """
        TextField("Email", text: .constant(""))
            .accessibilityLabel("Email address")
        """
        let results = FormLabelsRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "an explicit accessibilityLabel satisfies the rule")
    }

    func testFormLabels_withPrecedingTextLabel_passes() {
        let source = """
        Text("Email")
        TextField("you@example.com", text: .constant(""))
        """
        let results = FormLabelsRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "a preceding Text label satisfies the rule")
    }

    // MARK: - ImageAccessibilityRule

    func testImageAccessibility_bareImage_isError() {
        let source = """
        Image("logo")
            .resizable()
            .frame(width: 100, height: 100)
        """
        let results = ImageAccessibilityRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "image-accessibility",
            severity: .error,
            messageContains: "missing an accessibility label"
        )
        XCTAssertEqual(result?.element, "Image")
        XCTAssertEqual(result?.wcagCriterion, "1.1.1")
    }

    func testImageAccessibility_hidden_passes() {
        let source = """
        Image("logo")
            .accessibilityHidden(true)
        """
        let results = ImageAccessibilityRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "a decorative image marked hidden is acceptable")
    }

    func testImageAccessibility_systemImage_passes() {
        // SF Symbols (systemName:) are excluded from this rule.
        let source = """
        Image(systemName: "checkmark.circle")
        """
        let results = ImageAccessibilityRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - KeyboardAccessRule

    func testKeyboardAccess_bareTapGesture_warns() {
        let source = """
        Text("Open terms")
            .onTapGesture {
                openTerms()
            }
        """
        let results = KeyboardAccessRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "keyboard-access",
            severity: .warning,
            messageContains: "keyboard equivalent"
        )
        XCTAssertEqual(result?.wcagCriterion, "2.1.1")
    }

    func testKeyboardAccess_tapGestureWithAccessibilityAction_passes() {
        let source = """
        Text("Open terms")
            .onTapGesture { openTerms() }
            .accessibilityAction(named: "Open terms") { openTerms() }
        """
        let results = KeyboardAccessRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "an accessibilityAction provides the keyboard path")
    }

    func testKeyboardAccess_tapGestureNearButton_passes() {
        // A Button in the window is treated as a keyboard-accessible alternative.
        let source = """
        Button("Primary") { submit() }
        Text("Secondary")
            .onTapGesture { submit() }
        """
        let results = KeyboardAccessRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - HeadingStructureRule

    func testHeadingStructure_titleWithoutHeaderTrait_warns() {
        let source = """
        Text("Section title")
            .font(.title)
        """
        let results = HeadingStructureRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "heading-structure",
            severity: .warning,
            messageContains: ".isHeader"
        )
        XCTAssertEqual(result?.wcagCriterion, "1.3.1")
    }

    func testHeadingStructure_titleWithHeaderTrait_passes() {
        let source = """
        Text("Section title")
            .font(.title)
            .accessibilityAddTraits(.isHeader)
        """
        let results = HeadingStructureRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "the .isHeader trait satisfies the rule")
    }

    func testHeadingStructure_bodyText_passes() {
        let source = """
        Text("Just a paragraph of body copy")
            .font(.body)
        """
        let results = HeadingStructureRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "body text is not a heading")
    }

    // MARK: - ColorOnlyIndicatorsRule

    func testColorOnly_colourTernaryWithoutTextOrIcon_warns() {
        // A status conveyed purely by a colour ternary, with no Text/Image nearby.
        let source = """
        let statusColour = isError ? .red : .green
        Rectangle()
            .fill(statusColour)
        """
        let results = ColorOnlyIndicatorsRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "color-only-indicators",
            severity: .warning,
            messageContains: "color alone"
        )
        XCTAssertEqual(result?.wcagCriterion, "1.4.1")
    }

    func testColorOnly_withAccompanyingText_passes() {
        // The same ternary, but paired with a Text label → acceptable.
        let source = """
        HStack {
            let statusColour = isError ? .red : .green
            Circle().fill(statusColour)
            Text(isError ? "Error" : "OK")
        }
        """
        let results = ColorOnlyIndicatorsRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "an accompanying Text label avoids colour-only signalling")
    }

    // MARK: - FocusManagementRule

    func testFocusManagement_twoFieldsNoFocusState_warns() {
        let source = """
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
        }
        """
        let results = FocusManagementRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "focus-management",
            severity: .warning,
            messageContains: "@FocusState"
        )
        XCTAssertTrue(result?.message.contains("2 input fields") ?? false,
                      "the field count should be reported")
        XCTAssertEqual(result?.wcagCriterion, "2.4.7")
    }

    func testFocusManagement_withFocusState_passes() {
        let source = """
        @FocusState private var focused: Field?
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
        }
        """
        let results = FocusManagementRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0, "@FocusState present → no warning")
    }

    func testFocusManagement_singleField_passes() {
        // Fewer than two fields → rule does not apply.
        let source = """
        VStack {
            TextField("Search", text: $query)
        }
        """
        let results = FocusManagementRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - AccessibilityOrderRule

    func testAccessibilityOrder_sortPriority_isInfo() {
        let source = """
        Text("Read me first")
            .accessibilitySortPriority(10)
        """
        let results = AccessibilityOrderRule().audit(source: source, fileExtension: "swift")
        let result = assertSingle(
            results,
            ruleId: "accessibility-order",
            severity: .info,
            messageContains: "accessibilitySortPriority"
        )
        XCTAssertEqual(result?.wcagCriterion, "1.3.2")
    }

    func testAccessibilityOrder_noSortPriority_passes() {
        let source = """
        Text("Default order")
            .font(.body)
        """
        let results = AccessibilityOrderRule().audit(source: source, fileExtension: "swift")
        XCTAssertEqual(results.count, 0)
    }
}
