# parlance for Xcode — Mac App Store submission

Copy-paste-ready submission pack for **parlance for Xcode**: a macOS app that ships an
**Xcode Source Editor Extension**, bringing parlance accessibility and UI-contract
checks directly into Xcode's editor.

All user-facing copy uses British English, the brand name lowercase (**parlance**),
no emoji. Apple character limits are respected and annotated inline.

> Source of truth checked: `project.yml`, `Parlance.xcodeproj/project.pbxproj`,
> the three `Info.plist` files, both `.entitlements` files, the asset catalogue,
> and the extension/SDK source (data flow). Where the generated project differs
> from `project.yml`, the **generated `project.pbxproj` and `Info.plist` win** —
> they are what Xcode archives. Discrepancies are called out in section 8.

---

## 1. Product summary

parlance for Xcode is a single macOS app submission made of three build targets:

| Target | Type | Bundle identifier | Role |
|---|---|---|---|
| **Parlance** | macOS application (container) | `business.parlance.xcode` | Menu-bar companion app (`LSUIElement` — no Dock icon). Holds the API key, picks the active project, browses contracts and glossary, runs audits from the clipboard, exports CSV/PDF. **Hosts the extension.** |
| **ParlanceEditor** | Xcode Source Editor Extension (`.appex`) | `business.parlance.xcode.editor` | Adds source-editor commands under Xcode's **Editor → parlance** menu. Runs the accessibility audit on the active editor buffer. |
| **ParlanceKit** | Embedded framework | `business.parlance.xcode.kit` | Shared audit engine (10 local WCAG rules), Keychain helper, and the parlance API client factory. Embedded in both the app and the extension. |

A unit-test bundle `business.parlance.xcode.kit.tests` also exists; it is **not** shipped.

**What the extension does.** With a `.swift` file open in Xcode, the developer opens
**Editor → parlance** and runs one of two commands:

| Command | Menu name | Identifier | Behaviour |
|---|---|---|---|
| Audit | **Run Accessibility Audit** | `business.parlance.xcode.audit` | Runs 10 accessibility rules locally on the editor buffer and inserts a findings comment block at the top of the file. **No network.** |
| Audit + push | **Audit and Push to parlance** | `business.parlance.xcode.push` | Runs the same local audit, then uploads the findings (not the source) to the developer's parlance project dashboard over HTTPS, using the API key stored in the Keychain. |

**Versioning (as configured today):**

- Marketing version (`CFBundleShortVersionString`): **1.0**
- Build (`CFBundleVersion`): **1**
- All three targets carry the same 1.0 / 1 in their `Info.plist`.
- Deployment target: **macOS 14.0** (note: the README says macOS 13.0; the project files require **14.0** — see section 8).

> For a first submission, set the marketing version to **1.0.0** and build to **1**
> across all targets so App Store Connect and the binary agree (section 9).

---

## 2. Mac App Store metadata

Paste each field into App Store Connect → your app → the macOS version page.
Character counts include spaces. British English throughout.

### App Name  — limit 30
```
parlance for Xcode
```
**18 / 30 characters.**

> If `parlance for Xcode` is unavailable as a unique name, fallbacks:
> `parlance — Xcode audits` (23) or `parlance: a11y for Xcode` (24).

### Subtitle  — limit 30
```
Accessibility audits in Xcode
```
**29 / 30 characters.**

### Promotional Text  — limit 170
```
Audit Swift and SwiftUI for WCAG 2.2 accessibility without leaving Xcode. Insert findings inline, then push them to your parlance project for the whole team to see.
```
**164 / 170 characters.** (Editable any time without a new build.)

### Description  — limit 4000
```
parlance for Xcode brings accessibility and design-contract checks straight into your editor. It adds commands to Xcode's Editor menu that audit the Swift or SwiftUI file you are working on against WCAG 2.2 success criteria — and a menu-bar companion app for working with your parlance projects.

The audit runs entirely on your Mac. It reads the source in the active editor, applies ten accessibility rules, and inserts a clear findings report as a comment block at the top of the file. You see exactly what to fix, where, and which WCAG criterion it maps to. No source code leaves your machine for this command.

WHAT IT CHECKS
• Image accessibility — images missing an accessibility label (WCAG 1.1.1, A)
• Colour contrast — known low-contrast foreground and background pairs (1.4.3, AA)
• Touch target size — interactive frames below 44 by 44 points (2.5.8, AA)
• Heading structure — title text not marked as a header (1.3.1, A)
• Form labels — text fields without a visible or accessibility label (1.3.1, A)
• Keyboard access — tap gestures with no keyboard equivalent (2.1.1, A)
• Focus management — multi-field forms with no focus state (2.4.7, AA)
• Dynamic Type — hardcoded font sizes that do not scale (1.4.4, AA)
• Colour-only indicators — state shown with colour alone (1.4.1, A)
• Accessibility order — custom VoiceOver ordering flagged for review (1.3.2, A)

HOW TO USE IT
1. Install the app from the Mac App Store and open it once. A shield icon appears in your menu bar.
2. Open System Settings, then Login Items & Extensions, then Xcode Source Editor, and turn on parlance.
3. Quit and reopen Xcode so it loads the extension.
4. Open any Swift file and choose Editor, then parlance, then Run Accessibility Audit.

The commands available under Editor, then parlance:
• Run Accessibility Audit — runs the ten checks locally and inserts the findings inline. Works offline.
• Audit and Push to parlance — runs the same audit, then sends the findings to your parlance project dashboard so your team can track them.

THE MENU-BAR COMPANION
Click the shield icon in the menu bar to:
• Browse your project's design contracts with category and status badges.
• Search your glossary of design tokens and their framework translations.
• Run an audit on Swift code from the clipboard and export the result as CSV or PDF.

CONNECTING YOUR ACCOUNT
The push command and the companion app need a parlance account and an API key. Open the companion app's settings, paste your key, and choose your project. Your key is stored in the macOS Keychain — never in plain text. You can use the local audit command without an account.

parlance is the single source of agreement between design and development. Learn more at parlancelabs.net.
```
**Well within 4000 characters** (approx. 2,250). Adjust freely; keep the enablement
steps and the "audit runs locally" line — both reduce review friction and support load.

### Keywords  — limit 100 (comma-separated, no spaces after commas)
```
accessibility,a11y,wcag,xcode,swiftui,swift,audit,contrast,voiceover,linter,design,tokens,inclusive
```
**99 / 100 characters.** Do not repeat the app name or subtitle words here — Apple
already indexes those. Avoid trademarks other than your own.

### Primary category
**Developer Tools**

### Secondary category (optional)
**Productivity**

### What's New in This Version  — limit 4000
```
First release of parlance for Xcode.

• Run Accessibility Audit — ten WCAG 2.2 checks on the active Swift file, inserted inline. Works offline.
• Audit and Push to parlance — send findings to your project dashboard for the team.
• Menu-bar companion — browse contracts, search your glossary, audit from the clipboard, export to CSV or PDF.
```

### Support URL  (required)
```
https://parlancelabs.net
```
> Provide a page that actually answers "how do I enable the extension". A dedicated
> `https://parlancelabs.net/support` or `/docs/xcode` is ideal.

### Marketing URL  (optional)
```
https://parlancelabs.net
```

### Copyright
```
2026 parlance
```
> The `Info.plist` currently reads `Copyright © 2024 Parlance. All rights reserved.`
> Update it to the current year and lowercase brand before archiving (section 8).
> App Store Connect's Copyright field takes the year + holder only (no "©").

### Privacy Policy URL  (required)
```
https://parlancelabs.net/legal/privacy
```

### Age rating
**4+** (no objectionable content).

---

## 3. App Privacy (App Store Connect → App Privacy)

Answers below are derived from the **actual data flow** in the code, not assumptions.

### Data flow facts
- **The accessibility audit runs locally.** `SwiftAuditEngine` applies pure-function
  rules to the buffer text. The **Run Accessibility Audit** command performs **no
  network request** and transmits nothing.
- **Audit and Push to parlance** is the only path from the extension that sends data.
  It uploads the *derived findings* only: each item is `{ ruleId, severity, message,
  filePath }`, where `message` is a generic rule description (e.g. "Image view missing
  accessibility label") and `filePath` is the **literal string `"xcode-file"`** — the
  real file name and path are **not** sent. **Your source code is not transmitted.**
- The upload goes over **HTTPS** to the parlance REST API
  (`https://api.parlance.business`; live host `https://parlance-api.vercel.app`,
  base path `/api/v1`), authenticated with the user's **API key** as
  `Authorization: Bearer …`, plus an `X-Parlance-Client: xcode-extension/<version>`
  header.
- The **companion app** additionally *reads* the user's projects, contracts, and
  glossary from the same API (account data the user already owns).
- The **API key** and the **selected project id** are stored in the **macOS Keychain**
  (service `business.parlance.xcode`). They are never written to UserDefaults or disk
  in plain text.
- **No analytics, no advertising, no third-party SDKs.** No tracking of any kind.

### "Do you or your third-party partners collect data from this app?"
**Yes** — because the push command and the companion app send data to parlance's own
server. (If you prefer to answer **No**, you would have to argue the data never leaves
the user's control; given it is uploaded to a hosted dashboard, answer **Yes** and
declare the categories below. This is the safe, accurate choice.)

### Data types to declare

| Apple data type | Collected? | Linked to identity? | Used for tracking? | Purpose | Notes |
|---|---|---|---|---|---|
| **Other User Content** (audit findings) | Yes | Yes | **No** | App Functionality | Findings pushed to the user's project dashboard. Source code is not included. |
| **User ID** (API key / account) | Yes | Yes | **No** | App Functionality, Authentication | API key authenticates the user to their parlance account. |
| **Other Data** (project identifier) | Yes | Yes | **No** | App Functionality | Identifies which project to attach findings to. |

> "Linked to identity" = **Yes** because the data is associated with the user's parlance
> account via their API key. "Used to track you" = **No** for every type (no cross-app
> or cross-company tracking, no data brokers, no advertising identifiers).

### Tracking
**This app does not track users.** (No App Tracking Transparency prompt is required.)

### Data NOT collected (explicitly)
Contact info, health, financial info, location, browsing history, search history,
contacts, diagnostics, usage data, advertising data — **none collected.**

### Privacy Policy URL
```
https://parlancelabs.net/legal/privacy
```

> Confirm the published privacy policy mentions: audit findings and account
> identifiers sent to parlance for the push/companion features; storage of the API key
> in the Keychain; and that source code is not transmitted. Reviewers cross-check this.

---

## 4. App Review information

### Notes for the Reviewer (paste verbatim, then fill the bracketed parts)

```
OVERVIEW
parlance for Xcode is a macOS app that ships an Xcode Source Editor Extension. The
extension adds accessibility-audit commands to Xcode's Editor menu. A menu-bar
companion app manages the API key and project selection.

The "Run Accessibility Audit" command works fully offline and is the core feature.
You can review the app without any account or network access using that command.

ENABLING THE EXTENSION (required to see the commands)
1. Launch "Parlance" from /Applications. It runs in the menu bar (no Dock icon) — look
   for the shield icon in the top-right menu bar.
2. Open System Settings > Login Items & Extensions. Scroll to "Xcode Source Editor".
   (On macOS 13 this lived under System Settings > Privacy & Security > Extensions >
   Xcode Source Editor.)
3. Enable "Parlance".
4. IMPORTANT: Quit and relaunch Xcode. Xcode only loads source-editor extensions at
   launch, so the menu items will not appear until Xcode is restarted.

EXERCISING THE OFFLINE COMMAND (no account needed)
5. In Xcode, open any .swift file. A simple SwiftUI view with an Image and a TextField
   works well; you may use the sample files in the project's /test folder
   (SampleView.swift, BadFormView.swift, GoodView.swift).
6. Choose Editor > parlance > Run Accessibility Audit.
7. A comment block listing the accessibility findings is inserted at the top of the
   file. This confirms the extension is working. No network is used.

EXERCISING THE PUSH COMMAND (needs an account — optional)
8. Click the menu-bar shield icon, open Settings, and paste the API key:
       DEMO_API_KEY
   (Replace with a real working key before submitting — see below.)
9. Choose a project from the Project picker.
10. Back in Xcode, choose Editor > parlance > Audit and Push to parlance. The findings
    are uploaded to the parlance dashboard and a confirmation comment is inserted.
    Only the findings are sent; the source code is not transmitted.

DEMO ACCOUNT
A working demo API key is required for the reviewer to test the push command and the
companion app. Provide it in the "Sign-in required" / demo-account fields:
   API key: [PASTE REAL DEMO KEY — do not ship the placeholder DEMO_API_KEY]
   Project: [a demo project will be visible in the picker once the key is entered]
There is no username/password; authentication is via the API key entered in Settings.

SANDBOX & NETWORK
The app and the extension run under the App Sandbox (required for the Mac App Store).
Outgoing network access (com.apple.security.network.client) is used solely to reach the
parlance REST API over HTTPS for the push and companion features. All connections are
HTTPS; the app uses no non-exempt encryption.

CONTACT
[Reviewer contact name]
[support@parlancelabs.net or your real address]
[phone number]
```

### Sign-in information
- **Sign-in required:** Yes (for the push command and companion app only; the core
  audit command needs no sign-in).
- **User name:** n/a (API-key auth)
- **Password:** n/a
- **Demo key:** paste a **real, working** API key. **Do not submit `DEMO_API_KEY`** —
  it is a placeholder and will fail review.

### Contact information
- First/Last name: **[account owner]**
- Phone: **[reviewer phone]**
- Email: **[support@parlancelabs.net]**

---

## 5. Build & signing

### Identifiers and versions

| Item | Value |
|---|---|
| Container app bundle id | `business.parlance.xcode` |
| Extension (`.appex`) bundle id | `business.parlance.xcode.editor` |
| Embedded framework bundle id | `business.parlance.xcode.kit` |
| Marketing version | `1.0` → set to **`1.0.0`** for first submission |
| Build number | `1` |
| Deployment target | macOS **14.0** |
| Swift | 5.9 |
| Category | Developer Tools |

> The extension id is the app id with the `.editor` suffix, which satisfies Apple's
> rule that an app-extension identifier begins with its container app's identifier.

### Entitlements — container app (`Sources/Parlance/Parlance.entitlements`)
```xml
<key>com.apple.security.app-sandbox</key>            <true/>   <!-- REQUIRED for Mac App Store -->
<key>com.apple.security.network.client</key>         <true/>   <!-- outgoing HTTPS to the parlance API -->
<key>com.apple.security.files.user-selected.read-write</key> <true/>   <!-- CSV/PDF export via NSSavePanel -->
```

### Entitlements — extension (`Sources/ParlanceEditor/ParlanceEditor.entitlements`)
```xml
<key>com.apple.security.app-sandbox</key>            <true/>   <!-- REQUIRED -->
<key>com.apple.security.network.client</key>         <true/>   <!-- push command HTTPS upload -->
```

Both files are correct for the Mac App Store: **App Sandbox is on** for the app and the
extension, and **network.client** is present where outbound HTTPS is needed. The app's
`files.user-selected.read-write` is justified by the Save panel used for CSV/PDF export.

> **Keychain sharing caveat (verify before upload).** The extension reads the API key
> and selected-project id from the Keychain (service `business.parlance.xcode`) that the
> container app writes. Under the App Sandbox, a container app and its `.appex` share a
> Keychain item **only when they share a Keychain access group** (same team id prefix +
> a `keychain-access-groups` entitlement, or by relying on the default
> `$(AppIdentifierPrefix)<bundle-id>` group). Because both targets are signed by the same
> team and the extension's id is prefixed by the app's id, the **default application
> Keychain group is shared** and the current code should work. **Do confirm on a real
> signed build** that **Audit and Push to parlance** finds the key after it is saved in
> the companion app — if it cannot, add an explicit shared
> `keychain-access-groups` entitlement (`$(AppIdentifierPrefix)business.parlance.xcode`)
> to both targets. (CLAUDE.md/README mention an app group `group.business.parlance`, but
> no `com.apple.security.application-groups` entitlement exists and the code does not use
> one — the sharing mechanism in code is the Keychain, not an app group.)

### Hardened Runtime
- **Not currently set in the project** (`ENABLE_HARDENED_RUNTIME` is absent from
  `project.pbxproj`).
- Mac App Store distribution does **not** require the Hardened Runtime (it is required
  for Developer-ID/notarised distribution). Enabling it is harmless and recommended for
  parity. **Action:** in Xcode, target **Parlance** and **ParlanceEditor** →
  Signing & Capabilities → add **Hardened Runtime**, or set
  `ENABLE_HARDENED_RUNTIME = YES` (and re-run `xcodegen` after adding it to `project.yml`).

### Signing
- The project currently has **no automatic signing** configured: `CODE_SIGN_IDENTITY`
  is empty and there is **no `DEVELOPMENT_TEAM` and no `CODE_SIGN_STYLE`**. This is
  expected for the local-first repo.
- For submission, the **account owner** sets, on all signed targets (Parlance,
  ParlanceEditor; the framework is signed by embedding):
  - Signing: **Automatically manage signing** (recommended), Team = the parlance
    Apple Developer team.
  - Provisioning: **Mac App Store** distribution profiles for
    `business.parlance.xcode` and `business.parlance.xcode.editor`, both with the
    **App Sandbox** capability registered in the Developer portal.
- Distribution certificate: **Apple Distribution** (3rd-party Mac App Store) — Xcode
  Organizer handles this when uploading.

### Export compliance
- The app uses only **standard HTTPS/TLS** (calls to the parlance API). No proprietary
  or non-exempt cryptography.
- Add to **the container app's `Info.plist`**:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```
  With this key present, App Store Connect will not prompt for export-compliance
  documentation on each upload. (Currently this key is **absent** — see section 8.)

---

## 6. Assets

### App icon — status: COMPLETE for macOS
`Sources/Parlance/Assets.xcassets/AppIcon.appiconset` provides every macOS slot, and
`ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` is set on the app target. Verified PNG
dimensions on disk:

| Slot | File | Pixels | Present |
|---|---|---|---|
| 16pt @1x | `icon-16.png` | 16×16 | yes |
| 16pt @2x / 32pt @1x | `icon-32.png` | 32×32 | yes |
| 32pt @2x / 64 | `icon-64.png` | 64×64 | yes |
| 128pt @1x | `icon-128.png` | 128×128 | yes |
| 128pt @2x / 256pt @1x | `icon-256.png` | 256×256 | yes |
| 256pt @2x / 512pt @1x | `icon-512.png` | 512×512 | yes |
| 512pt @2x (App Store) | `icon-1024.png` | 1024×1024 | yes |

No missing sizes. (macOS uses the asset-catalogue icon set; unlike iOS there is no
separate single 1024 "marketing" upload — the 1024 lives in the catalogue, and it is
present.) Confirm the 1024 has **no alpha/transparency** and **no rounded corners**
(macOS applies the squircle mask itself); if the source PNG has an alpha channel,
flatten it before archiving to avoid a validation warning.

### Screenshots — REQUIRED, currently NONE exist
The Mac App Store requires at least **one** screenshot; up to **10**. Accepted display
sizes (provide one set; 2880×1800 is the simplest to capture on a Retina Mac):

| Size (px) | Aspect | Notes |
|---|---|---|
| **2880 × 1800** | 16:10 | Recommended. Native Retina capture, scaled down. |
| 2560 × 1600 | 16:10 | Acceptable. |
| 1440 × 900 | 16:10 | Acceptable (non-Retina). |
| 1280 × 800 | 16:10 | Minimum. |

Format: PNG or JPEG, RGB, no alpha, sRGB. File ≤ 8 MB each.

**Capture plan (show the extension is the product):**
1. **The commands in Xcode.** Open `test/BadFormView.swift`, open the
   **Editor → parlance** submenu so both commands are visible, with the file in the
   background. This is the most important shot — it proves the extension exists.
2. **Audit output inline.** After running **Run Accessibility Audit**, capture the
   inserted findings comment block at the top of a Swift file.
3. **Enablement.** System Settings → Login Items & Extensions → Xcode Source Editor
   with **parlance** toggled on (reinforces the setup step for reviewers and users).
4. **Menu-bar companion — Contracts.** The popover showing contracts with status badges.
5. **Menu-bar companion — Glossary** or an exported **PDF audit report**.

Add a short caption strip per image if desired (kept in British English, brand lowercase).

> Optional: an **App Preview** video (same display sizes, .mov/.mp4, 15–30s) showing the
> enable-then-audit flow. Not required for first submission.

---

## 7. Privacy manifest (`PrivacyInfo.xcprivacy`)

**Status: MISSING.** No `PrivacyInfo.xcprivacy` exists anywhere in the repo.

A privacy manifest is **not strictly required** for this app today: it has **no
third-party SDKs** and uses **no "required-reason" APIs** that mandate a declaration
(it does not read UserDefaults for required-reason purposes, file timestamps, disk
space, active keyboard, or system boot time in a way that triggers the list). However,
Apple is steadily expanding the requirement and a manifest makes the App Privacy answers
auditable. **Recommended: add one to the container app target** (and optionally the
extension). It must be a **plain, top-level** resource named exactly
`PrivacyInfo.xcprivacy`, added to the app target's Copy Bundle Resources.

Suggested contents — **no tracking, no tracking domains, no collected-data types
declared in-manifest** (the App Privacy questionnaire in section 3 is the binding
declaration), and **no required-reason APIs**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array/>
</dict>
</plist>
```

> If you would rather mirror the App Privacy answers inside the manifest, add entries to
> `NSPrivacyCollectedDataTypes` for `NSPrivacyCollectedDataTypeOtherUserContent`,
> `NSPrivacyCollectedDataTypeUserID`, and `NSPrivacyCollectedDataTypeOtherDataTypes`,
> each linked = true, tracking = false, purpose = App Functionality. Keep it consistent
> with section 3 either way.

Place at e.g. `Sources/Parlance/PrivacyInfo.xcprivacy` and add it to `project.yml` so
`xcodegen` includes it in the app target's resources.

---

## 8. Readiness gaps — checklist with exact fixes

Ordered by likelihood of causing a rejection or a failed upload.

- [ ] **No working demo key.** The reviewer notes/demo field must contain a **real**
      API key, not `DEMO_API_KEY`. *Common rejection cause.* → Provision a demo
      account + key and paste it into App Review information (section 4).

- [ ] **Screenshots missing.** At least one Mac screenshot is mandatory; none exist.
      → Capture the set in section 6 (lead with the Editor → parlance menu).

- [ ] **No privacy policy linkage check.** Ensure
      `https://parlancelabs.net/legal/privacy` is live and mentions findings/account
      data sent to parlance, Keychain key storage, and that source is not transmitted.

- [ ] **`PrivacyInfo.xcprivacy` absent.** → Add the manifest from section 7 to the app
      target (recommended; reduces audit risk).

- [ ] **`ITSAppUsesNonExemptEncryption` not set.** → Add `<false/>` to the container
      app's `Info.plist` (section 5) to skip per-upload export-compliance prompts.

- [ ] **Signing/team not configured.** `CODE_SIGN_IDENTITY` empty, no `DEVELOPMENT_TEAM`.
      → Owner enables Automatic signing with the parlance team and Mac App Store
      distribution profiles for both `business.parlance.xcode` and
      `business.parlance.xcode.editor` (App Sandbox capability registered for each).

- [ ] **Hardened Runtime not enabled.** Optional for MAS but recommended. → Add the
      Hardened Runtime capability to Parlance and ParlanceEditor (section 5).

- [ ] **Version is 1.0 / build 1 across targets.** → Bump to **1.0.0 / 1** consistently
      in all three `Info.plist` files (or via `MARKETING_VERSION`/
      `CURRENT_PROJECT_VERSION` — note `MARKETING_VERSION` is **not** currently in the
      project; the version comes from `Info.plist`). The app and `.appex` versions must
      match.

- [ ] **Copyright string stale & wrong case.** `Info.plist` has
      `Copyright © 2024 Parlance. All rights reserved.` → Update to current year and
      lowercase brand, e.g. `Copyright © 2026 parlance.` (and set the App Store Connect
      Copyright field to `2026 parlance`).

- [ ] **Deployment-target doc drift.** README claims macOS 13.0; project requires
      **14.0**. → Either lower the project's `MACOSX_DEPLOYMENT_TARGET` to 13.0 (after
      confirming all APIs used are available — the SwiftUI MenuBarExtra and `@Observable`
      patterns here are fine on 13) **or** fix the README to say 14.0. Pick one; the
      store listing's "minimum macOS" comes from the binary, so the **binary is
      authoritative**.

- [ ] **Verify Keychain sharing on a signed build.** Confirm the push command can read
      the key saved by the companion app under the App Sandbox. If not, add a shared
      `keychain-access-groups` entitlement to both targets (section 5).

- [ ] **App-group mention is misleading.** Docs reference `group.business.parlance`, but
      no app-group entitlement exists and the code uses the Keychain, not an app group.
      → No action needed for the store; optionally correct the docs to avoid confusion.

- [ ] **`project.yml` vs generated project drift.** `project.yml` sets
      `deploymentTarget.macOS: "14.0"` and `xcodeVersion: "15.0"`, and entitlements that
      match the committed `.entitlements`. If you regenerate with `xcodegen`, re-verify
      the bundle ids and entitlements above survive, then re-add Hardened Runtime / icon
      name if you set them only in Xcode.

- [ ] **Flatten the 1024 icon if it has alpha.** macOS app icons must not carry an alpha
      channel; flatten `icon-1024.png` if needed (section 6).

---

## 9. Submission runbook

Do these in order. Steps marked **(owner)** require the Apple Developer account holder.

1. **Set versions.** In all three `Info.plist` files set
   `CFBundleShortVersionString = 1.0.0` and `CFBundleVersion = 1` (app and `.appex`
   must match). Update the copyright string.
2. **Add export-compliance key** `ITSAppUsesNonExemptEncryption = false` to the app's
   `Info.plist`.
3. **Add the privacy manifest** `PrivacyInfo.xcprivacy` (section 7) to the app target
   and (optionally) to `project.yml`.
4. **Regenerate the project** if you edited `project.yml`: `xcodegen generate`, then
   `open Parlance.xcodeproj`.
5. **(owner) Configure signing.** For **Parlance** and **ParlanceEditor**: enable
   Automatic signing, select the parlance team, ensure App Sandbox + (recommended)
   Hardened Runtime capabilities are present, and that Mac App Store distribution
   profiles exist for both bundle ids.
6. **Select destination** "Any Mac (Apple Silicon, Intel)" and **Product → Archive**
   the **Parlance** scheme (archive config is Release per the scheme).
7. **Validate.** In Xcode Organizer, select the archive → **Validate App** →
   **App Store Connect / TestFlight & App Store** → fix any validation errors
   (signing, icon alpha, entitlements) and re-archive if needed.
8. **(owner) Upload.** Organizer → **Distribute App** → **App Store Connect** →
   **Upload**. Wait for processing (the build appears under the macOS app's TestFlight/
   Builds list).
9. **(owner) Create the App Store Connect record** (if not already): My Apps → **+** →
   **New App** → Platform **macOS**, name from section 2, primary language English (U.K.),
   bundle id `business.parlance.xcode`, SKU (e.g. `parlance-xcode`).
10. **Fill metadata** from section 2: name, subtitle, promotional text, description,
    keywords, category (Developer Tools), what's new, support/marketing URLs, copyright.
11. **Attach screenshots** from section 6 (lead image = Editor → parlance menu).
12. **Complete App Privacy** from section 3 (declare the three data types, tracking =
    No, add the privacy policy URL).
13. **Set pricing & availability** (free or paid; territories).
14. **App Review information** from section 4: enablement steps, **real** demo key,
    contact. Confirm export-compliance shows "no" (from step 2).
15. **Select the uploaded build** on the version page.
16. **(owner) Submit for Review.**

---

## 10. What only the account owner can do

These require the parlance Apple Developer / App Store Connect account and cannot be
completed from the source tree:

- **App Store Connect record** — create the macOS app, set bundle id, pricing,
  availability, and the listing.
- **Signing & profiles** — Apple Distribution certificate, Mac App Store provisioning
  profiles for `business.parlance.xcode` and `business.parlance.xcode.editor`, and
  registering the **App Sandbox** capability for both ids in the Developer portal.
- **Archive upload** — Distribute App → App Store Connect upload from Xcode Organizer
  (needs the signing assets above).
- **Agreements, Tax, and Banking** — the Paid Apps agreement must be active if the app
  is paid; free apps need the standard agreement accepted.
- **Screenshots & preview media** — capture on the owner's Mac and upload (cannot be
  generated from code).
- **Real demo API key** — provision a working parlance account + key for the reviewer.
- **App Privacy & export-compliance attestations** — legal declarations the owner must
  affirm in App Store Connect.
- **Submit for Review** and respond to any reviewer messages.
```
