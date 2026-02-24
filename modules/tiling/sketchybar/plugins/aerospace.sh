#!/bin/bash

# shellcheck disable=SC2154
# $NAME, $AEROSP_FOCUSED_WORKSPACE, $FOCUSED_WORKSPACE, $SENDER are set by
# sketchybar at runtime.

# Highlight the focused workspace, dim the rest
if [ "$AEROSP_FOCUSED_WORKSPACE" = "$NAME" ] || [ "$FOCUSED_WORKSPACE" = "${NAME#space.}" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=@ACCENT_COLOR@ \
    icon.color=0xff1e1e2e \
    icon.font="SF Pro:Bold:14.0"
else
  sketchybar --set "$NAME" \
    background.drawing=off \
    icon.color=@ICON_COLOR@ \
    icon.font="SF Pro:Regular:14.0"
fi

# On initial load, highlight the focused workspace
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  FOCUSED="$(aerospace list-workspaces --focused)"
  # shellcheck disable=SC2046
  for sid in $(aerospace list-workspaces --all); do
    if [ "$sid" = "$FOCUSED" ]; then
      sketchybar --set "space.$sid" \
        background.drawing=on \
        background.color=@ACCENT_COLOR@ \
        icon.color=0xff1e1e2e
    else
      sketchybar --set "space.$sid" \
        background.drawing=off \
        icon.color=@ICON_COLOR@
    fi
  done
fi
