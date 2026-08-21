# 01 — Product Strategy
*Kneadly · iOS · v1.0*

---

## 1. Positioning

### 1.1 The problem, stated honestly

Two people who love each other sit on a bed. One says *"my neck is killing me."* The other says *"want me to rub it?"* — and then spends four minutes squeezing the wrong muscle with the wrong part of their hand in the wrong direction, until both of them give up.

That is the entire market. It is enormous, it is universal, and nothing on the App Store addresses it well. The knowledge exists (it's taught in 500-hour massage certifications) but it has never been packaged as *ten numbered steps with a picture on each one.*

### 1.2 The one-line positioning

> **Kneadly turns anyone's hands into good hands — in ten minutes, with pictures.**

### 1.3 What we are and are not

| We ARE | We are NOT |
|--------|------------|
| A step-by-step **teaching + doing** app | A therapist booking marketplace |
| For **hands on skin** (and hands on clothes) | A massage-gun / percussion device companion |
| **Two-person capable** (the differentiator) | A meditation app that happens to mention massage |
| Anatomically specific and safety-screened | Medical treatment or physiotherapy |
| Wellness, intimacy, and relief | Anything sexual — hard line, see `07 § 5` |

### 1.4 Naming

The working name is **Kneadly** (knead + -ly; the pun is obvious in English, reads as a real brand, short, App-Store-searchable, and the "kneading" motion is a literal massage technique — *petrissage*).

Alternates that were considered and remain viable:

| Name | Read | Risk |
|------|------|------|
| **Kneadly** ← recommended | Warm, clever, memorable | Pun may not translate outside English |
| **Sukha** (Sanskrit: *ease, comfort*) | Premium, global, wellness-native | Less descriptive; pronunciation |
| **Palmly** | Soft, modern, app-like | Sounds like a plant app |
| **Hands On** | Instantly descriptive | Generic, poor SEO, likely taken |
| **Anmo** (按摩, Chinese for massage) | Short, authentic, unique | Meaningless to Western users |

**Action:** run a quick App Store + trademark check on the final choice before Sprint 1. The name lives in `AppBrand.swift` and can be changed globally in under an hour.

---

## 2. The people we're building for

### 2.1 Primary — "Maryam & Omar", the couple with a sore neck
- 28–45, live together, both work at screens.
- One or both have chronic neck/shoulder/lower-back tension.
- They *want* to do this for each other. Willingness is not the barrier — **competence is.**
- Have tried YouTube: 14-minute video, hands off-camera, therapist talking about fascia, no idea where to pause.
- **What they need:** a step counter, a timer, and a picture of exactly where to put their thumb.
- **Will pay for:** the partner routines. This is the paywall.

### 2.2 Primary — "Sara", solo and self-sufficient
- 24–40, lives alone or partner unavailable, desk job or nursing/retail (on feet all day).
- Wants relief at 11pm without booking anything or leaving the house.
- **What she needs:** self-reachable routines, one-handed, in bed, with the lights low.
- **Will pay for:** programs (7-night sleep, headache relief) and offline voice guidance.

### 2.3 Secondary — "Danish", the caregiver
- Cares for an ageing parent or a partner with a condition. Wants to help with circulation, swelling, comfort.
- **What he needs:** gentle, safety-first content; explicit "stop if…" rules; lymphatic and chair-based routines.
- Highest safety sensitivity of any persona. Drives the contraindication engine design.

### 2.4 Secondary — "Aisha & friends", social/wellness
- 20–35, wellness-curious, does face gua sha, buys oils, follows spa content.
- **What she needs:** face/scalp/hand routines, beautiful imagery, something shareable.
- Drives the visual quality bar — **this persona will uninstall over ugly images.** She is the reason `05_VISUAL_ASSET_PLAN.md` exists.

### 2.5 Anti-persona (explicitly not served)
- Anyone looking for erotic content. Actively designed out: language, imagery, search terms, and store metadata all steer away. See `07 § 5`.
- Licensed therapists seeking CE credit. Different product.

---

## 3. Competitive landscape and the gap

| Category | Examples | What they do | The gap we fill |
|----------|----------|--------------|-----------------|
| Booking marketplaces | Soothe, Zeel, Urban | Send a therapist to you | Costs $100+/visit, needs booking, not available at 11pm |
| Self-massage / mobility | Pliability, GOWOD, roll-recovery apps | Foam roller & stretch libraries | Tool-dependent, sports-framed, **no partner mode**, no hands-on technique |
| Massage-gun companions | Theragun, Hypervolt apps | Where to point the device | Requires a $200 device |
| YouTube / TikTok | Thousands of channels | Free, deep | Unstructured, no timer, no step counter, no safety screening, terrible to follow with oily hands |
| Reflexology / acupressure point apps | Various | Point charts | Static reference images, no routine, no guidance, visually dated |

**The gap, precisely:** *nobody has built a guided, timed, illustrated, two-person massage instructor.* Partner mode is the moat — it is also the hardest thing to build, because it needs two viewpoints, consent design, draping guidance, and imagery that is warm without being sexual.

---

## 4. Monetization

### 4.1 Model — freemium subscription (StoreKit 2)

**Free forever (the hook must be genuinely useful):**
- Full body map browsing + anatomy education
- Complete safety & contraindication library (never paywall safety)
- 5 complete starter routines:
  1. Neck & Shoulder Reset — *Solo*, 8 min
  2. Foot Relief — *Solo*, 10 min
  3. Back Basics — *Partner*, 12 min
  4. Hand & Wrist Reset — *Solo*, 5 min (for phone/keyboard users)
  5. Scalp & Head Wind-Down — *Partner*, 7 min
- Session history (last 7 days)
- Oils & preparation guide

**Kneadly Plus:**

| Plan | Price (USD) | Notes |
|------|-------------|-------|
| Monthly | $9.99 | Anchor price |
| Annual | $49.99 | *"$4.17/mo — 58% off"*. **Target: 70%+ of conversions** |
| Lifetime | $99.99 | Meaningful revenue from commitment-averse users |
| 7-day free trial | — | On annual only, with Day-5 reminder notification |

**Plus unlocks:** all 62 routines · all 9 programs · all 4 modes · offline downloads · voice guidance in all languages · Apple Watch companion · custom routine builder · unlimited history & streaks · Live Activity.

**Family Sharing: ON.** This is a two-person app; making a couple buy twice is hostile and would show up in reviews.

### 4.2 Why not ads, not one-time purchase
- Ads inside a relaxation session destroy the product. Non-starter.
- One-time purchase kills the funding for continuous content (new routines are the retention engine).

### 4.3 Paywall placement (tested order)
1. **Not on launch.** First-session-before-paywall is the single biggest lever on D1 retention.
2. After the **first completed session**, on the celebration screen, while endorphins are high: *"That's one. Here are 61 more."*
3. On any locked routine tap — contextual, showing that specific routine's hero image.
4. Soft prompt at Day 3 streak.

### 4.4 Unit economics targets (first 12 months)

| Metric | Target |
|--------|--------|
| Install → first session completed | ≥ 55% |
| Free → trial start | 6–9% |
| Trial → paid | 45–55% |
| Blended install → paid | 3–4% |
| Annual plan share of conversions | ≥ 70% |
| Month-12 subscription retention (annual) | ≥ 55% |
| Target blended LTV | $28–36 |
| Max sustainable CPI | $8 |

---

## 5. Success metrics

### 5.1 North Star
> **Weekly Completed Sessions per Active User (WCSU).** Target: ≥ 2.4 by Month 6.

Chosen because it captures the only thing that matters — did somebody actually get massaged. Not opens, not minutes, not streaks.

### 5.2 Supporting KPIs

| Layer | Metric | Target |
|-------|--------|--------|
| Acquisition | App Store page → install conversion | ≥ 32% |
| Activation | Onboarding completion | ≥ 80% |
| Activation | First session started within 5 min of install | ≥ 60% |
| Activation | First session **completed** (not abandoned) | ≥ 55% |
| Engagement | Step-level drop-off (any single step) | ≤ 8% |
| Engagement | Partner-mode sessions as % of total | ≥ 30% *(proves the differentiator)* |
| Engagement | Voice guidance enabled | ≥ 70% |
| Retention | D1 / D7 / D30 | 45% / 25% / 14% |
| Quality | Post-session "did that help?" positive | ≥ 85% |
| Quality | App Store rating | ≥ 4.6 |
| Safety | Contraindication screening completion | 100% (blocking) |

### 5.3 Instrumentation events (v1)
`onboarding_step_viewed` · `mode_selected` · `contraindication_flagged` · `routine_opened` · `session_started` · `step_advanced` · `step_repeated` · `session_paused` · `session_completed` · `session_abandoned{step_index}` · `pressure_feedback_given` · `paywall_shown{trigger}` · `trial_started` · `purchase_completed` · `voice_toggled` · `download_offline`

**Privacy:** all analytics anonymous, no health conditions ever leave the device (contraindication answers are stored in the Keychain-protected local store and are never transmitted, only the boolean `flagged` count is). See `07 § 6`.

---

## 6. Launch strategy (brief)

**Phase 1 — Soft launch (Weeks 1–4):** Canada, Australia, Ireland, UAE. Tune onboarding and paywall on cheap traffic. 500–1,000 installs/week target.

**Phase 2 — Global (Week 5):** English first. Localization order by wellness-app ARPU: **German, Spanish, French, Portuguese (BR), Arabic, Japanese, Korean.** Arabic is high priority given the couples/home-wellness framing and RTL is a design requirement from day one (see `03 § 11`).

**Phase 3 — Growth:**
- **ASO keywords:** *massage tutorial, couples massage, self massage, neck pain relief, back massage guide, foot reflexology, partner massage, acupressure, massage at home.* (Deliberately excluded: any erotic-adjacent term — see `07 § 5.3`.)
- **Content marketing:** short vertical video is the perfect medium for this product. A 20-second "3 thumb presses that kill a tension headache" clip *is* the app.
- **Apple pitch:** submit for "Apps We Love" / Health & Fitness featuring. This app has a strong featuring story: beautiful, useful, novel category, deeply iOS-native (Live Activities, Watch, HealthKit, haptics).

---

## 7. Risks and mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| **App Store rejection under Guideline 1.1.4** (overtly sexual content), triggered by "couples massage" | **Critical** | Full mitigation plan in `07 § 5`: clothed/draped imagery only, clinical language, no sensual terminology anywhere in metadata, 12+ rating, pre-submission review, prepared appeal letter |
| Users get hurt and blame the app | High | Blocking contraindication screening, conservative pressure defaults, "stop if it hurts" reinforced at every routine start, explicit disclaimer accepted at onboarding, liability insurance |
| Image quality doesn't match the promise | High | This is the risk the client already identified. Fully addressed in `05_VISUAL_ASSET_PLAN.md` — verified free photo sources, a controlled AI-generation prompt kit, and a fallback commission plan |
| Partner mode goes unused because people are alone | Medium | Solo mode is a complete product on its own; partner mode is upside, not dependency |
| Content feels thin after 3 weeks | Medium | Programs (multi-day) + remote content packs so new routines ship without an App Store release |
| Cannot compete with free YouTube | Medium | The differentiator is *structure* — timer, steps, safety, partner mode. Lean into it in ASO and screenshots |
