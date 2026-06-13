# parlance for Xcode — App Store submission

**Product:** parlance for Xcode (menu bar app + Source Editor Extension)
**Store:** Mac App Store
**Canonical API:** `https://api.parlancelabs.net/api/v1`
**Marketing / support:** `https://parlancelabs.net`
**Privacy policy:** `https://parlancelabs.net/legal/privacy`
**Category:** Developer Tools (set in `Sources/Parlance/Info.plist`)

> Cross-cutting decisions for all three Apple products live in the parlance
> monorepo at `docs/APP_STORE_SUBMISSION.md` (master). This doc is the
> per-product runbook for the Xcode integration.

---

## 0. Status — done in code vs owner-only

**Done in this repo (config/source):**
- ✅ API repointed to `https://api.parlancelabs.net` — `ParlanceAPIClient` default
  base, the Settings link, the PDF export footer, and `CLAUDE.md`. (The client
  appends `/api/v1/...` to each path, so the base is the bare host — verified.)
- ✅ Version normalised to **1.0.0** (`CFBundleShortVersionString`) + Settings fallback.
- ✅ Copyright fixed: `© 2024 Parlance` → `© 2026 parlance`.
- ✅ Export compliance: `ITSAppUsesNonExemptEncryption = NO` in the app Info.plist.
- ✅ App category: `public.app-category.developer-tools`.
- ✅ Privacy manifests added for the app (`Sources/Parlance/PrivacyInfo.xcprivacy`)
  and the extension (`Sources/ParlanceEditor/PrivacyInfo.xcprivacy`).

**⚠️ Build-verify required (no Swift toolchain in the authoring environment):**
these edits were made and reviewed by hand but **not compiled**. Step 1 below
regenerates the project and builds — do it before archiving.

**Owner-only (your Apple account, on a Mac):**
- ⬜ Set `DEVELOPMENT_TEAM` / signing for all three targets (§3).
- ⬜ Confirm the bundle-id prefix / developer-account convention (master decision #1;
  this repo uses `business.parlance.*`).
- ⬜ Create the App Store Connect record, archive, upload, screenshots, App Privacy,
  reviewer key, submit (§4–§7).

---

## 1. Regenerate + build (your Mac) — required

The committed `Parlance.xcodeproj` predates the new privacy manifests, so
regenerate so the `.xcprivacy` files are bundled:

```bash
brew install xcodegen          # if needed
xcodegen generate              # picks up Sources/**/PrivacyInfo.xcprivacy
open Parlance.xcodeproj
# Scheme "Parlance" → My Mac → Cmd+B  (must build clean before archiving)
```

In Xcode, confirm each `PrivacyInfo.xcprivacy` is in its target's
**Copy Bundle Resources** phase (XcodeGen adds it automatically; verify).

---

## 2. App Store metadata (copy-paste; limits respected)

- **Name** (30 max): `parlance for Xcode` (18)
- **Subtitle** (30 max): `SwiftUI accessibility audits` (28)
- **Keywords** (100 max):
  `accessibility,wcag,swiftui,a11y,audit,xcode,voiceover,contrast,inclusive,developer` (83)
- **Description:**
  ```
  parlance audits your SwiftUI for accessibility, right inside Xcode.

  Run ten WCAG checks on the file in the editor — image labels, colour
  contrast, touch targets, heading traits, form labels, keyboard access,
  focus management, dynamic type, colour-only state, and accessibility order
  — and get findings inserted as inline comments. Everything runs on-device.

  The companion menu bar app keeps your parlance contracts and glossary one
  click away, and can push audit findings to your dashboard.

  No account required to audit. Connect a parlance API key (parlancelabs.net)
  for contracts, glossary, and dashboard sync. No analytics, no tracking.
  ```
- **Source Editor command names** (already in the extension): "Run Accessibility
  Audit", "Audit and Push".

---

## 3. Signing (your Apple account)

For **Parlance** (app), **ParlanceEditor** (extension), **ParlanceKit** (framework):
Signing & Capabilities → Automatically manage signing → your **Team**.
Bundle ids (from `project.yml`): `business.parlance.xcode`,
`business.parlance.xcode.editor`, `business.parlance.xcode.kit`. The app group
`group.business.parlance` and Keychain group must be registered to that team.

---

## 4. App Privacy answers (App Store Connect)

- **Data collection:** **No, we do not collect data from this app.**
- Tracking: **No.**
- Matches the bundled `PrivacyInfo.xcprivacy`: no tracking, no collected data,
  UserDefaults reason `CA92.1`. The API key lives in the Keychain; audit findings
  are only sent when the user explicitly pushes them.

---

## 5. App Review notes (paste into App Review Information)

```
parlance for Xcode audits the SwiftUI source in the active editor for
accessibility issues, on-device. No account is required for auditing.

To test connected features (optional): open the parlance menu bar app →
Settings → paste the API key below → select a project. Contracts/Glossary load
and "Audit and Push" becomes active. The key authenticates against
https://api.parlancelabs.net.

Enabling the editor extension: System Settings → Privacy & Security →
Extensions → Xcode Source Editor → enable parlance. Then in Xcode:
Editor → parlance → Run Accessibility Audit (try test/BadFormView.swift).

Demo API key: <PASTE plc_… HERE — do not commit it to the repo>
```

---

## 6. Screenshots (your Mac)

Mac App Store: ≥1 at 1280×800 or 1440×900. Suggested:
1. Editor with inline audit comments inserted into a SwiftUI file.
2. The menu bar popover (contracts/glossary).
3. Settings → connected, project selected.
4. A generated PDF audit report.

---

## 7. Readiness checklist

| Item | State |
|---|---|
| API → `api.parlancelabs.net` | ✅ done (code) |
| Version 1.0.0 | ✅ done |
| Copyright © 2026 parlance | ✅ done |
| `ITSAppUsesNonExemptEncryption=NO` | ✅ done |
| App category = Developer Tools | ✅ done |
| Privacy manifests (app + extension) | ✅ done |
| `xcodegen generate` + clean build | ⬜ you (Mac) — **build not yet verified** |
| Signing team set | ⬜ you |
| App Store Connect record | ⬜ you |
| Screenshots | ⬜ you |
| App Privacy answered | ⬜ you (§4) |
| Reviewer key pasted | ⬜ you (§5) |

---

## 8. Out of scope / follow-ups

- **Brand casing.** User-facing strings still render "Parlance" in some views
  (e.g. the menu bar title, the PDF footer's "Parlance Xcode Extension"). The
  master rule is lowercase brand in user-facing copy; a full sweep was left out
  of this submission pass to avoid churning the app's display name. Track
  separately if desired.
- **SDK adoption.** This repo uses its own `ParlanceAPIClient` rather than
  `parlance-swift-sdk`. Migrating is a larger refactor and not required for
  submission.
