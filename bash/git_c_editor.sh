#!/usr/bin/env bash

TEMP_FILE=$(mktemp)
$EDITOR "$TEMP_FILE"

# If empty, fail
if [[ ! -s "$TEMP_FILE" ]]; then
  echo "Aborting commit due to empty message."
  rm "$TEMP_FILE"
  exit 1
fi

git c "$(cat "$TEMP_FILE")"
git stash list -n 1
