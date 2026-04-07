#!/bin/bash
# ~/.claude/update-skills.sh
# Checks for skill updates from github.com/pavlovs/project-methodology
# Runs automatically via Claude Code Stop hook. Safe to call at any frequency.

SKILLS_DIR="$HOME/.claude/commands"
CACHE_DIR="$HOME/.claude/.skill-cache"
LOG="$CACHE_DIR/update.log"
REPO="pavlovs/project-methodology"

# Use installed version tag if available, fall back to main
INSTALLED_VERSION=$(cat "$CACHE_DIR/methodology-version" 2>/dev/null)
if [ -n "$INSTALLED_VERSION" ]; then
  BASE_URL="https://raw.githubusercontent.com/${REPO}/v${INSTALLED_VERSION}/commands"
else
  BASE_URL="https://raw.githubusercontent.com/${REPO}/main/commands"
fi

# Minimum acceptable file size (bytes) — guards against empty/error responses
MIN_BYTES=200

mkdir -p "$CACHE_DIR"

# ── Throttle: check at most once per 24 hours ────────────────────────────────
STAMP_FILE="$CACHE_DIR/last-check"
if [ -f "$STAMP_FILE" ]; then
  last=$(cat "$STAMP_FILE")
  now=$(date +%s)
  if [ $((now - last)) -lt 86400 ]; then
    exit 0
  fi
fi

# Update timestamp before network calls — prevents retry storms if GitHub is slow
date +%s > "$STAMP_FILE"

# ── Log rotation: keep last 50 lines ─────────────────────────────────────────
if [ -f "$LOG" ] && [ "$(wc -l < "$LOG")" -gt 50 ]; then
  tail -50 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi

updated=0
errors=0

for skill in new-project plan-milestone execute-milestone review-milestone audit-security write-tests upload-learnings review-methodology; do
  local_file="$SKILLS_DIR/${skill}.md"
  etag_file="$CACHE_DIR/${skill}.etag"

  # HEAD request only — no body download unless ETag changed
  remote_etag=$(curl -sI --max-time 5 --max-redirs 3 "${BASE_URL}/${skill}.md" 2>/dev/null \
    | grep -i '^etag:' | sed 's/[Ee][Tt][Aa][Gg]: //;s/"//g' | tr -d '[:space:]')

  # GitHub unreachable or returned no ETag — skip silently
  [ -z "$remote_etag" ] && continue

  stored_etag=$(cat "$etag_file" 2>/dev/null)
  [ "$remote_etag" = "$stored_etag" ] && continue  # no change

  # ETag changed — download update to a temp file first
  tmp_file="${local_file}.tmp"
  http_code=$(curl -sL --max-time 15 --max-redirs 3 -w "%{http_code}" \
    -o "$tmp_file" "${BASE_URL}/${skill}.md" 2>/dev/null)

  # Validate: HTTP 200, non-empty, minimum size, starts with expected header
  if [ "$http_code" != "200" ]; then
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SKIP ${skill}: HTTP ${http_code}" >> "$LOG"
    rm -f "$tmp_file"
    errors=$((errors + 1))
    continue
  fi

  actual_bytes=$(wc -c < "$tmp_file" 2>/dev/null || echo 0)
  if [ "$actual_bytes" -lt "$MIN_BYTES" ]; then
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SKIP ${skill}: file too small (${actual_bytes} bytes)" >> "$LOG"
    rm -f "$tmp_file"
    errors=$((errors + 1))
    continue
  fi

  # Content must start with the expected skill header
  first_line=$(head -1 "$tmp_file" 2>/dev/null)
  if [[ "$first_line" != "# /"* ]]; then
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SKIP ${skill}: unexpected content (first line: ${first_line:0:60})" >> "$LOG"
    rm -f "$tmp_file"
    errors=$((errors + 1))
    continue
  fi

  # All checks passed — atomically replace the skill file
  mv "$tmp_file" "$local_file"
  echo "$remote_etag" > "$etag_file"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] UPDATED ${skill} (${actual_bytes} bytes)" >> "$LOG"
  updated=$((updated + 1))
done

# ── Check for major version bump ─────────────────────────────────────────────
if [ -n "$INSTALLED_VERSION" ]; then
  remote_version=$(curl -sL --max-time 5 "https://raw.githubusercontent.com/${REPO}/main/VERSION" 2>/dev/null | tr -d '[:space:]')
  if [ -n "$remote_version" ] && [ "$remote_version" != "$INSTALLED_VERSION" ]; then
    local_major=$(echo "$INSTALLED_VERSION" | cut -d. -f1)
    remote_major=$(echo "$remote_version" | cut -d. -f1)
    if [ "$remote_major" != "$local_major" ]; then
      echo "[skills] Major version update available: v${INSTALLED_VERSION} → v${remote_version}. Run install.sh to upgrade." | tee -a "$LOG"
    fi
  fi
fi

[ $updated -gt 0 ] && echo "[skills] $updated skill(s) updated from github.com/${REPO}"
[ $errors -gt 0 ] && echo "[skills] $errors update(s) skipped — see $LOG"
exit 0
