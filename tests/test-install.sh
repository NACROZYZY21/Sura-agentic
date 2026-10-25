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

# Project profile saved for plugin-mode hook & --upgrade
grep -qxF 'PROJECT_SCOPE=backend' "$TEST_DIR_1/sura-memory/.profile" && grep -qxF 'TEST_MODE=no-test' "$TEST_DIR_1/sura-memory/.profile" \
  || { echo "  ❌ [FAIL] sura-memory/.profile tidak menyimpan profil proyek"; exit 1; }

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

# Verify Claude Code hooks installed and registered in settings.local.json
for h in sura-session-start.sh sura-block-noise.sh; do
  cmp -s "$REPO_ROOT/hooks/$h" "$TEST_DIR_1/.claude/hooks/$h" || { echo "  ❌ [FAIL] .claude/hooks/$h tidak terpasang"; exit 1; }
done
SETTINGS_1="$TEST_DIR_1/.claude/settings.local.json"
jq -e '[.hooks.SessionStart[].hooks[].command | select(test("sura-session-start"))] | length == 1' "$SETTINGS_1" >/dev/null \
  || { echo "  ❌ [FAIL] hook SessionStart tidak terdaftar"; exit 1; }
jq -e '[.hooks.PreToolUse[] | select(.matcher == "Read|Grep|Glob") | .hooks[].command | select(test("sura-block-noise"))] | length == 1' "$SETTINGS_1" >/dev/null \
  || { echo "  ❌ [FAIL] hook PreToolUse tidak terdaftar"; exit 1; }

# Non-Replit projects never get replit.md
[ ! -e "$TEST_DIR_1/replit.md" ] || { echo "  ❌ [FAIL] replit.md dibuat di proyek non-Replit"; exit 1; }

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
jq -e '[.hooks.SessionStart[].hooks[].command | select(test("sura-"))] | length == 1' "$TEST_DIR_1/.claude/settings.local.json" >/dev/null \
  || { echo "  ❌ [FAIL] hook terdaftar dobel setelah re-run"; exit 1; }
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
echo '{"permissions":{"allow":["Bash(ls:*)"]},"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"team-guard.sh"}]}]}}' > "$TEST_DIR_2/.claude/settings.local.json"
echo "team" > "$TEST_DIR_2/.claude/skills/team-skill/SKILL.md"

bash "$INSTALLER" "$TEST_DIR_2" --non-interactive --no-deps >/dev/null

grep -qxF "team" "$TEST_DIR_2/.claude/skills/team-skill/SKILL.md"
[ -f "$TEST_DIR_2/.claude/skills/sura-prd-trd/SKILL.md" ]
if grep -q 'team-skill' "$TEST_DIR_2/.git/info/exclude"; then echo "  ❌ [FAIL] skill tim ikut di-exclude"; exit 1; fi
[ "$(wc -c < "$TEST_DIR_2/CLAUDE.local.md")" -le 6144 ]
jq -e '.permissions.allow == ["Bash(ls:*)"]' "$TEST_DIR_2/.claude/settings.local.json" >/dev/null || { echo "  ❌ [FAIL] permissions tim di settings.local.json hilang"; exit 1; }
jq -e '[.hooks.PreToolUse[].hooks[].command] | index("team-guard.sh") != null' "$TEST_DIR_2/.claude/settings.local.json" >/dev/null || { echo "  ❌ [FAIL] hook tim di settings.local.json hilang"; exit 1; }
jq -e '[.hooks.SessionStart[].hooks[].command | select(test("sura-session-start"))] | length == 1' "$TEST_DIR_2/.claude/settings.local.json" >/dev/null || { echo "  ❌ [FAIL] hook Sura tidak ditambahkan ke settings tim"; exit 1; }
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

# Tracked settings.local.json belongs to the team: never modified
TEST_DIR_3="$TMP_BASE/proj-tracked-settings"
mkdir -p "$TEST_DIR_3/.claude"
git -C "$TEST_DIR_3" init -q
echo '{"permissions":{}}' > "$TEST_DIR_3/.claude/settings.local.json"
git -C "$TEST_DIR_3" add .claude/settings.local.json
git -C "$TEST_DIR_3" -c user.email=t@t -c user.name=t commit -qm init
OUT="$(bash "$INSTALLER" "$TEST_DIR_3" --non-interactive --no-deps)"
[ "$(cat "$TEST_DIR_3/.claude/settings.local.json")" = '{"permissions":{}}' ] || { echo "  ❌ [FAIL] settings.local.json yang di-track tim diubah"; exit 1; }
grep -q 'settings.local.json' <<<"$OUT" || { echo "  ❌ [FAIL] tidak ada peringatan hook dilewati"; exit 1; }
echo "  ✅ [PASS] Hook Claude Code: terdaftar sekali, settings tim dipertahankan, file yang di-track tidak disentuh"
# Re-init with a different profile updates the profile lines in existing notes (nothing else)
TEST_DIR_PR="$TMP_BASE/proj-reprofile"
mkdir -p "$TEST_DIR_PR"; git -C "$TEST_DIR_PR" init -q
bash "$INSTALLER" "$TEST_DIR_PR" --plugin --scope fullstack --test no-test --no-deps >/dev/null < /dev/null
echo "catatan pribadi" >> "$TEST_DIR_PR/sura-memory/CONVENTIONS.md"
bash "$INSTALLER" "$TEST_DIR_PR" --plugin --scope frontend --test flexible --no-deps >/dev/null < /dev/null
C="$TEST_DIR_PR/sura-memory/CONVENTIONS.md"; M="$TEST_DIR_PR/sura-memory/MEMORY.md"
grep -qF '**`PROJECT_SCOPE`:** `frontend`' "$C" && grep -qF '**`TEST_MODE`:** `flexible`' "$C" || { echo "  ❌ [FAIL] CONVENTIONS.md tidak ikut profil baru"; exit 1; }
grep -qF '**Project Scope:** `frontend`' "$M" && grep -qF '**Testing Mode:** `flexible`' "$M" || { echo "  ❌ [FAIL] MEMORY.md tidak ikut profil baru"; exit 1; }
if grep -qF '**`PROJECT_SCOPE`:** `fullstack`' "$C" || grep -qF '**Project Scope:** `fullstack`' "$M"; then echo "  ❌ [FAIL] profil lama tersisa"; exit 1; fi
grep -qxF "catatan pribadi" "$C" || { echo "  ❌ [FAIL] init ulang menghapus catatan"; exit 1; }
echo "  ✅ [PASS] Init ulang dengan profil berbeda memperbarui baris profil di CONVENTIONS.md & MEMORY.md saja"

# Plugin mode: project gets only sura-memory/, .ignore, ~/.sura — rules come from the Claude Code plugin
TEST_DIR_P="$TMP_BASE/proj-plugin"
mkdir -p "$TEST_DIR_P"; git -C "$TEST_DIR_P" init -q
bash "$INSTALLER" "$TEST_DIR_P" --plugin --scope frontend --test flexible --no-deps >/dev/null < /dev/null
for want in sura-memory/MEMORY.md sura-memory/.profile .ignore; do
  [ -e "$TEST_DIR_P/$want" ] || { echo "  ❌ [FAIL] mode plugin tidak membuat $want"; exit 1; }
done
grep -qxF 'PROJECT_SCOPE=frontend' "$TEST_DIR_P/sura-memory/.profile" || { echo "  ❌ [FAIL] mode plugin: profil salah"; exit 1; }
for gone in CLAUDE.md CLAUDE.local.md GEMINI.md .cursor .agents .claude .cursorignore .geminiignore; do
  [ ! -e "$TEST_DIR_P/$gone" ] || { echo "  ❌ [FAIL] mode plugin menulis $gone ke repo"; exit 1; }
done
[ -z "$(git -C "$TEST_DIR_P" status --porcelain -uall)" ] || { echo "  ❌ [FAIL] mode plugin bocor ke git"; git -C "$TEST_DIR_P" status --porcelain -uall; exit 1; }
echo "  ✅ [PASS] Mode plugin: hanya sura-memory/, .ignore, ~/.sura — tanpa file rules di repo"

# Replit: one marked block inside replit.md; Replit Agent's own notes are never touched
TEST_DIR_R="$TMP_BASE/proj-replit"
mkdir -p "$TEST_DIR_R"; git -C "$TEST_DIR_R" init -q
echo 'run = "npm start"' > "$TEST_DIR_R/.replit"
printf '# Overview\nCatatan dari Replit Agent\n' > "$TEST_DIR_R/replit.md"
count_blocks() { grep -cxF '<!-- SURA:START -->' "$1" | tr -d ' '; }
bash "$INSTALLER" "$TEST_DIR_R" --scope frontend --test no-test --no-deps >/dev/null < /dev/null
R="$TEST_DIR_R/replit.md"
grep -qxF 'Catatan dari Replit Agent' "$R" || { echo "  ❌ [FAIL] catatan Replit Agent hilang"; exit 1; }
[ "$(count_blocks "$R")" = 1 ] && grep -qxF '<!-- SURA:END -->' "$R" || { echo "  ❌ [FAIL] blok Sura tidak tepat satu"; exit 1; }
grep -qF '# Sura Protocol' "$R" && grep -qF 'Siklus Hidup "Satu Fitur Aktif"' "$R" || { echo "  ❌ [FAIL] isi rules/skill tidak ada di blok"; exit 1; }
grep -qF 'PROJECT_SCOPE=frontend' "$R" || { echo "  ❌ [FAIL] profil proyek tidak ada di blok"; exit 1; }
if grep -q 'superpowers:' "$R"; then echo "  ❌ [FAIL] replit.md menyebut skill superpowers"; exit 1; fi
bash "$INSTALLER" "$TEST_DIR_R" --scope frontend --test no-test --no-deps >/dev/null < /dev/null
[ "$(count_blocks "$R")" = 1 ] || { echo "  ❌ [FAIL] re-run menggandakan blok Sura"; exit 1; }
awk '/^<!-- SURA:START -->$/{s=1} !s; /^<!-- SURA:END -->$/{s=0}' "$R" > "$R.tmp" && mv "$R.tmp" "$R"
echo "Catatan baru dari Agent" >> "$R"
bash "$INSTALLER" "$TEST_DIR_R" --upgrade --no-deps >/dev/null < /dev/null
[ "$(count_blocks "$R")" = 1 ] || { echo "  ❌ [FAIL] --upgrade tidak memasang ulang blok yang dihapus Agent"; exit 1; }
grep -qxF 'Catatan baru dari Agent' "$R" || { echo "  ❌ [FAIL] --upgrade menghapus catatan Agent"; exit 1; }
bash "$INSTALLER" "$TEST_DIR_R" --uninstall >/dev/null < /dev/null
[ "$(count_blocks "$R")" = 0 ] || { echo "  ❌ [FAIL] uninstall tidak mencabut blok Sura"; exit 1; }
grep -qxF 'Catatan dari Replit Agent' "$R" && grep -qxF 'Catatan baru dari Agent' "$R" || { echo "  ❌ [FAIL] uninstall menghapus catatan Agent"; exit 1; }
TEST_DIR_RF="$TMP_BASE/proj-replit-flag"
mkdir -p "$TEST_DIR_RF"; git -C "$TEST_DIR_RF" init -q
bash "$INSTALLER" "$TEST_DIR_RF" --replit --non-interactive --no-deps >/dev/null < /dev/null
[ "$(count_blocks "$TEST_DIR_RF/replit.md")" = 1 ] || { echo "  ❌ [FAIL] --replit tidak membuat replit.md"; exit 1; }
[ -z "$(git -C "$TEST_DIR_RF" status --porcelain -uall)" ] || { echo "  ❌ [FAIL] replit.md buatan Sura bocor ke git"; exit 1; }
bash "$INSTALLER" "$TEST_DIR_RF" --uninstall >/dev/null < /dev/null
[ ! -e "$TEST_DIR_RF/replit.md" ] || { echo "  ❌ [FAIL] uninstall menyisakan replit.md kosong buatan Sura"; exit 1; }
echo "  ✅ [PASS] Replit: blok bertanda di replit.md, catatan Agent aman, upgrade memulihkan, uninstall mencabut"

# Uninstall: remove only Sura's files; keep team files, notes (sura-memory/) and ~/.sura
TEST_DIR_U="$TMP_BASE/proj-uninstall"
mkdir -p "$TEST_DIR_U/.cursor/rules" "$TEST_DIR_U/.claude/skills/team-skill"
git -C "$TEST_DIR_U" init -q
echo "# Team Claude" > "$TEST_DIR_U/CLAUDE.md"
echo "team rule" > "$TEST_DIR_U/.cursor/rules/team.mdc"
echo "team" > "$TEST_DIR_U/.claude/skills/team-skill/SKILL.md"
echo '{"permissions":{"allow":["Bash(ls:*)"]}}' > "$TEST_DIR_U/.claude/settings.local.json"
echo "custom_only/" > "$TEST_DIR_U/.geminiignore"
bash "$INSTALLER" "$TEST_DIR_U" --non-interactive --no-deps >/dev/null
echo "catatan saya" >> "$TEST_DIR_U/sura-memory/MEMORY.md"
OUT="$(bash "$INSTALLER" "$TEST_DIR_U" --uninstall < /dev/null)"
if grep -q 'Pilih Scope' <<<"$OUT"; then echo "  ❌ [FAIL] uninstall menampilkan prompt profil"; exit 1; fi
for gone in CLAUDE.local.md GEMINI.md .cursor/rules/agentic-sop.mdc .agents/rules/agentic-sop.md \
            .claude/skills/sura-prd-trd .claude/hooks/sura-session-start.sh .ignore .cursorignore; do
  [ ! -e "$TEST_DIR_U/$gone" ] || { echo "  ❌ [FAIL] uninstall tidak menghapus $gone"; exit 1; }
done
grep -qxF "# Team Claude" "$TEST_DIR_U/CLAUDE.md" || { echo "  ❌ [FAIL] uninstall menyentuh CLAUDE.md tim"; exit 1; }
grep -qxF "team rule" "$TEST_DIR_U/.cursor/rules/team.mdc" || { echo "  ❌ [FAIL] uninstall menghapus rule tim"; exit 1; }
[ -f "$TEST_DIR_U/.claude/skills/team-skill/SKILL.md" ] || { echo "  ❌ [FAIL] uninstall menghapus skill tim"; exit 1; }
grep -qxF "custom_only/" "$TEST_DIR_U/.geminiignore" || { echo "  ❌ [FAIL] uninstall menghapus ignore yang dikustomisasi"; exit 1; }
jq -e '(.hooks == null) and (.permissions.allow == ["Bash(ls:*)"])' "$TEST_DIR_U/.claude/settings.local.json" >/dev/null \
  || { echo "  ❌ [FAIL] settings.local.json tidak dibersihkan dengan benar"; exit 1; }
grep -qxF "catatan saya" "$TEST_DIR_U/sura-memory/MEMORY.md" || { echo "  ❌ [FAIL] uninstall menghapus sura-memory/"; exit 1; }
[ -f "$HOME/.sura/profile.md" ] || { echo "  ❌ [FAIL] uninstall menghapus ~/.sura"; exit 1; }
[ "$(grep -cvxF 'sura-memory/' "$TEST_DIR_U/.git/info/exclude" | tr -d ' ')" = "$(grep -c '^#' "$TEST_DIR_U/.git/info/exclude" | tr -d ' ')" ] \
  || { echo "  ❌ [FAIL] entri exclude Sura tersisa:"; grep -v '^#' "$TEST_DIR_U/.git/info/exclude"; exit 1; }
if git -C "$TEST_DIR_U" status --porcelain -uall | grep -q 'sura-memory'; then echo "  ❌ [FAIL] sura-memory/ bocor ke git setelah uninstall"; exit 1; fi
bash "$INSTALLER" "$TEST_DIR_U" --uninstall --purge >/dev/null < /dev/null
[ ! -e "$TEST_DIR_U/sura-memory" ] || { echo "  ❌ [FAIL] --purge tidak menghapus sura-memory/"; exit 1; }
if grep -qxF 'sura-memory/' "$TEST_DIR_U/.git/info/exclude"; then echo "  ❌ [FAIL] --purge menyisakan exclude sura-memory/"; exit 1; fi
echo "  ✅ [PASS] Uninstall: hanya file Sura dicabut; file tim, sura-memory/, ~/.sura aman; --purge hapus catatan"

# Upgrade: refresh payload with the saved profile, surface template changes as diffs, never overwrite notes
SURA_COPY="$TMP_BASE/sura-copy"
mkdir -p "$SURA_COPY"
cp -R "$REPO_ROOT/install.sh" "$REPO_ROOT/rules" "$REPO_ROOT/skills" "$REPO_ROOT/templates" "$REPO_ROOT/ignore" "$REPO_ROOT/hooks" "$SURA_COPY/"
TEST_DIR_G="$TMP_BASE/proj-upgrade"
mkdir -p "$TEST_DIR_G"; git -C "$TEST_DIR_G" init -q
bash "$SURA_COPY/install.sh" "$TEST_DIR_G" --scope backend --test no-test --no-deps >/dev/null
echo "isi saya" >> "$TEST_DIR_G/sura-memory/TASK_LOG.md"
echo "BARIS-TEMPLATE-BARU" >> "$SURA_COPY/templates/TASK_LOG.template.md"
OUT="$(bash "$SURA_COPY/install.sh" "$TEST_DIR_G" --upgrade --no-deps < /dev/null)"
grep -q 'PROJECT_SCOPE=backend' "$TEST_DIR_G/CLAUDE.md" && grep -q 'TEST_MODE=no-test' "$TEST_DIR_G/CLAUDE.md" \
  || { echo "  ❌ [FAIL] upgrade tidak memakai profil proyek yang tersimpan"; exit 1; }
grep -qxF "isi saya" "$TEST_DIR_G/sura-memory/TASK_LOG.md" || { echo "  ❌ [FAIL] upgrade menimpa catatan"; exit 1; }
if grep -q 'BARIS-TEMPLATE-BARU' "$TEST_DIR_G/sura-memory/TASK_LOG.md"; then echo "  ❌ [FAIL] upgrade menulis langsung ke catatan"; exit 1; fi
grep -qxF '+BARIS-TEMPLATE-BARU' "$TEST_DIR_G/sura-memory/.upgrade/TASK_LOG.md.diff" || { echo "  ❌ [FAIL] diff template tidak dibuat"; exit 1; }
[ ! -e "$TEST_DIR_G/sura-memory/.upgrade/MEMORY.md.diff" ] || { echo "  ❌ [FAIL] diff dibuat untuk template yang tidak berubah"; exit 1; }
grep -q 'TASK_LOG.md' <<<"$OUT" || { echo "  ❌ [FAIL] upgrade tidak melaporkan template yang berubah"; exit 1; }
rm -rf "$TEST_DIR_G/sura-memory/.templates" "$TEST_DIR_G/sura-memory/.upgrade"
bash "$SURA_COPY/install.sh" "$TEST_DIR_G" --upgrade --no-deps >/dev/null < /dev/null
[ -f "$TEST_DIR_G/sura-memory/.upgrade/TASK_LOG.md.diff" ] || { echo "  ❌ [FAIL] upgrade instalasi lama (tanpa baseline) tidak membuat diff"; exit 1; }
[ -f "$TEST_DIR_G/sura-memory/.templates/MEMORY.md" ] || { echo "  ❌ [FAIL] baseline template tidak dibuat"; exit 1; }
echo "  ✅ [PASS] Upgrade: profil tersimpan dipakai, perubahan template jadi diff, catatan tidak ditimpa"

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
