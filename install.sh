#!/usr/bin/env bash

# ==============================================================================
# Sura-agentic - 1-Click Project Setup
# Portable AI-Pair Programming Framework with Graphify & Superpowers
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"

cd "$TARGET_DIR"
TARGET_FULL_PATH="$(pwd)"

echo "🚀 Installing Sura-agentic into: $TARGET_FULL_PATH"

# 1. Setup Memory Directory
MEMORY_DIR="$TARGET_FULL_PATH/sura-memory"
mkdir -p "$MEMORY_DIR"

if [ ! -f "$MEMORY_DIR/MEMORY.md" ]; then
  TODAY="$(date +'%Y-%m-%d')"
  sed "s/{{DATE}}/$TODAY/g; s/{{START_DATE}}/$TODAY/g" "$SCRIPT_DIR/templates/MEMORY.template.md" > "$MEMORY_DIR/MEMORY.md"
  echo "  ✅ Created: sura-memory/MEMORY.md"
fi

if [ ! -f "$MEMORY_DIR/TASK_LOG.md" ]; then
  TODAY="$(date +'%Y-%m-%d')"
  sed "s/{{YYYY-MM-DD}}/$TODAY/g" "$SCRIPT_DIR/templates/TASK_LOG.template.md" > "$MEMORY_DIR/TASK_LOG.md"
  echo "  ✅ Created: sura-memory/TASK_LOG.md"
fi

if [ ! -f "$MEMORY_DIR/CONVENTIONS.md" ]; then
  TODAY="$(date +'%Y-%m-%d')"
  sed "s/{{DATE}}/$TODAY/g" "$SCRIPT_DIR/templates/CONVENTIONS.template.md" > "$MEMORY_DIR/CONVENTIONS.md"
  echo "  ✅ Created: sura-memory/CONVENTIONS.md"
fi

# 2. Deploy Universal Token-Saver Ignore Files
cp "$SCRIPT_DIR/ignore/.ignore-template" "$TARGET_FULL_PATH/.ignore"
cp "$SCRIPT_DIR/ignore/.ignore-template" "$TARGET_FULL_PATH/.cursorignore"
cp "$SCRIPT_DIR/ignore/.ignore-template" "$TARGET_FULL_PATH/.geminiignore"
echo "  ✅ Deployed token ignore filters: .ignore, .cursorignore, .geminiignore"

# 3. Setup AI Rules for Cursor, Gemini & Claude Code
RULE_FILES=(
  "$SCRIPT_DIR/rules/SOUL.md"
  "$SCRIPT_DIR/rules/RULES.md"
  "$SCRIPT_DIR/rules/token-protocol.md"
  "$SCRIPT_DIR/rules/graphify.md"
  "$SCRIPT_DIR/rules/superpowers.md"
)

mkdir -p "$TARGET_FULL_PATH/.gemini/rules"
cat "${RULE_FILES[@]}" > "$TARGET_FULL_PATH/.gemini/rules/agentic-sop.md"

# Cursor butuh frontmatter agar rule benar-benar auto-apply
mkdir -p "$TARGET_FULL_PATH/.cursor/rules"
{
  printf -- '---\ndescription: Sura Protocol - SOP pair-programming\nalwaysApply: true\n---\n\n'
  cat "${RULE_FILES[@]}"
} > "$TARGET_FULL_PATH/.cursor/rules/agentic-sop.mdc"

# Claude Code membaca CLAUDE.md di root. Jangan pernah menimpa milik tim.
if [ -f "$TARGET_FULL_PATH/CLAUDE.md" ]; then
  CLAUDE_FILE="CLAUDE.local.md"
  echo "  ⚠️  CLAUDE.md sudah ada (kemungkinan milik tim) → menulis ke CLAUDE.local.md"
else
  CLAUDE_FILE="CLAUDE.md"
fi
cat "${RULE_FILES[@]}" > "$TARGET_FULL_PATH/$CLAUDE_FILE"

echo "  ✅ Configured AI Rules for Gemini, Cursor & Claude Code ($CLAUDE_FILE)"

# 4. Protect Everything in Local Git Exclude (Zero Risk of PR Leakage)
if [ -d "$TARGET_FULL_PATH/.git/info" ]; then
  GIT_EXCLUDE="$TARGET_FULL_PATH/.git/info/exclude"
  for pattern in "sura-memory/" ".ignore" ".cursorignore" ".geminiignore" ".gemini/rules/" ".cursor/rules/" "$CLAUDE_FILE"; do
    if ! grep -qxF "$pattern" "$GIT_EXCLUDE" 2>/dev/null; then
      echo "$pattern" >> "$GIT_EXCLUDE"
    fi
  done
  echo "  🛡️ Protected all config in .git/info/exclude (100% safe from git & PR leaks!)"
fi

echo ""
echo "🎉 Sura-agentic successfully installed!"
echo "👉 Buka sesi chat AI lo dan panggil: \"baca sura\""
