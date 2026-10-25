#!/usr/bin/env bash

# ==============================================================================
# Content Lint for Sura-agentic rules, skills & templates (no installer run)
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

fail() { echo "  ❌ [FAIL] $*"; exit 1; }
pass() { echo "  ✅ [PASS] $*"; }

echo "🧪 Running Sura-agentic Content Lint..."

# 1. Skills: valid frontmatter, name matches folder
SKILLS=(sura-prd-trd sura-project-profile sura-graphify)
for n in "${SKILLS[@]}"; do
  f="skills/$n/SKILL.md"
  [ -f "$f" ] || fail "$f tidak ada"
  [ "$(head -1 "$f")" = "---" ] || fail "$f tidak diawali frontmatter"
  fm="$(awk 'NR==1{next} /^---$/{exit} {print}' "$f")"
  grep -qxF "name: $n" <<<"$fm" || fail "$f: name harus '$n'"
  grep -qE '^description: .+' <<<"$fm" || fail "$f: description kosong"
done
pass "Frontmatter skill valid (${SKILLS[*]})"

# 2. Skills are tool-neutral, archive-not-delete, no rigid read ban
! grep -rn 'superpowers:' skills/ || fail "skills/ tidak boleh menyebut superpowers:"
! grep -rniE '(hapus|timpa|replace)[^.]*(PRD|TRD)' skills/ || fail "skills/ masih menyuruh hapus/timpa PRD/TRD"
grep -q 'sura-memory/TRD/archive/' skills/sura-prd-trd/SKILL.md || fail "sura-prd-trd tidak menyebut lokasi arsip"
! grep -rn 'lebih dari 100 baris\|> 100 baris' skills/ || fail "skills/ masih melarang baca > 100 baris"
grep -q 'graphify-out/' skills/sura-graphify/SKILL.md || fail "sura-graphify kehilangan kondisional graphify-out/"
pass "Skills tool-neutral, arsip PRD/TRD, Graphify kondisional"

# 3. Old monolithic protocol files are gone
for old in rules/prd-trd-protocol.md rules/project-structure.md rules/graphify.md; do
  [ ! -e "$old" ] || fail "$old seharusnya sudah dipindah ke skills/"
done
pass "File protokol lama sudah dipindah"

echo "🎉 All content lint passed!"
