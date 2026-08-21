#!/usr/bin/env python3
"""
Merges ios/content-src/pack_*.json into Kneadly/Resources/content.json and
validates it against the rules the app relies on.

    python3 Scripts/build_content.py

Adding routines is a content change, not a code change: edit or add a pack file,
run this, commit. CI runs the same checks on every push.
"""
import json, glob, os, re, sys, collections

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SRC = os.path.join(ROOT, "content-src")
OUT = os.path.join(ROOT, "Kneadly", "Resources", "content.json")

MODES = {"solo", "partner", "friends", "together"}
LEVELS = {"beginner", "intermediate", "advanced"}
KINDS = {"warmUp", "main", "coolDown"}
HANDS = {"flatPalm","palmHeel","thumbPad","doubleThumb","fingertips","knuckles",
         "forearm","cGrip","pincerGrip","cuppedHand","tool","none"}
MOTIONS = {"glide","knead","circle","hold","walk","rake","stretch","press"}
POSITIONS = {"proneBed","supine","sideLying","seatedChairReversed","seatedUpright","floorMat","standing"}
ZONES = {"head","neck","shoulders","chest","abdomen","hips","arms","forearms",
         "hands","thighs","knees","calves","feet"}
BANNED = re.compile(r"\b(cure[sd]?|heals?|healing|treat(s|ed|ment)?|diagnos\w*|"
                    r"detox\w*|toxins?|realign\w*|clinically proven)\b", re.I)
SUGGESTIVE = re.compile(r"\b(sensual|erotic|foreplay|arousal|tantric|seductive|intimate touch)\b", re.I)


def main() -> int:
    routines, steps, errors = [], [], []

    packs = sorted(glob.glob(os.path.join(SRC, "pack_*.json")))
    if not packs:
        print(f"No pack files found in {SRC}")
        return 1

    for path in packs:
        try:
            data = json.load(open(path))
        except json.JSONDecodeError as exc:
            errors.append(f"{os.path.basename(path)}: invalid JSON — {exc}")
            continue
        routines += data.get("routines", [])
        steps += data.get("steps", [])

    step_ids = [s["id"] for s in steps]
    dupes = [i for i, c in collections.Counter(step_ids).items() if c > 1]
    if dupes:
        errors.append(f"duplicate step ids: {dupes[:5]}")
    by_id = {s["id"]: s for s in steps}

    routine_ids = [r["id"] for r in routines]
    rdupes = [i for i, c in collections.Counter(routine_ids).items() if c > 1]
    if rdupes:
        errors.append(f"duplicate routine ids: {rdupes}")

    used = set()
    for r in routines:
        rid = r["id"]
        if r["mode"] not in MODES: errors.append(f"{rid}: bad mode {r['mode']}")
        if r["level"] not in LEVELS: errors.append(f"{rid}: bad level {r['level']}")
        if r["position"] not in POSITIONS: errors.append(f"{rid}: bad position {r['position']}")
        kinds = {sec["kind"] for sec in r["sections"]}
        if not kinds <= KINDS: errors.append(f"{rid}: bad section kind")
        if "warmUp" not in kinds: errors.append(f"{rid}: no warm-up section")
        if "coolDown" not in kinds: errors.append(f"{rid}: no cool-down section")

        ids = [i for sec in r["sections"] for i in sec["stepIDs"]]
        used |= set(ids)
        if not 6 <= len(ids) <= 14:
            errors.append(f"{rid}: {len(ids)} steps (expected 6–14)")
        total = 0
        for sid in ids:
            step = by_id.get(sid)
            if step is None:
                errors.append(f"{rid}: missing step {sid}")
                continue
            total += step["durationSeconds"]
        if abs(total - r["durationSeconds"]) > 90:
            errors.append(f"{rid}: steps total {total}s but routine claims {r['durationSeconds']}s")
        if r["mode"] == "friends":
            for need in r.get("needs", []):
                low = need.lower()
                if "oil" in low and not re.search(r"\b(no|without|never)\b[^.]*oil", low):
                    errors.append(f"{rid}: Friends routines must work with no oil ({need!r})")

    for sid in set(by_id) - used:
        errors.append(f"orphan step never used by a routine: {sid}")

    for s in steps:
        sid = s["id"]
        if len(s["title"].split()) > 6: errors.append(f"{sid}: title over 6 words")
        if len(s["body"]) > 200: errors.append(f"{sid}: body over 200 characters")
        if len(s.get("sensationCue", "")) > 90: errors.append(f"{sid}: sensation cue over 90 characters")
        if s["handPosition"] not in HANDS: errors.append(f"{sid}: bad hand position {s['handPosition']}")
        if not 1 <= s["pressure"] <= 5: errors.append(f"{sid}: pressure out of range")
        if not s.get("heroImage"): errors.append(f"{sid}: no hero image")
        zones = set(s.get("bodyMapZones", []))
        if not zones: errors.append(f"{sid}: no body map zone")
        if not zones <= ZONES: errors.append(f"{sid}: unknown zone {zones - ZONES}")
        sp = s.get("strokePath")
        if sp:
            if sp["motion"] not in MOTIONS: errors.append(f"{sid}: bad motion {sp['motion']}")
            for pt in sp.get("points", []):
                if len(pt) != 2 or not all(0 <= v <= 1 for v in pt):
                    errors.append(f"{sid}: stroke point out of 0–1 range")
                    break
        for field in ("title", "body", "sensationCue", "voiceScript", "commonMistake", "caution"):
            text = s.get(field) or ""
            if BANNED.search(text): errors.append(f"{sid}: banned claim in {field}")
            if SUGGESTIVE.search(text): errors.append(f"{sid}: suggestive language in {field}")

    if errors:
        print(f"CONTENT VALIDATION FAILED — {len(errors)} problem(s):")
        for e in errors[:50]:
            print("  -", e)
        if len(errors) > 50:
            print(f"  … and {len(errors) - 50} more")
        return 1

    pack = {"schemaVersion": 1, "packID": "core.v1", "routines": routines, "steps": steps}
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w") as fh:
        json.dump(pack, fh, ensure_ascii=False, separators=(",", ":"))

    modes = collections.Counter(r["mode"] for r in routines)
    free = [r["id"] for r in routines if not r.get("isPremium")]
    minutes = sum(r["durationSeconds"] for r in routines) // 60
    print(f"OK  {len(routines)} routines · {len(steps)} steps · {minutes} minutes of guided content")
    print(f"    modes: {dict(modes)}")
    print(f"    free:  {len(free)} routines")
    print(f"    wrote {OUT} ({os.path.getsize(OUT) // 1024} KB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
