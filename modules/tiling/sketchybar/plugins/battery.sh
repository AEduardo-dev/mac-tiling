#!/bin/bash

# shellcheck disable=SC2154
# $NAME is set by sketchybar at runtime.

PERCENTAGE="$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)"
PERCENTAGE="${PERCENTAGE:-0}"
CHARGING="$(pmset -g batt | grep 'AC Power')"

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
