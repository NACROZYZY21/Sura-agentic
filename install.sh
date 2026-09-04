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

# 3. Setup AI Rules for Cursor & Gemini
mkdir -p "$TARGET_FULL_PATH/.gemini/rules"
cat "$SCRIPT_DIR/rules/ai-sop.md" "$SCRIPT_DIR/rules/graphify.md" "$SCRIPT_DIR/rules/superpowers.md" > "$TARGET_FULL_PATH/.gemini/rules/agentic-sop.md"

mkdir -p "$TARGET_FULL_PATH/.cursor/rules"
cat "$SCRIPT_DIR/rules/ai-sop.md" "$SCRIPT_DIR/rules/graphify.md" "$SCRIPT_DIR/rules/superpowers.md" > "$TARGET_FULL_PATH/.cursor/rules/agentic-sop.mdc"
echo "  ✅ Configured AI Rules for Gemini & Cursor"

# 4. Protect Everything in Local Git Exclude (Zero Risk of PR Leakage)
if [ -d "$TARGET_FULL_PATH/.git/info" ]; then
  GIT_EXCLUDE="$TARGET_FULL_PATH/.git/info/exclude"
  for pattern in "sura-memory/" ".ignore" ".cursorignore" ".geminiignore" ".gemini/rules/" ".cursor/rules/"; do
    if ! grep -qxF "$pattern" "$GIT_EXCLUDE" 2>/dev/null; then
      echo "$pattern" >> "$GIT_EXCLUDE"
    fi
  done
  echo "  🛡️ Protected all config in .git/info/exclude (100% safe from git & PR leaks!)"
fi

echo ""
echo "🎉 Sura-agentic successfully installed!"
echo "👉 Buka sesi chat AI lo dan panggil: \"Baca sura-memory ya\""
