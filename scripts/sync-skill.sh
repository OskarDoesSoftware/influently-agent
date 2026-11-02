#!/usr/bin/env bash
# Copies skills/influently to .agents/skills/influently (portable skills location).
# skills/ is the source of truth. Run with --check to verify without writing.
set -euo pipefail
cd "$(dirname "$0")/.."
src="skills/influently"
dst=".agents/skills/influently"
if [ "${1:-}" = "--check" ]; then
  if diff -r "$src" "$dst" >/dev/null 2>&1; then
    echo "ok: $dst matches $src"
  else
    echo "FAIL: $dst is out of sync with $src. Run scripts/sync-skill.sh" >&2
    exit 1
  fi
  exit 0
fi
rm -rf "$dst"
mkdir -p "$(dirname "$dst")"
cp -R "$src" "$dst"
echo "synced $src -> $dst"
