#!/usr/bin/env bash
set -euo pipefail

f_usage() {
  echo "Usage: CACHED_CURL <URL> <TTL_SECONDS> <CACHE_PATH> [curl args...]" >&2
  exit 2
}

f_say() {
  if [ "${QUIET:-false}" != "true" ]; then
    echo "$@" >&2
  fi
}

[ $# -ge 3 ] || f_usage

URL="$1"
TTL_SECONDS="$2"
CACHE_PATH="$3"
shift 3

mkdir -p "$(dirname "$CACHE_PATH")"

f_file_is_empty_or_missing() {
  [ ! -s "$CACHE_PATH" ]
}

f_file_reached_ttl() {
  if [ ! -f "$CACHE_PATH" ]; then
    return 0
  fi

  NOW="$(date +%s)"
  UPDATED_SINCE_SECONDS=$(( NOW - $(stat -c %Y "$CACHE_PATH") ))

  f_say "Cache age: ${UPDATED_SINCE_SECONDS}s"
  f_say "Cache TTL: ${TTL_SECONDS}s"

  [ "$UPDATED_SINCE_SECONDS" -gt "$TTL_SECONDS" ]
}

f_fetch_newest_data() {
  TMP_FILE="$(mktemp)"

  if curl -fsS "$URL" "$@" > "$TMP_FILE"; then
    mv "$TMP_FILE" "$CACHE_PATH"
  else
    rm -f "$TMP_FILE"
    return 1
  fi
}

if f_file_is_empty_or_missing || f_file_reached_ttl; then
  f_say "Fetching newest data..."
  f_fetch_newest_data
fi

cat "$CACHE_PATH"
