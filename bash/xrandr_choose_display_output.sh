#!/usr/bin/env bash

SELECTED_ON_SCREEN=$1
MONITOR_OPTION="monitor"
LAPTOP_OPTION="laptop"

if [ -z "$SELECTED_ON_SCREEN" ]; then
    echo "Please provide an argument: $MONITOR_OPTION or $LAPTOP_OPTION"
    exit 1
fi

# if monitor then
if [ "$SELECTED_ON_SCREEN" == "$MONITOR_OPTION" ]; then
    xrandr --output HDMI-0 --auto; xrandr --output DP-2 --off
    echo "Monitor is selected. Laptop screen is turned off."
# if laptop then
elif [ "$SELECTED_ON_SCREEN" == "$LAPTOP_OPTION" ]; then
    xrandr --output DP-2 --auto; xrandr --output HDMI-0 --off
    echo "Laptop screen is selected. Monitor is turned off."
else
    echo "Invalid argument. Use $MONITOR_OPTION or $LAPTOP_OPTION."
    exit 1
fi
