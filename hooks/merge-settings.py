#!/usr/bin/env python3
"""Add or remove Sura hook entries in a Claude Code settings JSON file.

  merge-settings.py add <settings.json>     register Sura hooks (idempotent)
  merge-settings.py remove <settings.json>  drop Sura hooks; delete file if nothing else is left

Entries are recognised by a command containing "/.claude/hooks/sura-"; everything
else in the file (permissions, team hooks) is preserved.
"""
import json
import os
import sys

MARK = "/.claude/hooks/sura-"
SURA_HOOKS = {
    "SessionStart": {
        "matcher": "startup|clear|compact",
        "hooks": [{"type": "command",
                   "command": 'bash "$CLAUDE_PROJECT_DIR/.claude/hooks/sura-session-start.sh"'}],
    },
    "PreToolUse": {
        "matcher": "Read|Grep|Glob",
        "hooks": [{"type": "command",
                   "command": 'bash "$CLAUDE_PROJECT_DIR/.claude/hooks/sura-block-noise.sh"'}],
    },
}


def strip_sura(settings):
    hooks = settings.get("hooks", {})
    for event in list(hooks):
        kept = []
        for group in hooks[event]:
            group["hooks"] = [h for h in group.get("hooks", []) if MARK not in h.get("command", "")]
            if group["hooks"]:
                kept.append(group)
        if kept:
            hooks[event] = kept
        else:
            del hooks[event]
    if not hooks:
        settings.pop("hooks", None)
    return settings


def main():
    action, path = sys.argv[1], sys.argv[2]
    settings = {}
    if os.path.exists(path):
        with open(path) as f:
            settings = json.load(f)
    settings = strip_sura(settings)
    if action == "add":
        hooks = settings.setdefault("hooks", {})
        for event, group in SURA_HOOKS.items():
            hooks.setdefault(event, []).append(group)
    elif not settings:
        if os.path.exists(path):
            os.remove(path)
        return
    with open(path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")


if __name__ == "__main__":
    main()
