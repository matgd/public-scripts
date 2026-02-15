#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: CACHED_CURL <URL> <TTL_SECONDS> <CACHE_PATH> [curl args...]" >&2
  exit 2
}

say() {
  if [ "${QUIET:-false}" != "true" ]; then
    echo "$@" >&2
  fi
}

[ $# -ge 3 ] || usage

URL="$1"
TTL_SECONDS="$2"
CACHE_PATH="$3"
shift 3

mkdir -p "$(dirname "$CACHE_PATH")"

FILE_IS_EMPTY_OR_MISSING() {
  [ ! -s "$CACHE_PATH" ]
}

FILE_REACHED_TTL() {
  if [ ! -f "$CACHE_PATH" ]; then
    return 0
  fi

  NOW="$(date +%s)"
  UPDATED_SINCE_SECONDS=$(( NOW - $(stat -c %Y "$CACHE_PATH") ))

  say "Cache age: ${UPDATED_SINCE_SECONDS}s"
  say "Cache TTL: ${TTL_SECONDS}s"

  [ "$UPDATED_SINCE_SECONDS" -gt "$TTL_SECONDS" ]
}

FETCH_NEWEST_DATA() {
  TMP_FILE="$(mktemp)"

  if curl -fsS "$URL" "$@" > "$TMP_FILE"; then
    mv "$TMP_FILE" "$CACHE_PATH"
  else
    rm -f "$TMP_FILE"
    return 1
  fi
}

if FILE_IS_EMPTY_OR_MISSING || FILE_REACHED_TTL; then
  say "Fetching newest data..."
  FETCH_NEWEST_DATA
fi

cat "$CACHE_PATH"
