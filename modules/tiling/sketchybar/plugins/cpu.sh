#!/bin/bash
CPU="$(ps -A -o %cpu= 2>/dev/null | awk '{sum+=$1} END {printf "%.0f", sum}')"

# Fallback to 0 if CPU parsing fails or is non-numeric
if ! [[ "$CPU" =~ ^[0-9]+$ ]]; then
  CPU=0
fi

sketchybar --set "$NAME" label="${CPU}%"
