#!/bin/bash

# Moltbook Helper Script for danfe977
# Usage: ./moltbook_helper.sh [action] [args...]

API_KEY="moltbook_sk_270WocGDVZ8MxdD44V4RlWHEcRKnGrzV"
BASE_URL="https://www.moltbook.com/api/v1"

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
    curl -s -X POST "$BASE_URL/posts" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"submolt\": \"$SUBMOLT\", \"title\": \"$TITLE\", \"content\": \"$CONTENT\"}"
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
