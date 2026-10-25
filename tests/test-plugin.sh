#!/usr/bin/env bash

# ==============================================================================
# Claude Code plugin checks: manifests, hooks, commands, plugin-mode SessionStart
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_BASE="$(mktemp -d)"
trap 'rm -rf "$TMP_BASE"' EXIT

fail() { echo "  ❌ [FAIL] $*"; exit 1; }
pass() { echo "  ✅ [PASS] $*"; }

echo "🧪 Running Sura-agentic Plugin Tests..."
cd "$REPO_ROOT"

# 1. Manifests are valid and agree with each other
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
  jq empty "$f" 2>/dev/null || fail "$f tidak ada atau bukan JSON valid"
done
[ "$(jq -r .name .claude-plugin/plugin.json)" = "sura" ] || fail "nama plugin harus 'sura'"
jq -e '.plugins[] | select(.name == "sura" and .source == "./")' .claude-plugin/marketplace.json >/dev/null \
  || fail "marketplace.json tidak mendaftarkan plugin sura dari root repo"
pass "plugin.json, marketplace.json, hooks.json valid"

# 2. Every hook command points at a script shipped in the plugin
for cmd_path in $(jq -r '.hooks[][].hooks[].command' hooks/hooks.json | grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}/[^" ]+'); do
  rel="${cmd_path#\$\{CLAUDE_PLUGIN_ROOT\}/}"
  [ -f "$rel" ] || fail "hooks.json menunjuk file yang tidak ada: $rel"
done
jq -e '.hooks.SessionStart and (.hooks.PreToolUse[] | select(.matcher == "Read|Grep|Glob"))' hooks/hooks.json >/dev/null \
  || fail "hooks.json harus mendaftarkan SessionStart dan PreToolUse(Read|Grep|Glob)"
pass "Hook plugin menunjuk script yang ada"

# 3. Slash commands /sura:init, /sura:baca, /sura:update
for c in init baca update build-prd build-trd execute; do
  f="commands/$c.md"
  [ -f "$f" ] || fail "$f tidak ada"
  awk 'NR==1 && $0=="---" {fm=1; next} fm && /^---$/ {exit} fm' "$f" | grep -qE '^description: .+' || fail "$f tanpa description"
done
grep -qF '${CLAUDE_PLUGIN_ROOT}/install.sh' commands/init.md || fail "/sura:init harus menjalankan installer plugin"
grep -qF -- '--plugin' commands/init.md || fail "/sura:init harus memakai mode --plugin"
grep -qF '/sura:build-prd' commands/build-trd.md || fail "/sura:build-trd harus menolak bila PRD belum ada (arahkan ke /sura:build-prd)"
grep -qF '/sura:build-trd' commands/execute.md || fail "/sura:execute harus menolak bila TRD belum ada (arahkan ke /sura:build-trd)"
grep -qF 'lanjut' commands/execute.md || fail "/sura:execute harus menunggu 'lanjut' sebelum mengubah file"
grep -qF 'graphify update .' commands/init.md || fail "/sura:init harus menawarkan pembuatan index Graphify"
pass "Command /sura:init|baca|update|build-prd|build-trd|execute lengkap, dengan gerbang PRD → TRD → eksekusi"

# 4. Official validator (skipped when the claude CLI is unavailable)
if command -v claude >/dev/null 2>&1; then
  OUT="$(claude plugin validate "$REPO_ROOT" 2>&1)" || { echo "$OUT"; fail "claude plugin validate gagal"; }
  grep -q 'Validation passed' <<<"$OUT" || { echo "$OUT"; fail "claude plugin validate tidak lulus"; }
  pass "claude plugin validate lulus"
else
  echo "  ⏭️  [SKIP] claude CLI tidak ada — validator resmi dilewati"
fi

# 5. Plugin-mode SessionStart injects core rules + project profile; silent when not needed
START="$REPO_ROOT/hooks/sura-session-start.sh"
mkdir -p "$TMP_BASE/home" "$TMP_BASE/plain" "$TMP_BASE/proj/sura-memory" "$TMP_BASE/legacy/sura-memory"
printf 'PROJECT_SCOPE=backend\nTEST_MODE=no-test\n' > "$TMP_BASE/proj/sura-memory/.profile"
run_start() { HOME="$TMP_BASE/home" CLAUDE_PLUGIN_ROOT="$REPO_ROOT" CLAUDE_PROJECT_DIR="$1" bash "$START"; }

[ -z "$(run_start "$TMP_BASE/plain")" ] || fail "plugin harus diam di proyek tanpa sura-memory/"
OUT="$(run_start "$TMP_BASE/proj")"
for want in '# Sura Protocol' '# Aturan Operasional' 'Override Superpowers' 'PROJECT_SCOPE=backend' 'TEST_MODE=no-test'; do
  grep -qF "$want" <<<"$OUT" || fail "SessionStart mode plugin tidak memuat: $want"
done
[ "$(printf '%s' "$OUT" | wc -c)" -le 12000 ] || fail "SessionStart mode plugin melebihi 12000 byte"

echo "<!-- SURA-AGENTIC-AUTO-GENERATED -->" > "$TMP_BASE/legacy/CLAUDE.md"
[ -z "$(run_start "$TMP_BASE/legacy")" ] || fail "plugin harus diam bila proyek sudah dipasang lewat install.sh (hindari dobel)"

OUT="$(HOME="$TMP_BASE/home" CLAUDE_PROJECT_DIR="$TMP_BASE/proj" bash "$START")"
if grep -qF '# Sura Protocol' <<<"$OUT"; then fail "mode install.sh tidak boleh menyuntik core (sudah ada di CLAUDE.md)"; fi
pass "SessionStart mode plugin: core + profil proyek; diam di luar Sura & bila install.sh sudah terpasang"

echo "🎉 All plugin tests passed!"
