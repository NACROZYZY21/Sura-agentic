#!/usr/bin/env bash

# ==============================================================================
# Unit tests for Claude Code hook scripts in hooks/
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLOCK="$REPO_ROOT/hooks/sura-block-noise.sh"
START="$REPO_ROOT/hooks/sura-session-start.sh"
TMP_BASE="$(mktemp -d)"
trap 'rm -rf "$TMP_BASE"' EXIT

fail() { echo "  ❌ [FAIL] $*"; exit 1; }
pass() { echo "  ✅ [PASS] $*"; }

echo "🧪 Running Sura-agentic Hook Tests..."

for f in "$BLOCK" "$START"; do [ -f "$f" ] || fail "$f tidak ada"; done

# 1. PreToolUse noise blocker: exit 2 blocks the tool call, exit 0 allows it
expect_block() {
  local code=0
  printf '%s' "$1" | bash "$BLOCK" 2>"$TMP_BASE/err" || code=$?
  [ "$code" -eq 2 ] || fail "seharusnya diblokir (exit 2, dapat $code): $1"
  grep -q 'Sura' "$TMP_BASE/err" || fail "pesan blokir tidak menjelaskan alasan: $1"
}
expect_allow() {
  local code=0
  printf '%s' "$1" | bash "$BLOCK" 2>/dev/null || code=$?
  [ "$code" -eq 0 ] || fail "seharusnya diizinkan (exit 0, dapat $code): $1"
}
expect_block '{"tool_name":"Read","tool_input":{"file_path":"/p/node_modules/react/index.js"}}'
expect_block '{"tool_name":"Read","tool_input":{"file_path":"/p/logs/server.log"}}'
expect_block '{"tool_name":"Read","tool_input":{"file_path":"/p/.gocache/x/y"}}'
expect_block '{"tool_name":"Grep","tool_input":{"pattern":"foo","path":"/p/vendor"}}'
expect_block '{"tool_name":"Glob","tool_input":{"pattern":"**/*.js","path":"/p/node_modules"}}'
expect_block '{"tool_name":"Read","tool_input":{"file_path":"/p/sec-audit.json"}}'
expect_allow '{"tool_name":"Read","tool_input":{"file_path":"/p/src/app.ts"}}'
expect_allow '{"tool_name":"Read","tool_input":{"file_path":"/p/docs/catalog.md"}}'
expect_allow '{"tool_name":"Grep","tool_input":{"pattern":"node_modules"}}'
expect_allow '{"tool_name":"Read","tool_input":{"file_path":"/p/src/vendors.ts"}}'
expect_allow ''
pass "PreToolUse memblokir node_modules/vendor/cache/log, mengizinkan file biasa"

# 2. SessionStart: silent outside Sura projects, injects profile + project summary inside
mkdir -p "$TMP_BASE/home/.sura" "$TMP_BASE/plain" "$TMP_BASE/proj/sura-memory"
OUT="$(cd "$TMP_BASE/plain" && HOME="$TMP_BASE/home" CLAUDE_PROJECT_DIR="$TMP_BASE/plain" bash "$START")"
[ -z "$OUT" ] || fail "SessionStart harus diam di proyek tanpa sura-memory/"

echo "- **Nama:** Tester Profil" > "$TMP_BASE/home/.sura/profile.md"
echo "- Pelajaran umum contoh" > "$TMP_BASE/home/.sura/lessons.md"
cat > "$TMP_BASE/proj/sura-memory/MEMORY.md" <<'EOF'
# Project Memory

## 🧭 Project Profile
- **Project Scope:** `backend`

---

## 📌 Proyek / Task Aktif Saat Ini
**[BE] Fitur Ekspor** — In Progress

---

## 🚧 Batasan Proyek (Constraints)
- Jangan sentuh migrations/

---

## 📖 Kamus Domain Bisnis (Domain Glossary)
| RAHASIA_GLOSSARY | tidak perlu disuntik |
EOF
OUT="$(HOME="$TMP_BASE/home" CLAUDE_PROJECT_DIR="$TMP_BASE/proj" bash "$START")"
for want in 'Tester Profil' 'Pelajaran umum contoh' 'Fitur Ekspor' 'Jangan sentuh migrations/' 'baca sura'; do
  grep -qF "$want" <<<"$OUT" || fail "SessionStart tidak memuat: $want"
done
if grep -q 'RAHASIA_GLOSSARY' <<<"$OUT"; then fail "SessionStart menyuntik bagian yang tidak perlu"; fi

awk 'BEGIN { for (i = 0; i < 500; i++) print "- baris profil panjang sekali untuk menguji batas ukuran" }' > "$TMP_BASE/home/.sura/profile.md"
OUT="$(HOME="$TMP_BASE/home" CLAUDE_PROJECT_DIR="$TMP_BASE/proj" bash "$START")"
[ "$(printf '%s' "$OUT" | wc -c)" -le 6000 ] || fail "SessionStart melebihi 6000 byte"
pass "SessionStart diam di luar proyek Sura, menyuntik profil + task aktif + batasan, maks 6000 byte"

echo "🎉 All hook tests passed!"
