#!/bin/bash

# On aerospace workspace change, each item checks if it is the focused one
if [ "$SENDER" = "aerospace_workspace_change" ]; then
    FOCUSED="$(aerospace list-workspaces --focused 2>/dev/null)" || exit 0
    WORKSPACE_ID="${NAME#space.}"
    if [ "$WORKSPACE_ID" = "$FOCUSED" ]; then
        sketchybar --set "$NAME" \
            background.drawing=on \
            background.color=@ACCENT_COLOR@ \
            icon.color=@FOCUSED_ICON_COLOR@ \
            icon.font="SF Pro:Bold:14.0"
    else
        sketchybar --set "$NAME" \
            background.drawing=off \
            icon.color=@ICON_COLOR@ \
            icon.font="SF Pro:Regular:14.0"
    fi
    exit 0
fi

# Initial state based on env vars from aerospace trigger
WORKSPACE_ID="${NAME#space.}"
if [ "$AEROSP_FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color=@ACCENT_COLOR@ \
        icon.color=@FOCUSED_ICON_COLOR@ \
        icon.font="SF Pro:Bold:14.0"
else
    sketchybar --set "$NAME" \
        background.drawing=off \
        icon.color=@ICON_COLOR@ \
        icon.font="SF Pro:Regular:14.0"
fi
