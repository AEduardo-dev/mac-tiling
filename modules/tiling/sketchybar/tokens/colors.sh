#!/usr/bin/env bash

# Color theme loader
# Used by plugins that need to dynamically update colors

# Set CONFIG_DIR if not set
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

# Use SBAR_THEME if already exported (e.g. by the Nix wrapper), otherwise fall
# back to the user runtime config, then default to onedark.
if [ -z "$SBAR_THEME" ]; then
  USER_CONFIG="$HOME/.config/sketchybar/user.sketchybarrc"
  if [ -f "$USER_CONFIG" ]; then
    SBAR_THEME=$(grep "^export SBAR_THEME=" "$USER_CONFIG" | sed 's/.*="\(.*\)"/\1/' | sed 's/.*=\(.*\)/\1/')
  fi
fi

THEME="${SBAR_THEME:-onedark}"
THEME_FILE="$CONFIG_DIR/tokens/themes/$THEME.sh"

if [ -f "$THEME_FILE" ]; then
  source "$THEME_FILE"
else
  source "$CONFIG_DIR/tokens/themes/onedark.sh"
fi
