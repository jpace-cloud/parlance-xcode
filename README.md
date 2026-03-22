# Parlance for Xcode

Accessibility audit and design contract tooling for Swift/SwiftUI developers. Runs inside Xcode as a Source Editor Extension and in the menu bar as a companion app.

## What it does

- **Audit command** — runs 10 WCAG accessibility checks directly on your Swift source file and inserts findings as inline comments
- **Push command** — audits and sends results to your Parlance dashboard for team visibility
- **Menu bar app** — browse your project's design contracts and glossary, run audits from clipboard

## Requirements

- macOS 13.0+
- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) to generate the `.xcodeproj`

## Installation

```bash
# 1. Clone the repo
git clone https://github.com/jpace-cloud/parlance-xcode.git
cd parlance-xcode

# 2. Generate the Xcode project
brew install xcodegen   # skip if already installed
xcodegen generate

# 3. Open in Xcode
open Parlance.xcodeproj
```

Build and run the **Parlance** scheme with **My Mac** as the destination.

### Enable the Source Editor Extension

1. Build and run the app — a shield icon appears in your menu bar
2. Open **System Settings → Privacy & Security → Extensions → Xcode Source Editor**
3. Enable **Parlance Editor**
4. Restart Xcode

The commands appear in Xcode under **Editor → Parlance**.

## Connecting your API key

1. Click the shield icon in the menu bar
2. Click the gear icon → **Settings**
3. Paste your Parlance API key and click **Save & Connect**
4. Select your project from the dropdown

Your API key is stored securely in the macOS Keychain — never in plain text or UserDefaults.

## Source Editor Commands

Open any `.swift` file in Xcode, then go to **Editor → Parlance**:

| Command | What it does |
|---|---|
| **Run Accessibility Audit** | Inserts a comment block at the top of the file with all findings |
| **Audit and Push to Parlance** | Same as above, then uploads results to your project dashboard |

Both commands work fully offline — audit rules run locally on the source text with no network requirement.

## Menu Bar App

Click the **checkmark.shield** icon in the menu bar:

- **Contracts** — browse your project's design contracts with category and status badges (Agreed / Proposed / Divergent)
- **Glossary** — searchable list of design tokens with raw values and framework translations
- **Audit** — copy Swift source code to clipboard, then tap "Run Audit on Clipboard" to see results inline

Data refreshes automatically every 5 minutes when connected. Use "Sync now" to refresh immediately.

## Audit Rules

| # | Rule | WCAG | Level |
|---|---|---|---|
| 1 | Image Accessibility | 1.1.1 | A |
| 2 | Color Contrast | 1.4.3 | AA |
| 3 | Touch Target Size | 2.5.8 | AA |
| 4 | Heading Structure | 1.3.1 | A |
| 5 | Form Labels | 1.3.1 | A |
| 6 | Keyboard Access | 2.1.1 | A |
| 7 | Focus Management | 2.4.7 | AA |
| 8 | Dynamic Type | 1.4.4 | AA |
| 9 | Color-Only Indicators | 1.4.1 | A |
| 10 | Accessibility Order | 1.3.2 | A |

### Rule details

1. **Image Accessibility** — Flags `Image("…")` views missing `.accessibilityLabel()`, `.accessibilityHidden(true)`, or `.accessibilityElement(children: .ignore)`.

2. **Color Contrast** — Heuristic check for known low-contrast foreground/background pairs (e.g. `.gray` text on `.white` background). Static analysis cannot compute exact ratios — use Xcode's Accessibility Inspector for precise measurement.

3. **Touch Target Size** — Warns when `.frame(width:height:)` on a Button, Link, NavigationLink, or Toggle is below the 44pt minimum.

4. **Heading Structure** — Warns when a `Text` view using `.largeTitle`, `.title`, or similar styles lacks `.accessibilityAddTraits(.isHeader)`.

5. **Form Labels** — Errors when a `TextField`, `SecureField`, or `TextEditor` has no `Text()` label in the same container and no `.accessibilityLabel()`. Placeholder text is not a substitute.

6. **Keyboard Access** — Warns when `.onTapGesture` is used without a matching `.accessibilityAction()` or `Button` — keyboard and switch access users cannot trigger the interaction.

7. **Focus Management** — Warns when a view with two or more input fields has no `@FocusState` — keyboard users cannot tab between fields.

8. **Dynamic Type** — Warns on `.font(.system(size:))` (hardcoded sizes don't scale). Info-level flag on `.minimumScaleFactor()` below 0.8.

9. **Color-Only Indicators** — Warns when ternary color expressions or conditional shape fills appear to convey state without an accompanying text or icon.

10. **Accessibility Order** — Info-level flag on `.accessibilitySortPriority()` for manual VoiceOver order review.

## Test Files

Three sample views in `test/` demonstrate issues and correct patterns:

- `test/SampleView.swift` — mixed: some issues, some correct patterns
- `test/BadFormView.swift` — intentionally broken form with multiple failures
- `test/GoodView.swift` — fully accessible reference implementation

Open any of these in Xcode and run **Editor → Parlance → Run Accessibility Audit** to see the output.

## Project Structure

```
Sources/
  ParlanceKit/          Shared framework (imported by both targets)
    Models/             AuditResult, Contract, GlossaryTerm, Project
    API/                ParlanceAPIClient, KeychainHelper
    Audit/              SwiftAuditEngine, AuditRule protocol
    Audit/Rules/        10 rule files
  Parlance/             Menu bar app
    ParlanceApp.swift
    AppState.swift
    Views/              MenuBarView, SettingsView
  ParlanceEditor/       Xcode Source Editor Extension
    SourceEditorExtension.swift
    SourceEditorCommand.swift
test/                   Sample Swift files for testing
project.yml             XcodeGen configuration
```

## License

MIT
