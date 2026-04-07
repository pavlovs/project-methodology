#!/bin/bash
# external-review.sh — call an external LLM for PM milestone review
# Usage: bash external-review.sh <prompt-file>
#
# Environment variables:
#   OPENAI_API_KEY          (required) OpenAI API key
#   EXTERNAL_REVIEW_MODEL   (optional) model to use, default: o3
#   EXTERNAL_REVIEW_MAX_CHARS (optional) max input chars, default: 50000
#
# Exit codes:
#   0 — success, review text on stdout
#   1 — missing dependencies or configuration
#   2 — API call failed

set -e

PROMPT_FILE="$1"
MODEL="${EXTERNAL_REVIEW_MODEL:-o3}"
MAX_CHARS="${EXTERNAL_REVIEW_MAX_CHARS:-50000}"

# ── Dependency checks ────────────────────────────────────────────────────────
if [ -z "$PROMPT_FILE" ] || [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: provide a prompt file as first argument" >&2
  exit 1
fi

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY not set" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed. Install with: brew install jq (macOS) or apt install jq (Linux) or choco install jq (Windows)" >&2
  exit 1
fi

if ! command -v curl &>/dev/null; then
  echo "Error: curl is required but not installed" >&2
  exit 1
fi

# ── Read and truncate prompt ─────────────────────────────────────────────────
PROMPT_CONTENT=$(head -c "$MAX_CHARS" "$PROMPT_FILE")

if [ ${#PROMPT_CONTENT} -ge "$MAX_CHARS" ]; then
  PROMPT_CONTENT="${PROMPT_CONTENT}

[... truncated at ${MAX_CHARS} characters to stay within token limits]"
fi

# ── Build JSON request via jq ────────────────────────────────────────────────
REQUEST_JSON=$(jq -n \
  --arg model "$MODEL" \
  --arg content "$PROMPT_CONTENT" \
  '{
    model: $model,
    messages: [
      {
        role: "user",
        content: $content
      }
    ],
    temperature: 0.2
  }')

# ── Call OpenAI API ──────────────────────────────────────────────────────────
RESPONSE=$(curl -s --max-time 120 \
  -w "\n%{http_code}" \
  -X POST "https://api.openai.com/v1/chat/completions" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_JSON" 2>/dev/null)

# Split response body and HTTP status
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" != "200" ]; then
  ERROR_MSG=$(echo "$BODY" | jq -r '.error.message // "Unknown error"' 2>/dev/null)
  echo "Error: OpenAI API returned HTTP ${HTTP_CODE}: ${ERROR_MSG}" >&2
  exit 2
fi

# ── Extract response text ────────────────────────────────────────────────────
REVIEW_TEXT=$(echo "$BODY" | jq -r '.choices[0].message.content // empty' 2>/dev/null)

if [ -z "$REVIEW_TEXT" ]; then
  echo "Error: no content in API response" >&2
  echo "Raw response: $BODY" >&2
  exit 2
fi

echo "$REVIEW_TEXT"
