# Kneadly — start here

You now have a complete, ready-to-build iOS app. This page is the whole thing in five minutes.

---

## What's in the box

| | |
|---|---|
| **`Kneadly-iOS-App.zip`** | The app. 38 Swift files, 24 massage routines, 225 steps, CI that uploads to TestFlight. Already a git repo with one commit — unzip, add a remote, push. |
| **`ios/TESTFLIGHT_RUNBOOK.md`** | The submission guide. Written for someone with an Apple Developer account and **no Mac**. |
| **`ios/README.md`** | How the code is organised and why. |
| **`ios/docs/`** | The nine design documents from before, carried along. |

---

## The one thing you need to understand

Xcode only runs on macOS. You don't have a Mac. So this project builds on **GitHub's hosted macOS runners** — you push code, a Mac in GitHub's cloud compiles it, signs it with your Apple credentials, and uploads it straight to TestFlight. You never touch a Mac, never generate a certificate by hand, never download a provisioning profile.

That's why the CI setup in `.github/workflows/` is not optional extra polish. **It is how your app gets built.**

---

## Your next four steps

**1. Push it to GitHub.**
```bash
unzip Kneadly-iOS-App.zip
cd ios
git remote add origin https://github.com/YOUR-USERNAME/kneadly.git
git push -u origin main
```

**2. Run "Build check" in the Actions tab.** No Apple credentials needed. This is the first time the code is actually compiled — see the honest note below. Get it green before anything else.

**3. Do the Apple setup.** Runbook §2: register the App ID `com.kneadly-Massage.app`, create the app record, create the three subscription products, generate an App Store Connect API key. About 30 minutes.

**4. Add four secrets and run "TestFlight".** Runbook §3–4. The build lands in TestFlight in about 15 minutes.

---

## One honest thing about the code

I built this on Linux, where **Xcode does not exist** — so I could not compile it. Every Swift file has been parsed with a real Swift grammar (38/38 clean, no syntax errors), and I ran static checks for duplicate types, undefined design tokens, missing image references, mismatched StoreKit product IDs and bundle-ID drift. All pass.

But a parser catches syntax, not type errors. The **first real compile is the Build check workflow**, and it is realistic that it surfaces a handful of type mismatches on the first run — that is normal for any codebase of this size on its first build, not a sign anything is wrong. The workflow log names the exact file and line. Send me the log and I'll fix them.

That's exactly why Build check exists as a separate, credential-free workflow: it separates *"does the code compile"* from *"is my Apple account set up right"*. Debugging both at once is miserable.

---

## What's actually in the app

**24 complete routines · 225 steps · 225 minutes of guided content**

- **12 solo** — neck & shoulder, feet, hands, scalp for sleep, face lymphatic, jaw/TMJ, headache, forearms, lower back ball release, glutes, calves, desk reset
- **8 partner** — back basics, neck & shoulder, scalp wind-down, upper back knot hunt, lower back & hips, foot ritual, hamstring & calf recovery, full body express
- **3 friends & family** — office chair 10-minute, hand & wrist, foot reflexology. Fully clothed, no oil, nothing awkward.
- **1 together** — hand exchange
- **8 of them free**, the rest behind the paywall
- **3 multi-day programs** — 7 Nights to Better Sleep, 10-Day Neck Reset, 14-Day Couples Connection

Every step carries a title, a two-sentence instruction, what the receiver should feel, hand position, pressure level with a plain-language anchor, duration, rhythm, a voice-narration script, common mistakes, safety cautions, body-map zones and a stroke-path.

**Screens:** onboarding (6, including a blocking health screen) → Today → interactive body map → Learn → Me → routine detail → 3-step prepare flow with the two-tap consent ritual → the Step Player → session complete with feedback → paywall.

---

## Three decisions worth knowing about

**The body map is vector, not images.** Every zone is drawn as a SwiftUI `Path` in code. It scales, tints, animates, works in dark mode, and adds nothing to the download. The diagrams do the teaching; photographs only set the mood. This is what removed most of the image-quality risk you were worried about.

**Photographs are optional at runtime.** `Scripts/fetch_assets.sh` downloads 23 free-licence photos and CI runs it automatically. If it fails, the app renders a warm gradient built from each item's stored colour instead — so it still looks deliberate, never a grey box. You can drop your own photos in at any time; the filenames are listed in `Scripts/assets.tsv`.

**Safety gates content rather than warning about it.** The contraindication engine runs *before* a routine list renders, not as a popup afterwards. And a blocked routine always offers a safe alternative in the same card — a dead end is a bad product and a worse safety outcome, because a user told only "no" will go do it wrong on YouTube.

---

## Before you invite external testers

TestFlight's **internal** testing (up to 100 people you add in App Store Connect) needs nothing more than a build. **External** testing needs a short Beta App Review — and a couples-massage app draws extra scrutiny under Guideline 1.1.4. Runbook §7 has reviewer notes written for exactly that, plus the vocabulary to keep out of your app and metadata.

You'll also want a privacy policy URL before external testing. Runbook §8 lists the rest.
