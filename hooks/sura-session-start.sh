#!/usr/bin/env bash
# Sura SessionStart hook: suntikkan profil global + ringkasan proyek aktif.
# Diam (tanpa output) di proyek yang tidak memakai Sura.
# Mode plugin (CLAUDE_PLUGIN_ROOT ada): tidak ada CLAUDE.md di proyek, jadi core rules ikut disuntikkan.

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MEM="$ROOT/sura-memory"
[ -d "$MEM" ] || exit 0

PLUGIN_MODE=false
LIMIT=6000
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  # Proyek yang dipasang lewat install.sh sudah punya CLAUDE.md + hook sendiri — jangan dobel
  for f in CLAUDE.md CLAUDE.local.md; do
    grep -qs "SURA-AGENTIC-AUTO-GENERATED" "$ROOT/$f" && exit 0
  done
  PLUGIN_MODE=true
  LIMIT=12000
fi

# section <file> <judul> → cetak bagian "## ...<judul>..." sampai pemisah '---' berikutnya
section() {
  awk -v h="$2" '/^## / { if (f) exit; f = index($0, h) > 0 } f && /^---$/ { exit } f' "$1"
}

{
  if [ "$PLUGIN_MODE" = true ]; then
    scope="$(grep -s '^PROJECT_SCOPE=' "$MEM/.profile" | cut -d= -f2)"
    test_mode="$(grep -s '^TEST_MODE=' "$MEM/.profile" | cut -d= -f2)"
    printf '> **Active Project Profile:** `PROJECT_SCOPE=%s` | `TEST_MODE=%s`\n\n' "${scope:-fullstack}" "${test_mode:-strict-tdd}"
    cat "$CLAUDE_PLUGIN_ROOT/rules/core/SOUL.md"
    echo
    cat "$CLAUDE_PLUGIN_ROOT/rules/core/RULES.md"
    echo
    cat "$CLAUDE_PLUGIN_ROOT/rules/claude/superpowers-overrides.md"
    echo
    cat "$CLAUDE_PLUGIN_ROOT/rules/claude/skill-triggers.md"
    echo
  fi
  echo "# Konteks Sura (otomatis dari hook SessionStart)"
  for g in profile lessons; do
    if [ -f "$HOME/.sura/$g.md" ]; then
      echo
      head -c 1500 "$HOME/.sura/$g.md"
    fi
  done
  if [ -f "$MEM/MEMORY.md" ]; then
    echo
    section "$MEM/MEMORY.md" "Task Aktif"
    section "$MEM/MEMORY.md" "Batasan Proyek"
  fi
  echo
  echo "> Ketik \`baca sura\` untuk mulai kerja (PRD/TRD & konteks lengkap), \`update sura\` saat task selesai."
} | head -c "$LIMIT"
