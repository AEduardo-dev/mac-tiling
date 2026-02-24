#!/bin/bash
BATTERY_INFO="$(pmset -g batt)"
PERCENTAGE="$(printf '%s\n' "$BATTERY_INFO" | grep -Eo "[0-9]+%" | cut -d% -f1)"
PERCENTAGE="${PERCENTAGE:-0}"
CHARGING="$(printf '%s\n' "$BATTERY_INFO" | grep 'AC Power')"

if [ -n "$CHARGING" ]; then
    ICON="󰂄"
elif [ "$PERCENTAGE" -gt 80 ]; then
    ICON="󰁹"
elif [ "$PERCENTAGE" -gt 60 ]; then
    ICON="󰂀"
elif [ "$PERCENTAGE" -gt 40 ]; then
    ICON="󰁾"
elif [ "$PERCENTAGE" -gt 20 ]; then
    ICON="󰁼"
else
    ICON="󰁺"
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
