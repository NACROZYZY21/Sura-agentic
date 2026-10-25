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
for n in sura-prd-trd sura-project-profile sura-graphify; do
  [ -f "skills/$n/SKILL.md" ] || fail "skills/$n/SKILL.md tidak ada"
done
SKILLS=()
for d in skills/*/; do SKILLS+=("$(basename "$d")"); done
for n in "${SKILLS[@]}"; do
  f="skills/$n/SKILL.md"
  [ -f "$f" ] || fail "$f tidak ada"
  [ "$(head -1 "$f")" = "---" ] || fail "$f tidak diawali frontmatter"
  awk 'NR>1 && /^---$/ {found=1; exit} END {exit !found}' "$f" || fail "$f: frontmatter tidak ditutup '---'"
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

# 4. Slim core + per-tool variants
CORE_FILES=(rules/core/SOUL.md rules/core/RULES.md rules/claude/superpowers-overrides.md rules/inline/workflow-checklist.md)
for f in "${CORE_FILES[@]}"; do
  [ -f "$f" ] || fail "$f tidak ada"
done
for old in rules/SOUL.md rules/RULES.md rules/superpowers.md rules/token-protocol.md; do
  [ ! -e "$old" ] || fail "$old seharusnya sudah diganti"
done
max_lines() { [ "$(wc -l < "$1")" -le "$2" ] || fail "$1 lebih dari $2 baris ($(wc -l < "$1"))"; }
max_lines rules/core/SOUL.md 25
max_lines rules/core/RULES.md 45
max_lines rules/claude/superpowers-overrides.md 15
max_lines rules/inline/workflow-checklist.md 15
pass "Core ramping & varian per tool ada dalam batas baris"

! grep -rn 'superpowers:' rules/core rules/inline || fail "superpowers: hanya boleh di rules/claude/"
grep -q 'sura-memory/designs/' rules/claude/superpowers-overrides.md || fail "override lokasi plan hilang"
grep -q 'no-test' rules/claude/superpowers-overrides.md || fail "override gerbang TEST_MODE hilang"
grep -q 'lanjut' rules/claude/superpowers-overrides.md || fail "override advisor-strict hilang"
grep -q 'tidak tersedia' rules/claude/superpowers-overrides.md || fail "fallback saat Superpowers tidak terpasang hilang"
grep -q 'aturan tim' rules/core/RULES.md || fail "aturan 'tim menang' hilang dari core"
! grep -rn 'lebih dari 100 baris\|> 100 baris' rules/ || fail "rules/ masih melarang baca > 100 baris"
grep -q 'review' rules/core/RULES.md && grep -q 'refactor' rules/core/RULES.md || fail "pengecualian baca utuh (review/refactor) hilang"
! grep -rniE '(hapus|timpa|replace)[^.]*(PRD|TRD)' rules/ || fail "rules/ masih menyuruh hapus/timpa PRD/TRD"
pass "Override superpowers lengkap, baca terarah default, arsip PRD/TRD"

# 5. Templates & README follow the archive + on-demand skill model
! grep -rniE '(hapus|dihapus|timpa|replace)[^.]*(PRD|TRD)' templates/ || fail "templates/ masih menyuruh hapus/timpa PRD/TRD"
! grep -rn 'superpowers:' templates/ || fail "templates/ tidak boleh menyebut superpowers:"
! grep -n '70–80%' README.md || fail "README masih memuat klaim 70–80% yang belum diukur"
grep -q 'skills/sura-prd-trd' README.md || fail "README belum menjelaskan skills/"
! grep -n 'rules/superpowers.md\|superpowers.md  ' README.md || fail "README masih menyebut rules/superpowers.md"
pass "Template & README mengikuti arsip PRD/TRD dan skill on-demand"

# 6. Global developer profile layer (~/.sura)
for t in templates/profile.template.md templates/lessons.template.md; do
  [ -f "$t" ] || fail "$t tidak ada"
done
grep -qF '~/.sura/profile.md' rules/core/RULES.md || fail "core tidak memuat ~/.sura/profile.md"
grep -qF '~/.sura/lessons.md' skills/sura-prd-trd/SKILL.md || fail "update sura tidak mempromosikan pelajaran ke ~/.sura/lessons.md"
grep -qi 'persetujuan' skills/sura-prd-trd/SKILL.md || fail "promosi pelajaran umum harus lewat persetujuan developer"
! grep -n 'DEVELOPER_NAME' templates/MEMORY.template.md || fail "MEMORY.template masih memuat profil developer"
pass "Lapis profil global ~/.sura (profil, pelajaran umum lewat persetujuan)"

# 7. No employer branding in the repo
! git -C "$REPO_ROOT" grep -n -i 'sawit' -- . ':!docs' ':!tests/test-content.sh' || fail "repo masih menyebut nama perusahaan (sawit...)"
pass "Tanpa nama perusahaan"

echo "🎉 All content lint passed!"
