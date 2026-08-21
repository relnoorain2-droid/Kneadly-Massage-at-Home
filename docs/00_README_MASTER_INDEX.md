# KNEADLY — Guided Body Massage App for iOS
### Complete Product, Design, Content & Engineering Documentation
**Platform:** iOS (Swift 6 / SwiftUI, iOS 17+) · **Version:** 1.0 Specification · **Date:** August 2026

> *"Kneadly"* is a working name. It appears in exactly one place in code (`AppBrand.swift`) and one place in this doc set (`03_DESIGN_SYSTEM.md § 1`), so it can be swapped in minutes. Alternates evaluated in `01 § 1.4`.

---

## What this app is, in one paragraph

Kneadly teaches ordinary people how to give and receive a real, safe, effective massage — **on themselves, on a partner, on a friend, on a parent** — using nothing but their hands, a bed or a chair, and 10 minutes. Every technique is broken into numbered steps. Every step shows a **photograph of the real hand position** plus an **illustrated body diagram with the exact target zone, stroke direction and pressure level marked on it**. A timer runs. A voice talks you through it. You cannot get lost, and you cannot accidentally do something unsafe, because the app screens for contraindications before it ever shows you a stroke.

---

## Document map — read in this order

| # | Document | What it answers |
|---|----------|-----------------|
| **00** | *This file* | Index, glossary, how the pieces fit |
| **01** | `01_PRODUCT_STRATEGY.md` | Who it's for, why they'd pay, competitive gap, naming, monetization, KPIs |
| **02** | `02_UX_FLOWS_AND_SCREENS.md` | Every screen from first launch to session complete, with wireframe-level detail |
| **03** | `03_DESIGN_SYSTEM.md` | Colors, type, spacing, components, motion, dark mode, accessibility |
| **04** | `04_MASSAGE_CONTENT_LIBRARY.md` | **The heart of the app.** All 17 body regions, 19 techniques, all 4 modes, 62 routines, 9 programs, the exact anatomy of one instruction step |
| **05** | `05_VISUAL_ASSET_PLAN.md` | **Your image problem, solved.** Every image the app needs, where to get it free, verified URLs, licenses, and an AI-generation prompt kit for consistent step art |
| **06** | `06_IOS_ARCHITECTURE_SWIFT.md` | SwiftUI architecture, data models, JSON content schema, SPM packages, code samples |
| **07** | `07_SAFETY_LEGAL_COMPLIANCE.md` | Contraindications engine, consent design, medical disclaimers, App Store Guideline 1.1.4 survival plan |
| **08** | `08_BUILD_ROADMAP.md` | 14-week MVP plan, sprint-by-sprint, team, cost, launch checklist |

**Also delivered:**

- `prototype/index.html` — clickable iPhone prototype, onboarding → full guided session, with real photography loaded
- `prototype/docs-hub.html` — this entire document set as a styled, searchable web page

---

## The four modes — the thing that makes this app different

Almost every massage app on the App Store is a *booking* app (find a therapist) or a *self-massage* app (foam rolling). Kneadly is a **doing** app, and it is built around who is in the room:

| Mode | Icon | Who | Design consequence |
|------|------|-----|--------------------|
| **Solo** | hand raised | You, on yourself | Steps must be reachable one-handed; phone propped or voice-only; no draping needed |
| **Partner** | two hands | Spouse / romantic partner | Two-sided UI: *Giver view* and *Receiver view*; intimacy-appropriate but never explicit; draping guidance; consent + pressure check-ins |
| **Friends & Family** | handshake | Friend, sibling, parent, colleague | **Fully clothed by default.** Chair-based and over-clothing routines promoted first. Neutral language, zero intimacy framing |
| **Together** | infinity | Both people at once | Back-to-back seated, hand-exchange, foot-swap. No one is "the therapist" |

Mode is chosen at session start and **changes the content, the imagery, the language, the draping instructions, and the safety copy** — not just a label. See `04 § 3`.

---

## Head-to-toe coverage at a glance

**17 body regions** → **19 massage traditions/techniques** → **62 routines** → **9 multi-day programs**

```
HEAD      1 Scalp & Head      2 Face & Sinus      3 Jaw / TMJ      4 Ears
NECK      5 Neck (front & sides)                  6 Suboccipitals (skull base)
TORSO     7 Shoulders & Upper Trapezius           8 Upper Back / Between Shoulder Blades
          9 Mid & Lower Back                     10 Chest & Sternum      11 Abdomen
ARMS     12 Upper Arm (delt/bicep/tricep)        13 Forearm & Elbow      14 Hand, Wrist & Fingers
HIPS     15 Glutes, Hips & Piriformis
LEGS     16 Thigh (quad / hamstring / IT band / adductor)   17 Knee
         18 Calf & Shin
FEET     19 Ankle, Arch, Plantar Fascia & Toes
```
*(Regions 5+6 and 16+17+18 collapse into 4 map zones in the UI; the content library keeps them separate. Full table: `04 § 2`.)*

---

## The single most important screen: the Step Player

Everything else in the app exists to deliver the user to this screen. It has **nine** simultaneous information channels, and getting them to coexist without clutter is the entire design challenge:

1. **Hero photograph** — a real human hand, in the real position, on the real body part
2. **Body map overlay** — silhouette with the target zone glowing, so there is no ambiguity about *where*
3. **Stroke-path animation** — an animated arrow/line showing the motion and its direction
4. **Step counter** — "Step 4 of 9"
5. **Countdown ring** — 45s, with the ring draining around the play button
6. **Pressure meter** — 1–5 dots, colored, with a plain-language label ("Firm — like pressing a ripe avocado")
7. **Instruction text** — max 2 sentences, 8th-grade reading level
8. **"You should feel…"** — the receiver's expected sensation, which is how a beginner self-corrects
9. **Voice narration** — hands-free, because the user's hands are literally busy

Full spec with the layout rules that keep this calm rather than chaotic: `02 § 7` and `03 § 8`.

---

## Glossary (used consistently across all 8 documents)

| Term | Meaning |
|------|---------|
| **Giver** | The person performing the massage |
| **Receiver** | The person being massaged |
| **Region** | A body area (e.g. *Calf & Shin*) |
| **Technique** | A named tradition or method (e.g. *Effleurage*, *Shiatsu*, *Reflexology*) |
| **Step** | One atomic instruction with one visual, one duration, one pressure level |
| **Routine** | An ordered set of steps for one region + one mode (e.g. *Neck & Shoulder Reset — Partner, 12 min*) |
| **Program** | A multi-day sequence of routines with a goal (e.g. *7 Nights to Better Sleep*) |
| **Session** | One completed run of a routine, logged with date, duration, mode and feedback |
| **Draping** | Towel/sheet coverage that keeps the receiver covered except the area being worked |
| **Contraindication** | A condition where massage must be avoided (absolute), modified (relative), or avoided in one spot (local) |
| **Pressure Scale** | 1–5 internal scale, mapped to plain language and to the receiver's 1–10 verbal scale |

---

## Non-negotiable product principles

1. **Safety gates content, not the reverse.** The contraindication check runs before the routine list renders, not as a dismissible popup afterwards.
2. **Never show a stroke without showing where.** No text-only instructions, ever. If there is no visual for a step, the step does not ship.
3. **Hands-free by default.** Voice narration and auto-advance are ON out of the box. A user with oily hands cannot tap a phone.
4. **Clothed-first for non-romantic modes.** Friends & Family mode never suggests removing clothing.
5. **Wellness, never sexual.** This is a hard line — it is also what keeps the app on the App Store. See `07 § 5`.
6. **Offline-first.** A massage happens in a bedroom with the phone on airplane mode. Everything core must work with no network.
7. **No account to start.** First session in under 90 seconds from install.
