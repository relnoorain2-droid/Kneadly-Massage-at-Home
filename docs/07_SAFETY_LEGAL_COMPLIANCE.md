# 07 — Safety, Legal & App Store Compliance
*Kneadly · The document that keeps users safe and the app on the store*

---

## 1. The safety philosophy

Massage is safe for almost everyone. But this app puts **untrained hands on other people's bodies**, sometimes on elderly parents, sometimes on pregnant partners, sometimes on someone with a blood clot they don't know about. That means safety cannot be a disclaimer screen users tap past. It has to be **structural**:

1. **Screen before you show.** The contraindication questions run in onboarding and gate the content that renders.
2. **Modify, don't just block.** Every blocked routine offers a safe alternative in the same card. A user told only "no" will go do it wrong on YouTube.
3. **Teach the stop signals relentlessly.** Sharp / burning / electric / radiating pain = stop, repeated at every routine start.
4. **Conservative defaults.** Beginners are capped at pressure 3/5 until they've completed 5 sessions.
5. **Never claim to treat anything.** See § 4.

---

## 2. The contraindication engine

### 2.1 Absolute contraindications — no massage at all

The app **blocks all routines** and shows a "please see a doctor first" card if any of these are indicated:

Acute emergency or severe illness: shock · stroke · heart attack · high fever · acute pneumonia or respiratory failure · meningitis · severe unexplained internal pain · haemorrhage · sepsis or bacteraemia · organ failure (liver, kidney, respiratory) · appendicitis · eclampsia · severe haemophilia · advanced atherosclerosis · endocarditis or pericarditis · pitting oedema · intoxication · recent major surgery · sudden severe headache.

Contagious illness: flu, cold, strep throat, shingles, any contagious airborne or skin infection — **for the protection of the giver as much as the receiver.**

### 2.2 Relative contraindications — modify, don't cancel

Massage may proceed with reduced pressure, avoided areas, changed position, or medical clearance: pregnancy · cancer (current or recent treatment) · thrombosis history or anticoagulant medication · osteoporosis · diabetes (especially with neuropathy or circulation issues) · heart failure · hypertension or hypotension · kidney disease · epilepsy or seizure disorders · compromised immunity · fibromyalgia · arthritis · Parkinson's (rigidity/spasticity) · paralysis · lymphoedema · recent fracture · joint dislocation or instability · frozen shoulder · aneurysm history · Bell's palsy · Raynaud's · recent head injury · severe asthma or emphysema · TMJ dysfunction.

**Engine behaviour:** these produce `.allowedWithCap` or `.modified`, never a hard block. Example: *osteoporosis* → global pressure cap of 2/5, tapotement removed entirely, deep-tissue routines hidden, gentle alternatives promoted.

### 2.3 Local contraindications — avoid that spot only

Work everywhere else, skip the area: acute inflammation · acute arthritis flare · acute neuritis · recent burns · open wounds · contagious skin conditions · **deep vein thrombosis** · undiagnosed lumps, cysts or changing moles · radiation therapy sites · phlebitis · severe varicose veins · trigeminal neuralgia · insect bites and stings · bruising · recent tattoo (2 weeks).

### 2.4 The four hardest-hitting rules, surfaced everywhere

| Rule | Where it appears |
|------|------------------|
| **DVT — never massage a calf that is swollen, warm, red, or painful on one side only. Massage can dislodge a clot. See a doctor.** | Every calf/leg routine, unskippable card on first open |
| **Pregnancy — no deep abdominal work, no strong ankle/heel pressure, side-lying only after the first trimester, and get your midwife's or doctor's OK.** | Trimester-gated, requires explicit acknowledgement |
| **Never press on the spine, the throat, the back of the knee, or the armpit.** | Taught in the primer, repeated in the relevant steps |
| **Sharp, burning, electric or radiating pain = stop immediately.** | Every routine start and every pressure-4+ step |

### 2.5 Special populations
- **Elderly:** pressure cap 3, longer warm-up, skin inspection first (thin skin bruises easily), never traction the neck, watch for osteoporosis. Dedicated Friends & Family routines.
- **Children:** app is 12+; content for massaging a child is limited to feet, hands and back at pressure 1–2, with a caregiver framing.
- **Pregnancy:** gated program, side-lying only, no strong pressure at the ankle (SP6/Kd3) or between thumb and index finger (LI4), no deep abdominal work, no heat. Requires explicit acknowledgement of a doctor conversation before unlocking.
- **Cancer:** modern oncology-massage guidance permits gentle massage, but this app **requires medical clearance acknowledgement** and offers only light effleurage and comfort-focused routines.

---

## 3. In-app safety surfaces

| Surface | Content |
|---------|---------|
| **Onboarding O6** | Blocking health screen (`02 § 2`) |
| **First-launch disclaimer** | Full-screen, must scroll to the bottom, explicit "I understand" tap. Version-tracked so it can be re-presented when materially changed |
| **Routine detail "Skip this if…"** | Always visible, never behind a disclosure triangle |
| **Session Prepare P3** | The consent + communication ritual |
| **Step-level cautions** | Inline on the step, in caution colour |
| **Stop banner** | Persistent small footer during any session: *"Stop if it's sharp."* |
| **Post-session "Worse"** | Routes to a gentle card: what to do now, and when to see someone |
| **LEARN → Safety** | Full plain-language library, never paywalled |

---

## 4. Claims language — legal risk control

**Never** say, imply or let user-facing copy contain: *cure · heal · treat · diagnose · therapy for [condition] · detox · remove toxins · realign · medical · clinically proven · replaces physiotherapy.*

**Always** frame as: *relieve · ease · soften · release · relax · comfort · loosen · warm · may help you feel.*

| ❌ Don't write | ✅ Write instead |
|---------------|-----------------|
| "Cures tension headaches" | "May help ease tension headaches" |
| "Treats sciatica" | "Gentle relief for tight hips and glutes" |
| "Detoxes your lymphatic system" | "Light strokes that encourage fluid movement" |
| "Realigns your spine" | "Softens the muscles either side of your spine" |
| "Medical-grade massage" | "Techniques used by massage therapists" |

Enforced by a **banned-verb CI check** across all content JSON and all App Store metadata (`06 § 9`).

**Required disclaimer (verbatim, in-app and in the App Store description):**
> *Kneadly is a wellness and education app. It does not provide medical advice, diagnosis or treatment, and it is not a substitute for care from a qualified healthcare professional. Always consult a doctor before starting massage if you have a medical condition, are pregnant, or are recovering from injury or surgery. Stop immediately if you feel sharp, burning or radiating pain. If you have swelling, warmth, redness or pain in one leg, do not massage it — seek medical attention.*

---

## 5. App Store Review — the real risk, and the plan

### 5.1 The threat
**Guideline 1.1.4** prohibits "overtly sexual or pornographic material." A massage app with a **couples mode** will get extra scrutiny. Rejection here is the single largest schedule risk in the project, and an appeal cycle costs 1–3 weeks.

### 5.2 The nine-point mitigation plan
1. **Every image shows a draped, towelled or clothed body.** Zero nudity, zero implied nudity, zero suggestive posing. Hands, shoulders, feet, backs of heads.
2. **Language is instructional, never sensual.** Banned everywhere: *sensual · erotic · intimate touch · foreplay · arousal · tantric · seductive · "for lovers."* Approved: *partner · couple · connection · relaxation · care.*
3. **Friends & Family mode exists and is prominent.** Its presence is direct evidence of non-sexual intent, and reviewers notice it.
4. **No genital, buttock-focused or breast content.** Glute routines are framed anatomically ("piriformis and glute medius"), imaged clothed, and require consent confirmation.
5. **Age rating 12+**, with "Infrequent/Mild Medical or Treatment Information" declared honestly.
6. **App Store metadata is scrubbed.** No erotic-adjacent keywords. Screenshots lead with the *body map* and the *step player*, not with couples photography.
7. **Reviewer notes submitted with the build:**
   > *Kneadly is a wellness education app teaching therapeutic massage techniques. All content is instructional and non-sexual. All imagery shows clothed or draped subjects. The app includes a health screening flow, medical disclaimers and licensed-therapist content review. "Partner" and "Friends & Family" modes teach the same techniques with context-appropriate guidance.*
8. **Demo account and a walkthrough video** attached to the submission so the reviewer sees the actual experience rather than guessing from screenshots.
9. **A pre-written appeal letter** kept ready, citing the above, so a rejection costs days rather than weeks.

### 5.3 Other guidelines to satisfy

| Guideline | Requirement | Our compliance |
|-----------|-------------|----------------|
| 1.4.1 Physical harm | Medical content must not risk harm | Contraindication engine, disclaimers, LMT review, conservative defaults |
| 2.3 Accurate metadata | Screenshots must show the real app | All screenshots from the shipping build |
| 3.1.1 In-app purchase | Digital content via IAP only | StoreKit 2 |
| 3.1.2 Subscriptions | Clear price, period, terms, restore, cancel info | Full paywall spec `02 § 10` |
| 5.1.1 Privacy | Privacy policy, data minimisation | § 6 |
| 5.1.2 Health data | Health data may not be used for advertising or shared | Health answers never leave the device |
| 5.1.1(v) Account | Don't require an account for non-account features | No account required at all in v1 |
| 4.2 Minimum functionality | Must not be a repackaged website | Deeply native: Live Activities, haptics, HealthKit, Watch |

---

## 6. Privacy

**Principle: the app should know as little as possible.**

| Data | Stored | Leaves device? |
|------|--------|----------------|
| Health screening answers | Local, in a separate non-CloudKit store | **Never** |
| Partner profiles & their conditions | Local only | **Never** |
| Session history | Local; optional CloudKit private DB | Only to the user's own iCloud, opt-in |
| Analytics events | — | Anonymous, aggregate, no user ID, no IDFA, no ATT prompt needed |
| Purchase state | StoreKit | Apple only |
| HealthKit mindful minutes | HealthKit | Write-only, opt-in, never read |

**App Privacy nutrition label:** *Data Not Collected* for health, contacts, location and identifiers; *Usage Data — not linked to you* for analytics. This is a genuine competitive advantage in the wellness category and should be said out loud on the App Store page.

**GDPR/CCPA:** no personal data is processed server-side in v1, which keeps compliance simple. A privacy policy and a data-deletion path (delete app = delete data; a "Reset all data" button in Settings) are still required and shipped.

---

## 7. Content credibility

- **Every routine reviewed by a licensed massage therapist** (LMT/RMT/equivalent) before release. Their credential appears on the routine detail page.
- **A named medical advisor** (physiotherapist or physician) reviews the entire safety library and signs off the contraindication engine annually.
- **Sources cited** in LEARN for anatomical and safety claims.
- **A content changelog** so users can see the library is maintained.

This costs a few thousand dollars and is the cheapest insurance the project can buy — legally, and for App Store review.

---

## 8. Insurance and business

- **Professional/general liability insurance** covering "wellness education content." Speak to a broker familiar with digital health products before launch.
- **Terms of Service** with an explicit assumption-of-risk clause and a limitation of liability.
- **Entity:** ship under a limited company, never a personal developer account, for liability separation.
- **Jurisdiction note:** some regions regulate the term "massage therapy." Marketing copy should say *"learn massage techniques,"* not *"massage therapy service,"* and the app must never imply the user becomes qualified to practise.
