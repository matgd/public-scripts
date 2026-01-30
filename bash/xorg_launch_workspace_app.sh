#!/usr/bin/env bash

# =========================
# CONFIG
# =========================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mg"
CONFIG_FILE="$CONFIG_DIR/workspace_apps.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config not found: $CONFIG_FILE" >&2
    echo "Create it from the example:" >&2
    echo "  cp $CONFIG_FILE.example $CONFIG_FILE" >&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed" >&2
    exit 1
fi

# =========================
# MAIN
# =========================

# Get the current workspace number
CURRENT_WORKSPACE=$(wmctrl -d | grep '*' | awk '{print $1}')

# Get apps for current workspace
APPS=$(jq -r ".workspaces[\"$CURRENT_WORKSPACE\"][]?" "$CONFIG_FILE")

if [[ -z "$APPS" ]]; then
    echo "No application defined for workspace $CURRENT_WORKSPACE"
    exit 0
fi

while IFS= read -r APP; do
    # Check if the application is already running
    if pgrep -x "$APP" > /dev/null; then
        echo "$APP is already running"
        continue
    fi

    "$APP" &
done <<< "$APPS"