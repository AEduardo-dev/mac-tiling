#!/usr/bin/env bash

# Sketchybar environment variables
: "${INFO:=}"

source "$CONFIG_DIR/core/env.sh"
source "$CONFIG_DIR/tokens/colors.sh"
source "$CONFIG_DIR/plugins/icon.sh"

if [ -n "$INFO" ]; then
  APP_NAME="$INFO"
  ICON=$(get_app_icon "$APP_NAME")

  sketchybar --set front_app.icon \
    icon="$ICON" \
    icon.font="${SBAR_APP_ICON_FONT:-sketchybar-app-font}:Regular:${SBAR_APP_ICON_FONT_SIZE:-13.5}"
  sketchybar --set front_app.name label="$APP_NAME"
fi
