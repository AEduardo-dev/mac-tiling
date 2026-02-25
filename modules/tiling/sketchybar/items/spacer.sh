#!/usr/bin/env bash

SPACER_NAME="$1"
POSITION="${2:-right}"

if [ -z "$SPACER_NAME" ]; then
  return 1
fi

sketchybar --add item "spacer_$SPACER_NAME" "$POSITION" \
  --set "spacer_$SPACER_NAME" width=8
