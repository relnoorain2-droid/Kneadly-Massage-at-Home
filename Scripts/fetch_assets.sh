#!/usr/bin/env bash
#
# Downloads the photography set into Kneadly/Resources/Photos/.
#
# Photos are free-licence (Unsplash License: commercial use permitted, no
# attribution required, modification allowed). We still ship a credits screen
# and record every source in CREDITS.json — it costs one screen and it ends
# any dispute instantly.
#
# The app runs perfectly without these files: KPhoto falls back to a warm
# gradient derived from each item's placeholderHex. Running this script is what
# turns the app from "clearly intentional" into "premium".
#
# Usage:  ./Scripts/fetch_assets.sh          (from the ios/ directory)
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"
OUT="$ROOT/Kneadly/Resources/Photos"
TSV="$HERE/assets.tsv"
CREDITS="$ROOT/Kneadly/Resources/CREDITS.json"

mkdir -p "$OUT"
echo "[" > "$CREDITS.tmp"
first=1
count=0
failed=0

while IFS=$'\t' read -r id photo author description; do
  [ -z "${id:-}" ] && continue
  case "$id" in \#*) continue ;; esac

  url="https://images.unsplash.com/photo-${photo}?w=1400&q=80&auto=format&fit=crop"
  dest="$OUT/${id}.jpg"

  if [ -f "$dest" ] && [ -s "$dest" ]; then
    echo "  cached  $id"
  else
    printf '  fetch   %s ... ' "$id"
    if curl -fsSL --retry 3 --retry-delay 2 -o "$dest.part" "$url"; then
      mv "$dest.part" "$dest"
      echo "ok"
    else
      rm -f "$dest.part"
      echo "FAILED (app will use its gradient fallback)"
      failed=$((failed+1))
      continue
    fi
  fi

  count=$((count+1))
  [ $first -eq 0 ] && echo "," >> "$CREDITS.tmp"
  first=0
  printf '  {"asset":"%s","source":"Unsplash","photographer":"%s","description":"%s","url":"https://unsplash.com/photos/%s","license":"Unsplash License","attributionRequired":false}' \
    "$id" "$author" "$description" "$photo" >> "$CREDITS.tmp"
done < "$TSV"

echo "" >> "$CREDITS.tmp"
echo "]" >> "$CREDITS.tmp"
mv "$CREDITS.tmp" "$CREDITS"

echo ""
echo "Photos ready: $count downloaded into Resources/Photos ($failed failed)."
echo "Credits written to Resources/CREDITS.json"
