#!/bin/bash

# shellcheck disable=SC2154
# $NAME is set by sketchybar at runtime.

sketchybar --set "$NAME" label="$(date '+%a %d %b %H:%M')"
