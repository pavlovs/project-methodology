#!/bin/bash
# ~/.claude/update-skills.sh
# Checks for skill updates from github.com/pavlovs/project-methodology
# Safe to call frequently — uses ETag caching and a 24h throttle.

SKILLS_DIR="$HOME/.claude/commands"
CACHE_DIR="$HOME/.claude/.skill-cache"
REPO="pavlovs/project-methodology"
BASE_URL="https://raw.githubusercontent.com/${REPO}/main/commands"

mkdir -p "$CACHE_DIR"

# Throttle: skip if checked within last 24 hours
STAMP_FILE="$CACHE_DIR/last-check"
if [ -f "$STAMP_FILE" ]; then
  last=$(cat "$STAMP_FILE")
  now=$(date +%s)
  if [ $((now - last)) -lt 86400 ]; then
    exit 0
  fi
fi

# Update timestamp first — if GitHub is unreachable, don't retry every session
date +%s > "$STAMP_FILE"

updated=0
for skill in new-project plan-milestone execute-milestone; do
  local_file="$SKILLS_DIR/${skill}.md"
  etag_file="$CACHE_DIR/${skill}.etag"

  # HEAD request only — no body download unless ETag changed
  remote_etag=$(curl -sI --max-time 5 "${BASE_URL}/${skill}.md" 2>/dev/null \
    | grep -i '^etag:' | sed 's/[Ee][Tt][Aa][Gg]: //;s/"//g' | tr -d '[:space:]')

  [ -z "$remote_etag" ] && continue  # GitHub unreachable — skip silently

  stored_etag=$(cat "$etag_file" 2>/dev/null)
  [ "$remote_etag" = "$stored_etag" ] && continue  # no change

  # ETag changed — download update
  new_content=$(curl -sL --max-time 10 "${BASE_URL}/${skill}.md" 2>/dev/null)
  if [ -n "$new_content" ]; then
    echo "$new_content" > "$local_file"
    echo "$remote_etag" > "$etag_file"
    updated=$((updated + 1))
  fi
done

[ $updated -gt 0 ] && echo "[skills] $updated skill(s) updated from github.com/${REPO}"
exit 0
