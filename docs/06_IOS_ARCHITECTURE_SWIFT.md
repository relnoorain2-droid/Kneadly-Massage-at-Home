# 06 — iOS Architecture (Swift / SwiftUI)
*Kneadly · Swift 6 · SwiftUI · iOS 17+*

---

## 1. Platform decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Minimum iOS | **17.0** | Unlocks `@Observable`, SwiftData, `ContentUnavailableView`, `.scrollTargetBehavior`, and the MuscleMap package. iOS 17+ covers ~92% of active devices in 2026 |
| Language | **Swift 6**, strict concurrency ON | Data-race safety is worth the up-front cost on a greenfield project |
| UI | **SwiftUI**, 100% | No UIKit except a `UIViewRepresentable` for the AVPlayer ambience mixer |
| Persistence | **SwiftData** | Sessions, streaks, partner profiles, download state |
| Content | **Bundled JSON + remote packs** | Content updates without an App Store release — the retention engine |
| Architecture | **MVVM with `@Observable`**, feature-sliced | No third-party architecture framework |
| DI | Plain protocol injection via a lightweight `AppEnvironment` | No DI framework needed at this size |
| Networking | `URLSession` + `async/await` | No Alamofire |
| Payments | **StoreKit 2** | Modern async API, no receipt-validation server needed for v1 |
| Analytics | TelemetryDeck or PostHog | Privacy-first, no IDFA, no ATT prompt |
| Crash | Sentry or Firebase Crashlytics | — |
| Orientation | **Portrait only** in v1 | Halves layout work; landscape adds nothing for this use case |

---

## 2. Module structure

```
Kneadly/
├── App/
│   ├── KneadlyApp.swift            @main, AppEnvironment, scene setup
│   ├── AppBrand.swift              ← the ONLY file with the brand name
│   └── RootTabView.swift
├── DesignSystem/                   Swift package — importable, previewable, testable
│   ├── Tokens/                     Color+Kneadly, Font+Kneadly, Spacing, Radius, Shadow
│   ├── Components/                 PrimaryButton, Chip, RoutineCard, PressureMeter,
│   │                               TimerRing, SensationCue, SafetyBanner, StreakRing…
│   └── Motion/                     KneadlyAnimation, Haptics
├── Features/
│   ├── Onboarding/
│   ├── Today/
│   ├── BodyMap/
│   ├── Learn/
│   ├── Me/
│   ├── SessionPrepare/
│   ├── StepPlayer/                 ← the core feature module
│   ├── SessionComplete/
│   └── Paywall/
├── Core/
│   ├── Content/                    ContentStore, ContentPackDownloader, JSON decoding
│   ├── Domain/                     Pure model types — no framework imports
│   ├── Persistence/                SwiftData models + repositories
│   ├── Safety/                     ContraindicationEngine
│   ├── Audio/                      NarrationPlayer, AmbienceMixer
│   ├── Health/                     HealthKitService
│   ├── Purchases/                  StoreKit2 SubscriptionService
│   ├── Notifications/
│   └── Analytics/
├── Widgets/                        WidgetKit + Live Activity
├── Watch/                          watchOS companion (v1.1)
└── Resources/
    ├── Content/                    routines.json, techniques.json, regions.json…
    ├── Assets.xcassets
    └── Localizable.xcstrings
```

**Rule:** `Core/Domain` imports nothing but Foundation. `DesignSystem` imports nothing from `Features`. Features never import each other — they communicate through the router and the environment. Enforced with a build-phase script.

---

## 3. Domain models

```swift
// MARK: - Content

struct Region: Identifiable, Codable, Sendable {
    let id: String                      // "shoulders_upper_trap"
    let name: String                    // localisation key
    let group: BodyGroup                // .head, .torso, .arms, .hips, .legs, .feet
    let anatomyNote: String
    let mapZoneIDs: [String]            // SVG paths that light up for this region
    let primaryTechniques: [Technique.ID]
    let cautions: [String]
}

struct Technique: Identifiable, Codable, Sendable {
    let id: String                      // "petrissage"
    let name: String
    let plainName: String               // "Kneading"
    let family: TechniqueFamily         // .swedish, .clinical, .eastern, .ritual
    let origin: String
    let goodFor: [String]
    let clothedFriendly: Bool
    let pressureRange: ClosedRange<Int>
    let heroImage: String
    let primerRoutineID: Routine.ID?    // the 60-second "try it now"
}

enum SessionMode: String, Codable, CaseIterable, Sendable {
    case solo, partner, friends, together
}

struct Routine: Identifiable, Codable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let regionIDs: [Region.ID]
    let mode: SessionMode
    let level: Level                    // .beginner, .intermediate, .advanced
    let durationSeconds: Int
    let pressureRange: ClosedRange<Int>
    let position: BodyPosition
    let needs: [String]                 // "towel", "oil", "chair", "tennis ball"
    let skipIf: [Contraindication.ID]
    let coverImage: String
    let coverPlaceholderHex: String     // avoids grey loading boxes
    let isPremium: Bool
    let reviewedBy: String?             // "Reviewed by Dana K., LMT #12345"
    let sections: [RoutineSection]
}

struct RoutineSection: Codable, Sendable {
    let kind: SectionKind               // .warmUp, .main, .coolDown
    let stepIDs: [Step.ID]
}

struct Step: Identifiable, Codable, Sendable {
    let id: String
    let regionID: Region.ID
    let techniqueID: Technique.ID
    let title: String                   // ≤ 6 words — lint-enforced
    let body: String                    // ≤ 200 chars — lint-enforced
    let sensationCue: String            // ≤ 90 chars — lint-enforced
    let handPosition: HandPosition
    let pressure: Int                   // 1...5
    let durationSeconds: Int
    let rhythm: String?
    let breathCue: String?
    let heroImage: String
    let heroPlaceholderHex: String
    let bodyMapZoneIDs: [String]
    let strokePath: StrokePath?
    let voiceScript: String
    let commonMistake: String?
    let caution: String?
    let modes: Set<SessionMode>
    let contraindications: [Contraindication.ID]
    let alternativeStepID: Step.ID?     // the gentle version
}

struct StrokePath: Codable, Sendable {
    let points: [CGPoint]               // normalised 0...1 within the body map
    let motion: Motion                  // .glide, .knead, .circle, .hold, .walk, .rake
    let loop: Bool
}

enum HandPosition: String, Codable, CaseIterable, Sendable {
    case flatPalm, palmHeel, thumbPad, doubleThumb, fingertips
    case knuckles, forearm, cGrip, pincerGrip, cuppedHand
    var symbolName: String { "hand.\(rawValue)" }   // custom SF Symbol
}

struct Program: Identifiable, Codable, Sendable {
    let id: String
    let title: String
    let days: [ProgramDay]
    let coverImage: String
    let isPremium: Bool
    let requiresAcknowledgement: Bool   // true for Pregnancy Comfort
}

// MARK: - Safety

struct Contraindication: Identifiable, Codable, Sendable {
    let id: String                      // "dvt_or_blood_thinners"
    let plainQuestion: String            // "Blood clot, DVT, or on blood thinners"
    let severity: Severity              // .absolute, .relative, .local
    let blockedRegionIDs: [Region.ID]
    let maxPressure: Int?               // cap rather than block, for .relative
    let explanation: String             // shown to the user, calm and clear
    let seeDoctor: Bool
}
```

---

## 4. Persistence (SwiftData)

```swift
@Model final class SessionLog {
    @Attribute(.unique) var id: UUID
    var routineID: String
    var mode: String
    var startedAt: Date
    var completedAt: Date?
    var durationSeconds: Int
    var stepsCompleted: Int
    var stepsTotal: Int
    var feelAfter: String?              // "better" | "same" | "worse"
    var pressureFeedback: String?       // "light" | "right" | "firm"
    var partnerProfileID: UUID?
    var abandonedAtStepIndex: Int?
    init(...) { ... }
}

@Model final class PartnerProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var preferredPressure: Int
    var sensitiveRegionIDs: [String]
    var contraindicationIDs: [String]   // ⚠️ local only — NEVER synced
    var avatarColorHex: String
}

@Model final class UserHealthAnswers {
    var contraindicationIDs: [String]
    var affectedRegionIDs: [String]
    var updatedAt: Date
    var acknowledgedDisclaimerVersion: Int
}

@Model final class ProgramProgress {
    var programID: String
    var currentDay: Int
    var completedDays: [Int]
    var startedAt: Date
}

@Model final class DownloadedPack {
    var packID: String
    var bytes: Int
    var downloadedAt: Date
}
```

**Sync policy:** `SessionLog` and `ProgramProgress` may sync via CloudKit private database (opt-in). **`UserHealthAnswers` and `PartnerProfile.contraindicationIDs` never leave the device** — enforced by keeping them in a separate, non-CloudKit `ModelContainer`. See `07 § 6`.

---

## 5. Key services

### 5.1 ContraindicationEngine
Runs *before* any routine list renders — not as a popup afterwards.

```swift
protocol ContraindicationEngine: Sendable {
    func evaluate(routine: Routine, for answers: UserHealthAnswers) -> SafetyVerdict
}

enum SafetyVerdict: Sendable {
    case allowed
    case allowedWithCap(maxPressure: Int, note: String)
    case modified(alternativeRoutineID: String, note: String)
    case blocked(reason: String, alternative: Routine.ID?, seeDoctor: Bool)
}
```
**Rule: `.blocked` must always carry an `alternative` where one exists.** A dead end is a bad product and a worse safety outcome — a user told only "no" will go do it wrong anyway.

### 5.2 BodyMapProvider (keeps MuscleMap swappable)
```swift
protocol BodyMapProvider {
    func path(for zoneID: String, view: BodyView, figure: Figure) -> Path
    var allZoneIDs: [String] { get }
}
struct MuscleMapProvider: BodyMapProvider { /* wraps the MIT package */ }
struct CustomArtProvider: BodyMapProvider { /* v1.2 commissioned art */ }
```

### 5.3 NarrationPlayer
```swift
@Observable final class NarrationPlayer {
    private let synth = AVSpeechSynthesizer()     // v1 fallback
    private var player: AVAudioPlayer?            // recorded VO from v1.1
    func speak(_ step: Step) async { ... }
    func duckAmbience(to level: Float) { ... }
}
```
Audio session: `.playback` with `.mixWithOthers` and `.duckOthers`, so the user's own music keeps playing quietly underneath. **Background audio capability required** — narration must continue with the screen locked.

### 5.4 SubscriptionService (StoreKit 2)
```swift
@Observable final class SubscriptionService {
    private(set) var isPlus = false
    func load() async throws { ... }
    func purchase(_ product: Product) async throws -> Bool { ... }
    func restore() async throws { ... }
    private func observeTransactions() -> Task<Void, Never> { ... }   // must run for app lifetime
}
```
Products: `plus.monthly` · `plus.annual` (7-day intro trial) · `plus.lifetime` (non-consumable). **Family Sharing enabled on all three.**

---

## 6. The Step Player (core implementation sketch)

```swift
@Observable final class StepPlayerModel {
    let routine: Routine
    private(set) var index = 0
    private(set) var remaining: Int
    private(set) var isPlaying = false
    private(set) var viewpoint: Viewpoint = .giver
    private var ticker: Task<Void, Never>?

    var step: Step { steps[index] }
    var progress: Double { Double(index) / Double(steps.count) }

    func play() {
        isPlaying = true
        ticker = Task { [weak self] in
            while let self, self.isPlaying, self.remaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    self.remaining -= 1
                    Haptics.tickIfNeeded(remaining: self.remaining)
                }
            }
            await self?.advance()
        }
    }

    func advance() async {
        analytics.log(.stepAdvanced(index: index))
        guard index + 1 < steps.count else { return await finish() }
        await showTransitionCard()          // 3s — time to move hands
        index += 1
        remaining = step.durationSeconds
        await narration.speak(step)
        imagePrefetcher.prefetch(steps[safe: index + 1]?.heroImage)
    }

    func repeatStep() { remaining = step.durationSeconds; analytics.log(.stepRepeated(index: index)) }
    func toggleViewpoint() { viewpoint = viewpoint == .giver ? .receiver : .giver }
}
```

**Non-negotiables in this screen:**
- `UIApplication.shared.isIdleTimerDisabled = true` for the session's lifetime, reset in `onDisappear`
- Live Activity started on `play()`, ended on `finish()`
- Next step's hero image prefetched during the current step — **no spinner, ever**
- Interruption handling: `AVAudioSession.interruptionNotification` → auto-pause
- All timing state survives backgrounding (store `Date`-based deadlines, not tick counts)

---

## 7. Content JSON schema and remote packs

`Resources/Content/routines.json` ships in the bundle; new packs download from a CDN.

```json
{
  "schemaVersion": 1,
  "packID": "core.v1",
  "routines": [{
    "id": "neck.partner.reset",
    "title": "Neck & Shoulder Reset",
    "mode": "partner",
    "level": "beginner",
    "durationSeconds": 720,
    "position": "seated_chair_reversed",
    "needs": ["chair", "towel"],
    "skipIf": ["recent_neck_surgery", "unexplained_neck_pain"],
    "coverImage": "img.reg.shoulder",
    "coverPlaceholderHex": "#C9A188",
    "isPremium": false,
    "reviewedBy": "Reviewed by a licensed massage therapist",
    "sections": [
      { "kind": "warmUp",   "stepIDs": ["neck.partner.reset.s01","neck.partner.reset.s02","neck.partner.reset.s03"] },
      { "kind": "main",     "stepIDs": ["...s04","...s05","...s06","...s07","...s08"] },
      { "kind": "coolDown", "stepIDs": ["...s09","...s10"] }
    ]
  }],
  "steps": [{
    "id": "neck.partner.reset.s04",
    "regionID": "shoulders_upper_trap",
    "techniqueID": "petrissage",
    "title": "Squeeze and roll the muscle",
    "body": "Grip the top of the shoulder between your thumb and fingers. Squeeze, lift slightly, and roll — like kneading dough.",
    "sensationCue": "A deep, satisfying ache that eases as you work. Never sharp.",
    "handPosition": "pincerGrip",
    "pressure": 4,
    "durationSeconds": 90,
    "rhythm": "About one squeeze per second",
    "breathCue": "Receiver: breathe out as you squeeze",
    "heroImage": "img.step.shoulder.petrissage.01",
    "heroPlaceholderHex": "#B98F76",
    "bodyMapZoneIDs": ["upper_trap_left", "upper_trap_right"],
    "strokePath": { "points": [[0.42,0.18],[0.58,0.19]], "motion": "knead", "loop": true },
    "voiceScript": "Now grip the top of the shoulder between your thumb and your fingers. Squeeze, lift the muscle slightly away from the bone, and roll it — like you're kneading dough. Slow and steady, about one squeeze a second. Their shoulder should feel a deep, satisfying ache, never anything sharp.",
    "commonMistake": "Don't pinch with your fingertips — use the whole flat of your fingers.",
    "caution": "Stay off the bony ridge of the collarbone.",
    "modes": ["partner", "friends", "together"],
    "contraindications": ["recent_shoulder_surgery", "acute_inflammation"],
    "alternativeStepID": "neck.partner.reset.s04.gentle"
  }]
}
```

**Remote pack flow:** app boots with `core.v1` bundled → checks a lightweight `manifest.json` on the CDN → downloads new packs in the background → merges into `ContentStore` → new routines appear without an App Store release. Packs are versioned and validated against `schemaVersion` before merging; an unknown schema version is ignored rather than crashing.

---

## 8. Swift Package dependencies (keep this list short)

| Package | License | Purpose | Necessary? |
|---------|---------|---------|-----------|
| [MuscleMap](https://github.com/melihcolpan/MuscleMap) | MIT | Body map rendering + interaction | **Yes** — saves ~3 weeks |
| [Nuke](https://github.com/kean/Nuke) | MIT | Image cache + prefetch | **Yes** |
| [SVGPath](https://github.com/nicklockwood/SVGPath) | MIT | SVG `d` → SwiftUI `Path` | Yes, if drawing custom maps |
| [Lottie](https://github.com/airbnb/lottie-ios) | Apache-2.0 | ≤ 6 animations | Optional |
| TelemetryDeck | MIT | Privacy-first analytics | Yes |
| Sentry or Crashlytics | — | Crash reporting | Yes |

Everything else — networking, persistence, payments, audio, haptics, widgets, health — is first-party Apple framework. **A short dependency list is an underrated feature** in an app that must keep working offline for years.

---

## 9. Quality gates (CI, ship-blocking)

```yaml
- swiftlint --strict                     # includes a no-hardcoded-strings rule
- swift build -Xswiftc -strict-concurrency=complete
- swift test                             # unit: ContraindicationEngine, ContentStore, timing math
- content-lint:                          # custom script
    - every step.title  ≤ 6 words
    - every step.body   ≤ 200 chars
    - every sensationCue ≤ 90 chars
    - every step has heroImage AND bodyMapZoneIDs
    - every image referenced exists in the catalog or CDN manifest
    - every image has an accessibilityLabel
    - every routine has ≥ 1 warmUp and ≥ 1 coolDown section
    - every blocked contraindication has an alternative where one exists
    - Flesch-Kincaid grade of all body copy ≤ 8
    - banned-verb check: cure|heal|treat|diagnose|detox|realign|toxins
- snapshot tests: DesignSystem components, light + dark, Dynamic Type L and XXL
- accessibility audit: XCUITest VoiceOver walkthrough of one full session
- bundle size check: initial download < 60 MB
```

---

## 10. Performance targets

| Metric | Target |
|--------|--------|
| Cold launch → Today rendered | < 900 ms |
| Body map first render | < 120 ms |
| Body map tap → sheet | < 100 ms |
| Step advance (incl. image) | < 250 ms, **zero spinner** |
| Scroll (62-card feed) | 120 fps on ProMotion, no dropped frames |
| Memory during a session | < 180 MB |
| Battery, 20-min session, screen on | < 6% |

---

## 11. Post-v1 platform surface

- **watchOS companion (v1.1)** — step title, timer, pressure dots, wrist tap on step change. The giver's hands are busy and oily; a glance at the wrist is far better than a phone. Genuinely the highest-value follow-up feature.
- **Live Activity (v1.0)** — session on the Lock Screen and in the Dynamic Island.
- **WidgetKit (v1.1)** — today's routine, streak.
- **App Intents / Siri (v1.1)** — *"Hey Siri, start my wind-down massage."*
- **iPad (v1.2)** — two-pane; also useful propped on a bed.
- **HealthKit** — write mindful minutes; read nothing.
