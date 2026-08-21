# 05 — Visual Asset Plan
*Kneadly · How every image in the app gets made, sourced, graded and shipped*

> **This document exists because of one specific concern:** *"I need best quality images in the app — AI-generated ones don't feel good enough."* That is correct, and the answer is not better prompting. The answer is a **three-layer visual system** where AI generation is the smallest and least important layer.

---

## 1. The three-layer visual system

| Layer | What it is | % of app visuals | Where it comes from | Quality risk |
|-------|-----------|------------------|---------------------|--------------|
| **A. Real photography** | Mood, onboarding, routine covers, paywall, programs | ~35% | Free stock (Unsplash / Pexels / Pixabay) — verified, curated, uniformly graded | **Low.** Professional photographers already shot these |
| **B. Vector body maps & diagrams** | The silhouette, target zones, stroke paths, hand positions, reflex maps | ~50% | **Drawn as SVG/SwiftUI paths — not images at all.** Open-source anatomy SVGs as the base | **None.** Infinitely sharp, tintable, animatable, ~0 KB |
| **C. Illustrated step art** | Optional stylised hand-position art where a photo doesn't exist | ~15% | AI-generated with a locked style, **then human-retouched** — or commissioned | Medium — fully controlled in § 7 |

**The insight:** the images that matter most in this app — *"exactly where do I put my thumb?"* — should not be photographs at all. They should be **vector diagrams**, because a diagram can show a target zone, a direction arrow, and a pressure point with total clarity, in any size, in any colour, in dark mode, animated. Photography's job is to make the app *feel* premium. Vectors do the actual teaching.

That single decision removes ~50% of the image-quality risk from the project.

---

## 2. Complete image inventory

| Set | Count | Type | Source layer |
|-----|-------|------|--------------|
| Onboarding full-bleeds | 7 | Photo 9:16 | A |
| Mode picker cards | 4 | Photo 1:1 | A |
| Routine covers | 62 | Photo 3:2 | A (reused across families, ~24 unique) |
| Program covers | 9 | Illustration 3:2 | C |
| Technique cards (Learn) | 19 | Photo 3:2 | A |
| Step hero visuals | ~640 | Photo 4:5 or illustration | A+C (~85 unique, reused by technique+region) |
| Body silhouettes | 6 | **SVG** | B |
| Body region paths | 24 | **SVG** | B |
| Hand-position diagrams | 10 | **SVG** | B |
| Stroke-path overlays | ~40 | **SVG (generated from coordinates)** | B |
| Reflexology maps (foot/hand/ear) | 3 | **SVG** | B |
| Acupressure point map | 1 | **SVG** | B |
| Position/propping diagrams | 6 | **SVG** | B |
| Oil & prep imagery | 8 | Photo 1:1 | A |
| Empty states | 6 | Illustration | C |
| App icon + marketing | 12 | Vector + photo | B+A |
| **Total unique assets** | **≈ 240** | | |

> Note the leverage: **640 steps need only ~85 unique hero visuals**, because "thumb circles beside the spine" looks the same whether it's in the Sleep Ritual or the Lower Back Rescue. Build a **visual library keyed by `technique × region × handPosition`**, not by step. This is the difference between a 3-week and a 6-month asset job.

---

## 3. Licensing — what you can actually use

| Source | License | Commercial app use | Attribution | Verdict |
|--------|---------|--------------------|-------------|---------|
| **Unsplash** | [Unsplash License](https://unsplash.com/license) — irrevocable, worldwide, free, incl. commercial; modification allowed | ✅ Yes | Not required (appreciated) | **Primary source.** Only forbidden use: compiling images to build a competing stock-photo service |
| **Pexels** | Pexels License — free, commercial, no attribution | ✅ Yes | Not required | **Secondary source** |
| **Pixabay** | Pixabay Content License | ✅ Yes | Not required | Tertiary — quality is more variable |
| **unDraw** | Open license, no attribution, commercial OK | ✅ Yes | No | Illustrations, empty states |
| **Humaaans / Open Peeps / Open Doodles** (Pablo Stanley) | CC0 | ✅ Yes | No | Character illustration |
| **Storyset** (Freepik) | Free **with attribution** | ⚠️ Yes, with credit | **Required** | Use only if you'll add a credits screen |
| **SF Symbols** | Apple license — use in apps only, no re-drawing into a logo | ✅ Yes | No | Icon base set |
| **Phosphor / Lucide / Tabler icons** | MIT / ISC | ✅ Yes | No | Custom icon gaps |
| **MuscleMap (SwiftUI)** | MIT | ✅ Yes | License file in app | Body map |
| **LottieFiles free tier** | Per-asset (check each) | ⚠️ Per-asset | Varies | **Check every single file individually** |

### 3.1 The three rules that keep you safe
1. **Save proof.** For each image, store the source URL, photographer, license name, and download date in `assets/CREDITS.json`. Ship a Credits screen even where attribution isn't required — it costs one screen and it ends any dispute instantly.
2. **No recognisable faces in the paywall or App Store screenshots.** Free stock licenses generally do **not** include model releases. Crop to hands, shoulders, and backs of heads. *(This also happens to be better art direction.)*
3. **Never** use a stock photo of a person in a way that implies they endorse the app.

---

## 4. Verified starter photo set
*Live `images.unsplash.com` IDs, pulled and confirmed from Unsplash search results. Append `?w=1600&q=80&auto=format&fit=crop` for retina, or `?w=400&q=70` for thumbnails — the Unsplash CDN resizes on the fly.*

### 4.1 Onboarding & hero
| ID | Photo | Shows | Use |
|----|-------|-------|-----|
| `img.onb.01` | `photo-1519823551278-64ac92734fb1` | Hands massaging a back, warm light *(Toa Heftiba)* | O1 Welcome |
| `img.onb.02` | `photo-1741522509438-a120c0bb5e88` | Back massage in progress | O2 Who |
| `img.onb.03` | `photo-1639162906614-0603b0ae95fd` | Back massage, spa, soft light *(Simon Humler)* | O3 Where hurts |
| `img.onb.04` | `photo-1542848285-4777eb2a621e` | Person deeply relaxed during massage *(Emiliano Vittoriosi)* | O4 Time |
| `img.onb.05` | `photo-1519824145371-296894a0daa9` | Hands on a back, close *(Toa Heftiba)* | O5 Experience |
| `img.onb.06` | `photo-1506126613408-eca07ce68773` | Calm seated figure *(Jared Rice)* | O6 Safety |
| `img.onb.07` | `photo-1696841212541-449ca29397cc` | Warm stones on a back *(Taylor Heery)* | O7 Ready |

### 4.2 Region & routine covers
| ID | Photo | Shows |
|----|-------|-------|
| `img.reg.shoulder` | `photo-1745327883508-b6cd32e5dde5` | Therapist working the shoulders |
| `img.reg.back` | `photo-1706353399656-210cca727a33` | Back massage, both hands |
| `img.reg.back.alt` | `photo-1700522924565-9fad1c05469e` | Back massage, spa setting |
| `img.reg.back.alt2` | `photo-1649751295468-953038600bef` | Back massage, warm tone |
| `img.reg.head` | `photo-1598901986949-f593ff2a31a6` | Hands on a face/head, warm bokeh *(Katherine Hanlon)* |
| `img.reg.face` | `photo-1706795033728-9232ef548a16` | Facial massage *(Anna Keibalo)* |
| `img.reg.ear` | `photo-1757066033606-b9552acb2dd0` | Gentle work at the ear *(Anna Blake)* |
| `img.reg.foot` | `photo-1675159364615-38e1f6b62282` | Hands massaging a foot with oil *(Oswald Elsaboath)* |
| `img.reg.foot.alt` | `photo-1675159364623-6938e10245f0` | Foot held in two hands |
| `img.reg.foot.alt2` | `photo-1728497872660-cc6b16238c3a` | Foot massage on a bed *(Filipp Romanovski)* |
| `img.reg.hand` | `photo-1611073615830-9f76902c10fe` | Hand massage on a towel *(THLT LCX)* |
| `img.reg.leg` | `photo-1712638932314-e2b185ca0930` | Leg massage with towel *(Mat Kilkeary)* |
| `img.reg.prone` | `photo-1544161515-4ab6ce6db874` | Person lying prone, draped |
| `img.reg.rest` | `photo-1701916672756-615f56fb0d4e` | Resting hands on a back |

### 4.3 Mood, oils & preparation
| ID | Photo | Shows |
|----|-------|-------|
| `img.prep.oil` | `photo-1515377905703-c4788e51af15` | Amber glass oil bottle *(Christin Hume)* |
| `img.prep.stones` | `photo-1600334089648-b0d9d3028eb2` | Spa stones and ceramic |
| `img.prep.candle` | `photo-1620733723572-11c53f73a416` | Candle, warm light |
| `img.prep.stack` | `photo-1767884161044-e75de514a2a3` | Stacked balance stones |
| `img.prep.robe` | `photo-1630595271375-5073a6c0638b` | Person in a robe, calm |
| `img.prep.towel` | `photo-1786800054088-f017f09fc650` | Folded towel, wood |
| `img.mood.hands` | `photo-1645005512968-0c1fe99f0093` | Two people's hands, connection *(Sincerely Media)* |
| `img.mood.couple` | `photo-1699523229208-be1e1dd9252d` | Couple, hands held, bed |

### 4.4 How to find the rest (repeatable process)
Search Unsplash and Pexels for these exact strings, then filter by the six photography rules in `03 § 6`:

`massage therapy` · `back massage` · `shoulder massage` · `foot massage` · `hand massage` · `head massage` · `facial massage` · `spa hands` · `massage oil` · `relaxing bed` · `couple relaxing home` · `reflexology` · `physiotherapy hands` · `wellness hands` · `neck pain relief` · `stretching at home` · `warm towel spa`

**Curation checklist per image — reject unless all six pass:**
`☐ Warm light` `☐ Hands actively working` `☐ Shallow depth of field` `☐ Body covered` `☐ No eye contact with camera` `☐ Subject in lower two-thirds`

---

## 5. Making 60 photos from 40 photographers look like one app

This is the step everyone skips, and it is the single biggest quality multiplier. Run **every** photo through the same treatment:

**The Kneadly grade**
```
1  Crop to the target aspect (4:5 step · 3:2 card · 9:16 onboarding)
2  White balance → warm:  temperature +6, tint +2
3  Desaturate greens and cyans by −18  (kills clinical/hospital tones)
4  Lift shadows +8, pull highlights −12  (soft, matte, filmic)
5  Slight S-curve for contrast, but keep blacks lifted (never crushed)
6  Vignette −8, feathered  (draws the eye to the hands)
7  Grain: 8% at fine size  (breaks up the "stock photo" plastic look)
8  Export: HEIC q80 for bundled, WebP q82 for remote, @1x @2x @3x
```

**Do it in one command** — a single Lightroom preset, a Capture One style, or free with ImageMagick:
```bash
magick input.jpg -modulate 100,88,104 -sigmoidal-contrast 3,50% \
  -fill '#C0664A' -colorize 4% -vignette 0x18+10+10 \
  -attenuate 0.35 +noise Gaussian -resize 1600x -quality 82 output.webp
```

**Verification:** lay all 60 graded images out in a grid at thumbnail size. If any one jumps out as differently-lit, re-grade or replace it. This grid test takes ten minutes and is what separates a $2 app from a $50 one.

---

## 6. Layer B — vectors (the important half)

### 6.1 Body maps
| Repo | Language | License | Use |
|------|----------|---------|-----|
| **[melihcolpan/MuscleMap](https://github.com/melihcolpan/MuscleMap)** | **SwiftUI, iOS 17+** | **MIT** | **Recommended.** Native SwiftUI, male/female, front/back, 36 muscle regions with left/right, highlighting, gradients, heatmaps, tap/long-press/drag/pinch, VoiceOver in 11 languages, zero dependencies. SPM: `https://github.com/melihcolpan/MuscleMap.git` from `1.6.4` |
| [vulovix/body-muscles](https://github.com/vulovix/body-muscles) | JS/TS, SVG | Open source | 70+ muscles. **Best raw SVG path source** even if you don't use the JS — extract the paths and convert to SwiftUI `Path` |
| [soroojshehryar/react-muscle-highlighter](https://github.com/soroojshehryar/react-muscle-highlighter) | React | Open source | Alternative SVG source |
| [eMahtab/human-anatomy](https://github.com/eMahtab/human-anatomy) | SVG | Open source | Plain anatomy SVGs |
| [etal/bodymap](https://github.com/etal/bodymap) | Python | Open source | Programmatic anatomical maps |

**Recommendation:** start with **MuscleMap** for v1 (it saves ~3 weeks and is MIT-licensed), then commission a custom illustrator to redraw the silhouette in the Kneadly style for v1.2 once the app has revenue. Wrap it behind a `BodyMapProvider` protocol so swapping it later is a one-file change (`06 § 5`).

### 6.2 SVG → SwiftUI conversion
```bash
# Extract every <path d="..."> from an SVG
grep -o 'd="[^"]*"' body-front.svg | sed 's/d="//;s/"//' > paths.txt
```
Then use **[SVGPath](https://github.com/nicklockwood/SVGPath)** (MIT, Nick Lockwood) to turn a path string into a SwiftUI `Path` at runtime, or [SwiftDraw](https://github.com/swhitty/SwiftDraw) to convert SVG → Swift source at build time. Both are MIT.

### 6.3 Stroke-path overlays — generated, not drawn
Do **not** draw 640 arrow graphics. Each step stores normalised coordinates:
```json
"strokePath": { "points": [[0.42,0.18],[0.51,0.19],[0.58,0.21]], "motion": "knead", "loop": true }
```
and one `StrokePathView` renders and animates all of them. **~40 lines of Swift replaces 640 image assets.**

### 6.4 Icons
SF Symbols 6 for everything possible. For the 14 gaps in `03 § 5`, use [Phosphor](https://phosphoricons.com) (MIT) or [Lucide](https://lucide.dev) (ISC) as a base and redraw to a 24×24 / 1.75pt-stroke grid.

### 6.5 Motion
[Lottie iOS](https://github.com/airbnb/lottie-ios) (Apache-2.0) for stroke-motion loops and the session-complete bloom. Source free animations from LottieFiles — **verify each file's individual license**, they are not uniform. Keep Lottie to ≤ 6 animations; everything else should be native SwiftUI animation, which is lighter and smoother.

---

## 7. Layer C — AI-generated step art, done properly

If a technique has no good stock photo (many don't — *"double thumb walking beside the spine"* is not a common stock subject), generate it. The reason AI images usually look bad in apps is **inconsistency**, not fidelity. Fix that with a locked recipe.

### 7.1 The locked style prompt
Keep everything before `<<SUBJECT>>` byte-identical across every generation:

```
Editorial wellness photography, extreme close-up on hands performing massage,
warm golden low-key lighting from the upper left, soft shadows, shallow depth
of field f/2.0, neutral warm sand and terracotta colour palette, matte film
grade with lifted blacks, subtle 35mm grain, skin texture natural and
unretouched, subject draped with a soft cream towel, calm and clinical yet
warm, no faces visible, no eye contact, shot on Canon R5 85mm,
composition leaving clear negative space in the upper third,
<<SUBJECT>>
```

`<<SUBJECT>>` examples:
- `two thumbs pressing either side of the spine at the base of the neck, seen from above and behind`
- `a forearm gliding down the length of an oiled upper back, seen from the side`
- `a thumb walking along the arch of a bare foot held in the other hand`
- `fingertips curled under the base of the skull, receiver lying face up`

**Negative prompt:**
```
faces, eye contact, nudity, exposed chest, sexualised posing, blue or fluorescent
lighting, white clinical studio background, plastic retouched skin, extra fingers,
malformed hands, watermark, text, logo, jewellery, long fingernails, cold colour cast
```

### 7.2 The four rules that actually produce consistency
1. **Lock the seed family.** Generate a style reference you love, then reuse that seed (and `--sref` / style-reference in Midjourney, or an IP-Adapter reference in Flux) for every subsequent image.
2. **One subject per image, always hands.** Hands are what AI struggles with most — so generate *large*, crop tight, and reject aggressively. Budget a **10:1 generate-to-keep ratio.** Generating 850 images to ship 85 is normal and correct.
3. **Always human-retouch.** Every kept image gets the § 5 grade plus a manual pass to fix finger anatomy. Budget ~10 minutes per image. 85 images ≈ 14 hours of retouching — one freelancer, three days.
4. **Never mix AI and photo in the same visual role.** All step heroes are one or the other. Mixing is what makes an app look cheap.

**Tools:** Midjourney v7 (best hand anatomy + `--sref` consistency) · Flux 1.1 Pro (best prompt adherence, ComfyUI + IP-Adapter for locked style) · Ideogram (best when text must appear). **Check each tool's commercial-use terms for your subscription tier before shipping.**

### 7.3 The honest alternative — commission it
For a $2,500–5,000 budget you can hire one illustrator to draw all **85 step visuals in a single consistent line-and-wash style**, which will look better than any AI output and be unambiguously yours.

- **Cost:** ~$30–60 per illustration on Upwork/Fiverr Pro for a mid-level medical/wellness illustrator, or a flat package rate.
- **Timeline:** 4–6 weeks.
- **Deliverable spec to give them:** SVG + 3× PNG, 4:5, the Kneadly palette from `03 § 2`, one hand-position reference sheet approved first before any full illustrations are drawn.
- **This is the recommended path once the app has revenue.** Ship v1 on photos + vectors, commission for v1.2.

**Cheapest credible path for v1:** photos (Layer A) + vectors (Layer B) cover **85% of the app**, and vectors carry all the actual teaching. Layer C can be deferred entirely to v1.1.

---

## 8. Technical delivery

### 8.1 Formats and sizes
| Asset | Format | Size | Notes |
|-------|--------|------|-------|
| Bundled photos | **HEIC** q80 | @1x/@2x/@3x | ~40% smaller than JPEG at equal quality |
| Remote photos | **WebP** q82 | 1600px long edge | Served from CDN |
| Vectors | **SVG → SwiftUI Path**, or PDF single-scale in the asset catalog | — | "Preserve Vector Data" ON |
| Icons | SF Symbols + custom symbol set | — | Inherits Dynamic Type + weight |
| Lottie | JSON | < 120 KB each | Max 6 in the app |

### 8.2 Bundle budget
- **Target initial download: under 60 MB.** Above ~200 MB you lose cellular installs, which is a real conversion tax.
- Bundle only: onboarding (7), mode cards (4), the 5 free routines' assets, all vectors, app icon. ≈ **22 MB**.
- Everything else ships as **On-Demand Resources** or CDN, downloaded per routine, with a per-routine "Download for offline" button. Programs download as a pack.

### 8.3 Naming convention (enforced by lint)
```
img.{set}.{subject}.{variant}
img.onb.01
img.step.shoulder.petrissage.01
img.reg.foot.alt2
svg.body.front.neutral
svg.hand.forearm
lot.session.complete
```

### 8.4 Loading
- `AsyncImage` is not good enough for a scrolling feed of 62 covers. Use **[Nuke](https://github.com/kean/Nuke)** (MIT) or **[Kingfisher](https://github.com/onevcat/Kingfisher)** (MIT) for memory + disk caching, prefetching and progressive decode.
- Every image has a **colour placeholder** derived from its own average colour (stored as a hex in the content JSON), so the UI never shows a grey box — it shows a warm block that fades into the photo. Small detail, large perceived-quality gain.
- Prefetch the next step's hero during the current step. The Step Player must **never** show a loading spinner.

### 8.5 Credits file (`assets/CREDITS.json`)
```json
{
  "img.onb.01": {
    "source": "Unsplash",
    "photographer": "Toa Heftiba",
    "url": "https://unsplash.com/photos/man-massaging-womans-body-a9pFSC8dTlo",
    "cdn": "https://images.unsplash.com/photo-1519823551278-64ac92734fb1",
    "license": "Unsplash License",
    "attributionRequired": false,
    "downloaded": "2026-08-20"
  }
}
```
Rendered directly into the in-app Credits screen from this file, so credits can never drift out of sync with the assets.

---

## 9. Asset production checklist

- [ ] Curate 60 photos passing all six § 4.4 rules
- [ ] Log every one in `CREDITS.json` **at download time**, not later
- [ ] Apply the § 5 grade to all 60 in one batch
- [ ] Run the thumbnail grid test; replace any outlier
- [ ] Export HEIC @1x/@2x/@3x + WebP
- [ ] Integrate MuscleMap; map its 36 regions onto our 24 tappable paths
- [ ] Draw the 10 hand-position diagrams as SVG
- [ ] Draw foot / hand / ear reflexology maps as SVG
- [ ] Draw the 6 position/propping diagrams
- [ ] Define `strokePath` coordinates for all ~640 steps *(the biggest content task — budget 3 weeks)*
- [ ] Generate or commission ~85 step heroes; retouch each
- [ ] Verify total bundle < 60 MB
- [ ] Verify every image has an `accessibilityLabel` describing the hand position
- [ ] Verify all assets render correctly in dark mode
