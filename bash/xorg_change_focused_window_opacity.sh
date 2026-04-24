#!/usr/bin/env bash

# Changes the opacity of the currently focused window on Xorg.
# Usage: xorg_change_focused_window_opacity.sh <step> [min_opacity]
#   step: opacity change, e.g. -0.1 to decrease, +0.1 to increase (default: -0.1)
#   min_opacity: minimum allowed opacity, 0.0-1.0 (default: 0.2)
# Requires: xdotool, xprop

set -euo pipefail

export LC_NUMERIC=C

MAX_OPACITY=4294967295 # 0xFFFFFFFF (fully opaque)

STEP="${1:--0.1}"
MIN_OPACITY="${2:-0.2}"

# Get the currently focused window ID
WINDOW_ID=$(xdotool getactivewindow)

# Get current opacity (default is fully opaque)
RAW_OUTPUT=$(xprop -id "$WINDOW_ID" -notype _NET_WM_WINDOW_OPACITY 2>/dev/null || true)
if echo "$RAW_OUTPUT" | grep -q 'not found\|no such'; then
    CURRENT_HEX=$MAX_OPACITY
else
    CURRENT_HEX=$(echo "$RAW_OUTPUT" | grep -oE '[0-9]+' | tail -1)
    CURRENT_HEX="${CURRENT_HEX:-$MAX_OPACITY}"
fi

# Convert current opacity to a 0.0-1.0 scale
CURRENT_FRACTION=$(awk "BEGIN { printf \"%.4f\", $CURRENT_HEX / $MAX_OPACITY }")

# Calculate new opacity, clamped between MIN_OPACITY and 1.0
NEW_FRACTION=$(awk "BEGIN {
    val = $CURRENT_FRACTION + ($STEP)
    if (val < $MIN_OPACITY) val = $MIN_OPACITY
    if (val > 1.0) val = 1.0
    printf \"%.4f\", val
}")

# Convert back to the 32-bit integer scale
NEW_HEX=$(awk "BEGIN { printf \"%d\", $NEW_FRACTION * $MAX_OPACITY }")

# Apply the new opacity
xprop -id "$WINDOW_ID" -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY "$NEW_HEX"

echo "Window $WINDOW_ID opacity: $CURRENT_FRACTION -> $NEW_FRACTION"