#!/usr/bin/env bash
# Sura SessionStart hook: suntikkan profil global + ringkasan proyek aktif.
# Diam (tanpa output) di proyek yang tidak memakai Sura.

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MEM="$ROOT/sura-memory"
[ -d "$MEM" ] || exit 0

# section <file> <judul> → cetak bagian "## ...<judul>..." sampai pemisah '---' berikutnya
section() {
  awk -v h="$2" '/^## / { if (f) exit; f = index($0, h) > 0 } f && /^---$/ { exit } f' "$1"
}

{
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
  echo "> Ketik \`baca sura\` untuk memuat PRD/TRD dan konteks proyek lengkap."
} | head -c 6000
