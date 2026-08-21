# 03 — Design System
*Kneadly · iOS · v1.0 · "Warm clinical" — a spa that knows anatomy*

---

## 1. Brand

**Name:** Kneadly · **Tagline:** *Good hands, guided.*

**Logotype:** lowercase wordmark in Fraunces Semibold, with the two "e"s in `kneadly` subtly rounded to echo thumbs. **App icon:** two overlapping hand silhouettes forming a soft arch, terracotta on warm sand, no gradient, no drop shadow — must read at 40pt.

**Voice:** *Warm expert.* A very good massage therapist who is also your friend. Plain words, short sentences, no wellness mysticism, no clinical coldness, never patronising.

| We say | We never say |
|--------|--------------|
| "Squeeze and roll, like kneading dough" | "Perform petrissage on the upper trapezius fibres" |
| "You should feel a deep, satisfying ache" | "Release your body's stored trauma" |
| "Stop if it's sharp" | "Push through the pain" |
| "Sit backwards on a dining chair" | "Assume a seated forward-flexed position" |

---

## 2. Colour

The palette is warm, low-saturation and skin-adjacent — it has to sit behind photographs of skin without fighting them.

### 2.1 Core ramp

| Token | Hex | Use |
|-------|-----|-----|
| `sand/50` | `#FBF8F4` | Light-mode app background |
| `sand/100` | `#F5EFE7` | Card background, light |
| `sand/200` | `#EBE1D5` | Dividers, inactive fills |
| `clay/200` | `#E3C8B7` | Body-map default fill |
| `clay/400` | `#D09A7C` | Hover / secondary accent |
| **`terracotta/500`** | **`#C0664A`** | **Primary. Buttons, active states, selected regions** |
| `terracotta/600` | `#A85539` | Pressed state |
| `terracotta/700` | `#8C4429` | Text on light when terracotta needed for contrast |
| `sage/300` | `#A9BFB0` | Sensation cue tint |
| **`sage/600`** | **`#5E8570`** | **Secondary. Safety, success, "you should feel"** |
| `sage/800` | `#33503F` | Safety card text |
| `ink/900` | `#14110F` | Dark-mode background |
| `ink/800` | `#1E1A17` | Dark-mode elevated surface |
| `ink/700` | `#2C2723` | Dark-mode card |
| `ink/500` | `#5C534C` | Secondary text, light mode |
| `ink/300` | `#8F847A` | Tertiary text, captions |
| `bone` | `#FFFDFA` | Text on dark, pure surfaces |

### 2.2 Pressure scale (semantic, never decorative)

| Level | Label | Hex | Plain-language anchor |
|-------|-------|-----|----------------------|
| 1 | Feather | `#8FB8A4` | Barely touching the skin |
| 2 | Light | `#B9C48D` | Stroking a cat |
| 3 | Medium | `#E0B15F` | Rubbing tired eyes |
| 4 | Firm | `#D08A4E` | Pressing a ripe avocado |
| 5 | Deep | `#C0664A` | Leaning on a stuck jar lid |

> The plain-language anchors are the important part. "Level 4 pressure" means nothing to a beginner; "like pressing a ripe avocado" means exactly the right thing.

### 2.3 Semantic
`caution` `#C87F5E` · `stop` `#B34A3F` · `info` `#5F7D91` · `locked` `#8F847A` @ 40%

### 2.4 Dark mode
Not an inversion — a **re-lighting**. Backgrounds go to warm near-black (`ink/900`), photographs get a `-8%` brightness and `+4%` warmth treatment, terracotta lifts to `#D4785C` to hold contrast, and all elevation is expressed with warm-tinted surfaces rather than shadows. Dark mode is the *expected* mode: most sessions happen at night in a dim room.

### 2.5 Contrast
All body text ≥ 4.5:1, all large text and glyphs ≥ 3:1, in both modes. Verified combinations:
`ink/900 on sand/50` = 15.8:1 · `bone on terracotta/500` = 4.7:1 · `sage/800 on sage/300` = 5.4:1 · `bone on ink/900` = 16.9:1.

---

## 3. Typography

| Role | Face | Size / Weight / Tracking |
|------|------|--------------------------|
| Display | **Fraunces** (SIL OFL, free) or **New York** (Apple system serif, zero-bundle) | 34pt Semibold, −0.4 |
| Title 1 | Fraunces / New York | 28pt Semibold, −0.3 |
| Step title | Fraunces / New York | 26pt Semibold, −0.3 |
| Title 2 | SF Pro | 22pt Semibold |
| Headline | SF Pro | 17pt Semibold |
| Body | SF Pro | 17pt Regular, line-height 1.47 |
| Callout | SF Pro | 16pt Regular |
| Subhead | SF Pro | 15pt Regular |
| Footnote | SF Pro | 13pt Regular |
| Overline | SF Pro | 11pt Semibold, +0.8 tracking, UPPERCASE |
| Numerals | SF Pro Rounded | Timers and counters only — tabular figures mandatory |

**Recommendation:** ship with **New York** for display. It is on every iOS device, costs 0 KB, supports every language we localise into, scales with Dynamic Type natively, and is genuinely beautiful. Bundle Fraunces only if brand differentiation demands it (adds ~180 KB and a subsetting step per language).

**Rules:** max 2 families on screen · body text never below 15pt · Dynamic Type supported to XXL everywhere, and to AX5 in the Step Player and Safety screens · line length ≤ 68 characters.

---

## 4. Spacing, radius, elevation

**Grid:** 4pt base. Scale: `4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 56 · 72`. Screen margin: 20pt. Card padding: 16pt. Section gap: 32pt.

**Radius:** `sm 8` (chips) · `md 12` (buttons, inputs) · `lg 16` (cards) · `xl 24` (hero cards, sheets) · `full 999` (pills, avatars).

**Elevation** — soft and warm, never grey:
```
e1  y2  blur 8   rgba(60,40,30,0.06)   cards
e2  y6  blur 20  rgba(60,40,30,0.10)   sheets, floating controls
e3  y12 blur 36  rgba(60,40,30,0.14)   modals
```
Dark mode: shadows → surface lightening (`ink/800`, `ink/700`) instead.

---

## 5. Iconography

**SF Symbols 6** as the base set (free, native, weight-matched to SF Pro, animate for free). Custom SVG only for the ~14 concepts SF Symbols lacks:

`hand-flat` · `hand-palm-heel` · `thumb-pad` · `double-thumb` · `knuckles` · `forearm` · `fingertips` · `c-grip` · `pincer-grip` · `cupped-hand` · `stroke-direction-arrow` · `pressure-dots` · `draping-towel` · `body-front-back-toggle`

Custom icons: 24×24 grid, 1.75pt stroke, rounded caps and joins, drawn to sit visually level with SF Symbols at `.regular` weight. Delivered as an SF Symbols custom symbol set (`.svg` in the symbol template) so they inherit Dynamic Type and weight automatically.

---

## 6. Photography direction

This is where most wellness apps fail, and it is the client's stated concern. **Every photo must pass all six rules:**

1. **Warm light only.** Golden, low, directional. No cool daylight, no white clinical studio light, no blue.
2. **Hands must be doing something.** A hand *on* a shoulder — mid-technique, showing pressure — not a hand hovering decoratively.
3. **Shallow depth of field.** f/1.8–2.8 look. Background falls away. This reads as premium instantly.
4. **Covered bodies.** Towel, sheet, or clothing in every frame. Non-negotiable, both for tone and for App Review (`07 § 5`).
5. **Real skin, real texture.** No plastic retouching, no stock-photo grins, no eye contact with camera.
6. **One consistent grade.** Every image passes through the same LUT: `+6 warmth · −10 saturation on greens · +4 shadow lift · slight film grain`. This is what makes 60 photos from 12 different photographers look like one app.

**Composition:** subject in the lower two-thirds so the bottom scrim carries text without covering the hands. 4:5 for step heroes, 3:2 for cards, 9:16 for onboarding full-bleeds.

Verified sources, exact URLs and the grading recipe: `05_VISUAL_ASSET_PLAN.md`.

---

## 7. The body map (signature asset)

- **Format:** SVG paths → SwiftUI `Path` / `Shape`, so they scale, animate and tint with zero raster assets.
- **Figures:** neutral, female, male — front and back = 6 base silhouettes.
- **Regions:** 19 content regions collapsed to 24 tappable paths (left/right split where it matters — shoulders, arms, legs, feet).
- **States:** `idle` (clay/200 fill, 1pt clay/400 outline) → `pressed` (clay/400) → `active` (terracotta/500 + 8pt outer glow @ 30%, 2s ease-in-out pulse) → `blocked` (clay/200 at 40% + diagonal hatch, for contraindicated regions).
- **Stroke-path overlay:** a dashed terracotta line with an arrowhead, animated with a marching-ants `phase` offset at 1 cycle/1.2s, plus a soft leading dot. This is the single most valuable custom visual in the app — it removes all ambiguity about direction.
- **Source options:** `MuscleMap` SwiftUI package (MIT, iOS 17+) or hand-drawn paths extracted from open-source anatomy SVGs. Both covered in `05 § 6`.

---

## 8. Components

| Component | Spec |
|-----------|------|
| `PrimaryButton` | Full-width, 56pt, radius 12, terracotta/500, bone label 17 Semibold, pressed → terracotta/600 + 0.97 scale, haptic `.light` |
| `SecondaryButton` | 56pt, transparent, 1.5pt terracotta/500 border, terracotta/700 label |
| `Chip` | 32pt, radius full, sand/100 bg, ink/500 label 13 Semibold, optional 14pt leading glyph |
| `RoutineCard` | 3:2 image, 16 radius, bottom scrim, title 17 Semibold bone, meta row (duration · mode · pressure), lock badge top-right when gated |
| `ProgramCard` | 240×160, illustrated cover, day-progress bar, terracotta accent |
| `PressureMeter` | 5 dots ⌀10pt, 6pt gap, filled = level colour, unfilled = sand/200, label 13 Semibold trailing |
| `TimerRing` | 72pt ⌀, 6pt stroke, sand/200 track, terracotta progress, drains counter-clockwise, tabular numeral centred |
| `BodyMapView` | § 7 |
| `StepTransitionCard` | 3s, next-step title + mini body map, sand/50 → sand/100 crossfade |
| `SensationCue` | Sage/300 @ 18% bg, 12 radius, 12pt padding, leading ⌀6 sage/600 dot, sage/800 text 15pt |
| `SafetyBanner` | Sage/300 @ 22% bg, `shield.checkered` glyph, always paired with an alternative action |
| `ModePicker` | 2×2 photo cards, 16 radius, selected = 2.5pt terracotta ring + checkmark |
| `ConsentSheet` | Two-tap ritual (`We're agreed` / `I'm ready`), each tap fills half a progress bar |
| `StreakRing` | 7 dots in an arc; completed = terracotta fill, today = terracotta ring, future = sand/200 |
| `Paywall` | § `02 § 10` |

---

## 9. Motion

**Principle: nothing snaps.** This is a relaxation app; every transition should feel like a slow exhale.

| Motion | Curve | Duration |
|--------|-------|----------|
| Screen push | `spring(response: 0.45, damping: 0.86)` | ~450ms |
| Sheet present | `spring(response: 0.5, damping: 0.85)` | ~500ms |
| Step advance | crossfade + 8pt upward drift | 400ms |
| Body-region select | `easeInOut` + glow pulse | 250ms select, 2s pulse loop |
| Stroke-path | linear `phase` loop | 1.2s/cycle |
| Timer ring | linear | continuous |
| Button press | `spring(response: 0.25, damping: 0.7)`, scale 0.97 | 200ms |
| Session complete | radial glow bloom, opacity + scale 1.0→1.06 | 900ms |

**Reduce Motion:** all springs → 200ms `easeInOut`; stroke-path → static arrow + text direction label; pulse → static glow; complete-bloom → simple fade.

---

## 10. Haptics (CoreHaptics)

| Event | Pattern |
|-------|---------|
| Body region tap | `.light` transient |
| Step advance | `.medium` transient |
| 15s tick during a step | very soft transient @ 0.25 intensity |
| 5s remaining | double transient, 80ms apart |
| Step complete | ascending two-tap |
| Session complete | custom 1.2s: three soft swells, decreasing |
| Rhythm guide (Plus) | optional continuous pulse at the step's stroke tempo — **the giver can match their hands to their pocket.** A small idea with outsized value |
| Warning / blocked | sharp single `.rigid` |

---

## 11. Localisation & RTL

- All strings in `Localizable.xcstrings` (String Catalog). **Zero hardcoded strings** — enforced by SwiftLint rule.
- Ship English at launch; **Arabic is a priority-1 follow-up** and RTL support is built from day one: leading/trailing everywhere (never left/right), body-map stroke-path arrows mirrored, layout mirrored, numerals localised.
- Body-part names use a localisation glossary reviewed by a native speaker with medical vocabulary — anatomical terms are the highest-risk translation category in this app.
- Voice narration recorded per language (or high-quality TTS as a v1 fallback, with real voice from v1.2).
- Allow +40% text expansion for German; step-title lint enforces ≤ 6 words *after* translation.

---

## 12. Accessibility checklist (ship-blocking)

- [ ] Every image has a meaningful `accessibilityLabel` describing the hand position, not "photo"
- [ ] Body map regions are individually focusable with correct labels and `.isButton` traits
- [ ] Step Player has a custom rotor for step navigation
- [ ] Dynamic Type to XXL app-wide; AX5 in Step Player and Safety
- [ ] Reduce Motion, Reduce Transparency and Increase Contrast all honoured
- [ ] Colour never the sole meaning carrier (pressure dots are labelled)
- [ ] All tap targets ≥ 44×44pt
- [ ] Full VoiceOver walkthrough of a complete session recorded and reviewed each release
- [ ] Voice guidance works with the screen off and locked — **this is also a core feature, not just an accessibility one**
