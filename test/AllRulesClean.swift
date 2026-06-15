import SwiftUI

// Parlance Xcode-extension test file — CLEAN BASELINE.
//
// The accessible counterpart of AllRulesViolations.swift. Running
// Editor → Parlance → Run Accessibility Audit here should report ZERO findings —
// use it to confirm the audit does not raise false positives.

// FIX image-accessibility (1.1.1): describe the image, or mark it decorative.
struct ImageClean: View {
    var body: some View {
        Image("hero_banner")
            .accessibilityLabel("Team reviewing a design system")
    }
}

// FIX heading-structure (1.3.1): expose the heading trait to assistive tech.
struct HeadingClean: View {
    var body: some View {
        Text("Dashboard")
            .font(.largeTitle)
            .accessibilityAddTraits(.isHeader)
    }
}

// FIX form-labels (1.3.1): each field has an accessibility label.
// FIX focus-management (2.4.7): @FocusState lets keyboard users move between fields.
struct FormClean: View {
    @State private var name = ""
    @State private var password = ""
    @FocusState private var focusedField: Bool
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .accessibilityLabel("Full name")
                .focused($focusedField)
            SecureField("Password", text: $password)
                .accessibilityLabel("Password")
        }
    }
}

// FIX accessibility-order (1.3.2): rely on natural reading order — no custom sort.
struct OrderClean: View {
    var body: some View {
        HStack {
            Text("Reads first")
            Text("Reads second")
        }
    }
}

// FIX color-only-indicators (1.4.1): pair colour with an icon AND text.
struct ColorOnlyClean: View {
    let isError: Bool
    var body: some View {
        HStack {
            Image(systemName: isError ? "xmark.circle" : "checkmark.circle")
            Text(isError ? "Error" : "OK")
        }
        .foregroundColor(isError ? .red : .green)
    }
}

// FIX dynamic-type (1.4.4): semantic text style scales with the user's setting.
struct DynamicTypeClean: View {
    var body: some View {
        Text("Scales with Dynamic Type")
            .font(.body)
    }
}

// FIX keyboard-access (2.1.1): a Button is reachable by keyboard and switch control.
struct KeyboardClean: View {
    var body: some View {
        Button("Tap me") { /* perform action */ }
    }
}

// FIX touch-target-size (2.5.8): at least 44×44pt (minWidth/minHeight is not flagged).
struct TouchTargetClean: View {
    var body: some View {
        Button("×") { /* close */ }
            .frame(minWidth: 44, minHeight: 44)
    }
}

// FIX color-contrast (1.4.3): .primary adapts to the system for sufficient contrast.
struct ContrastClean: View {
    var body: some View {
        Text("Easy to read")
            .foregroundColor(.primary)
    }
}
