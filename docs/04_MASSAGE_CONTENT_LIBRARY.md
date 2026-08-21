# 04 — Massage Content Library
*Kneadly · The complete head-to-toe content specification*

> This is the heart of the product. Everything in the other seven documents exists to deliver this content well. **19 regions · 19 techniques · 4 modes · 62 routines · 9 programs · ~640 individual steps.**

---

## 1. Content hierarchy

```
PROGRAM      multi-day goal        "7 Nights to Better Sleep"
 └── ROUTINE  one session          "Night 3 — Lower Back Release · Partner · 14 min"
      └── SECTION                  Prepare → Warm-up → Main work → Cool-down → Aftercare
           └── STEP                one instruction, one visual, one timer, one pressure level
                └── CHANNELS       photo · body map · stroke path · text · sensation cue ·
                                   pressure · rhythm · voice line · caution
```

---

## 2. The 19 body regions

| # | Region | Key muscles / structures | Primary techniques | Modes | Cautions |
|---|--------|--------------------------|--------------------|-------|----------|
| 1 | **Scalp & Head** | Occipitofrontalis, temporalis, galea aponeurotica | Indian Head (Champi), friction, effleurage | Solo · Partner · Friends · Together | Recent head injury, migraine aura (go very light) |
| 2 | **Face** | Masseter, zygomaticus, orbicularis, sinus lines | Lymphatic drainage, gua sha, acupressure | Solo · Partner | Never over eyeball; active acne/rash; recent fillers/botox (2 wks) |
| 3 | **Jaw / TMJ** | Masseter, temporalis, pterygoids | Trigger point, sustained hold | Solo · Partner | Diagnosed TMJ disorder → gentle only; no forced opening |
| 4 | **Ears** | Auricle, tragus, ear reflex zones | Reflexology, gentle traction | Solo · Partner · Friends | Infection, recent piercing, grommets |
| 5 | **Neck (front & sides)** | SCM, scalenes, levator scapulae | Effleurage, gentle pincer, stretch | Solo · Partner | **Never press the front-centre throat.** Avoid carotid triangle. Dizziness → stop |
| 6 | **Suboccipitals (skull base)** | Rectus capitis, obliquus capitis | Sustained fingertip hold, friction | Solo · Partner | Go slow; this area refers strongly to the head |
| 7 | **Shoulders & Upper Trapezius** | Upper trap, supraspinatus, deltoid | Petrissage, trigger point, forearm | All four | The single most-requested area in the app |
| 8 | **Upper Back / Between Shoulder Blades** | Rhomboids, mid trap, levator | Thumb glide, trigger point, forearm | Partner · Friends · Together | Never press directly on the spine — work the muscle beside it |
| 9 | **Mid & Lower Back** | Erector spinae, quadratus lumborum, lats | Effleurage, petrissage, forearm, palm heel | Partner · Friends | Kidney area = light only. Pregnancy = side-lying only. Never on the spine itself |
| 10 | **Chest & Sternum** | Pectoralis major/minor, intercostals | Fingertip friction, sustained hold | Solo · Partner | Breast tissue avoided entirely; drape properly; consent explicit |
| 11 | **Abdomen** | Rectus abdominis, colon path, diaphragm | Clockwise colon massage, gentle effleurage | Solo · Partner | **Clockwise only** (follows the colon). Avoid: pregnancy, recent surgery, IUD discomfort, full stomach, hernia |
| 12 | **Upper Arm** | Deltoid, biceps, triceps | Petrissage, compression, effleurage | All four | Avoid heavy pressure in the inner-arm nerve channel |
| 13 | **Forearm & Elbow** | Flexors, extensors, brachioradialis | Thumb stripping, cross-fibre friction | All four | Golden for phone/keyboard users. Avoid the ulnar nerve at the elbow ("funny bone") |
| 14 | **Hand, Wrist & Fingers** | Thenar, hypothenar, interossei, carpal tunnel | Reflexology, thumb circles, traction | All four | Carpal tunnel → no direct pressure into the tunnel; work around it |
| 15 | **Glutes, Hips & Piriformis** | Glute max/med/min, piriformis, TFL | Palm heel, elbow (advanced), compression | Partner · Friends (clothed) · Solo (ball) | Sciatic nerve — no sharp pressure. Consent and draping are critical here |
| 16 | **Thigh** | Quads, hamstrings, IT band, adductors | Effleurage, petrissage, forearm, compression | Partner · Friends · Solo | **Inner thigh (adductor) only with explicit consent, partner mode only.** No deep pressure on varicose veins |
| 17 | **Knee** | Patellar border, popliteal fossa | Circling around the patella, gentle | Partner · Solo | **Never press into the back of the knee** (popliteal — nerves and vessels) |
| 18 | **Calf & Shin** | Gastrocnemius, soleus, tibialis anterior | Petrissage, thumb stripping, compression | Partner · Friends · Solo | **DVT is the #1 absolute contraindication here.** Blood thinners, recent flight/immobility, swelling, heat, one-sided pain → skip entirely, see a doctor |
| 19 | **Ankle, Arch, Plantar Fascia & Toes** | Plantar fascia, arch, toe joints, reflex zones | Reflexology, thumb walking, traction | All four | Diabetic neuropathy → very light, inspect skin first. Avoid open wounds |

**Map collapsing for the UI:** the interactive body map shows 12 tappable zones (head, face, neck, shoulders, upper back, lower back, chest, abdomen, arms L/R, hands L/R, hips/glutes, thighs L/R, calves L/R, feet L/R). Tapping a zone opens the sheet listing all its underlying regions.

---

## 3. The four modes, in depth

### 3.1 Solo (Self-Massage)
- **Constraint that shapes everything:** the user has one or two hands occupied and cannot reach their own mid-back. Content must be honest about this — we do not fake mid-back self-massage with awkward contortions; we substitute tool-based (tennis ball against a wall) or a stretch.
- **Positions:** seated, lying, against a wall, on the floor with a ball.
- **Tools offered (all optional, all cheap):** tennis/lacrosse ball, rolled towel, foam roller, a cold spoon (face), a gua sha stone.
- **Voice-first:** the user cannot look at the screen while working their own scalp. Solo routines have the fullest narration scripts.
- **Reachable regions:** 1, 2, 3, 4, 5, 6, 7 (partial), 10, 11, 12, 13, 14, 15 (with ball), 16, 17, 18, 19.

### 3.2 Partner (spouse / romantic partner)
- **Two viewpoints.** The Step Player toggles between *Giver view* (technique, pressure, hand position) and *Receiver view* (breathing, feedback prompts, large text readable face-down).
- **Tone:** warm, connected, unhurried. Language like *"take your time here"* and *"notice their breathing slow down."* **Never** sexual, never suggestive. The warmth comes from care, not innuendo.
- **Draping:** taught properly — towel over everything, uncover only the region being worked, re-cover before moving on. This is what a professional does, it is what makes the receiver relax, and it is also our App Review armour.
- **All 19 regions available**, with regions 10, 15 and 16 requiring an explicit in-app consent confirmation before the routine starts.

### 3.3 Friends & Family
- **The rule that defines this mode: fully clothed, always.** No oil, no draping, no lying down required.
- Content is chair-based, over-clothing compression, and hand/foot/scalp work — the things you can genuinely do to a colleague, a sibling, or your mother.
- **Language is neutral and functional.** Zero intimacy framing. A user in this mode should never see a sentence that would be awkward to read out loud to their brother.
- Regions offered: 1, 4, 5, 6, 7, 8, 12, 13, 14, 19 + clothed compression on 9, 15, 16, 18.
- **This mode is a trust signal.** Its existence tells users the app understands social context, which makes them more comfortable with partner mode too.

### 3.4 Together
- Both people are giver and receiver simultaneously. No hierarchy.
- **Formats:** back-to-back seated breathing and shoulder reach · facing hand-and-forearm exchange · foot swap (each person massages the other's feet at opposite ends of a sofa) · scalp exchange · synchronised self-massage guided by a shared timer.
- **UI:** the Step Player shows one instruction that applies to both people; the timer is shared; the narration says *"both of you…"*.
- This mode is short (5–12 min), highly shareable, and the best candidate for marketing video.

---

## 4. The 19 techniques

### 4.1 The five foundational strokes (Swedish — taught first, used everywhere)

| Technique | Plain-language name | What it is | Where in a routine | Pressure |
|-----------|--------------------|-----------|--------------------|----------|
| **Effleurage** | *Gliding* | Long, flowing strokes with flat palms, always toward the heart | Opens and closes every routine | 1–3 |
| **Petrissage** | *Kneading* | Squeeze, lift and roll the muscle between thumb and fingers | Main work on fleshy areas | 2–4 |
| **Friction** | *Small circles* | Small, deep circular or cross-fibre movement on one spot | Knots, adhesions, tendon insertions | 3–5 |
| **Tapotement** | *Tapping* | Rhythmic cupping, hacking or pounding | Energising finish; never on the kidneys or spine | 2–3 |
| **Vibration** | *Shaking* | Fine trembling or rocking of a limb or muscle | Between deep sections, to reset | 1–2 |

### 4.2 The traditions

| # | Technique | Origin | Best for | Clothed? | Modes | In-app depth |
|---|-----------|--------|----------|----------|-------|--------------|
| 6 | **Deep Tissue** | Western | Chronic knots, athletes | No | Partner | Full |
| 7 | **Trigger Point** | Western clinical | A specific painful knot that refers pain elsewhere | Either | All | Full + referral map |
| 8 | **Myofascial Release** | Western | Tight, restricted, "stuck" feeling | No | Partner · Solo | Full |
| 9 | **Shiatsu / Acupressure** | Japan / China | Energy, headaches, nausea, sleep | **Yes** | All | Full + 24 mapped points |
| 10 | **Reflexology** | Global / Egypt-China | Feet, hands, ears; deep relaxation | **Yes** | All | Full + reflex zone map |
| 11 | **Thai Massage** | Thailand | Stiffness, mobility, passive stretching | **Yes** | Partner · Friends | Selected safe sequences only |
| 12 | **Lymphatic Drainage** | Western clinical | Puffiness, post-flight, post-illness recovery | Either | Solo · Partner | Gentle subset — direction is everything |
| 13 | **Indian Head Massage (Champi)** | India | Scalp, stress, sleep, hair health | **Yes** | All | Full |
| 14 | **Abhyanga** | Ayurveda | Full-body warm-oil self-massage ritual | No | Solo | Full |
| 15 | **Gua Sha** | China | Face sculpting, neck tension | Either | Solo · Partner | Face + neck only; tool required |
| 16 | **Lomi Lomi** | Hawaii | Flowing, forearm-led, deeply relaxing | No | Partner | Simplified sequences |
| 17 | **Sports / Pre & Post** | Western | Warm-up, recovery, DOMS | **Yes** | All | Full |
| 18 | **Chair Massage** | Western corporate | 10 minutes, clothed, anywhere | **Yes** | Friends · Partner | Full — the backbone of Friends mode |
| 19 | **Prenatal** | Clinical | Pregnancy comfort | Either | Partner · Solo | Side-lying only, trimester-gated, heavy safety copy |
| — | **Hot Stone (home version)** | Global | Deep warmth before deep work | No | Partner | Adaptation using a warm towel or rice sock — **no actual hot stones**, safety |
| — | **Cupping** | China | Advanced; silicone cups | No | Partner | v1.2, education only in v1 |
| — | **Craniosacral-style holds** | Western osteopathic | Very light, nervous-system calming | **Yes** | Partner | Simplified gentle holds only |
| — | **Aromatherapy** | Global | A layer over any routine, not a technique | — | All | Oil pairing guide |
| — | **Self-Myofascial (ball/roller)** | Western | Solo access to unreachable areas | **Yes** | Solo | Full |

---

## 5. Anatomy of a single step (the content schema every step must satisfy)

Every one of the ~640 steps in the app carries these fields. A step missing any required field fails the content lint and cannot ship.

| Field | Req | Example |
|-------|-----|---------|
| `id` | ✔ | `neck.partner.reset.s04` |
| `region` | ✔ | `shoulders_upper_trap` |
| `technique` | ✔ | `petrissage` |
| `title` | ✔ | "Squeeze and roll the muscle" *(≤ 6 words)* |
| `body` | ✔ | "Grip the top of the shoulder between thumb and fingers. Squeeze, lift slightly, and roll — like kneading dough." *(≤ 2 sentences / 200 chars)* |
| `sensationCue` | ✔ | "A deep, satisfying ache that eases as you work. Never sharp." *(≤ 90 chars)* |
| `handPosition` | ✔ | `pincer_grip` *(one of the 10 illustrated positions)* |
| `pressure` | ✔ | `4` *(1–5)* |
| `durationSeconds` | ✔ | `45` |
| `rhythm` | — | "About one squeeze per second" |
| `breathCue` | — | "Receiver: breathe out as you squeeze" |
| `heroImage` | ✔ | `img.step.shoulder.petrissage.01` |
| `bodyMapZone` | ✔ | `upper_trap_left` |
| `strokePath` | ✔ | `[{x:0.42,y:0.18},{x:0.58,y:0.19}]` + `motion: "knead"` |
| `voiceScript` | ✔ | Full narration, longer and warmer than the on-screen text |
| `commonMistake` | — | "Don't pinch with your fingertips — use the whole flat of your fingers." |
| `caution` | — | "Stay off the bony ridge of the collarbone." |
| `modes` | ✔ | `[partner, friends, together]` |
| `contraindications` | — | `[recent_shoulder_surgery, acute_inflammation]` |
| `alternativeStepId` | — | `neck.partner.reset.s04.gentle` *(the modified version shown when a contraindication is flagged)* |

---

## 6. Two fully worked routines
*(These are ship-ready content, and the template every other routine follows.)*

### 6.1 Routine — **"Neck & Shoulder Reset"** · Partner · 12 min · Beginner · Pressure 2–4

**Goal:** release the upper trapezius and levator scapulae tension that builds from screens and stress.
**Position:** receiver seated backwards on a dining chair, chest against the chair back, forehead resting on folded arms. *(Also runs prone on a bed.)*
**Needs:** a chair, optional towel. Clothed or bare-shouldered — both supported.
**Skip if:** recent neck injury or surgery · severe unexplained neck pain · dizziness or numbness in the arms.

| # | Section | Title | Technique | Hand | Press | Time | Instruction | You should feel |
|---|---------|-------|-----------|------|-------|------|-------------|-----------------|
| 1 | Warm-up | Rest your hands and breathe | Static hold | Flat palms | 1 | 30s | Place both palms flat on their shoulders. Don't move. Take three slow breaths together. | Warmth spreading. Their shoulders drop. |
| 2 | Warm-up | Long strokes down the back | Effleurage | Flat palms | 2 | 60s | Glide both palms from the base of the neck out across the shoulders and down the upper arms. Return lightly. | Smooth, warm, unhurried. Nothing sharp. |
| 3 | Warm-up | Warm the whole shoulder | Effleurage | Flat palms | 2 | 45s | Sweep in wide circles over both shoulder blades, moving upward and outward. | The muscle starting to soften and warm. |
| 4 | Main | Squeeze and roll the muscle | Petrissage | Pincer grip | 3–4 | 90s | Grip the top of the shoulder between your thumb and fingers. Squeeze, lift slightly, and roll — like kneading dough. | A deep, satisfying ache that eases as you work. |
| 5 | Main | Thumb circles beside the spine | Friction | Thumb pads | 3 | 90s | Place your thumbs either side of the spine at the base of the neck. Make slow, small circles, walking down one thumb-width at a time. **Never on the spine itself.** | Small tight spots that soften under steady pressure. |
| 6 | Main | Find and hold the knot | Trigger point | Thumb pad | 4 | 60s | Feel for the tightest spot on the top of the shoulder. Press straight down and **hold still** for 30 seconds each side. Don't rub. | A strong ache that fades by about half while you hold. |
| 7 | Main | Release the base of the skull | Suboccipital hold | Fingertips | 3 | 60s | Curl your fingertips up under the bony ridge at the base of their skull. Let the weight of their head rest on your fingers. Hold. | A melting, spreading release up into the head. |
| 8 | Main | Lengthen the side of the neck | Assisted stretch | Flat palm | 2 | 60s | One hand rests on top of their head, the other on the opposite shoulder. Gently ease the head sideways. Hold 20s. Swap. **Never force it.** | A long, comfortable stretch — a pull, never a pinch. |
| 9 | Cool-down | Light raking down the back | Nerve stroke | Fingertips | 1 | 45s | Rake your fingertips slowly from the neck down the back, alternating hands. Getting lighter each time. | Shivery, calming, like the session is closing. |
| 10 | Cool-down | Rest and finish | Static hold | Flat palms | 1 | 30s | Rest both palms on their shoulders again. Three slow breaths. Then lift your hands away slowly. | Stillness. Don't rush this part. |

**Aftercare:** *"Sit up slowly — you'll feel lighter and a bit floaty. Drink some water. Don't lift anything heavy for the next half hour."*

---

### 6.2 Routine — **"Foot Relief"** · Solo · 10 min · Beginner · Pressure 2–5

**Goal:** relieve plantar fascia tightness and tired arches after a day on your feet.
**Position:** seated, one ankle crossed over the opposite knee.
**Needs:** optional oil or balm; optional tennis ball and a chilled water bottle.
**Skip if:** diabetic neuropathy (very light only, and check your skin first) · open wound, ulcer or infection · suspected stress fracture · plantar fascia tear.

| # | Section | Title | Technique | Hand | Press | Time | Instruction | You should feel |
|---|---------|-------|-----------|------|-------|------|-------------|-----------------|
| 1 | Warm-up | Warm the whole foot | Effleurage | Both palms | 2 | 45s | Sandwich your foot between both hands and stroke firmly from toes to ankle, over and over. | Warmth and blood coming into a cold foot. |
| 2 | Warm-up | Loosen the ankle | Joint mobilisation | C-grip | 1 | 30s | Hold your heel still and slowly circle the foot five times each way. | Easy movement, no clicking or pinching. |
| 3 | Main | Thumb-walk the arch | Reflexology | Thumb pad | 3–4 | 90s | Press your thumb into the heel and "walk" it forward along the arch in small bites, like a caterpillar. Three passes. | Tender spots that ease with a few seconds of pressure. |
| 4 | Main | Stretch the sole open | Myofascial | Both thumbs | 3 | 60s | Place both thumbs in the centre of the sole and slowly draw them apart, opening the foot outward. | The sole broadening, a spreading stretch. |
| 5 | Main | Work the heel | Friction | Knuckles | 4 | 60s | Make firm circles into the fleshy pad of the heel with your knuckles. | Deep, dull, satisfying. Never sharp or burning. |
| 6 | Main | Squeeze between the bones | Friction | Thumb & finger | 3 | 60s | Slide your thumb along the grooves between the long bones on top of the foot, from toes toward the ankle. | Narrow lines of tenderness releasing. |
| 7 | Main | Pull and circle each toe | Traction | Pincer grip | 2 | 60s | Take each toe, pull gently for two seconds, then circle it once each way. | A tiny release in each joint. |
| 8 | Main | Roll it out | Self-myofascial | Ball | 3–5 | 90s | Stand and roll a ball under your foot, from heel to toes. Pause 10 seconds on any spot that complains. | Firm pressure you control by how much weight you lean in. |
| 9 | Cool-down | Stretch the calf | Static stretch | — | 2 | 45s | Press your palms to a wall, step this foot back, keep the heel down, lean in. Hold 30 seconds. | A long pull through the back of the calf. |
| 10 | Cool-down | Finish with long strokes | Effleurage | Both palms | 1 | 30s | Stroke the whole foot from toes to ankle, getting lighter each time. Then swap feet and repeat. | Light, warm, finished. |

**Aftercare:** *"Do the other foot even if it doesn't hurt — feet like to match. Drink water. If your heel is angry in the morning, roll a frozen water bottle under it for five minutes."*

---

## 7. The routine catalogue (62)

### Solo (22)
Neck & Shoulder Reset · Foot Relief · Hand & Wrist Reset · Scalp & Sleep · Face Lymphatic Glow · Jaw & TMJ Release · Sinus & Headache Relief · Eye Strain Relief · Forearm Rescue (phone/keyboard) · Lower Back Ball Release · Glute & Piriformis Ball · IT Band & Outer Thigh · Calf & Shin Release · Abhyanga Full-Body Oil Ritual · Morning Wake-Up (5 min) · Evening Wind-Down (8 min) · Post-Workout Legs · Post-Flight Lymphatic · Period Comfort (abdomen + lower back) · Desk Reset (chair, 5 min, clothed) · Anxiety Grounding (hands + breath) · Gua Sha Face Sculpt

### Partner (24)
Back Basics *(free)* · Full Back Deep Release · Neck & Shoulder Reset *(free)* · Scalp & Head Wind-Down *(free)* · Face & Jaw Softening · Upper Back Knot Hunt · Lower Back & Hip Relief · Glute & Piriformis Release · Hamstring & Calf Recovery · Quad & IT Band · Foot Ritual · Hand & Forearm Ritual · Full Body Relaxation (45 min) · Full Body Express (20 min) · Sleep Ritual (before bed, 15 min) · Sunday Slow Massage (60 min) · Post-Workout Recovery · Headache Rescue · Prenatal Comfort — 2nd Trimester · Prenatal Comfort — 3rd Trimester · Lomi Lomi Flow · Hot Towel Warm-Up · Chest & Breathing Opener · Arm & Shoulder Mobility

### Friends & Family (10) — all clothed
Office Chair 10-Minute · Shoulder Squeeze (2 min, standing) · Hand & Wrist (seated, clothed) · Scalp Refresh (seated) · Foot Reflexology (clothed, socks off) · Neck Relief Over Clothing · Thai-Style Back Compression · Post-Match Leg Compression · Elderly Care — Gentle Hands & Feet · Elderly Care — Gentle Circulation Legs

### Together (6)
Back-to-Back Breathing & Reach · Hand Exchange · Foot Swap · Scalp Exchange · Synchronised Self-Massage · Five-Minute Reset (both, standing)

---

## 8. Programs (9 multi-day)

| Program | Days | Mode mix | Arc |
|---------|------|----------|-----|
| **7 Nights to Better Sleep** | 7 | Solo + Partner | Scalp → neck → back → feet → full wind-down. Each night ~12 min, ending progressively lighter |
| **10-Day Neck & Shoulder Reset** | 10 | Solo + Partner | For desk workers. Alternates release days and mobility days |
| **Couples Connection** | 14 | Partner + Together | Builds from 8-minute clothed shoulder work to a 45-minute full-body ritual. **The flagship Plus program** |
| **Lower Back Rescue** | 7 | Partner + Solo | Glutes and hips first (where the cause usually is), back last |
| **Period Comfort** | 5 | Solo | Abdomen (clockwise, gentle), lower back, feet, warmth |
| **Post-Workout Recovery** | 6 | Solo + Partner | Legs, back, arms on a rotating cycle |
| **Headache & Migraine Relief** | 5 | Solo | Suboccipitals, temples, jaw, neck, acupressure points |
| **Feet That Work Hard** | 5 | Solo | For nurses, retail, hospitality — 8 min each evening |
| **Pregnancy Comfort** | 8 | Partner | Trimester-gated, side-lying only, heavy safety framing, needs explicit acknowledgement to unlock |

---

## 9. Symptom → routine map (powers search)

| User types… | We surface |
|-------------|------------|
| headache, migraine | Sinus & Headache Relief · Headache Rescue · Suboccipital Release |
| can't sleep, insomnia | Scalp & Sleep · Sleep Ritual · 7 Nights to Better Sleep |
| sore after gym, DOMS | Post-Workout Legs · Hamstring & Calf Recovery |
| desk, computer, laptop | Desk Reset · Forearm Rescue · 10-Day Neck & Shoulder |
| period, cramps | Period Comfort |
| stressed, anxious | Anxiety Grounding · Scalp & Head Wind-Down · Back-to-Back Breathing |
| pregnant | Prenatal routines *(gated behind a trimester + safety acknowledgement)* |
| feet hurt, standing all day | Foot Relief · Feet That Work Hard |
| jaw, teeth grinding, clenching | Jaw & TMJ Release |
| swollen, puffy, after a flight | Post-Flight Lymphatic |
| romantic, date night, anniversary | Couples Connection · Sunday Slow Massage *(warm framing, never sexual)* |

---

## 10. The ten hand positions (illustrated set)

| Position | Use | Pressure range |
|----------|-----|----------------|
| **Flat palm** | Effleurage, warming, broad strokes | 1–3 |
| **Palm heel** | Broad deep pressure on large muscles | 3–5 |
| **Thumb pad** | Precision work, trigger points | 3–5 |
| **Double thumb** | Walking down either side of the spine | 3–4 |
| **Fingertips (4)** | Small circles, scalp, face, suboccipitals | 1–3 |
| **Knuckles** | Deep work on feet, glutes, soles | 4–5 |
| **Forearm** | Broad deep pressure on back and thighs — **saves the giver's hands** | 3–5 |
| **C-grip (thumb + fingers)** | Wrapping limbs — calves, forearms | 2–4 |
| **Pincer grip** | Kneading the trapezius, toes | 3–4 |
| **Cupped hand** | Tapotement, percussion | 2–3 |

> **Teach the forearm early.** Beginners exhaust their thumbs in four minutes and then give up. The forearm is the single most useful thing an amateur can learn, and it's the thing YouTube tutorials never emphasise.

---

## 11. Pressure, communication and consent

**The 1–10 scale is agreed out loud before every partner session.** 1 = barely there · 5 = pleasant · **6–7 = the target zone, "good pain"** · 8 = too much · 10 = stop.

**Giver rules taught in the app:**
1. Start lighter than you think. You can always add.
2. Pressure comes from your body weight leaning in, not your arm muscles.
3. Slow is deeper than hard. Speed is what makes pressure hurt.
4. **Sharp, burning, electric, or radiating pain = stop immediately.** Dull ache = fine.
5. Never press on bone, the spine, the throat, the back of the knee, or the armpit.
6. Ask "how's that?" at the start of each new area — then stop asking and let them relax.

**Receiver rules:**
1. Speak up early. Waiting until it hurts means it already hurt.
2. Breathe out into the pressure. Holding your breath makes everything tighter.
3. You can stop at any moment for any reason and don't need a reason.

---

## 12. Oils and preparation

| Carrier oil | Feel | Best for | Note |
|-------------|------|----------|------|
| **Fractionated coconut** | Light, slippery, long glide | Full body, beginners | Doesn't go rancid. **Best default recommendation** |
| **Sweet almond** | Medium, nourishing | Full body, dry skin | ⚠️ Nut allergy |
| **Jojoba** | Absorbs fast, skin-like | Face, scalp | Most expensive |
| **Grapeseed** | Very light, non-greasy | Oily skin, back | Short shelf life |
| **Sesame (warm)** | Heavy, warming | Abhyanga, Ayurvedic | Strong smell |
| **Unscented lotion** | Grippy, less glide | Deep tissue, when you want friction | Easiest to buy |

**Essential oil dilution (never apply neat):** adults 2% = **12 drops per 30 ml** carrier · face or sensitive skin 1% = 6 drops · elderly or unwell 1% · children over 6 = 0.5% · **pregnancy: 1%, and avoid clary sage, rosemary, jasmine, juniper.**

**Pairings:** lavender → sleep · peppermint → headache (**keep away from the eyes**) · eucalyptus → congestion, chest · sweet orange → mood · chamomile → sensitive skin · ginger → warmth, cold muscles.

**Always:** patch test on the inner forearm 24 hours ahead for first use. **Never:** undiluted essential oils on skin · citrus oils before sun exposure (phototoxic) · any oil on broken skin · petroleum jelly for massage (no glide, blocks pores).

**Setting up:** room 22–24 °C (warmer than you think — a still body gets cold fast) · warm your hands and the oil in your palms first · nails short, rings and watch off · towels within reach · lights low, phone propped and charging · a firm surface beats a soft mattress.

---

## 13. Positions library

| Position | Propping | Best for |
|----------|----------|----------|
| **Prone on a bed/floor** | Pillow under chest and under ankles; head turned or in a face cradle | Back, glutes, hamstrings, calves |
| **Supine** | Pillow under knees and a thin one under the head | Face, scalp, neck, chest, arms, front of legs, feet, abdomen |
| **Side-lying** | Pillow between the knees, one hugged to the chest | **Pregnancy**, hips, shoulders, anyone who can't lie flat |
| **Seated backwards on a chair** | Cushion against the chair back, forehead on folded arms | Neck, shoulders, upper back — clothed, no equipment |
| **Seated upright** | Feet flat, back supported | Scalp, face, hands, feet |
| **Floor / Thai mat** | Firm mat, no pillows | Thai compression and stretch sequences |

---

## 14. Content production standards

- **Reading level:** Grade 6–8 (Flesch-Kincaid). Checked in CI.
- **Every step has a visual.** No exceptions. A step without an approved image does not ship.
- **Every routine reviewed by a licensed massage therapist (LMT/RMT)** before release, with their name and credential shown on the routine detail page. This is a trust asset and a legal one.
- **Anatomical accuracy checked against a second source** for every named muscle and every claimed safety rule.
- **Never claim to treat, cure, or diagnose.** Approved verbs: *relieve, ease, soften, release, relax, comfort, loosen, warm*. Banned verbs: *cure, heal, treat, fix, detox, realign, remove toxins.* See `07 § 4`.
