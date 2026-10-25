#!/usr/bin/env bash

# ==============================================================================
# Automated Verification Suite for Sura-agentic install.sh
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$REPO_ROOT/install.sh"
TMP_BASE="$(mktemp -d)"
trap 'rm -rf "$TMP_BASE"' EXIT

echo "🧪 Running Sura-agentic Installer Verification Suite..."

# 1. Syntax Check
bash -n "$INSTALLER"
echo "  ✅ [PASS] bash -n syntax check on install.sh"

# 2. Test Case 1: Backend + No-Test Profile on a Git Repo
TEST_DIR_1="$TMP_BASE/proj-backend"
mkdir -p "$TEST_DIR_1"
git -C "$TEST_DIR_1" init -q
touch "$TEST_DIR_1/go.mod"

bash "$INSTALLER" "$TEST_DIR_1" --scope backend --test no-test >/dev/null

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
grep -q 'sura-memory/TRD/archive/' "$TEST_DIR_1/GEMINI.md"
if grep -q '^name: sura-' "$TEST_DIR_1/GEMINI.md"; then echo "  ❌ [FAIL] frontmatter skill ikut ter-inline"; exit 1; fi
[ "$(head -1 "$TEST_DIR_1/.cursor/rules/agentic-sop.mdc")" = "---" ]
grep -q 'alwaysApply: true' "$TEST_DIR_1/.cursor/rules/agentic-sop.mdc"

# Verify archive dir & ignore entry
[ -d "$TEST_DIR_1/sura-memory/TRD/archive" ]
grep -qxF 'sura-memory/TRD/archive/' "$TEST_DIR_1/.ignore"
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
bash "$INSTALLER" "$TEST_DIR_1" --scope backend --test no-test >/dev/null
[ "$(wc -l < "$TEST_DIR_1/CLAUDE.md")" -le 80 ] || { echo "  ❌ [FAIL] re-run tidak meramping CLAUDE.md lama"; exit 1; }
[ "$(grep -cxF 'sura-memory/' "$TEST_DIR_1/.git/info/exclude")" -eq 1 ] || { echo "  ❌ [FAIL] exclude dobel"; exit 1; }
echo "  ✅ [PASS] Re-run upgrade dari payload lama: CLAUDE.md ramping, exclude tidak dobel"

# 3. Test Case 2: Team CLAUDE.md / GEMINI.md & Custom .ignore Preservation
TEST_DIR_2="$TMP_BASE/proj-team"
mkdir -p "$TEST_DIR_2"
git -C "$TEST_DIR_2" init -q
echo "# Team Claude Rules" > "$TEST_DIR_2/CLAUDE.md"
echo "# Team Gemini Rules" > "$TEST_DIR_2/GEMINI.md"
echo "custom_ignore_dir/" > "$TEST_DIR_2/.ignore"
mkdir -p "$TEST_DIR_2/.claude/skills/team-skill"
echo "team" > "$TEST_DIR_2/.claude/skills/team-skill/SKILL.md"

bash "$INSTALLER" "$TEST_DIR_2" --non-interactive >/dev/null

grep -qxF "team" "$TEST_DIR_2/.claude/skills/team-skill/SKILL.md"
[ -f "$TEST_DIR_2/.claude/skills/sura-prd-trd/SKILL.md" ]
if grep -q 'team-skill' "$TEST_DIR_2/.git/info/exclude"; then echo "  ❌ [FAIL] skill tim ikut di-exclude"; exit 1; fi
[ "$(wc -c < "$TEST_DIR_2/CLAUDE.local.md")" -le 6144 ]

grep -qxF "# Team Claude Rules" "$TEST_DIR_2/CLAUDE.md"
grep -qxF "# Team Gemini Rules" "$TEST_DIR_2/GEMINI.md"
grep -qxF "custom_ignore_dir/" "$TEST_DIR_2/.ignore"
[ -f "$TEST_DIR_2/CLAUDE.local.md" ]
[ -f "$TEST_DIR_2/GEMINI.local.md" ]

echo "  ✅ [PASS] Team CLAUDE.md, GEMINI.md, and custom .ignore preserved safely"
echo "🎉 All installer tests passed (100%)!"
