# 02 — UX Flows & Screen Specifications
*Kneadly · iOS · v1.0 · Every screen from cold launch to session complete*

---

## 1. Information architecture

```
LAUNCH
 └─ First run? ──YES──> ONBOARDING (7 screens, ~75 seconds)
                          └─> SAFETY SCREENING (blocking, 1 screen + conditional)
                              └─> FIRST SESSION SUGGESTION ──> STEP PLAYER
    └────────NO──────────> HOME (Tab 1)

TAB BAR (4 tabs — no more; a 5th tab is where wellness apps go to die)
├── ① TODAY        Home / recommendation surface
├── ② BODY         Interactive body map → region → routines
├── ③ LEARN        Techniques, oils, positions, safety, glossary
└── ④ ME           History, streaks, programs in progress, partners, settings

MODAL / FULL-SCREEN COVER (never a tab)
├── MODE PICKER          (who is in the room?)
├── ROUTINE DETAIL       (preview + "what you'll need")
├── SESSION PREPARE      (position, draping, oil, consent)
├── STEP PLAYER          ← the core screen
├── SESSION COMPLETE     (celebration + feedback + paywall trigger)
└── PAYWALL
```

**Why 4 tabs:** TODAY answers *"what should I do now?"*, BODY answers *"my X hurts"*, LEARN answers *"how do I do this properly?"*, ME answers *"what have I done?"*. Every user need maps to one of these four.

---

## 2. Onboarding — 7 screens, ~75 seconds

Design rules for this whole flow: **full-bleed photograph, text over a bottom scrim, one idea per screen, progress dots at top, "Skip" only from screen 3 onwards.** No sign-up. No email. No permission requests except the two we actually need, asked in context.

### O1 — Welcome
- **Visual:** Full-bleed warm photograph — hands resting on a shoulder, low warm light, shallow depth of field. *(Asset `img.onb.01` — see `05 § 4.1`.)*
- **Headline:** *"Good hands aren't a talent."*
- **Sub:** *"They're ten steps and a bit of guidance. Let's teach yours."*
- **CTA:** `Begin` (primary, full width, bottom, 56pt tall)
- **Micro:** `Already have Kneadly Plus? Restore` (text link, small, bottom)

### O2 — Who will you be massaging?
This is the most important onboarding question — it sets the entire content slant.
- **Visual:** Four large cards in a 2×2 grid, each with its own photograph and icon.
- **Cards:** `Myself` · `My partner` · `A friend or family member` · `Both of us together`
- **Multi-select allowed.** Most users pick 2.
- **Copy under grid:** *"You can change this any time — nothing is locked."*

### O3 — Where does it hurt?
- **Visual:** The interactive body silhouette (the app's signature asset) — front view, tappable regions, muted by default, tapped regions glow terracotta.
- **Interaction:** Tap up to 3. A front/back toggle sits top-right. Regions animate a soft pulse when selected.
- **Copy:** *"Tap up to three spots. We'll start there."*
- **Skip:** *"Nothing hurts, I just want to relax"* → tags user into the *Relaxation* content slant instead of the *Relief* slant.

### O4 — How much time do you usually have?
- Three cards: `5–10 min · A quick reset` / `15–20 min · A proper session` / `30+ min · The full experience`
- Sets the default routine-length filter everywhere in the app.

### O5 — Experience level
- `Complete beginner` / `I've done this a bit` / `I know what I'm doing`
- **Consequence:** Beginner = longer step durations, more "you should feel" cues, mandatory technique primer before first routine, lower default pressure cap (3/5). Advanced = compact steps, optional primers, full pressure range.

### O6 — Safety screening ← **BLOCKING, cannot skip**
- **Visual:** Calm, clinical, no photo. A soft sage-tinted card. This screen intentionally looks different from the rest — it should feel like it matters.
- **Headline:** *"Two quick health questions."*
- **Sub:** *"Massage is safe for almost everyone. These questions make sure it's safe for you."*
- **Q1 — checkbox list (multi-select, plain language, no medical jargon):**
  `Pregnant or recently gave birth` · `Blood clot, DVT, or on blood thinners` · `Cancer, current or recent treatment` · `Heart condition or uncontrolled blood pressure` · `Recent surgery or fracture (last 3 months)` · `Diabetes with nerve or circulation issues` · `Skin condition, open wound, rash, or infection` · `Currently have a fever or infection` · `Osteoporosis` · `None of these apply to me`
- **Q2 — conditional:** if anything is checked, a follow-up asks for the affected body area so the engine can apply a *local* rather than *global* restriction.
- **Outcome:** feeds the Contraindication Engine (`07 § 2`). Certain answers hard-block certain routines with a clear, non-alarming explanation and a safe alternative offered in the same card. **We never just say "no" — we always offer the modified version.**
- **Storage:** local only, never transmitted. Editable later in ME → Health.

### O7 — Notifications + you're ready
- Soft-ask first (**never** the raw iOS prompt cold): *"Want a gentle nudge at your wind-down time?"* with a time picker defaulting to 21:30. `Yes, remind me` triggers the system prompt; `Not now` skips it entirely.
- Then: **"You're ready."** with a single suggested routine card built from O2+O3+O4+O5, e.g. *"Neck & Shoulder Reset · Partner · 12 min · Beginner."*
- CTA: `Start my first massage` → straight into SESSION PREPARE.

> **Target: 80% completion, 60% starting a session immediately.** Everything above is optimized for that single number.

---

## 3. TAB ① — Today

Scrolling feed, warm and calm, never more than ~5 cards before the fold on an iPhone 15.

1. **Greeting strip** — *"Good evening, Noorul"* + a single line of state: *"3-day streak · 47 minutes this week"*. Time-aware (morning/afternoon/evening changes both copy and the background gradient).
2. **Continue card** (only if a program or unfinished session exists) — *"7 Nights to Better Sleep · Night 3 of 7"* with a progress bar.
3. **Today's suggestion** — one large hero card, full-bleed photo, routine name, duration chip, mode chip, pressure chip. **One suggestion, not three.** Decision fatigue is the enemy at 10pm.
4. **Mode quick-switch row** — 4 pills: `Solo · Partner · Friends · Together`. Tapping filters the whole feed below.
5. **"Because you said your lower back hurts"** — horizontal carousel of 4–6 routines.
6. **Programs** — horizontal carousel of program cards with a subtle illustrated cover.
7. **Learn something** — one technique card (*"Effleurage: the stroke that starts everything"*) linking into LEARN.
8. **Your week** — a compact 7-dot streak visualisation + total minutes.

---

## 4. TAB ② — Body (the signature screen)

- **Full-screen interactive body map.** Gender-neutral silhouette by default; a settings toggle offers male / female / neutral figures. Front/back toggle as a floating segmented control, bottom-right.
- **Regions** are tappable SVG paths. Default state: soft clay fill, thin outline. Hover/press: terracotta glow + haptic tick. Selected: solid terracotta with a subtle pulse.
- **Tension heat overlay** (Plus): regions the user has logged as sore recently render with a warm heat gradient, so the map becomes a personal record.
- **Tap a region** → bottom sheet slides to 45% height:
  - Region name + a one-line anatomy note (*"Upper trapezius — the muscle that carries your stress and your handbag"*)
  - Mode filter pills
  - List of routines for that region, each row: thumbnail · name · duration · mode icon · pressure dots · lock badge if Plus
  - `Learn about this area` link → LEARN
- **Drag the sheet up to full screen** for the complete list.
- **Search icon** top-right: search by symptom, not just body part — *"headache", "can't sleep", "sore after gym", "period cramps", "sat at a desk all day"*. Symptom→routine mapping table is in `04 § 8`.

---

## 5. TAB ③ — Learn

Four sections, card-grid layout, each card a beautiful photo or illustration:

1. **Techniques (19)** — Swedish, Deep Tissue, Trigger Point, Shiatsu, Reflexology, Thai, Lymphatic, Indian Head, Abhyanga, Gua Sha, Lomi Lomi, Sports, Chair, Prenatal, Hot Stone, Cupping, Craniosacral, Aromatherapy, Self-Myofascial. Each opens a detail page: what it is · origin · what it's good for · what it feels like · a 60-second "try it now" mini-routine.
2. **The Basics** — Hand positions (10 illustrated: flat palm, palm heel, thumb pad, double thumb, knuckles, forearm, fingertips, C-grip, pincer grip, cupped hand) · Pressure & communication · Positions & propping · Draping & modesty · Rhythm & breathing.
3. **Oils & Prep** — Carrier oils compared, essential-oil dilution table, allergy patch test, what to never use, setting the room, temperature, towel and sheet setup.
4. **Safety** — Contraindications explained in plain language, when to stop immediately, when to see a doctor, pregnancy chapter, working with older bodies, aftercare.

---

## 6. Session Prepare (full-screen cover, 3 steps)

The bridge between "I want a massage" and "I'm being massaged." Skipping this is why home massages fail.

**P1 — Get set up**
- Illustrated checklist with satisfying tick-off animation: `Towel or sheet` · `Oil or lotion (optional)` · `Warm room` · `Phone propped where you can see it` · `Nails short, hands warm, rings off`
- A "what you'll need" chip row derived from the routine's metadata.

**P2 — Position**
- A clear illustration of the exact position (prone on bed with a pillow under the chest and ankles / supine / side-lying with a pillow between the knees / seated backwards on a dining chair / seated on the floor).
- Propping notes: *"A pillow under the ankles takes the strain out of the lower back."*
- Draping instructions — **mode-dependent.** Friends & Family mode says *"stay fully clothed; this routine works over a t-shirt."*

**P3 — Agree the rules (Partner / Friends / Together modes only)**
- **The consent + communication card.** Not a legal checkbox — a genuinely useful ritual:
  - *"Agree a number scale now: 1 is barely there, 10 is too much. Aim for 6 or 7."*
  - *"Agree a stop word. 'Stop' works fine."*
  - *"Receiver: you're in charge. Speak up early, not after it hurts."*
  - Giver taps `We're agreed`, receiver taps `I'm ready` — **two taps, one from each person.** This tiny bit of ceremony measurably improves session quality and is a genuinely novel interaction.
- Solo mode replaces this with a 15-second breathing settle.

`Start` → STEP PLAYER.

---

## 7. THE STEP PLAYER — core screen specification

The screen the whole product exists to deliver. Portrait-locked, screen stays awake, Do Not Disturb suggested.

### 7.1 Layout (top → bottom)

```
┌─────────────────────────────────────────────┐
│  ✕            Step 4 of 9            ⋯      │  44pt · close, counter, options
│  ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░                     │  3pt segmented progress bar
├─────────────────────────────────────────────┤
│                                             │
│         HERO VISUAL   (aspect 4:5)          │  Real photograph of the hand position
│                                             │
│    ┌──────────┐                             │
│    │ BODY MAP │  ← inset card, 88×112pt,    │  Silhouette, target zone glowing,
│    │  overlay │    bottom-left, 12pt inset  │  animated stroke-path arrow
│    └──────────┘                             │
│                              ┌────────────┐ │
│                              │ ⏱ 0:38     │ │  Countdown pill, top-right of image
│                              └────────────┘ │
├─────────────────────────────────────────────┤
│  UPPER TRAPEZIUS · PETRISSAGE               │  Overline · 11pt · letterspaced
│  Squeeze and roll the muscle                │  Title · 26pt serif
│                                             │
│  Grip the top of the shoulder between your  │  Body · 17pt · max 2 sentences
│  thumb and fingers. Squeeze, lift slightly, │
│  and roll — like kneading dough.            │
│                                             │
│  ● You should feel: a deep, satisfying ache │  Sensation cue · sage tint
│    that eases as you work. Never sharp.     │
│                                             │
│  PRESSURE  ●●●○○  Firm                      │  5 dots, filled = level
│  RHYTHM    ~1 squeeze per second            │
├─────────────────────────────────────────────┤
│   ↺ Repeat      ▶ / ⏸  (ring)      Next →   │  Transport · 72pt tall
│   🔊 Voice on          👁 Giver view         │  Secondary toggles
└─────────────────────────────────────────────┘
```

### 7.2 The nine information channels and how they stay calm

The risk is visual noise. The rules that prevent it:

1. **Only one thing moves at a time.** The stroke-path arrow animates; the timer ring drains. Nothing else animates during a step.
2. **The body map is small and always in the same corner.** It is a reference, not a feature. Tap to expand it full-screen if needed.
3. **Text is capped**: title ≤ 6 words, body ≤ 2 sentences / 200 characters, sensation cue ≤ 90 characters. Enforced by a content lint rule in CI (`06 § 9`).
4. **Pressure and rhythm are glyphs, not paragraphs.**
5. **Voice carries the nuance.** Anything longer than 2 sentences goes into the narration script, not onto the screen.

### 7.3 Behaviour

| Behaviour | Spec |
|-----------|------|
| Auto-advance | ON by default. Timer ends → 3s "changing position" transition card → next step |
| Transition card | Shows next step's title + body map, gives the giver time to move hands |
| Voice | On by default. Reads title, body, then pressure. Re-reads a shortened cue at the halfway point of long steps |
| Haptics | Soft tick each 15s; double-tick at 5s remaining; success pattern at step end |
| Repeat | Restarts the current step timer. Logged as `step_repeated` — high repeat rate on a step means the instruction is unclear, and is a content-quality signal |
| Swipe | Left/right swipes move between steps. Swipe down = pause |
| Pause | Dims to a calm pause card: `Resume` · `Skip this step` · `End session` |
| Screen | `isIdleTimerDisabled = true` for the whole session |
| Ambience | Optional background audio (rain, low drone, ocean) mixed under narration, ducking automatically |
| **Giver / Receiver view** | Partner modes only. Toggle flips the screen to the receiver's perspective: large text, minimal UI, *"Breathe out as they press. Tell them if it's above a 7."* Designed to be readable from a face-down position with the phone on the floor |
| Live Activity | Session appears in Dynamic Island / Lock Screen: routine name, step counter, time remaining |
| Watch | Companion shows step title, timer, pressure dots; wrist tap on step change |

### 7.4 Accessibility in the player
- VoiceOver reads the full step in a logical order with a custom rotor for step navigation.
- Dynamic Type up to XXL supported; hero image shrinks, text never truncates, layout switches to scrolling above XL.
- Reduce Motion replaces the stroke-path animation with a static arrow + a "direction" text label.
- Colour is never the sole carrier of meaning: pressure dots are filled/unfilled *and* labelled.

---

## 8. Session Complete

- **Visual:** a soft radial glow bloom, calm haptic success, no confetti (wrong emotional register for a relaxation app).
- **Headline:** *"Done. 12 minutes, 9 steps."*
- **Feedback — two taps maximum:**
  1. *"How does it feel now?"* → 3 large emoji-free glyph buttons: `Better` / `Same` / `Worse` (Worse routes to a gentle safety note + "when to see someone")
  2. *"Pressure was…"* → `Too light` / `Just right` / `Too firm` → **this directly tunes the default pressure of future routines for this user.** A genuinely personalising loop from a single tap.
- **Aftercare card:** *"Drink some water. Give it 20 minutes before anything strenuous."*
- **Log:** written to history, streak updated, HealthKit mindful minutes written (if authorised).
- **Then:** paywall (first session only), or *"Tomorrow: Night 4 — Lower Back Release"* if in a program.

---

## 9. TAB ④ — Me

- Streak ring + total minutes + sessions count, rendered as a calm stat row (no gamified aggression).
- **Programs in progress** with day-by-day progress.
- **History** — grouped by week; each row shows routine, mode, duration, and the feel-after result.
- **Body heat record** — a small body map showing which regions get worked most and which get neglected (*"You haven't touched your feet in 3 weeks"* is a great re-engagement hook).
- **Partners** — named local profiles (*"Omar"*) storing his pressure preference, sensitive areas, and contraindications, so partner sessions auto-tune. **Stored locally only, never synced.**
- **Settings** — voice & language, ambience, units, figure style, haptics, reminders, health answers, downloads, subscription, legal.

---

## 10. Paywall

- **Visual:** full-bleed hero photo (warm, hands, low light), dark scrim, content bottom-anchored.
- **Headline:** *"61 more routines. Both of your hands."*
- **Four benefit rows with icons** — not a feature table. `Every routine, head to toe` · `Partner & couples modes` · `Multi-day programs` · `Offline + voice guidance`
- **Plan selector:** annual pre-selected with a `SAVE 58%` badge; monthly and lifetime as smaller adjacent options.
- **CTA:** `Start 7-day free trial` + microcopy *"Cancel anytime. We'll remind you 2 days before it ends."*
- **Below:** `Restore purchases` · `Terms` · `Privacy` — required by App Review, small but present and tappable.
- **Dismiss:** a real, obvious `✕` at top-left. Hidden or delayed close buttons are a rejection risk and a review-score killer.

---

## 11. Empty, error and edge states

| State | Treatment |
|-------|-----------|
| No network | Everything core works. A quiet banner: *"Offline — your downloaded routines are ready."* Never a blocking error |
| No history yet | Illustration + *"Your first session will show up here."* + a suggested routine |
| Routine locked | Blurred hero with a lock chip; tapping opens the contextual paywall for that routine |
| Contraindication blocks a routine | Sage card, calm tone: *"We're skipping deep pressure on your calves while you're on blood thinners. Here's a gentle version instead."* + `Why?` link. **Always offer the alternative in the same card** |
| Session interrupted by a call | Auto-pause, resume banner on return |
| Low battery <10% during session | Offer audio-only mode |
| First launch, iPad | v1 is iPhone-only (portrait). iPad ships in v1.2 with a two-pane layout |
