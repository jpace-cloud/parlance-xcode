# Parlance Xcode Integration

A macOS app containing a Source Editor Extension for auditing Swift/SwiftUI accessibility, and a menu bar companion for accessing Parlance contracts and glossary.

## Architecture
- **ParlanceKit**: shared framework (audit engine, API client, models, keychain)
- **Parlance**: SwiftUI menu bar app (no dock icon, lives in menu bar)
- **ParlanceEditor**: Xcode Source Editor Extension (XcodeKit)

## Source layout
```
Sources/
  ParlanceKit/
    Models/         AuditResult, Contract, GlossaryTerm, Project
    API/            ParlanceAPIClient, KeychainHelper
    Audit/          SwiftAuditEngine, AuditRule protocol
    Audit/Rules/    10 rule implementations
  Parlance/
    ParlanceApp.swift, AppState.swift
    Views/          MenuBarView, SettingsView
  ParlanceEditor/
    SourceEditorExtension.swift, SourceEditorCommand.swift
test/               SampleView, BadFormView, GoodView (intentional issues)
```

## Audit rules (10)
1. **Image accessibility** (WCAG 1.1.1-A) — missing accessibilityLabel on Image views
2. **Color contrast** (WCAG 1.4.3-AA) — heuristic check for known low-contrast pairs
3. **Touch target size** (WCAG 2.5.8-AA) — frame dimensions below 44×44
4. **Heading structure** (WCAG 1.3.1-A) — missing accessibilityAddTraits(.isHeader)
5. **Form labels** (WCAG 1.3.1-A) — TextField/SecureField without visible or accessibility labels
6. **Keyboard access** (WCAG 2.1.1-A) — onTapGesture without keyboard equivalent
7. **Focus management** (WCAG 2.4.7-AA) — forms with multiple fields and no @FocusState
8. **Dynamic type** (WCAG 1.4.4-AA) — hardcoded font sizes; minimumScaleFactor below 0.8
9. **Color-only indicators** (WCAG 1.4.1-A) — state changes using only color
10. **Accessibility order** (WCAG 1.3.2-A) — custom accessibilitySortPriority flagged for review

## API
- Base URL: `https://api.parlance.business`
- Auth: `Authorization: Bearer <key>`
- Client header: `X-Parlance-Client: xcode-extension/{version}`
- API key stored in macOS Keychain (service: `business.parlance.xcode`)
- Never store key in UserDefaults or plain text

## App group
`group.business.parlance` — shared between Parlance.app and ParlanceEditor extension for selected project ID.

## Build
1. Install XcodeGen: `brew install xcodegen`
2. Generate project: `xcodegen generate` in the repo root
3. Open `Parlance.xcodeproj` in Xcode 15+
4. Select "Parlance" scheme, "My Mac" destination
5. Cmd+R to build and run
6. Enable extension: System Settings → Privacy & Security → Extensions → Xcode Source Editor

## Test files
Open `test/*.swift` in Xcode, then Editor → Parlance → Run Accessibility Audit.
- `SampleView.swift` — mix of issues and correct patterns
- `BadFormView.swift` — multiple form accessibility failures
- `GoodView.swift` — fully accessible reference implementation

## Style
- Purple accent: `Color(red: 0.498, green: 0.467, blue: 0.867)` (#7F77DD)
- No third-party dependencies — only Apple frameworks
- Dark and light mode supported via system colors
