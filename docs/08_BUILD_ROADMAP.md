# 08 — Build Roadmap
*Kneadly · From this document to the App Store in 14 weeks*

---

## 1. Scope of the MVP

**In:** 4 modes · 19 regions · 24 routines (of the 62) · 3 programs (of the 9) · full body map · Step Player with voice, haptics and Live Activity · contraindication engine · StoreKit 2 subscriptions · English only · iPhone portrait only.

**Explicitly out of v1:** Apple Watch · iPad · localisation · custom routine builder · CloudKit sync · recorded voice-over (TTS in v1) · cupping · social/sharing.

> Cutting from 62 routines to 24 saves ~5 weeks and costs almost nothing in perceived value — users complete 4 routines in their first month, not 62. Ship 24, then release the rest as free content drops, which is also excellent retention marketing.

---

## 2. Team

| Role | Commitment | Notes |
|------|-----------|-------|
| iOS engineer | 1 full-time, 14 weeks | Senior; SwiftUI + StoreKit experience essential |
| Product designer | 0.5 FTE, weeks 1–8 | Design system + all screens |
| Content lead (you) | 0.7 FTE throughout | Writes every step; the critical path |
| Licensed massage therapist | ~40 hours total | Reviews and corrects all content |
| Photo curator / retoucher | 2 weeks, weeks 3–5 | Curates and grades 60 photos |
| Illustrator | Optional, weeks 5–9 | Step art — deferrable to v1.1 |
| QA | 2 weeks, weeks 11–13 | Device matrix + accessibility |

**Solo-founder variant:** 22–26 weeks. Sequence: content → design system → body map → Step Player → everything else. Do **not** start with onboarding; start with the Step Player, because it is the product and it is where the unknowns are.

---

## 3. Sprint plan (14 weeks / 7 sprints)

### Sprint 1 — Foundations (weeks 1–2)
- Xcode project, Swift 6 strict concurrency, SPM deps, CI with SwiftLint + tests
- `DesignSystem` package: all tokens, 8 core components, snapshot tests, light + dark
- Domain models + `ContentStore` decoding the JSON schema
- SwiftData stack, both containers (synced + never-synced)
- **Content:** finalise the 24 MVP routines list; write routines 1–4 in full
- ✅ **Exit:** a component gallery builds and previews in both modes; one routine decodes from JSON

### Sprint 2 — Body map + browse (weeks 3–4)
- Integrate MuscleMap; map its regions onto our 24 tappable zones behind `BodyMapProvider`
- BODY tab: map, region sheet, routine list, front/back toggle, search
- TODAY tab: feed, cards, mode filter
- **Assets:** curate 60 photos, apply the grade, export, wire `CREDITS.json`
- **Content:** routines 5–10
- ✅ **Exit:** tap the body map → see real routines with real graded photography

### Sprint 3 — The Step Player (weeks 5–6) ← *the risky sprint, do it early*
- Full player: hero, body-map inset, stroke-path animation, timer ring, pressure meter, transport
- Auto-advance, transition card, repeat, pause, swipe
- Haptics, screen-awake, image prefetch, background-safe timing
- Giver / Receiver viewpoint toggle
- **Content:** routines 11–16
- ✅ **Exit:** a complete 10-step partner routine runs end-to-end without a spinner or a dropped frame

### Sprint 4 — Safety, prepare, complete (weeks 7–8)
- Contraindication engine + unit tests (highest test coverage in the app)
- Onboarding O1–O7 including the blocking health screen
- Session Prepare P1–P3 including the two-tap consent ritual
- Session Complete + feedback loop + pressure auto-tuning
- **Content:** routines 17–24; LMT review round 1
- ✅ **Exit:** install → onboard → screen → prepare → session → complete, with no dead ends

### Sprint 5 — Voice, monetisation, polish (weeks 9–10)
- `NarrationPlayer` with TTS, ducking, background audio, lock-screen playback
- Ambience mixer
- StoreKit 2: products, paywall, trial, restore, Family Sharing, transaction observer
- LEARN tab: techniques, basics, oils, safety
- ME tab: history, streaks, partner profiles, settings
- Live Activity
- ✅ **Exit:** a paid subscription unlocks content; voice guides a full session with the screen locked

### Sprint 6 — Programs, offline, accessibility (weeks 11–12)
- 3 programs with day-by-day progress
- On-Demand Resources / CDN packs + per-routine offline download
- Full accessibility pass: VoiceOver, Dynamic Type to AX5 in the player, Reduce Motion
- Localisation infrastructure (String Catalog, zero hardcoded strings) even though we ship English only
- Analytics instrumentation, crash reporting
- ✅ **Exit:** the accessibility checklist in `03 § 12` passes completely

### Sprint 7 — Harden and submit (weeks 13–14)
- Device matrix: iPhone SE 3 → 17 Pro Max, iOS 17 and 18/19
- Performance against the `06 § 10` targets
- LMT review round 2 + medical advisor sign-off
- Legal: ToS, privacy policy, disclaimers, insurance
- App Store: metadata, screenshots, preview video, reviewer notes, demo walkthrough
- TestFlight with 30+ external testers, **including at least 5 real couples**
- ✅ **Exit:** submitted

---

## 4. Critical path and the three real risks

```
CONTENT WRITING ──────────────────────────────────► (14 weeks, never stops)
        │
        ├── LMT review ──► corrections ──► final content
        │
STEP PLAYER (S3) ──► SAFETY (S4) ──► MONETISATION (S5) ──► SUBMIT
        │
BODY MAP (S2) ──┘
```

| Risk | Why it bites | Mitigation |
|------|-------------|------------|
| **Content is the bottleneck, not code** | 24 routines × ~10 steps × 18 fields = ~4,300 pieces of written content, each needing a visual and a safety check | Start content in week 1, before any code. Write the schema first and fill it relentlessly. Hire a second writer if you slip past week 6 |
| **App Store rejection under 1.1.4** | Couples massage triggers review scrutiny | The full nine-point plan in `07 § 5`, executed *before* submission, not after rejection |
| **Stroke-path coordinates for every step** | 640 hand-authored coordinate sets is genuinely tedious | Build a small internal web tool: load the body SVG, click points, copy JSON. Two days of tooling saves three weeks of misery |

---

## 5. Budget estimate (contractor rates, USD)

| Line | Low | High |
|------|-----|------|
| iOS engineering (14 wks) | $28,000 | $56,000 |
| Product design (7 wks @ 0.5) | $7,000 | $14,000 |
| Photo curation + grading | $1,500 | $3,000 |
| Illustration (85 step visuals, optional in v1) | $2,500 | $6,000 |
| LMT content review (40 h) | $2,000 | $4,000 |
| Medical advisor sign-off | $1,500 | $3,000 |
| Legal (ToS, privacy, review) | $1,500 | $3,500 |
| QA (2 wks) | $2,500 | $5,000 |
| Apple Developer Program | $99 | $99 |
| Analytics, CDN, tools (yr 1) | $600 | $2,000 |
| **Total** | **≈ $47,000** | **≈ $97,000** |

**Solo-founder path:** ~$8,000–12,000 out of pocket (LMT review, legal, illustration, tools) plus ~6 months of your time.

---

## 6. Post-launch roadmap

| Version | Timing | Contents |
|---------|--------|----------|
| **1.0** | Launch | 24 routines, 3 programs, 4 modes, English |
| **1.0.x** | Weeks 1–8 after | Bug fixes; **free content drops** — 6 new routines a month, announced by push. Cheapest retention lever available |
| **1.1** | +3 months | Apple Watch companion · recorded human voice-over · widgets · Siri shortcuts · remaining 38 routines · all 9 programs |
| **1.2** | +6 months | Localisation (DE, ES, FR, PT-BR, **AR** with full RTL) · iPad · custom routine builder · CloudKit sync · commissioned illustration set replacing AI/photo step art |
| **2.0** | +12 months | Couples shared progress (two devices, one session) · video technique demos · massage-gun and tool integrations · optional LMT video consults |

---

## 7. Definition of done for v1

- [ ] 24 routines, every step with a visual, all LMT-reviewed
- [ ] All 4 modes functional and content-differentiated
- [ ] Contraindication engine gating content, with alternatives for every block
- [ ] Step Player: voice, haptics, auto-advance, Live Activity, zero spinners
- [ ] Onboarding completion ≥ 80% in TestFlight
- [ ] Subscription purchase, restore, trial and Family Sharing all verified in sandbox
- [ ] Accessibility checklist (`03 § 12`) fully passing
- [ ] Bundle < 60 MB; performance targets (`06 § 10`) met
- [ ] Everything core works in airplane mode
- [ ] Legal pack complete; reviewer notes and appeal letter prepared
- [ ] 30+ TestFlight testers including 5 couples; no P0/P1 open
