import SwiftUI

// Parlance Xcode-extension test file — DELIBERATE VIOLATIONS (all 10 rules).
//
// Open this file in Xcode, then run  Editor → Parlance → Run Accessibility Audit.
// Each view below trips exactly ONE rule; the comment names the rule id, the WCAG
// criterion, and the severity you should see. Pair with AllRulesClean.swift to
// confirm the audit does not false-positive.
//
// The rules are line-window heuristics on the source text, so each case is kept
// in its own view to avoid windows bleeding into one another. This file also
// declares no focus-state binding anywhere — that is intentional, so the
// focus-management rule fires on FormViolation below.

// RULE image-accessibility · 1.1.1 A · ERROR — Image with no accessibility label.
struct ImageViolation: View {
    var body: some View {
        Image("hero_banner")
    }
}

// RULE heading-structure · 1.3.1 A · ERROR — heading-style font without .isHeader.
struct HeadingViolation: View {
    var body: some View {
        Text("Dashboard")
            .font(.largeTitle)
    }
}

// RULE form-labels · 1.3.1 A · ERROR (×2) — inputs with only placeholder text.
// Also trips focus-management · 2.4.7 AA — two inputs, no focus-state binding.
struct FormViolation: View {
    @State private var name = ""
    @State private var password = ""
    var body: some View {
        VStack {
            TextField("Name", text: $name)
            SecureField("Password", text: $password)
        }
    }
}

// RULE accessibility-order · 1.3.2 A · WARNING — custom focus order to verify.
struct OrderViolation: View {
    var body: some View {
        HStack {
            Text("Reads first, but second visually")
                .accessibilitySortPriority(1)
            Text("Reads second")
        }
    }
}

// RULE color-only-indicators · 1.4.1 A · ERROR — state shown with colour alone.
struct ColorOnlyViolation: View {
    let isError: Bool
    var body: some View {
        Text("Status")
            .foregroundColor(isError ? .red : .green)
    }
}

// RULE dynamic-type · 1.4.4 AA · WARNING — hardcoded font size won't scale.
struct DynamicTypeViolation: View {
    var body: some View {
        Text("Fixed at 18pt")
            .font(.system(size: 18))
    }
}

// RULE keyboard-access · 2.1.1 A · ERROR — tap gesture, no keyboard equivalent.
struct KeyboardViolation: View {
    var body: some View {
        Text("Tap me")
            .onTapGesture { /* perform action */ }
    }
}

// RULE touch-target-size · 2.5.8 AA · ERROR — interactive control below 44pt.
struct TouchTargetViolation: View {
    var body: some View {
        Button("×") { /* close */ }
            .frame(width: 28, height: 28)
    }
}

// RULE color-contrast · 1.4.3 AA · ERROR — .gray on .white is a known low pair.
struct ContrastViolation: View {
    var body: some View {
        Text("Hard to read")
            .foregroundColor(.gray)
            .background(Color.white)
    }
}
