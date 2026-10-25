#!/usr/bin/env bash
# Sura PreToolUse hook (Read|Grep|Glob): tolak akses ke sampah token.
# Exit 2 = blokir tool call; stderr dikirim ke AI sebagai alasan.

INPUT="$(cat)"
PATHS="$(printf '%s' "$INPUT" \
  | grep -oE '"(file_path|path)"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | sed -E 's/^"[a-z_]+"[[:space:]]*:[[:space:]]*"(.*)"$/\1/')"

NOISE='(^|/)(node_modules|vendor|\.gocache|\.go-cache|\.gomodcache|logs-server)(/|$)|\.log$|-audit\.json$'

while IFS= read -r p; do
  [ -n "$p" ] || continue
  if printf '%s' "$p" | grep -qE "$NOISE"; then
    echo "Sura: '$p' diblokir — dependency/cache/log adalah sampah token. Cari di kode sumber proyek; bila developer memang meminta isinya, minta mereka menempelkan bagian yang relevan." >&2
    exit 2
  fi
done <<<"$PATHS"

exit 0
