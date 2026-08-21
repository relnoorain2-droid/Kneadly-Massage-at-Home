# Kneadly — TestFlight Runbook
*From this repository to a build on your phone, without owning a Mac.*

---

## 0. Read this first — how this works

Xcode only runs on macOS, and TestFlight builds must be compiled and signed by Xcode. You do not have a Mac, so this project builds on **GitHub's hosted macOS runners** instead. You push code; a macOS machine in GitHub's cloud checks it out, builds it, signs it with your Apple credentials, and uploads it straight to TestFlight.

There are two workflows in `.github/workflows/`:

| Workflow | When it runs | Needs secrets? | What it proves |
|----------|--------------|----------------|----------------|
| **Build check** | Every push | No | The code compiles and the tests pass |
| **TestFlight** | When you click "Run workflow", or push a `v*` tag | Yes (4) | A real signed build reaches TestFlight |

**Run Build check first.** It needs no Apple account at all. Get it green before you touch anything Apple-related — that separates "does the code work" from "is my Apple setup right", and debugging those two things at once is miserable.

GitHub's macOS runners cost minutes on private repos (roughly 10× the Linux rate). A full TestFlight build is about 10–15 minutes. On a free account that is fine for a handful of builds a month; if you plan to build daily, make the repo public or expect to pay.

---

## 1. What you need before you start

- [ ] An **Apple Developer Program** membership ($99/year), active — not just a free Apple ID
- [ ] A **GitHub account** and this project pushed to a repository
- [ ] About **45 minutes** for the first run. Later builds take one click.

You will **not** need: a Mac, Xcode, certificates you generate by hand, or `.p12` files. Signing is handled automatically on the runner using an API key.

---

## 2. Set up Apple's side (once)

### 2.1 Register the App ID

1. Go to **developer.apple.com** → Account → **Certificates, Identifiers & Profiles** → **Identifiers** → **+**
2. Choose **App IDs** → **App**
3. Description: `Kneadly`
4. Bundle ID: **Explicit** → `com.kneadly.app`
5. Capabilities: leave everything **off**. This app needs none.
6. Register.

> Changing the bundle ID later means editing it in three places: `project.yml` (`PRODUCT_BUNDLE_IDENTIFIER`), `Kneadly/App/AppBrand.swift` (`bundleID`), and `Kneadly/Core/Purchases/SubscriptionService.swift` (the three product IDs).

### 2.2 Create the app record

1. Go to **appstoreconnect.apple.com** → **My Apps** → **+** → **New App**
2. Platform: **iOS**
3. Name: `Kneadly` — this must be globally unique across the App Store. If it's taken, pick another and update `AppBrand.name`.
4. Primary language: English (U.K.) or (U.S.)
5. Bundle ID: pick `com.kneadly.app` from the list
6. SKU: `KNEADLY001` (internal only, any string)
7. User Access: Full Access
8. Create.

### 2.3 Create the three in-app purchases

App Store Connect → your app → **Monetization** → **Subscriptions** and **In-App Purchases**.

First create a **subscription group** called `Kneadly Plus`, then inside it:

| Product ID | Type | Duration | Price | Notes |
|-----------|------|----------|-------|-------|
| `com.kneadly.app.plus.monthly` | Auto-renewable | 1 month | $9.99 | — |
| `com.kneadly.app.plus.annual` | Auto-renewable | 1 year | $49.99 | Add a **7-day free trial** introductory offer |
| `com.kneadly.app.plus.lifetime` | Non-consumable | — | $99.99 | Created under In-App Purchases, not the group |

Turn **Family Sharing ON** for all three. This is a two-person app — making a couple buy it twice reads as hostile and will show up in your reviews.

Each product needs a display name, a description, and a review screenshot before it can be submitted. **For TestFlight you can leave them in "Missing Metadata" state** — they only block App Store submission, not beta testing. The paywall will show your placeholder prices until the products are approved, which is fine for testing.

### 2.4 Generate the App Store Connect API key

This is the credential that lets the GitHub runner act on your behalf.

1. App Store Connect → **Users and Access** → **Integrations** tab → **App Store Connect API**
2. Click **+** to generate a key
3. Name: `GitHub CI`
4. Access: **App Manager**
5. Generate, then **Download** the `.p8` file — **you can only download it once.** Keep it somewhere safe.
6. Note these three values from the same page:
   - **Key ID** — a 10-character code, e.g. `2X9ABCD3EF`
   - **Issuer ID** — a UUID at the top of the page, e.g. `69a6de70-1234-47e3-e053-5b8c7c11a4d1`
   - **Team ID** — from developer.apple.com → Membership, e.g. `A1B2C3D4E5`

---

## 3. Set up GitHub's side (once)

Push this project to a GitHub repository, then go to **Settings → Secrets and variables → Actions → New repository secret** and add these four:

| Secret name | Value |
|-------------|-------|
| `APPLE_TEAM_ID` | Your 10-character Team ID |
| `APP_STORE_CONNECT_KEY_ID` | The Key ID from 2.4 |
| `APP_STORE_CONNECT_ISSUER_ID` | The Issuer ID from 2.4 |
| `APP_STORE_CONNECT_PRIVATE_KEY` | **The entire contents** of the `.p8` file, including the `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines |

For the last one: open the `.p8` in a plain text editor, select all, copy, paste. Line breaks matter — paste it exactly as it is.

> Never commit the `.p8` file itself. `.gitignore` already blocks `*.p8`, but be careful anyway.

---

## 4. First build

### 4.1 Green light the code

GitHub → **Actions** → **Build check** → **Run workflow**.

This compiles the app, runs the unit tests, and lints the content pack. No Apple credentials involved. **Get this green first.** If it fails, the log will point at the exact file and line.

### 4.2 Ship to TestFlight

GitHub → **Actions** → **TestFlight** → **Run workflow** → optionally write what testers should try → **Run**.

Roughly what happens, and where it can stop:

| Step | ~Time | If it fails |
|------|-------|-------------|
| Checkout + Xcode select | 1 min | Runner image changed — bump `Xcode_16.2.app` in the workflow |
| Install XcodeGen | 1 min | Rare; transient brew issue, re-run |
| Fetch photography | 1 min | Non-blocking. App falls back to gradients (see §6) |
| Generate project | 10 s | A syntax error in `project.yml` |
| Archive | 5–9 min | **Most failures land here** — see §5 |
| Export + upload | 2–4 min | Usually an App Store Connect metadata problem |

When it succeeds, the build appears in App Store Connect → your app → **TestFlight** within 5–15 minutes, with status "Processing".

### 4.3 Finish the TestFlight setup

Once processing completes:

1. **Export compliance.** App Store Connect will ask whether your app uses encryption. Kneadly does not — `ITSAppUsesNonExemptEncryption` is already set to `false` in `Info.plist`, so this should be answered automatically. If it still asks, answer **No**.
2. **Test Information** (TestFlight tab → Test Information). Required before external testing:
   - **Beta App Description:** *Kneadly teaches you how to give and receive a proper massage — on yourself, on a partner, or on a friend. Every technique is broken into numbered steps with a photograph, a body diagram showing exactly where to press, a timer, and voice guidance.*
   - **Feedback email:** your email
   - **Privacy policy URL:** required. A simple hosted page is enough — see §8.
3. **Add testers.**
   - **Internal testing** (up to 100 people, no review needed, available immediately): add them under Users and Access first, then to an internal group. **Start here.**
   - **External testing** (up to 10,000 people) requires a short **Beta App Review** — usually under 24 hours. Use the reviewer notes in §7.

---

## 5. When the archive step fails

| Error contains | What it means | Fix |
|---|---|---|
| `No profiles for 'com.kneadly.app' were found` | Xcode couldn't create a profile | Check `APPLE_TEAM_ID` is right and the App ID from 2.1 exists with that exact bundle ID |
| `Authentication credentials are missing or invalid` | API key problem | Re-paste `APP_STORE_CONNECT_PRIVATE_KEY` — the header/footer lines are usually what got lost |
| `No signing certificate "Apple Distribution" found` | The API key lacks permission | The key needs **App Manager** access, not Developer |
| `Provisioning profile ... doesn't include signing certificate` | Stale state on Apple's side | Re-run the workflow; automatic signing will recreate it |
| `error: no such module 'X'` | A Swift compile error | Run **Build check** and fix there — much faster feedback |
| `The bundle version must be higher than the previously uploaded version` | Duplicate build number | Build number comes from the GitHub run number, so this only happens after re-running an old run. Just run the workflow again |
| `Missing Info.plist value ... CFBundleIconName` | Icon not found | Make sure `Assets.xcassets/AppIcon.appiconset/icon-1024.png` is committed |
| `App Store Connect Operation Error ... app record` | The app record doesn't exist yet | Do 2.2 |

Every run uploads its logs as an artefact — download it from the run summary page and search for `error:`.

---

## 6. About the photographs

The app ships with **no photographs committed to the repository.** This is deliberate: it keeps the repo small, keeps licensing clean, and means the build never depends on files that might be missing.

`Scripts/fetch_assets.sh` downloads 23 free-licence photographs from the Unsplash CDN into `Kneadly/Resources/Photos/`, and writes `CREDITS.json` recording the photographer and licence for each one. Both CI workflows run it automatically.

**If the fetch fails, nothing breaks.** `KPhoto` falls back to a warm gradient built from each item's `placeholderHex`, so the app still looks deliberate — just abstract rather than photographic. That is a design decision, not a workaround: a missing image should never produce a grey box.

To use your own photography instead, drop JPEGs into `Kneadly/Resources/Photos/` named exactly by asset ID — `img.reg.shoulder.jpg`, `img.reg.foot.jpg`, and so on. The IDs are listed in `Scripts/assets.tsv`. Run every photo through the grading recipe in `docs/05_VISUAL_ASSET_PLAN.md § 5` first — that single step is what makes photographs from different photographers look like one app.

---

## 7. Beta App Review notes

External TestFlight testing needs a short review. A massage app with a couples mode attracts extra scrutiny under **Guideline 1.1.4 (overtly sexual content)**, so say the quiet part out loud in your reviewer notes. Paste this into the **Notes for Review** field:

> Kneadly is a wellness and education app that teaches therapeutic massage techniques. All content is instructional and non-sexual. Every photograph shows clothed or towel-draped subjects with no nudity. The app includes a blocking health-screening flow, medical disclaimers, and per-routine safety guidance.
>
> The app has four modes — Solo, Partner, Friends & Family, and Together — which teach the same techniques with context-appropriate guidance. Friends & Family mode is fully clothed and chair-based throughout.
>
> No account is required. To reach the paywall, complete onboarding and finish any routine. All subscription products are configured in App Store Connect with Family Sharing enabled.

**Also keep this true as you edit the app:** no use of the words *sensual, erotic, intimate touch, foreplay, arousal, tantric, seductive* anywhere in the app, the metadata, the screenshots, or the keywords. The content lint in CI checks the content pack; the rest is on you. Full nine-point plan in `docs/07_SAFETY_LEGAL_COMPLIANCE.md § 5`.

---

## 8. Loose ends before public release

TestFlight doesn't need all of these, but the App Store will:

- [ ] **Privacy policy URL** — required even for TestFlight external testing. Update `AppBrand.privacyURL` and `AppBrand.termsURL`.
- [ ] **App Privacy questionnaire** in App Store Connect. Answer honestly and it's short: health answers never leave the device, analytics are anonymous and not linked to the user, no tracking, no IDFA. Declare *Data Not Collected* for health, contacts, location and identifiers.
- [ ] **Age rating** — 12+. Declare "Infrequent/Mild Medical or Treatment Information".
- [ ] **Screenshots** — 6.9" and 6.5" required. Lead with the **body map** and the **Step Player**, not with couples photography.
- [ ] **Licensed therapist review** of the content before public launch. Their name goes on each routine's detail page — it's a trust asset and a legal one.
- [ ] **In-app purchase metadata and review screenshots** for all three products.
- [ ] Consider **liability insurance** covering wellness education content.

---

## 9. Day-to-day after the first build

- Push to `main` → **Build check** runs automatically. Keep it green.
- Ready to ship a beta? Actions → **TestFlight** → Run workflow. Or tag a release: `git tag v1.0.1 && git push --tags`.
- Build numbers come from the GitHub run number, so they always increase. Marketing version lives in `project.yml` (`MARKETING_VERSION`) — bump it by hand for a real release.
- Adding routines does **not** require a code change. Edit `ios/content-src/pack_*.json`, re-run the merge step in `Scripts/`, and the content lint in CI will catch anything malformed.
