#!/bin/bash

# Highlight the focused workspace, dim the rest
if [ "$AEROSP_FOCUSED_WORKSPACE" = "$NAME" ]; then
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
  FOCUSED="$(aerospace list-workspaces --focused 2>/dev/null)" || exit 0
  WORKSPACES="$(aerospace list-workspaces --all 2>/dev/null)" || exit 0
  for sid in $WORKSPACES; do
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
