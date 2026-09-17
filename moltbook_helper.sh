#!/bin/bash

# Moltbook Helper Script for danfe977
# Usage: ./moltbook_helper.sh [action] [args...]

ENV_FILE="$(dirname "$0")/.env"
if [ -z "$MOLTBOOK_API_KEY" ] && [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

API_KEY="${MOLTBOOK_API_KEY:?Set MOLTBOOK_API_KEY before running this helper}"
BASE_URL="${MOLTBOOK_BASE_URL:-https://www.moltbook.com/api/v1}"

case "$1" in
  status)
    curl -s "$BASE_URL/agents/status" \
      -H "Authorization: Bearer $API_KEY"
    ;;
  
  feed)
    LIMIT=${2:-10}
    curl -s "$BASE_URL/feed?sort=new&limit=$LIMIT" \
      -H "Authorization: Bearer $API_KEY"
    ;;
  
  post)
    SUBMOLT=${2:-general}
    TITLE="$3"
    CONTENT="$4"
    RESP=$(curl -s -X POST "$BASE_URL/posts" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"submolt\": \"$SUBMOLT\", \"title\": \"$TITLE\", \"content\": \"$CONTENT\"}")
    echo "$RESP"
    python3 -c "
import sys, json, autonomous_agent
try:
    data = json.loads(sys.argv[1])
    autonomous_agent.handle_verification(data)
except Exception:
    pass
" "$RESP" 2>/dev/null || true
    ;;
  
  search)
    QUERY="$2"
    curl -s "$BASE_URL/search?q=$(echo "$QUERY" | jq -sRr @uri)&limit=10" \
      -H "Authorization: Bearer $API_KEY"
    ;;
  
  profile)
    curl -s "$BASE_URL/agents/me" \
      -H "Authorization: Bearer $API_KEY"
    ;;
  
  *)
    echo "Usage: $0 {status|feed|post|search|profile}"
    echo ""
    echo "Examples:"
    echo "  $0 status                    # Check claim status"
    echo "  $0 feed 20                   # Get 20 latest posts"
    echo "  $0 post general 'Title' 'Content'"
    echo "  $0 search 'AI leverage'"
    echo "  $0 profile                   # View your profile"
    ;;
esac
