#!/bin/bash
# install.sh — one-command setup for project-methodology skills
# Usage: bash <(curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/install.sh)
#
# Works on macOS, Linux, and Windows (Git Bash).
# Safe to re-run — idempotent.

set -e

REPO="pavlovs/project-methodology"
BASE_URL="https://raw.githubusercontent.com/${REPO}/main"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
CACHE_DIR="$CLAUDE_DIR/.skill-cache"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Installing project-methodology skills..."
echo "  Repo: github.com/${REPO}"
echo ""

# ── 1. Directories ────────────────────────────────────────────────────────────
mkdir -p "$COMMANDS_DIR" "$CACHE_DIR"

# ── 2. Skill files ────────────────────────────────────────────────────────────
for skill in new-project plan-milestone execute-milestone; do
  curl -sL "${BASE_URL}/commands/${skill}.md" > "${COMMANDS_DIR}/${skill}.md"
  echo "  [ok] commands/${skill}.md"
done

# ── 3. Update script ──────────────────────────────────────────────────────────
curl -sL "${BASE_URL}/update-skills.sh" > "${CLAUDE_DIR}/update-skills.sh"
chmod +x "${CLAUDE_DIR}/update-skills.sh"
echo "  [ok] update-skills.sh"

# ── 4. Seed ETag cache (skip first-run re-download) ──────────────────────────
for skill in new-project plan-milestone execute-milestone; do
  etag=$(curl -sI "${BASE_URL}/commands/${skill}.md" 2>/dev/null \
    | grep -i '^etag:' | sed 's/[Ee][Tt][Aa][Gg]: //;s/"//g' | tr -d '[:space:]')
  [ -n "$etag" ] && echo "$etag" > "${CACHE_DIR}/${skill}.etag"
done
date +%s > "${CACHE_DIR}/last-check"
echo "  [ok] ETag cache seeded"

# ── 5. Stop hook in settings.json ─────────────────────────────────────────────
# Detect python binary
PYTHON=""
for bin in python3 python; do
  if command -v "$bin" &>/dev/null && "$bin" -c "import sys; sys.exit(0 if sys.version_info >= (3,6) else 1)" 2>/dev/null; then
    PYTHON="$bin"
    break
  fi
done

if [ -z "$PYTHON" ]; then
  echo ""
  echo "  [warn] Python 3 not found — skipping automatic hook setup."
  echo "         Add this manually to ~/.claude/settings.json:"
  echo '         "hooks": {"Stop": [{"matcher": "","hooks": [{"type": "command","command": "bash \"$HOME/.claude/update-skills.sh\" >> \"$HOME/.claude/.skill-cache/update.log\" 2>&1 &"}]}]}'
else
  SETTINGS="$SETTINGS" "$PYTHON" << 'PYEOF'
import json, os, sys

settings_path = os.environ['SETTINGS']
hook = {
    "type": "command",
    "command": 'bash "$HOME/.claude/update-skills.sh" >> "$HOME/.claude/.skill-cache/update.log" 2>&1 &'
}

settings = {}
if os.path.exists(settings_path):
    try:
        with open(settings_path, encoding='utf-8') as f:
            settings = json.load(f)
    except (json.JSONDecodeError, OSError):
        pass  # corrupt or empty — start fresh, preserving nothing

stop_hooks = settings.setdefault('hooks', {}).setdefault('Stop', [])

already = any(
    any('update-skills' in h.get('command', '') for h in entry.get('hooks', []))
    for entry in stop_hooks
)

if already:
    print('  [ok] Stop hook already configured — skipping')
else:
    stop_hooks.append({"matcher": "", "hooks": [hook]})
    with open(settings_path, 'w', encoding='utf-8') as f:
        json.dump(settings, f, indent=2)
        f.write('\n')
    print('  [ok] Stop hook added to settings.json')
PYEOF
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "Done. Available commands in Claude Code:"
echo "  /new-project        scaffold a new project"
echo "  /plan-milestone     plan a milestone (research → decision-complete doc)"
echo "  /execute-milestone  execute an approved plan"
echo ""
echo "Skills auto-update daily in the background (Stop hook + ETag check)."
echo "To update manually: bash ~/.claude/update-skills.sh"
