#!/usr/bin/env bash

# ==============================================================================
# Automated Verification Suite for Sura-agentic install.sh
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$REPO_ROOT/install.sh"
TMP_BASE="$(mktemp -d)"
trap 'rm -rf "$TMP_BASE"' EXIT
# Installer menulis ke ~/.sura — jangan pernah sentuh HOME asli developer
REAL_HOME="$HOME"
export HOME="$TMP_BASE/home"
mkdir -p "$HOME"

echo "🧪 Running Sura-agentic Installer Verification Suite..."

# 1. Syntax Check
bash -n "$INSTALLER"
echo "  ✅ [PASS] bash -n syntax check on install.sh"

# 2. Test Case 1: Backend + No-Test Profile on a Git Repo
TEST_DIR_1="$TMP_BASE/proj-backend"
mkdir -p "$TEST_DIR_1"
git -C "$TEST_DIR_1" init -q
touch "$TEST_DIR_1/go.mod"

bash "$INSTALLER" "$TEST_DIR_1" --scope backend --test no-test --no-deps >/dev/null

# Verify directories & files created
for f in \
  "sura-memory/README.md" \
  "sura-memory/MEMORY.md" \
  "sura-memory/CONVENTIONS.md" \
  "sura-memory/COMMANDS.md" \
  "sura-memory/SKILL.md" \
  "sura-memory/DESIGN_BEFORE_CODE.md" \
  "sura-memory/PR_REVIEW_PLAYBOOK.md" \
  "sura-memory/TASK_LOG.md" \
  "sura-memory/TASK_LOG.archive.md" \
  "sura-memory/TRD/PRD.md" \
  "sura-memory/TRD/TRD.md" \
  "sura-memory/.gitignore" \
  ".ignore" \
  ".cursorignore" \
  ".geminiignore" \
  "CLAUDE.md" \
  "GEMINI.md" \
  ".agents/rules/agentic-sop.md" \
  ".cursor/rules/agentic-sop.mdc"; do
  if [ ! -f "$TEST_DIR_1/$f" ]; then
    echo "  ❌ [FAIL] Missing expected file: $f"
    exit 1
  fi
done

for d in "sura-memory/TRD" "sura-memory/designs" "sura-memory/reviews" "sura-memory/lessons"; do
  if [ ! -d "$TEST_DIR_1/$d" ]; then
    echo "  ❌ [FAIL] Missing expected directory: $d"
    exit 1
  fi
done

# Verify profile interpolation
grep -q "PROJECT_SCOPE=backend" "$TEST_DIR_1/CLAUDE.md"
grep -q "TEST_MODE=no-test" "$TEST_DIR_1/CLAUDE.md"
grep -q "\`backend\`" "$TEST_DIR_1/sura-memory/CONVENTIONS.md"
grep -q "\`no-test\`" "$TEST_DIR_1/sura-memory/CONVENTIONS.md"

# Verify global developer profile (~/.sura) — created once, never overwritten
[ -f "$HOME/.sura/profile.md" ] || { echo "  ❌ [FAIL] ~/.sura/profile.md tidak dibuat"; exit 1; }
[ -f "$HOME/.sura/lessons.md" ] || { echo "  ❌ [FAIL] ~/.sura/lessons.md tidak dibuat"; exit 1; }
if grep -q '{{DEVELOPER_NAME}}' "$TEST_DIR_1/sura-memory/MEMORY.md"; then echo "  ❌ [FAIL] MEMORY.md masih memuat profil developer"; exit 1; fi
grep -qF '~/.sura/profile.md' "$TEST_DIR_1/sura-memory/MEMORY.md" || { echo "  ❌ [FAIL] MEMORY.md tidak menunjuk ke ~/.sura/profile.md"; exit 1; }
echo "custom profile" >> "$HOME/.sura/profile.md"
echo "custom lesson" >> "$HOME/.sura/lessons.md"

# Verify slim Claude payload
[ "$(wc -c < "$TEST_DIR_1/CLAUDE.md")" -le 6144 ] || { echo "  ❌ [FAIL] CLAUDE.md > 6144 byte ($(wc -c < "$TEST_DIR_1/CLAUDE.md"))"; exit 1; }
[ "$(wc -l < "$TEST_DIR_1/CLAUDE.md")" -le 80 ] || { echo "  ❌ [FAIL] CLAUDE.md > 80 baris"; exit 1; }

# Verify Claude skills installed verbatim
for n in sura-prd-trd sura-project-profile sura-graphify; do
  cmp -s "$REPO_ROOT/skills/$n/SKILL.md" "$TEST_DIR_1/.claude/skills/$n/SKILL.md" \
    || { echo "  ❌ [FAIL] .claude/skills/$n/SKILL.md tidak terpasang / berbeda"; exit 1; }
done

# Verify per-tool payloads: superpowers refs only for Claude, skills inlined for others
grep -q 'superpowers:' "$TEST_DIR_1/CLAUDE.md"
for f in GEMINI.md .agents/rules/agentic-sop.md .cursor/rules/agentic-sop.mdc; do
  if grep -q 'superpowers:' "$TEST_DIR_1/$f"; then echo "  ❌ [FAIL] $f menyebut superpowers:"; exit 1; fi
done
for marker in 'Siklus Hidup "Satu Fitur Aktif"' 'Peta Folder `sura-memory/`' 'Graphify Knowledge Graph Protocol'; do
  grep -qF "$marker" "$TEST_DIR_1/GEMINI.md" || { echo "  ❌ [FAIL] isi skill tidak ter-inline: $marker"; exit 1; }
done
if grep -q '^name: sura-' "$TEST_DIR_1/GEMINI.md"; then echo "  ❌ [FAIL] frontmatter skill ikut ter-inline"; exit 1; fi
[ "$(head -1 "$TEST_DIR_1/.cursor/rules/agentic-sop.mdc")" = "---" ]
grep -q 'alwaysApply: true' "$TEST_DIR_1/.cursor/rules/agentic-sop.mdc"

# Verify archive dir & ignore entry
[ -d "$TEST_DIR_1/sura-memory/TRD/archive" ]
grep -qxF 'sura-memory/TRD/archive/' "$TEST_DIR_1/.ignore"
for f in .cursorignore .geminiignore; do
  if grep -q 'sura-memory/TRD/archive/' "$TEST_DIR_1/$f"; then echo "  ❌ [FAIL] $f memblokir arsip"; exit 1; fi
done
# Exclude only Sura's own rule files, never whole team folders
for pat in '.cursor/rules/' '.agents/rules/'; do
  if grep -qxF "$pat" "$TEST_DIR_1/.git/info/exclude"; then echo "  ❌ [FAIL] seluruh folder $pat di-exclude"; exit 1; fi
done
grep -qxF '.cursor/rules/agentic-sop.mdc' "$TEST_DIR_1/.git/info/exclude"
grep -qxF '.agents/rules/agentic-sop.md' "$TEST_DIR_1/.git/info/exclude"
echo "  ✅ [PASS] Payload per tool (CLAUDE.md ramping, skill terpasang, inline untuk tool lain)"

# Verify zero git leakage (excluding dummy go.mod)
rm -f "$TEST_DIR_1/go.mod"
GIT_STATUS="$(git -C "$TEST_DIR_1" status --porcelain)"
if [ -n "$GIT_STATUS" ]; then
  echo "  ❌ [FAIL] Git status is not clean! Leaked files:"
  echo "$GIT_STATUS"
  exit 1
fi
echo "  ✅ [PASS] Profile (backend + no-test), full sura-memory tree, and zero Git leakage verified"

# Re-run upgrade: old monolithic CLAUDE.md gets replaced, excludes not duplicated
{ echo "<!-- SURA-AGENTIC-AUTO-GENERATED -->"; for i in $(seq 1 500); do echo "old rule line $i"; done; } > "$TEST_DIR_1/CLAUDE.md"
printf ".agents/rules/\n.cursor/rules/\n" >> "$TEST_DIR_1/.git/info/exclude"
bash "$INSTALLER" "$TEST_DIR_1" --scope backend --test no-test --no-deps >/dev/null
for pat in '.cursor/rules/' '.agents/rules/'; do
  if grep -qxF "$pat" "$TEST_DIR_1/.git/info/exclude"; then echo "  ❌ [FAIL] exclude lama $pat tidak dibersihkan saat upgrade"; exit 1; fi
done
[ "$(wc -l < "$TEST_DIR_1/CLAUDE.md")" -le 80 ] || { echo "  ❌ [FAIL] re-run tidak meramping CLAUDE.md lama"; exit 1; }
[ "$(grep -cxF 'sura-memory/' "$TEST_DIR_1/.git/info/exclude")" -eq 1 ] || { echo "  ❌ [FAIL] exclude dobel"; exit 1; }
grep -qxF "custom profile" "$HOME/.sura/profile.md" || { echo "  ❌ [FAIL] ~/.sura/profile.md tertimpa saat re-run"; exit 1; }
grep -qxF "custom lesson" "$HOME/.sura/lessons.md" || { echo "  ❌ [FAIL] ~/.sura/lessons.md tertimpa saat re-run"; exit 1; }
echo "  ✅ [PASS] Re-run upgrade dari payload lama: CLAUDE.md ramping, exclude tidak dobel"

# 3. Test Case 2: Team CLAUDE.md / GEMINI.md & Custom .ignore Preservation
TEST_DIR_2="$TMP_BASE/proj-team"
mkdir -p "$TEST_DIR_2"
git -C "$TEST_DIR_2" init -q
echo "# Team Claude Rules" > "$TEST_DIR_2/CLAUDE.md"
echo "# Team Gemini Rules" > "$TEST_DIR_2/GEMINI.md"
echo "custom_ignore_dir/" > "$TEST_DIR_2/.ignore"
mkdir -p "$TEST_DIR_2/.claude/skills/team-skill" "$TEST_DIR_2/.cursor/rules" "$TEST_DIR_2/.agents/rules"
echo "team cursor rule" > "$TEST_DIR_2/.cursor/rules/team.mdc"
echo "team sop" > "$TEST_DIR_2/.cursor/rules/agentic-sop.mdc"
echo "team agy sop" > "$TEST_DIR_2/.agents/rules/agentic-sop.md"
echo "team" > "$TEST_DIR_2/.claude/skills/team-skill/SKILL.md"

bash "$INSTALLER" "$TEST_DIR_2" --non-interactive --no-deps >/dev/null

grep -qxF "team" "$TEST_DIR_2/.claude/skills/team-skill/SKILL.md"
[ -f "$TEST_DIR_2/.claude/skills/sura-prd-trd/SKILL.md" ]
if grep -q 'team-skill' "$TEST_DIR_2/.git/info/exclude"; then echo "  ❌ [FAIL] skill tim ikut di-exclude"; exit 1; fi
[ "$(wc -c < "$TEST_DIR_2/CLAUDE.local.md")" -le 6144 ]
grep -qxF "team sop" "$TEST_DIR_2/.cursor/rules/agentic-sop.mdc" || { echo "  ❌ [FAIL] agentic-sop.mdc milik tim tertimpa"; exit 1; }
grep -qxF "team agy sop" "$TEST_DIR_2/.agents/rules/agentic-sop.md" || { echo "  ❌ [FAIL] agentic-sop.md milik tim tertimpa"; exit 1; }
grep -q 'SURA-AGENTIC-AUTO-GENERATED' "$TEST_DIR_2/.cursor/rules/sura-agentic-sop.mdc"
grep -q 'SURA-AGENTIC-AUTO-GENERATED' "$TEST_DIR_2/.agents/rules/sura-agentic-sop.md"
git -C "$TEST_DIR_2" status --porcelain -uall | grep -qF '.cursor/rules/team.mdc' || { echo "  ❌ [FAIL] rule tim baru tersembunyi dari git"; exit 1; }
if git -C "$TEST_DIR_2" status --porcelain -uall | grep -q 'sura-agentic-sop'; then echo "  ❌ [FAIL] payload Sura bocor ke git"; exit 1; fi

grep -qxF "# Team Claude Rules" "$TEST_DIR_2/CLAUDE.md"
grep -qxF "# Team Gemini Rules" "$TEST_DIR_2/GEMINI.md"
grep -qxF "custom_ignore_dir/" "$TEST_DIR_2/.ignore"
[ -f "$TEST_DIR_2/CLAUDE.local.md" ]
[ -f "$TEST_DIR_2/GEMINI.local.md" ]

echo "  ✅ [PASS] Team CLAUDE.md, GEMINI.md, and custom .ignore preserved safely"
# 4. Superpowers skill names referenced in rules must exist (catches upstream renames)
SP_DIR="${SUPERPOWERS_SKILLS_DIR:-$(ls -d "$REAL_HOME"/.claude/plugins/cache/*/superpowers/*/skills 2>/dev/null | sort -V | tail -1 || true)}"
if [ -z "$SP_DIR" ] || [ ! -d "$SP_DIR" ]; then
  echo "  ⏭️  [SKIP] Superpowers tidak ditemukan — cek nama skill dilewati"
else
  for s in $(grep -rhoE 'superpowers:[a-z-]+' "$REPO_ROOT/rules" | sort -u | cut -d: -f2); do
    [ -f "$SP_DIR/$s/SKILL.md" ] || { echo "  ❌ [FAIL] Skill superpowers:$s tidak ada di $SP_DIR"; exit 1; }
  done
  echo "  ✅ [PASS] Semua referensi superpowers:* ada di $SP_DIR"
fi

# 5. Dependency offer (Superpowers + Graphify) — stubbed PATH, nothing real is installed
STUB_BIN="$TMP_BASE/stub-bin"
make_stubs() {
  rm -rf "$STUB_BIN"; mkdir -p "$STUB_BIN"; : > "$STUB_BIN/calls.log"; : > "$STUB_BIN/plugins"
  printf '#!/bin/sh\necho "claude $*" >> "%s/calls.log"\n[ "$1 $2" = "plugin list" ] && cat "%s/plugins"\nexit 0\n' "$STUB_BIN" "$STUB_BIN" > "$STUB_BIN/claude"
  printf '#!/bin/sh\necho "graphify $*" >> "%s/calls.log"\n' "$STUB_BIN" > "$STUB_BIN/graphify.real"
  printf '#!/bin/sh\necho "uv $*" >> "%s/calls.log"\n[ "$1 $2" = "tool install" ] && cp "%s/graphify.real" "%s/graphify" && chmod +x "%s/graphify"\nexit 0\n' "$STUB_BIN" "$STUB_BIN" "$STUB_BIN" "$STUB_BIN" "$STUB_BIN" > "$STUB_BIN/uv"
  chmod +x "$STUB_BIN/claude" "$STUB_BIN/uv" "$STUB_BIN/graphify.real"
}
SYS_BIN="$TMP_BASE/sys-bin"; mkdir -p "$SYS_BIN"
for t in bash sh env mkdir pwd dirname basename date sed cp rm rmdir grep awk cat ls sort tail cut head chmod wc tr; do
  ln -sf "$(command -v "$t")" "$SYS_BIN/$t"
done
run_deps() {
  local dir="$TMP_BASE/deps-$1"; shift
  mkdir -p "$dir"
  PATH="$STUB_BIN:$SYS_BIN" bash "$INSTALLER" "$dir" --scope cli-lib --test flexible "$@" < /dev/null 2>&1
}

make_stubs
OUT="$(run_deps missing-noninteractive --non-interactive)"
grep -qF 'uv tool install graphifyy' <<<"$OUT" || { echo "  ❌ [FAIL] rekomendasi graphify tidak dicetak"; exit 1; }
grep -qF 'claude plugin install superpowers@superpowers-marketplace' <<<"$OUT" || { echo "  ❌ [FAIL] rekomendasi superpowers tidak dicetak"; exit 1; }
if grep -q 'install' "$STUB_BIN/calls.log"; then echo "  ❌ [FAIL] non-interactive menjalankan install"; cat "$STUB_BIN/calls.log"; exit 1; fi

make_stubs
run_deps missing-with-deps --with-deps >/dev/null
grep -qF 'uv tool install graphifyy' "$STUB_BIN/calls.log" || { echo "  ❌ [FAIL] --with-deps tidak memasang graphifyy"; exit 1; }
grep -qF 'claude plugin install superpowers@superpowers-marketplace' "$STUB_BIN/calls.log" || { echo "  ❌ [FAIL] --with-deps tidak memasang superpowers"; exit 1; }
grep -qF 'graphify install --platform claude' "$STUB_BIN/calls.log" || { echo "  ❌ [FAIL] skill graphify tidak didaftarkan"; exit 1; }
if grep -q 'graphify claude install' "$STUB_BIN/calls.log"; then echo "  ❌ [FAIL] memakai graphify claude install"; exit 1; fi

make_stubs
cp "$STUB_BIN/graphify.real" "$STUB_BIN/graphify"; chmod +x "$STUB_BIN/graphify"
echo "superpowers@superpowers-marketplace" > "$STUB_BIN/plugins"
OUT="$(run_deps present --with-deps)"
grep -q 'sudah terpasang' <<<"$OUT" || { echo "  ❌ [FAIL] deps terpasang tidak dikenali"; exit 1; }
if grep -q 'install' "$STUB_BIN/calls.log"; then echo "  ❌ [FAIL] install ulang padahal sudah ada"; exit 1; fi

make_stubs
rm -f "$STUB_BIN/uv"
if PATH="$STUB_BIN:$SYS_BIN" command -v uv >/dev/null; then echo "  ❌ [FAIL] PATH test tidak hermetis (uv sistem terlihat)"; exit 1; fi
OUT="$(run_deps no-uv --with-deps)" || { echo "  ❌ [FAIL] installer gagal saat uv tidak ada"; exit 1; }
grep -q '⚠️' <<<"$OUT" || { echo "  ❌ [FAIL] tidak ada peringatan saat uv tidak ada"; exit 1; }

make_stubs
OUT="$(run_deps skip --no-deps)"
if grep -q 'Superpowers' <<<"$OUT"; then echo "  ❌ [FAIL] --no-deps masih mengecek dependensi"; exit 1; fi
echo "  ✅ [PASS] Tawaran install Superpowers & Graphify (rekomendasi, --with-deps, sudah ada, tanpa uv, --no-deps)"

echo "🎉 All installer tests passed (100%)!"
