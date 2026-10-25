#!/usr/bin/env bash

# ==============================================================================
# Token Budget Measurement — payload & session-start reads, baseline vs now
#   bash tests/measure.sh            → print markdown table
#   bash tests/measure.sh --check    → fail if README numbers are stale
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASELINE_REV="0a94e8a"   # monolithic rules, before the rules-split refactor
TMP_BASE="$(mktemp -d)"
trap 'rm -rf "$TMP_BASE"' EXIT
export HOME="$TMP_BASE/home"   # installer menulis ~/.sura — jangan sentuh HOME asli
mkdir -p "$HOME"

fail() { echo "  ❌ [FAIL] $*"; exit 1; }

# install_into <installer-root> <target>
install_into() {
  mkdir -p "$2"
  git -C "$2" init -q
  bash "$1/install.sh" "$2" --non-interactive --no-deps >/dev/null 2>&1 \
    || bash "$1/install.sh" "$2" --non-interactive >/dev/null 2>&1
}

bytes() { cat "$@" | wc -c | tr -d ' '; }
kb() { awk -v b="$1" 'BEGIN { printf "%.1f", b / 1000 }'; }
tok() { awk -v b="$1" 'BEGIN { printf "%d", b / 4 }'; }

mkdir -p "$TMP_BASE/old-src"
git -C "$REPO_ROOT" archive "$BASELINE_REV" | tar -x -C "$TMP_BASE/old-src"
install_into "$TMP_BASE/old-src" "$TMP_BASE/old"
install_into "$REPO_ROOT" "$TMP_BASE/new"

O="$TMP_BASE/old"; N="$TMP_BASE/new"
OM="$O/sura-memory"; NM="$N/sura-memory"
OLD_CLAUDE="$(bytes "$O/CLAUDE.md")";  NEW_CLAUDE="$(bytes "$N/CLAUDE.md")"
OLD_INLINE="$(bytes "$O/GEMINI.md")";  NEW_INLINE="$(bytes "$N/GEMINI.md")"
# Old RULES required 5 project files at session start; new core requires 2 global + 3 project files
# (PRD/TRD only with an active task)
OLD_READ="$(bytes "$OM/MEMORY.md" "$OM/CONVENTIONS.md" "$OM/TASK_LOG.md" "$OM/TRD/PRD.md" "$OM/TRD/TRD.md")"
NEW_READ="$(bytes "$HOME/.sura/profile.md" "$HOME/.sura/lessons.md" "$NM/MEMORY.md" "$NM/CONVENTIONS.md" "$NM/TASK_LOG.md")"
# SessionStart hook output is injected automatically every Claude Code session
NEW_HOOK="$(CLAUDE_PROJECT_DIR="$N" bash "$N/.claude/hooks/sura-session-start.sh" | wc -c | tr -d ' ')"
OLD_TOTAL=$((OLD_CLAUDE + OLD_READ)); NEW_TOTAL=$((NEW_CLAUDE + NEW_HOOK + NEW_READ))

table() {
  echo "| Dibaca AI di awal sesi | Sebelum refactor | Sekarang |"
  echo "|---|---|---|"
  echo "| \`CLAUDE.md\` (selalu dimuat) | $(kb "$OLD_CLAUDE") KB | $(kb "$NEW_CLAUDE") KB |"
  echo "| Hook \`SessionStart\` (otomatis) | — | $(kb "$NEW_HOOK") KB |"
  echo "| File wajib saat \`baca sura\` | 5 file, $(kb "$OLD_READ") KB | 5 file (2 global + 3 proyek), $(kb "$NEW_READ") KB |"
  echo "| **Total awal sesi (Claude Code)** | **$(kb "$OLD_TOTAL") KB ≈ $(tok "$OLD_TOTAL") token** | **$(kb "$NEW_TOTAL") KB ≈ $(tok "$NEW_TOTAL") token** |"
  echo "| \`GEMINI.md\` / Cursor / Antigravity (selalu dimuat) | $(kb "$OLD_INLINE") KB | $(kb "$NEW_INLINE") KB |"
}

if [ "${1:-}" != "--check" ]; then
  table
  exit 0
fi

README="$REPO_ROOT/README.md"
EXPECTED="$(table)"
ACTUAL="$(awk '/<!-- MEASURE:START -->/{f=1; next} /<!-- MEASURE:END -->/{f=0} f' "$README")"
[ "$ACTUAL" = "$EXPECTED" ] || {
  echo "  ❌ [FAIL] Tabel ukuran di README basi. Ganti isi antara MEASURE:START/END dengan:"
  echo "$EXPECTED"
  exit 1
}
grep -qF "~$(kb "$NEW_CLAUDE") KB di \`CLAUDE.md\`" "$README" \
  || fail "Klaim ukuran CLAUDE.md di README tidak sama dengan hasil ukur ($(kb "$NEW_CLAUDE") KB)"
echo "  ✅ [PASS] Angka ukuran di README sesuai hasil ukur (CLAUDE.md $(kb "$NEW_CLAUDE") KB)"
