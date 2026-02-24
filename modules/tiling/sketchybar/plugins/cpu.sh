#!/bin/bash

# shellcheck disable=SC2154
# $NAME is set by sketchybar at runtime.

CPU="$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')"
sketchybar --set "$NAME" label="${CPU}%"
