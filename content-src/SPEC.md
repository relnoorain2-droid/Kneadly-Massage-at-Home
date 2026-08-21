# Kneadly content pack — authoring spec (v1)

You are writing **real, safe, expert massage instruction** for a consumer iOS app.
Output is JSON only. It is decoded by Swift `Codable` — the shape must be exact.

## Voice
A very good massage therapist who is also your friend. Plain words. Short sentences.
Grade 6–8 reading level. Never clinical jargon in `body`, never mystical wellness-speak.

GOOD: "Grip the top of the shoulder between your thumb and fingers. Squeeze, lift slightly, and roll — like kneading dough."
BAD:  "Perform petrissage on the upper trapezius fibres."
BAD:  "Release your body's stored trauma."

## Hard rules
- `title`: max 6 words, imperative, no trailing period.
- `body`: max 2 sentences, max 200 characters total.
- `sensationCue`: max 90 characters. Describes what the RECEIVER should feel. Always include a "not this" boundary where useful ("Never sharp.").
- `voiceScript`: 1–3 sentences, warmer and slightly longer than `body`. It is read aloud. Never references the screen.
- BANNED VERBS anywhere: cure, heal, treat, diagnose, detox, toxins, realign, medical, clinically proven.
  Use instead: relieve, ease, soften, release, relax, comfort, loosen, warm.
- Never instruct pressure on: the spine itself, the front/centre of the throat, the back of the knee, the armpit, the eyeball, breast tissue, genitals.
- Nothing sexual, suggestive or romantic-explicit. `partner` mode is warm and caring, never sensual.
- `friends` mode routines must be doable FULLY CLOTHED, with no oil and no lying down.
- Every routine opens with at least one warmUp step and closes with at least one coolDown step.
- Total of all `durationSeconds` in a routine should land within ±60s of `durationSeconds` on the routine.

## Enums — use these EXACT strings
mode: "solo" | "partner" | "friends" | "together"
level: "beginner" | "intermediate" | "advanced"
sectionKind: "warmUp" | "main" | "coolDown"
handPosition: "flatPalm" | "palmHeel" | "thumbPad" | "doubleThumb" | "fingertips" | "knuckles" | "forearm" | "cGrip" | "pincerGrip" | "cuppedHand" | "tool" | "none"
motion: "glide" | "knead" | "circle" | "hold" | "walk" | "rake" | "stretch" | "press"
position: "proneBed" | "supine" | "sideLying" | "seatedChairReversed" | "seatedUpright" | "floorMat" | "standing"
bodyMapZone: "head" | "neck" | "shoulders" | "chest" | "abdomen" | "hips" | "arms" | "forearms" | "hands" | "thighs" | "knees" | "calves" | "feet"
techniqueID: "effleurage" | "petrissage" | "friction" | "tapotement" | "vibration" | "deepTissue" | "triggerPoint" | "myofascial" | "shiatsu" | "reflexology" | "thai" | "lymphatic" | "indianHead" | "abhyanga" | "guaSha" | "lomiLomi" | "sports" | "chair" | "prenatal" | "selfMyofascial" | "stretch" | "staticHold"
regionID: "scalp" | "face" | "jaw" | "ears" | "neck" | "suboccipitals" | "shouldersUpperTrap" | "upperBack" | "lowerBack" | "chest" | "abdomen" | "upperArm" | "forearm" | "hand" | "glutesHips" | "thigh" | "knee" | "calfShin" | "foot"
contraindication IDs you may reference:
  "pregnancy" | "dvtOrBloodThinners" | "cancerTreatment" | "heartOrBloodPressure" | "recentSurgeryOrFracture" | "diabetesNeuropathy" | "skinConditionOrWound" | "feverOrInfection" | "osteoporosis" | "recentNeckInjury" | "carpalTunnel" | "tmjDisorder"

## Image IDs — pick the closest fit from this list ONLY
"img.reg.shoulder","img.reg.back","img.reg.back.alt","img.reg.back.alt2","img.reg.head","img.reg.face",
"img.reg.ear","img.reg.foot","img.reg.foot.alt","img.reg.foot.alt2","img.reg.hand","img.reg.leg",
"img.reg.prone","img.reg.rest","img.prep.oil","img.prep.stones","img.prep.candle","img.prep.stack",
"img.prep.robe","img.prep.towel","img.mood.hands","img.mood.couple"

## JSON shape — EXACT

```json
{
  "routines": [
    {
      "id": "neck.partner.reset",
      "title": "Neck & Shoulder Reset",
      "subtitle": "Release the tension screens put in your shoulders.",
      "regionIDs": ["shouldersUpperTrap", "neck"],
      "mode": "partner",
      "level": "beginner",
      "durationSeconds": 720,
      "minPressure": 1,
      "maxPressure": 4,
      "position": "seatedChairReversed",
      "needs": ["A chair", "Towel", "Oil optional"],
      "skipIf": ["recentNeckInjury"],
      "coverImage": "img.reg.shoulder",
      "coverPlaceholderHex": "#C9A188",
      "isPremium": false,
      "reviewedBy": "Reviewed by a licensed massage therapist",
      "aftercare": "Sit up slowly. Drink some water. Nothing heavy for the next half hour.",
      "sections": [
        { "kind": "warmUp",   "stepIDs": ["neck.partner.reset.s01"] },
        { "kind": "main",     "stepIDs": ["neck.partner.reset.s02"] },
        { "kind": "coolDown", "stepIDs": ["neck.partner.reset.s03"] }
      ]
    }
  ],
  "steps": [
    {
      "id": "neck.partner.reset.s01",
      "regionID": "shouldersUpperTrap",
      "techniqueID": "staticHold",
      "title": "Rest your hands and breathe",
      "body": "Place both palms flat on their shoulders. Don't move. Take three slow breaths together.",
      "sensationCue": "Warmth spreading. Their shoulders drop.",
      "handPosition": "flatPalm",
      "pressure": 1,
      "durationSeconds": 30,
      "rhythm": "Still — no movement",
      "breathCue": "Both of you: breathe out slowly",
      "heroImage": "img.reg.shoulder",
      "heroPlaceholderHex": "#C9A188",
      "bodyMapZones": ["shoulders"],
      "strokePath": { "points": [[0.42,0.18],[0.58,0.19]], "motion": "hold", "loop": false },
      "voiceScript": "Start by resting both palms flat on their shoulders. Don't move at all. Just take three slow breaths together and let them settle.",
      "commonMistake": "Don't start rubbing straight away. The pause is the point.",
      "caution": null,
      "modes": ["partner"],
      "contraindications": []
    }
  ]
}
```

### Field notes
- `strokePath.points` are normalised 0–1 coordinates on a 200×400 body silhouette
  (x = value/200, y = value/400). Useful anchors:
  head 0.50/0.09 · neck 0.50/0.16 · shoulders L 0.37/0.20 R 0.63/0.20 ·
  chest/upper back 0.50/0.26 · abdomen/lower back 0.50/0.37 · hips 0.50/0.47 ·
  upper arm L 0.31/0.27 R 0.69/0.27 · forearm L 0.25/0.41 R 0.75/0.41 ·
  hands L 0.23/0.50 R 0.77/0.50 · thigh L 0.43/0.59 R 0.57/0.59 ·
  knee L 0.42/0.70 R 0.58/0.70 · calf L 0.41/0.80 R 0.59/0.80 · foot L 0.40/0.91 R 0.60/0.91
  Give 2–5 points. For a "hold" use two points very close together.
- `caution` is null unless there is a real anatomical warning.
- `commonMistake` is optional (may be null) but include it on at least half the steps.
- `coverPlaceholderHex` / `heroPlaceholderHex`: a warm mid-tone hex sampled from the photo, e.g. "#C9A188", "#B98F76", "#A8836B", "#C2A58E".
- Step IDs must be `<routineID>.sNN` with two digits.
- 8–12 steps per routine.
