# parlance — App Store submission: your next steps

_Last updated: 14 June 2026._

**Where things stand**
- Both **app records are created** in App Store Connect.
- All **code, config, privacy manifests, and metadata content** are written and pushed.
- What remains is the part that needs a browser session and a Mac: pasting metadata, building/uploading from Xcode, screenshots, and hitting submit. That's this document.

**The two apps**

| App | App Store Connect | Repo | Bundle ID |
|---|---|---|---|
| **parlance for Xcode** | app ID `6780118310` | `parlance-xcode` | `business.parlance.xcode` |
| **parlance: accessibility audit** (Safari) | created | `parlance-browser-extension` | `business.parlance.safari` |

**Shared values (both apps)**
- Privacy Policy URL: `https://parlancelabs.net/legal/privacy`
- Support URL: `https://parlancelabs.net`
- Marketing URL: `https://parlancelabs.net`
- Copyright: `2026 parlance`
- Category: Primary **Developer Tools**, Secondary **Utilities**
- Price: **Free**, all countries
- App Privacy: **Data Not Collected**, no tracking

---

## Phase A — Browser: fill metadata (no Mac needed)

Open each app at https://appstoreconnect.apple.com/apps and do all of the below.

### A1. General → App Information
- **Subtitle** — Xcode: `SwiftUI accessibility audits` · Safari: `Live WCAG 2.2 auditor`
- **Privacy Policy URL**: `https://parlancelabs.net/legal/privacy`
- **Category**: Primary Developer Tools, Secondary Utilities
- *(Optional: set Name to lowercase "parlance …" to match the brand.)*

### A2. The "1.0 Prepare for Submission" version page

**Keywords**
- Xcode: `accessibility,wcag,swiftui,a11y,audit,xcode,voiceover,contrast,inclusive,developer`
- Safari: `accessibility,wcag,a11y,audit,contrast,aria,section508,developer,inclusive,compliance`

**Support URL / Marketing URL**: `https://parlancelabs.net` (both)

**Copyright**: `2026 parlance`

**Promotional Text** (Safari only):
```
Audit any web page against WCAG 2.2 Level AA in one click. Colour contrast, alt text, headings, labels, focus, targets and more — with CSV and PDF reports.
```

**Description — Xcode:**
```
parlance audits your SwiftUI for accessibility, right inside Xcode.

Run ten WCAG checks on the file in the editor — image labels, colour contrast, touch targets, heading traits, form labels, keyboard access, focus management, dynamic type, colour-only state, and accessibility order — and get findings inserted as inline comments. Everything runs on-device.

The companion menu bar app keeps your parlance contracts and glossary one click away, and can push audit findings to your dashboard.

No account required to audit. Connect a parlance API key (parlancelabs.net) for contracts, glossary, and dashboard sync. No analytics, no tracking.
```

**Description — Safari:**
```
parlance is an accessibility auditor for Safari. Open any page and run a WCAG 2.2 Level AA audit in one click — every check runs on your device.

Ten audit rules: colour contrast, image alt text, heading hierarchy, form labels, ARIA roles, keyboard access, touch target size, link purpose, page language, and focus visible.

Click any finding to highlight the element on the page. Toggle overlay badges to see every issue at once. Export a CSV or a formatted PDF report.

No account required — auditing works standalone. Connect a parlance API key (parlancelabs.net) to validate against your UI contracts, browse your glossary, and push findings to your dashboard.

No analytics. No tracking. No third-party SDKs.
```

> Leave **Screenshots** and **Build** empty here — they come in Phase D.

### A3. App Privacy (left sidebar)
Get Started → **Data Not Collected** → No tracking → Publish.

### A4. Pricing and Availability
Price **Free** → Availability all countries.

### A5. App Review Information (bottom of the version page)
- "Sign-In required?" → **No**
- Notes:
  ```
  Auditing works with no account. To test connected mode: open Settings, paste the
  API key above, select a project — Contracts/Glossary and push then activate.
  Authenticated against api.parlancelabs.net.
  ```
- If you have a parlance API key, paste it above the note. Not required — the app fully works standalone, so review passes without it.

---

## Phase B — Mac: build & upload the Xcode app

In the `parlance-xcode` repo:

```bash
xcodegen generate          # regenerate so the new privacy manifests are included
open Parlance.xcodeproj
```
1. For **all three targets** (Parlance, ParlanceEditor, ParlanceKit): Signing & Capabilities → tick **Automatically manage signing** → select your **Team**.
2. Scheme **Parlance**, destination **My Mac** → **Product → Archive**.
3. In the Organizer: **Distribute App → App Store Connect → Upload** → accept the signing prompts.
4. Wait ~5–30 min for the build to finish processing (you'll get an email).

---

## Phase C — Mac: build & upload the Safari app

In the `parlance-browser-extension` repo:

```bash
npm ci && npm run build:safari

xcrun safari-web-extension-converter dist/safari/ \
  --project-location safari/xcode-project \
  --app-name "parlance" --bundle-identifier "business.parlance.safari" \
  --swift --macos-only --no-open

open safari/xcode-project/parlance/parlance.xcodeproj
```
1. Set your **Team** on both targets (the app and the extension).
2. In the **app target's** Info.plist add `ITSAppUsesNonExemptEncryption` = **NO**.
3. Drag `safari/PrivacyInfo.xcprivacy` into the project; tick **both** targets in the file inspector.
4. **Product → Archive → Distribute App → App Store Connect → Upload.**
5. Wait for processing.

---

## Phase D — Screenshots, then submit (browser)

For **each** app:
1. **Screenshot** — at least one Mac image at **1280×800, 1440×900, 2560×1600, or 2880×1800**. Run the app, capture it (⌘⇧4, resize to an accepted size), drag it into "App Previews and Screenshots".
2. **Select the build** — the "Build" section now lists your uploaded build; pick it.
3. Confirm all Phase A fields are filled and App Privacy shows a green check.
4. **Add for Review → Submit for Review.**

Apple review for Developer Tools is typically 1–3 days. You'll get email on each state change.

---

## Reference (already in the repos)
- `parlance-xcode/docs/APP_STORE_SUBMISSION.md`
- `parlance-browser-extension/docs/APP_STORE_SUBMISSION.md`
