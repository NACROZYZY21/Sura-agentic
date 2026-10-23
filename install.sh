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

usage() {
  cat <<EOF
Usage: bash install.sh [TARGET_DIR] [OPTIONS]

Options:
  --scope <scope>       Project scope: fullstack | backend | frontend | apidef | cli-lib
  --test <mode>         Testing mode:  strict-tdd | flexible | no-test
  --non-interactive     Use auto-detected/default profile without prompting
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
# 1. Setup sura-memory/ Directory & Complete Sawitpro-Style Ecosystem
# ------------------------------------------------------------------------------
MEMORY_DIR="$TARGET_FULL_PATH/sura-memory"
mkdir -p "$MEMORY_DIR/TRD" "$MEMORY_DIR/designs" "$MEMORY_DIR/reviews" "$MEMORY_DIR/lessons"

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
    echo "  ✅ Created: sura-memory/$out_rel"
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
for ignore_file in ".ignore" ".cursorignore" ".geminiignore"; do
  if [ -f "$TARGET_FULL_PATH/$ignore_file" ]; then
    echo "  ⏭️  $ignore_file sudah ada → dilewati (kustomisasi kamu aman)"
  else
    cp "$SCRIPT_DIR/ignore/.ignore-template" "$TARGET_FULL_PATH/$ignore_file"
    echo "  ✅ Created: $ignore_file"
  fi
done

# ------------------------------------------------------------------------------
# 3. Setup AI Rules for Antigravity, Gemini CLI, Cursor, & Claude Code
# ------------------------------------------------------------------------------
RULE_FILES=(
  "$SCRIPT_DIR/rules/SOUL.md"
  "$SCRIPT_DIR/rules/RULES.md"
  "$SCRIPT_DIR/rules/prd-trd-protocol.md"
  "$SCRIPT_DIR/rules/project-structure.md"
  "$SCRIPT_DIR/rules/token-protocol.md"
  "$SCRIPT_DIR/rules/graphify.md"
  "$SCRIPT_DIR/rules/superpowers.md"
)

build_rules_payload() {
  printf "<!-- SURA-AGENTIC-AUTO-GENERATED -->\n"
  printf "> **Active Project Profile:** \`PROJECT_SCOPE=%s\` | \`TEST_MODE=%s\`\n\n" "$PROJECT_SCOPE" "$TEST_MODE"
  cat "${RULE_FILES[@]}"
}

# Gemini CLI membaca GEMINI.md di root (hierarkis)
if [ -f "$TARGET_FULL_PATH/GEMINI.md" ] && ! grep -q "SURA-AGENTIC-AUTO-GENERATED" "$TARGET_FULL_PATH/GEMINI.md" 2>/dev/null; then
  echo "  ⚠️  GEMINI.md milik tim sudah ada → menulis ke GEMINI.local.md"
  GEMINI_FILE="GEMINI.local.md"
else
  GEMINI_FILE="GEMINI.md"
fi
build_rules_payload > "$TARGET_FULL_PATH/$GEMINI_FILE"

# Antigravity membaca .agents/rules/ (plural)
mkdir -p "$TARGET_FULL_PATH/.agents/rules"
build_rules_payload > "$TARGET_FULL_PATH/.agents/rules/agentic-sop.md"

# Bersihkan jalur lama yang tidak pernah dibaca tool manapun
if [ -f "$TARGET_FULL_PATH/.gemini/rules/agentic-sop.md" ]; then
  rm -f "$TARGET_FULL_PATH/.gemini/rules/agentic-sop.md"
  rmdir "$TARGET_FULL_PATH/.gemini/rules" "$TARGET_FULL_PATH/.gemini" 2>/dev/null || true
  echo "  🧹 Dibersihkan: .gemini/rules/agentic-sop.md (jalur lama)"
fi

# Cursor butuh frontmatter agar rule benar-benar auto-apply
mkdir -p "$TARGET_FULL_PATH/.cursor/rules"
{
  printf -- '---\ndescription: Sura Protocol - SOP pair-programming (Scope: %s, Test: %s)\nalwaysApply: true\n---\n\n' "$PROJECT_SCOPE" "$TEST_MODE"
  build_rules_payload
} > "$TARGET_FULL_PATH/.cursor/rules/agentic-sop.mdc"

# Claude Code membaca CLAUDE.md / CLAUDE.local.md di root. Jangan pernah menimpa milik tim.
if [ -f "$TARGET_FULL_PATH/CLAUDE.md" ] && ! grep -q "SURA-AGENTIC-AUTO-GENERATED" "$TARGET_FULL_PATH/CLAUDE.md" 2>/dev/null; then
  CLAUDE_FILE="CLAUDE.local.md"
  echo "  ⚠️  CLAUDE.md milik tim sudah ada → menulis ke CLAUDE.local.md"
else
  CLAUDE_FILE="CLAUDE.md"
fi
build_rules_payload > "$TARGET_FULL_PATH/$CLAUDE_FILE"

echo "  ✅ Configured AI Rules → $CLAUDE_FILE, $GEMINI_FILE, .cursor/rules/, .agents/rules/"

# ------------------------------------------------------------------------------
# 4. Protect Everything in Local Git Exclude (Zero Risk of PR Leakage)
# ------------------------------------------------------------------------------
if [ -d "$TARGET_FULL_PATH/.git/info" ]; then
  GIT_EXCLUDE="$TARGET_FULL_PATH/.git/info/exclude"
  for pattern in "sura-memory/" ".ignore" ".cursorignore" ".geminiignore" ".agents/rules/" ".cursor/rules/" "$CLAUDE_FILE" "$GEMINI_FILE"; do
    if [ -n "$pattern" ] && ! grep -qxF "$pattern" "$GIT_EXCLUDE" 2>/dev/null; then
      echo "$pattern" >> "$GIT_EXCLUDE"
    fi
  done
  echo "  🛡️ Protected all config in .git/info/exclude (100% safe from git & PR leaks!)"
fi

echo ""
echo "🎉 Sura-agentic successfully installed! (Scope: $PROJECT_SCOPE | Test Mode: $TEST_MODE)"
echo "👉 Buka sesi chat AI lo dan panggil: \"baca sura\""
