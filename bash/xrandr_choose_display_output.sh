#!/usr/bin/env bash

# =========================
# CONFIG
# =========================
# Override these with environment variables or edit directly
EXTERNAL_DISPLAY="${EXTERNAL_DISPLAY:-HDMI-0}"
LAPTOP_DISPLAY="${LAPTOP_DISPLAY:-DP-2}"

# =========================
# MAIN
# =========================
SELECTED_ON_SCREEN=$1
MONITOR_OPTION="monitor"
LAPTOP_OPTION="laptop"

if [ -z "$SELECTED_ON_SCREEN" ]; then
    echo "Please provide an argument: $MONITOR_OPTION or $LAPTOP_OPTION"
    exit 1
fi

# if monitor then
if [ "$SELECTED_ON_SCREEN" == "$MONITOR_OPTION" ]; then
    xrandr --output "$EXTERNAL_DISPLAY" --auto; xrandr --output "$LAPTOP_DISPLAY" --off
    echo "Monitor ($EXTERNAL_DISPLAY) is selected. Laptop screen ($LAPTOP_DISPLAY) is turned off."
# if laptop then
elif [ "$SELECTED_ON_SCREEN" == "$LAPTOP_OPTION" ]; then
    xrandr --output "$LAPTOP_DISPLAY" --auto; xrandr --output "$EXTERNAL_DISPLAY" --off
    echo "Laptop screen ($LAPTOP_DISPLAY) is selected. Monitor ($EXTERNAL_DISPLAY) is turned off."
else
    echo "Invalid argument. Use $MONITOR_OPTION or $LAPTOP_OPTION."
    exit 1
fi
