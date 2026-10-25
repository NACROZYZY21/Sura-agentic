#!/usr/bin/env bash

# ==============================================================================
# Sura-agentic - 1-Click Project Setup
# Portable AI Pair-Programming Framework (Sura + Graphify + Superpowers)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="."
PROJECT_SCOPE=""
TEST_MODE=""
NON_INTERACTIVE=false
DEPS_MODE="ask"
UNINSTALL=false
PURGE=false
UPGRADE=false
PLUGIN_MODE=false
REPLIT_MODE=false

usage() {
  cat <<EOF
Usage: bash install.sh [TARGET_DIR] [OPTIONS]

Options:
  --scope <scope>       Project scope: fullstack | backend | frontend | apidef | cli-lib
  --test <mode>         Testing mode:  strict-tdd | flexible | no-test
  --non-interactive     Use auto-detected/default profile without prompting
  --with-deps           Install missing Superpowers & Graphify without asking
  --no-deps             Skip the Superpowers & Graphify check entirely
  --upgrade             Refresh rules/skills/hooks with the saved profile; template changes become diffs in sura-memory/.upgrade/
  --replit              Also write the Sura block into replit.md (auto when .replit or $REPL_ID exists)
  --plugin              Claude Code plugin mode: only sura-memory/, .ignore, ~/.sura (rules/hooks come from the plugin)
  --uninstall           Remove everything Sura installed (keeps sura-memory/ and ~/.sura)
  --purge               With --uninstall: also delete sura-memory/
  -h, --help            Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)
      PROJECT_SCOPE="$2"
      shift 2
      ;;
    --test)
      TEST_MODE="$2"
      shift 2
      ;;
    --non-interactive|-y)
      NON_INTERACTIVE=true
      shift
      ;;
    --with-deps)
      DEPS_MODE="yes"
      shift
      ;;
    --no-deps)
      DEPS_MODE="no"
      shift
      ;;
    --uninstall)
      UNINSTALL=true
      shift
      ;;
    --purge)
      PURGE=true
      shift
      ;;
    --replit)
      REPLIT_MODE=true
      shift
      ;;
    --plugin)
      PLUGIN_MODE=true
      shift
      ;;
    --upgrade)
      UPGRADE=true
      NON_INTERACTIVE=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "❌ Unknown flag: $1"
      usage
      exit 1
      ;;
    *)
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"
TARGET_FULL_PATH="$(pwd)"

MARKER="SURA-AGENTIC-AUTO-GENERATED"
BLOCK_START="<!-- SURA:START -->"
BLOCK_END="<!-- SURA:END -->"

# Replit Agent ikut menulis replit.md, jadi Sura hanya mengelola satu blok bertanda di dalamnya.
# write_block <file> <content-file>: ganti blok yang ada, atau tambahkan di akhir file.
write_block() {
  local file="$1" content="$2"
  if [ -f "$file" ] && grep -qxF "$BLOCK_START" "$file" && grep -qxF "$BLOCK_END" "$file"; then
    awk -v s="$BLOCK_START" -v e="$BLOCK_END" -v cf="$content" '
      $0 == s { print; while ((getline line < cf) > 0) print line; skip = 1; next }
      $0 == e { skip = 0 }
      !skip' "$file" > "$file.tmp"
  else
    { if [ -s "$file" ]; then cat "$file"; echo; fi; echo "$BLOCK_START"; cat "$content"; echo "$BLOCK_END"; } > "$file.tmp"
  fi
  mv "$file.tmp" "$file"
}

# remove_block <file>: cabut blok Sura; hapus file bila tidak tersisa isi apa pun
remove_block() {
  local file="$1"
  [ -f "$file" ] && grep -qxF "$BLOCK_START" "$file" || return 0
  awk -v s="$BLOCK_START" -v e="$BLOCK_END" '$0 == s { skip = 1 } !skip; $0 == e { skip = 0 }' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
  if ! grep -q '[^[:space:]]' "$file"; then rm -f "$file"; fi
  echo "  🗑️  blok Sura di ${file#"$TARGET_FULL_PATH"/}"
}

# Isi ignore file persis seperti saat dibuat installer — dipakai juga oleh uninstall
# untuk mengenali file yang belum dikustomisasi.
ignore_content() {
  cat "$SCRIPT_DIR/ignore/.ignore-template"
  # Arsip hanya disembunyikan dari pencarian (ripgrep); .cursorignore/.geminiignore
  # akan memblokir akses total, padahal arsip harus tetap bisa dibuka saat diminta.
  if [ "$1" = ".ignore" ]; then
    printf "\n# Sura (dibaca hanya saat diminta)\nsura-memory/TRD/archive/\nsura-memory/.templates/\n"
  fi
}

# ------------------------------------------------------------------------------
# Uninstall: cabut hanya file buatan Sura. sura-memory/ (catatan developer) dan
# ~/.sura (profil global) tetap ada, kecuali --purge untuk sura-memory/.
# ------------------------------------------------------------------------------
do_uninstall() {
  local f name exclude="$TARGET_FULL_PATH/.git/info/exclude"
  echo "🧹 Uninstalling Sura-agentic from: $TARGET_FULL_PATH"
  for f in CLAUDE.md CLAUDE.local.md GEMINI.md GEMINI.local.md \
           .agents/rules/agentic-sop.md .agents/rules/sura-agentic-sop.md \
           .cursor/rules/agentic-sop.mdc .cursor/rules/sura-agentic-sop.mdc; do
    if [ -f "$TARGET_FULL_PATH/$f" ] && grep -q "$MARKER" "$TARGET_FULL_PATH/$f"; then
      rm -f "$TARGET_FULL_PATH/$f"
      echo "  🗑️  $f"
    fi
  done
  for f in "$TARGET_FULL_PATH"/.claude/skills/sura-*/ "$TARGET_FULL_PATH"/.claude/hooks/sura-*.sh; do
    [ -e "$f" ] || continue
    rm -rf "$f"
    echo "  🗑️  ${f#"$TARGET_FULL_PATH"/}"
  done
  remove_block "$TARGET_FULL_PATH/replit.md"
  if [ -f "$TARGET_FULL_PATH/.claude/settings.local.json" ] && command -v python3 >/dev/null 2>&1; then
    python3 "$SCRIPT_DIR/hooks/merge-settings.py" remove "$TARGET_FULL_PATH/.claude/settings.local.json"
    echo "  🧽 Hook Sura dicabut dari .claude/settings.local.json"
  fi
  for name in .ignore .cursorignore .geminiignore; do
    [ -f "$TARGET_FULL_PATH/$name" ] || continue
    if cmp -s <(ignore_content "$name") "$TARGET_FULL_PATH/$name"; then
      rm -f "$TARGET_FULL_PATH/$name"
      echo "  🗑️  $name"
    else
      echo "  ⏭️  $name sudah dikustomisasi → dibiarkan"
    fi
  done
  for f in .claude/skills .claude/hooks .claude .cursor/rules .cursor .agents/rules .agents; do
    rmdir "$TARGET_FULL_PATH/$f" 2>/dev/null || true
  done
  if [ "$PURGE" = true ]; then
    rm -rf "$TARGET_FULL_PATH/sura-memory"
    echo "  🗑️  sura-memory/ (--purge)"
  fi
  if [ -f "$exclude" ]; then
    local keep='^$'
    [ "$PURGE" = true ] || keep='^sura-memory/$'
    grep -vxE '\.ignore|\.cursorignore|\.geminiignore|(CLAUDE|GEMINI)(\.local)?\.md|\.claude/settings\.local\.json|replit\.md|sura-memory/|graphify-out/|\.claude/skills/sura-[^/]+/|\.claude/hooks/sura-[^/]+|\.(agents|cursor)/rules/((sura-)?agentic-sop\.mdc?)?' "$exclude" > "$exclude.tmp" || true
    grep -xE "$keep" "$exclude" >> "$exclude.tmp" || true
    # Index Graphify yang masih ada tetap disembunyikan dari git
    if [ -d "$TARGET_FULL_PATH/graphify-out" ] && grep -qxF 'graphify-out/' "$exclude"; then
      echo 'graphify-out/' >> "$exclude.tmp"
    fi
    mv "$exclude.tmp" "$exclude"
  fi
  echo ""
  echo "✅ Sura-agentic dicabut. Catatan di sura-memory/ dan profil ~/.sura tidak disentuh$( [ "$PURGE" = true ] && echo " (sura-memory/ dihapus karena --purge)")."
}

if [ "$UNINSTALL" = true ]; then
  do_uninstall
  exit 0
fi

# Upgrade memakai profil proyek yang tersimpan di payload sebelumnya
if [ "$UPGRADE" = true ]; then
  if [ -f sura-memory/.profile ]; then
    [ -n "$PROJECT_SCOPE" ] || PROJECT_SCOPE="$(grep '^PROJECT_SCOPE=' sura-memory/.profile | cut -d= -f2)"
    [ -n "$TEST_MODE" ] || TEST_MODE="$(grep '^TEST_MODE=' sura-memory/.profile | cut -d= -f2)"
  fi
  for f in CLAUDE.md CLAUDE.local.md GEMINI.md GEMINI.local.md; do
    if [ -f "$f" ] && grep -q "$MARKER" "$f"; then
      [ -n "$PROJECT_SCOPE" ] || PROJECT_SCOPE="$(grep -oE 'PROJECT_SCOPE=[a-z-]+' "$f" | head -1 | cut -d= -f2)"
      [ -n "$TEST_MODE" ] || TEST_MODE="$(grep -oE 'TEST_MODE=[a-z-]+' "$f" | head -1 | cut -d= -f2)"
      break
    fi
  done
fi

echo "🚀 Installing Sura-agentic into: $TARGET_FULL_PATH"

# ------------------------------------------------------------------------------
# 0. Auto-Detect Smart Defaults & Interactive Project Profile
# ------------------------------------------------------------------------------
detect_default_scope() {
  if [ -f "$TARGET_FULL_PATH/oapi-codegen.cfg.yaml" ] || [ -f "$TARGET_FULL_PATH/src/main.yaml" ]; then
    echo "apidef"
  elif [ -f "$TARGET_FULL_PATH/go.mod" ] && [ ! -f "$TARGET_FULL_PATH/package.json" ]; then
    echo "backend"
  elif [ -f "$TARGET_FULL_PATH/package.json" ] && [ ! -f "$TARGET_FULL_PATH/go.mod" ]; then
    if [ -f "$TARGET_FULL_PATH/nx.json" ] || [ -d "$TARGET_FULL_PATH/src/components" ] || [ -d "$TARGET_FULL_PATH/apps" ]; then
      echo "frontend"
    else
      echo "fullstack"
    fi
  else
    echo "fullstack"
  fi
}

DEFAULT_SCOPE="$(detect_default_scope)"
DEFAULT_TEST="strict-tdd"

if [ -z "$PROJECT_SCOPE" ]; then
  if [ "$NON_INTERACTIVE" = false ] && [ -t 0 ]; then
    echo ""
    echo "📦 Pilih Scope Proyek (default: $DEFAULT_SCOPE):"
    echo "  1) fullstack  — Frontend + Backend + Database"
    echo "  2) backend    — Backend / API Server / Microservice"
    echo "  3) frontend   — WebApp / UI / Frontend Only"
    echo "  4) apidef     — API Contract (OpenAPI / Swagger / Protobuf)"
    echo "  5) cli-lib    — CLI Tool / Library / Package"
    read -r -p "👉 Pilihan [1-5, Enter=$DEFAULT_SCOPE]: " scope_choice
    case "$scope_choice" in
      1|fullstack) PROJECT_SCOPE="fullstack" ;;
      2|backend|be) PROJECT_SCOPE="backend" ;;
      3|frontend|fe) PROJECT_SCOPE="frontend" ;;
      4|apidef) PROJECT_SCOPE="apidef" ;;
      5|cli-lib|cli) PROJECT_SCOPE="cli-lib" ;;
      *) PROJECT_SCOPE="$DEFAULT_SCOPE" ;;
    esac
  else
    PROJECT_SCOPE="$DEFAULT_SCOPE"
  fi
fi

if [ -z "$TEST_MODE" ]; then
  if [ "$NON_INTERACTIVE" = false ] && [ -t 0 ]; then
    echo ""
    echo "🧪 Pilih Kebijakan File Test (default: $DEFAULT_TEST):"
    echo "  1) strict-tdd — Wajib unit/integration test per layer (Superpowers TDD aktif)"
    echo "  2) flexible   — Test hanya untuk business logic krusial"
    echo "  3) no-test    — Tanpa file test baru (Fokus verifikasi build, linter, & manual)"
    read -r -p "👉 Pilihan [1-3, Enter=$DEFAULT_TEST]: " test_choice
    case "$test_choice" in
      1|strict-tdd|tdd) TEST_MODE="strict-tdd" ;;
      2|flexible) TEST_MODE="flexible" ;;
      3|no-test|none) TEST_MODE="no-test" ;;
      *) TEST_MODE="$DEFAULT_TEST" ;;
    esac
  else
    TEST_MODE="$DEFAULT_TEST"
  fi
fi

echo "  🎯 Project Profile → Scope: [$PROJECT_SCOPE] | Test Mode: [$TEST_MODE]"

# ------------------------------------------------------------------------------
# 1. Setup sura-memory/ Directory & Complete Memory Ecosystem
# ------------------------------------------------------------------------------
MEMORY_DIR="$TARGET_FULL_PATH/sura-memory"
mkdir -p "$MEMORY_DIR/TRD/archive" "$MEMORY_DIR/designs" "$MEMORY_DIR/reviews" "$MEMORY_DIR/lessons"

# Init ulang dengan profil berbeda: perbarui baris profil di catatan yang sudah ada (isi lain tidak disentuh)
if [ -f "$MEMORY_DIR/CONVENTIONS.md" ]; then
  sed -i.bak -E \
    -e 's/^(- \*\*`PROJECT_SCOPE`:\*\* )`[a-z-]+`/\1`'"$PROJECT_SCOPE"'`/' \
    -e 's/^(- \*\*`TEST_MODE`:\*\* )`[a-z-]+`/\1`'"$TEST_MODE"'`/' \
    -e 's/(\(Mengikuti `TEST_MODE`: )`[a-z-]+`/\1`'"$TEST_MODE"'`/' \
    "$MEMORY_DIR/CONVENTIONS.md" && rm -f "$MEMORY_DIR/CONVENTIONS.md.bak"
fi
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  sed -i.bak -E \
    -e 's/^(- \*\*Project Scope:\*\* )`[a-z-]+`/\1`'"$PROJECT_SCOPE"'`/' \
    -e 's/^(- \*\*Testing Mode:\*\* )`[a-z-]+`/\1`'"$TEST_MODE"'`/' \
    "$MEMORY_DIR/MEMORY.md" && rm -f "$MEMORY_DIR/MEMORY.md.bak"
fi

# Profil proyek tersimpan: dibaca hook mode plugin dan --upgrade
printf 'PROJECT_SCOPE=%s\nTEST_MODE=%s\n' "$PROJECT_SCOPE" "$TEST_MODE" > "$MEMORY_DIR/.profile"

# Double safety net: local .gitignore inside sura-memory/
if [ ! -f "$MEMORY_DIR/.gitignore" ]; then
  printf "*\n!.gitignore\n" > "$MEMORY_DIR/.gitignore"
fi

TODAY="$(date +'%Y-%m-%d')"

render_template() {
  local src="$1"
  local dest="$2"
  sed -e "s/{{DATE}}/$TODAY/g" \
      -e "s/{{START_DATE}}/$TODAY/g" \
      -e "s/{{YYYY-MM-DD}}/$TODAY/g" \
      -e "s/{{PROJECT_SCOPE}}/$PROJECT_SCOPE/g" \
      -e "s/{{TEST_MODE}}/$TEST_MODE/g" \
      "$src" > "$dest"
}

declare -A TEMPLATE_MAP=(
  ["README.template.md"]="README.md"
  ["MEMORY.template.md"]="MEMORY.md"
  ["CONVENTIONS.template.md"]="CONVENTIONS.md"
  ["COMMANDS.template.md"]="COMMANDS.md"
  ["SKILL.template.md"]="SKILL.md"
  ["DESIGN_BEFORE_CODE.template.md"]="DESIGN_BEFORE_CODE.md"
  ["PR_REVIEW_PLAYBOOK.template.md"]="PR_REVIEW_PLAYBOOK.md"
  ["TASK_LOG.template.md"]="TASK_LOG.md"
  ["TRD/PRD.template.md"]="TRD/PRD.md"
  ["TRD/TRD.template.md"]="TRD/TRD.md"
)

for tmpl in "${!TEMPLATE_MAP[@]}"; do
  out_rel="${TEMPLATE_MAP[$tmpl]}"
  out_path="$MEMORY_DIR/$out_rel"
  if [ ! -f "$out_path" ]; then
    render_template "$SCRIPT_DIR/templates/$tmpl" "$out_path"
    # Baseline = template mentah asal file ini; --upgrade membandingkannya dengan template baru
    mkdir -p "$(dirname "$MEMORY_DIR/.templates/$out_rel")"
    cp "$SCRIPT_DIR/templates/$tmpl" "$MEMORY_DIR/.templates/$out_rel"
    echo "  ✅ Created: sura-memory/$out_rel"
  fi
done

# --upgrade: catatan developer tidak pernah ditimpa — perubahan template jadi diff untuk diterapkan manual
if [ "$UPGRADE" = true ]; then
  UPGRADED=()
  for tmpl in "${!TEMPLATE_MAP[@]}"; do
    out_rel="${TEMPLATE_MAP[$tmpl]}"
    base="$MEMORY_DIR/.templates/$out_rel"
    diff_out="$MEMORY_DIR/.upgrade/$out_rel.diff"
    mkdir -p "$(dirname "$diff_out")" "$(dirname "$base")"
    if [ -f "$base" ]; then
      cmp -s "$base" "$SCRIPT_DIR/templates/$tmpl" && continue
      diff -u --label "template lama" --label "template baru" "$base" "$SCRIPT_DIR/templates/$tmpl" > "$diff_out" || true
    else
      render_template "$SCRIPT_DIR/templates/$tmpl" "$diff_out.rendered"
      if cmp -s "$diff_out.rendered" "$MEMORY_DIR/$out_rel"; then
        rm -f "$diff_out.rendered"
        cp "$SCRIPT_DIR/templates/$tmpl" "$base"
        continue
      fi
      diff -u --label "sura-memory/$out_rel (sekarang)" --label "template terbaru" "$MEMORY_DIR/$out_rel" "$diff_out.rendered" > "$diff_out" || true
      rm -f "$diff_out.rendered"
    fi
    cp "$SCRIPT_DIR/templates/$tmpl" "$base"
    UPGRADED+=("$out_rel")
  done
  rmdir "$MEMORY_DIR/.upgrade/TRD" "$MEMORY_DIR/.upgrade" 2>/dev/null || true
  if [ ${#UPGRADED[@]} -gt 0 ]; then
    echo "  📝 Template berubah (catatan kamu tidak disentuh) — terapkan manual dari sura-memory/.upgrade/:"
    printf '       %s.diff\n' "${UPGRADED[@]}"
  else
    echo "  ✅ Semua template sura-memory/ sudah versi terbaru"
  fi
fi

# Profil developer global — dibuat sekali, tidak pernah ditimpa (berlaku lintas proyek)
SURA_HOME="$HOME/.sura"
mkdir -p "$SURA_HOME"
for global in profile lessons; do
  if [ ! -f "$SURA_HOME/$global.md" ]; then
    cp "$SCRIPT_DIR/templates/$global.template.md" "$SURA_HOME/$global.md"
    echo "  ✅ Created: ~/.sura/$global.md (global, semua proyek)"
  fi
done

if [ ! -f "$MEMORY_DIR/TASK_LOG.archive.md" ]; then
  printf "# Task Log Archive\n\n> Arsip task selesai yang dipindahkan saat menjalankan \`update sura\`.\n> Tidak dibaca otomatis oleh AI kecuali diminta eksplisit.\n" > "$MEMORY_DIR/TASK_LOG.archive.md"
  echo "  ✅ Created: sura-memory/TASK_LOG.archive.md"
fi

# ------------------------------------------------------------------------------
# 2. Deploy Universal Token-Saver Ignore Files
# Filter yang sudah ada TIDAK PERNAH ditimpa — sering dikustomisasi per proyek.
# ------------------------------------------------------------------------------
# Mode plugin hanya untuk Claude Code: .cursorignore/.geminiignore tidak relevan
if [ "$PLUGIN_MODE" = true ]; then IGNORE_FILES=(".ignore"); else IGNORE_FILES=(".ignore" ".cursorignore" ".geminiignore"); fi
for ignore_file in "${IGNORE_FILES[@]}"; do
  if [ -f "$TARGET_FULL_PATH/$ignore_file" ]; then
    echo "  ⏭️  $ignore_file sudah ada → dilewati (kustomisasi kamu aman)"
  else
    ignore_content "$ignore_file" > "$TARGET_FULL_PATH/$ignore_file"
    echo "  ✅ Created: $ignore_file"
  fi
done

# ------------------------------------------------------------------------------
# 3. Setup AI Rules for Antigravity, Gemini CLI, Cursor, & Claude Code
# ------------------------------------------------------------------------------
REPLIT_FILE=""; CLAUDE_FILE=""; GEMINI_FILE=""; AGENTS_FILE=""; CURSOR_FILE=""
SKILL_EXCLUDES=(); HOOK_EXCLUDES=()
if [ "$PLUGIN_MODE" = true ]; then
  echo "  🔌 Mode plugin: rules, skill, dan hook disediakan plugin Claude Code 'sura' — tidak ada file rules di repo"
else
# Core selalu dimuat semua tool. Claude Code memuat protokol detail sebagai skill
# on-demand; tool lain (tanpa mekanisme skill) menerima isinya secara inline.
strip_frontmatter() {
  awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$1"
}

build_core_payload() {
  printf "<!-- SURA-AGENTIC-AUTO-GENERATED -->\n"
  printf "> **Active Project Profile:** \`PROJECT_SCOPE=%s\` | \`TEST_MODE=%s\`\n\n" "$PROJECT_SCOPE" "$TEST_MODE"
  cat "$SCRIPT_DIR/rules/core/SOUL.md"
  printf "\n"
  cat "$SCRIPT_DIR/rules/core/RULES.md"
}

build_claude_payload() {
  build_core_payload
  printf "\n"
  cat "$SCRIPT_DIR/rules/claude/superpowers-overrides.md"
  printf "\n> Protokol detail (sura-prd-trd, sura-project-profile, sura-graphify) dimuat otomatis sebagai skill dari .claude/skills/.\n"
}

build_inline_payload() {
  build_core_payload
  local skill
  for skill in "$SCRIPT_DIR"/skills/*/SKILL.md; do
    printf "\n"
    strip_frontmatter "$skill"
  done
  printf "\n"
  cat "$SCRIPT_DIR/rules/inline/workflow-checklist.md"
}

# Hanya folder sura-* milik kita yang diganti; skill lain di .claude/skills/ tidak disentuh.
SKILL_EXCLUDES=()
install_claude_skills() {
  local src name
  mkdir -p "$TARGET_FULL_PATH/.claude/skills"
  for src in "$SCRIPT_DIR"/skills/*/; do
    name="$(basename "$src")"
    rm -rf "$TARGET_FULL_PATH/.claude/skills/$name"
    cp -R "$src" "$TARGET_FULL_PATH/.claude/skills/$name"
    SKILL_EXCLUDES+=(".claude/skills/$name/")
  done
}

# Gemini CLI membaca GEMINI.md di root (hierarkis)
if [ -f "$TARGET_FULL_PATH/GEMINI.md" ] && ! grep -q "SURA-AGENTIC-AUTO-GENERATED" "$TARGET_FULL_PATH/GEMINI.md" 2>/dev/null; then
  echo "  ⚠️  GEMINI.md milik tim sudah ada → menulis ke GEMINI.local.md"
  GEMINI_FILE="GEMINI.local.md"
else
  GEMINI_FILE="GEMINI.md"
fi
build_inline_payload > "$TARGET_FULL_PATH/$GEMINI_FILE"

# Hook Claude Code: SessionStart (suntik profil + ringkasan proyek) & PreToolUse (blokir sampah token).
# Didaftarkan di .claude/settings.local.json (pribadi), tidak pernah di settings.json milik tim.
HOOK_EXCLUDES=()
install_claude_hooks() {
  local settings="$TARGET_FULL_PATH/.claude/settings.local.json" h
  if [ -d "$TARGET_FULL_PATH/.git" ] && git -C "$TARGET_FULL_PATH" ls-files --error-unmatch .claude/settings.local.json >/dev/null 2>&1; then
    echo "  ⚠️  .claude/settings.local.json di-track git oleh tim → hook Sura dilewati"
    return 0
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "  ⚠️  python3 tidak ditemukan → hook Sura (settings.local.json) dilewati"
    return 0
  fi
  [ -f "$settings" ] || HOOK_EXCLUDES+=(".claude/settings.local.json")
  mkdir -p "$TARGET_FULL_PATH/.claude/hooks"
  for h in sura-session-start.sh sura-block-noise.sh; do
    cp "$SCRIPT_DIR/hooks/$h" "$TARGET_FULL_PATH/.claude/hooks/$h"
    HOOK_EXCLUDES+=(".claude/hooks/$h")
  done
  python3 "$SCRIPT_DIR/hooks/merge-settings.py" add "$settings"
}

# File rule milik tim (tanpa marker) dengan nama yang sama tidak pernah ditimpa.
pick_rule_file() {
  local dir="$1" name="$2" fallback="$3"
  if [ -f "$TARGET_FULL_PATH/$dir/$name" ] && ! grep -q "SURA-AGENTIC-AUTO-GENERATED" "$TARGET_FULL_PATH/$dir/$name" 2>/dev/null; then
    echo "  ⚠️  $dir/$name milik tim sudah ada → menulis ke $dir/$fallback" >&2
    echo "$dir/$fallback"
  else
    echo "$dir/$name"
  fi
}

# Antigravity membaca .agents/rules/ (plural)
mkdir -p "$TARGET_FULL_PATH/.agents/rules"
AGENTS_FILE="$(pick_rule_file .agents/rules agentic-sop.md sura-agentic-sop.md)"
build_inline_payload > "$TARGET_FULL_PATH/$AGENTS_FILE"

# Bersihkan jalur lama yang tidak pernah dibaca tool manapun
if [ -f "$TARGET_FULL_PATH/.gemini/rules/agentic-sop.md" ]; then
  rm -f "$TARGET_FULL_PATH/.gemini/rules/agentic-sop.md"
  rmdir "$TARGET_FULL_PATH/.gemini/rules" "$TARGET_FULL_PATH/.gemini" 2>/dev/null || true
  echo "  🧹 Dibersihkan: .gemini/rules/agentic-sop.md (jalur lama)"
fi

# Cursor butuh frontmatter agar rule benar-benar auto-apply
mkdir -p "$TARGET_FULL_PATH/.cursor/rules"
CURSOR_FILE="$(pick_rule_file .cursor/rules agentic-sop.mdc sura-agentic-sop.mdc)"
{
  printf -- '---\ndescription: Sura Protocol - SOP pair-programming (Scope: %s, Test: %s)\nalwaysApply: true\n---\n\n' "$PROJECT_SCOPE" "$TEST_MODE"
  build_inline_payload
} > "$TARGET_FULL_PATH/$CURSOR_FILE"

# Claude Code membaca CLAUDE.md / CLAUDE.local.md di root. Jangan pernah menimpa milik tim.
if [ -f "$TARGET_FULL_PATH/CLAUDE.md" ] && ! grep -q "SURA-AGENTIC-AUTO-GENERATED" "$TARGET_FULL_PATH/CLAUDE.md" 2>/dev/null; then
  CLAUDE_FILE="CLAUDE.local.md"
  echo "  ⚠️  CLAUDE.md milik tim sudah ada → menulis ke CLAUDE.local.md"
else
  CLAUDE_FILE="CLAUDE.md"
fi
build_claude_payload > "$TARGET_FULL_PATH/$CLAUDE_FILE"
install_claude_skills
install_claude_hooks

# Replit Agent membaca replit.md (bukan CLAUDE.md/AGENTS.md)
REPLIT_FILE=""
if [ "$REPLIT_MODE" = true ] || [ -f "$TARGET_FULL_PATH/.replit" ] || [ -n "${REPL_ID:-}" ]; then
  if [ ! -f "$TARGET_FULL_PATH/replit.md" ]; then
    REPLIT_FILE="replit.md"
  elif [ -d "$TARGET_FULL_PATH/.git" ] && git -C "$TARGET_FULL_PATH" ls-files --error-unmatch replit.md >/dev/null 2>&1; then
    echo "  ⚠️  replit.md di-track git → blok Sura akan ikut ter-commit"
  fi
  build_inline_payload > "$TARGET_FULL_PATH/.sura-replit-block.tmp"
  write_block "$TARGET_FULL_PATH/replit.md" "$TARGET_FULL_PATH/.sura-replit-block.tmp"
  rm -f "$TARGET_FULL_PATH/.sura-replit-block.tmp"
  echo "  ✅ Configured Replit → blok Sura di replit.md (catatan Replit Agent tidak disentuh)"
fi

echo "  ✅ Configured AI Rules → $CLAUDE_FILE, .claude/skills/, .claude/hooks/, $GEMINI_FILE, .cursor/rules/, .agents/rules/"
fi

# ------------------------------------------------------------------------------
# 4. Protect Everything in Local Git Exclude (Zero Risk of PR Leakage)
# ------------------------------------------------------------------------------
if [ -d "$TARGET_FULL_PATH/.git/info" ]; then
  GIT_EXCLUDE="$TARGET_FULL_PATH/.git/info/exclude"
  # Versi lama meng-exclude seluruh folder rule, sehingga rule tim baru ikut tersembunyi.
  if [ -f "$GIT_EXCLUDE" ] && grep -qxE '\.(agents|cursor)/rules/' "$GIT_EXCLUDE"; then
    grep -vxE '\.(agents|cursor)/rules/' "$GIT_EXCLUDE" > "$GIT_EXCLUDE.tmp" || true
    mv "$GIT_EXCLUDE.tmp" "$GIT_EXCLUDE"
    echo "  🧹 Exclude lama .agents/rules/ & .cursor/rules/ diganti per file"
  fi
  for pattern in "sura-memory/" "graphify-out/" "${IGNORE_FILES[@]}" "$AGENTS_FILE" "$CURSOR_FILE" "$REPLIT_FILE" "$CLAUDE_FILE" "$GEMINI_FILE" "${SKILL_EXCLUDES[@]}" "${HOOK_EXCLUDES[@]}"; do
    if [ -n "$pattern" ] && ! grep -qxF "$pattern" "$GIT_EXCLUDE" 2>/dev/null; then
      echo "$pattern" >> "$GIT_EXCLUDE"
    fi
  done
  echo "  🛡️ Protected all config in .git/info/exclude (100% safe from git & PR leaks!)"
fi

# ------------------------------------------------------------------------------
# 5. Dependencies: Superpowers (Claude Code plugin) & Graphify (CLI)
# Terpasang per user, bukan per proyek — cek dulu, tawarkan hanya yang belum ada.
# ------------------------------------------------------------------------------
has_superpowers() {
  command -v claude >/dev/null 2>&1 && claude plugin list 2>/dev/null | grep -q 'superpowers@'
}

has_graphify() {
  command -v graphify >/dev/null 2>&1
}

check_superpowers_skill_names() {
  local sp_dir s
  sp_dir="${SUPERPOWERS_SKILLS_DIR:-$(ls -d "$HOME"/.claude/plugins/cache/*/superpowers/*/skills 2>/dev/null | sort -V | tail -1)}"
  [ -n "$sp_dir" ] && [ -d "$sp_dir" ] || return 0
  for s in $(grep -rhoE 'superpowers:[a-z-]+' "$SCRIPT_DIR/rules" | sort -u | cut -d: -f2); do
    [ -f "$sp_dir/$s/SKILL.md" ] || echo "  ⚠️  Skill superpowers:$s tidak ditemukan di versi terpasang — rules Sura perlu disesuaikan"
  done
}

offer_deps() {
  local MISSING_CMDS=() answer cmd
  if has_superpowers; then :; elif command -v claude >/dev/null 2>&1; then
    MISSING_CMDS+=("claude plugin marketplace add obra/superpowers-marketplace")
    MISSING_CMDS+=("claude plugin install superpowers@superpowers-marketplace")
  else
    echo "  ⚠️  Claude Code (claude) tidak ditemukan — Superpowers dilewati. Lihat https://github.com/obra/superpowers"
  fi
  if has_graphify; then :; elif command -v uv >/dev/null 2>&1; then
    MISSING_CMDS+=("uv tool install graphifyy")
    MISSING_CMDS+=("graphify install --platform claude")
  else
    echo "  ⚠️  uv tidak ditemukan — Graphify dilewati. Pasang uv lalu: uv tool install graphifyy"
  fi
  command -v gemini >/dev/null 2>&1 && echo "  💡 Gemini CLI: gemini extensions install https://github.com/obra/superpowers"
  command -v agy >/dev/null 2>&1 && echo "  💡 Antigravity: agy plugin install https://github.com/obra/superpowers"

  if [ ${#MISSING_CMDS[@]} -eq 0 ]; then
    has_superpowers && has_graphify && echo "  ✅ Superpowers & Graphify sudah terpasang"
    return 0
  fi

  echo "  📦 Rekomendasi: pasang Superpowers & Graphify (graphifyy = paket resmi, dua huruf y):"
  printf '       %s\n' "${MISSING_CMDS[@]}"

  if [ "$DEPS_MODE" = "ask" ]; then
    if [ "$NON_INTERACTIVE" = true ] || [ ! -t 0 ]; then
      echo "  ℹ️  Jalankan perintah di atas, atau ulangi install dengan --with-deps"
      return 0
    fi
    read -r -p "👉 Pasang sekarang? [Y/n]: " answer
    case "$answer" in n|N|no|tidak) return 0 ;; esac
  fi

  for cmd in "${MISSING_CMDS[@]}"; do
    echo "  ▶️  $cmd"
    $cmd || echo "  ⚠️  Gagal: $cmd (lanjut tanpa menghentikan installer)"
  done
  has_superpowers && check_superpowers_skill_names
  return 0
}

if [ "$DEPS_MODE" != "no" ]; then
  echo ""
  echo "🔌 Cek Superpowers & Graphify..."
  offer_deps
fi

echo ""
echo "🎉 Sura-agentic successfully installed! (Scope: $PROJECT_SCOPE | Test Mode: $TEST_MODE)"
echo "👉 Buka sesi chat AI lo dan panggil: \"baca sura\""
