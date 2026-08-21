#!/usr/bin/env bash
# Sets CURRENT_PROJECT_VERSION in project.yml. CI passes the run number so every
# TestFlight upload gets a unique, increasing build number.
set -euo pipefail
BUILD="${1:?usage: bump_build.sh <build-number>}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"
/usr/bin/sed -i '' -E "s/CURRENT_PROJECT_VERSION: \".*\"/CURRENT_PROJECT_VERSION: \"${BUILD}\"/" "$ROOT/project.yml" 2>/dev/null \
  || sed -i -E "s/CURRENT_PROJECT_VERSION: \".*\"/CURRENT_PROJECT_VERSION: \"${BUILD}\"/" "$ROOT/project.yml"
echo "Build number set to ${BUILD}"
