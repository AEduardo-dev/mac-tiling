#!/usr/bin/env bash

# AeroSpace workspace integration
# Replaces yabai.sh for workspace management

get_spaces() {
  aerospace list-workspaces --all 2>/dev/null
}

get_space_apps() {
  local sid=$1
  aerospace list-windows --workspace "$sid" --format "%{app-name}" 2>/dev/null | sort -u | grep -v '^$'
}

get_space_click_command() {
  local sid=$1
  echo "aerospace workspace $sid"
}

get_focused_space() {
  aerospace list-workspaces --focused 2>/dev/null
}
