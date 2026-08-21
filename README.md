# Kneadly — iOS

A guided body-massage app. Teaches you how to give and receive a real massage — on yourself, on a partner, on a friend — in numbered steps, with a photograph, a body diagram showing exactly where to press, a timer, and voice guidance.

**iOS 17+ · SwiftUI · Swift 5 language mode · no third-party dependencies.**

---

## Getting a build onto your phone

Read **[TESTFLIGHT_RUNBOOK.md](TESTFLIGHT_RUNBOOK.md)**. It covers the whole path from an Apple Developer account to a build in TestFlight, and it assumes you do not own a Mac — GitHub's macOS runners do the building.

Short version: push this repo to GitHub, run the **Build check** workflow (no credentials needed), add four secrets, run the **TestFlight** workflow.

---

## Layout

```
project.yml                 Source of truth for the Xcode project (XcodeGen)
ExportOptions.plist         Archive export + direct upload to App Store Connect
Scripts/
  build_content.py          Merges content packs → content.json, validates everything
  fetch_assets.sh           Downloads the free-licence photography set
  bump_build.sh             Sets the build number (CI passes the run number)
  assets.tsv                asset ID → Unsplash photo, photographer, licence
content-src/
  SPEC.md                   The content authoring spec
  pack_a..d.json            24 routines, 225 steps — edit these to add content
Kneadly/
  App/                      Entry point, environment, routing, brand constants
  DesignSystem/
    Tokens/                 Colour, type, spacing, motion
    Components/             Body map, photo loader, controls, cards
  Core/
    Domain/                 Pure model types — no framework imports
    Content/                ContentStore, programs
    Persistence/            SwiftData models, UserState
    Safety/                 ContraindicationEngine
    Audio/ Haptics/ Purchases/ Analytics/
  Features/                 One folder per screen
  Resources/                content.json, Assets.xcassets, StoreKit config, Photos/
KneadlyTests/               Content, safety and player-timing tests
```

## Local development (if you get access to a Mac)

```bash
brew install xcodegen
bash Scripts/fetch_assets.sh     # optional — the app runs fine without it
xcodegen generate
open Kneadly.xcodeproj
```

The `.xcodeproj` is generated and git-ignored. **Never edit it by hand** — change `project.yml` and regenerate, or your change disappears on the next CI run.

For paywall testing in the simulator, set the scheme's StoreKit configuration to `Kneadly/Resources/Kneadly.storekit`.

## Adding or editing content

Content is data, not code.

1. Edit a file in `content-src/` following `content-src/SPEC.md`
2. `python3 Scripts/build_content.py`
3. Commit

The script rejects anything that would break the app or the brand: over-long copy, missing steps, orphaned steps, unknown enum values, stroke-path coordinates outside 0–1, medical claims (*cure, heal, treat, detox, realign*), suggestive language, Friends-mode routines that need oil, and routines whose step durations don't add up. CI runs the same script.

## Architecture notes

- **`@Observable` + MVVM.** No architecture framework, no DI container. `AppEnvironment` is the container and it is 90 lines.
- **The body map is vector, not raster.** `BodyGeometry` builds every zone as a SwiftUI `Path` in a 200×400 design space. It scales, tints, animates, works in dark mode, and adds nothing to the bundle. The teaching visuals are diagrams; photographs only set the mood.
- **Photographs are optional at runtime.** `KPhoto` falls back to a warm gradient built from each item's `placeholderHex`. A missing image never produces a grey box.
- **Safety gates content, not the reverse.** `ContraindicationEngine` runs before a routine list renders. A blocked routine always offers an alternative — a dead end is a bad product and a worse safety outcome.
- **Timing is deadline-based.** `StepPlayerModel` stores a `Date` deadline rather than counting ticks, so backgrounding, phone calls and clock changes never desynchronise a session.
- **Health answers never leave the device.** They live in `UserState` (UserDefaults), deliberately outside the SwiftData container, which is configured with `cloudKitDatabase: .none`.

## What is not in v1

Apple Watch companion · iPad · localisation (the infrastructure is there, English only ships) · recorded human voice-over (uses `AVSpeechSynthesizer`) · CloudKit sync · Live Activity · custom routine builder. Roadmap in `docs/08_BUILD_ROADMAP.md`.

## Licence and credits

Photography is used under the Unsplash Licence (commercial use permitted, no attribution required). `Scripts/fetch_assets.sh` writes `Resources/CREDITS.json` recording every source, and the app renders it in About.
