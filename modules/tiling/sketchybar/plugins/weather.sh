#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/icon.sh"

LOCATION_ENCODED="${SBAR_WEATHER_LOCATION// /%20}"

# Geocode the location name to lat/lon via Open-Meteo
GEO_JSON=$(curl -s --connect-timeout 5 --max-time 10 \
  "https://geocoding-api.open-meteo.com/v1/search?name=${LOCATION_ENCODED}&count=1&language=en&format=json" 2>/dev/null)

LAT=$(echo "$GEO_JSON" | jq -r '.results[0].latitude // empty' 2>/dev/null)
LON=$(echo "$GEO_JSON" | jq -r '.results[0].longitude // empty' 2>/dev/null)

if [ -z "$LAT" ] || [ -z "$LON" ]; then
  TEMP="N/A"
  WEATHER_CODE=0
  IS_DAY=1
else
  WEATHER_JSON=$(curl -s --connect-timeout 5 --max-time 10 \
    "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code,is_day&timezone=auto" 2>/dev/null)

  if [ -z "$WEATHER_JSON" ] || ! echo "$WEATHER_JSON" | jq -e '.current' >/dev/null 2>&1; then
    TEMP="N/A"
    WEATHER_CODE=0
    IS_DAY=1
  else
    TEMP=$(echo "$WEATHER_JSON" | jq -r '.current.temperature_2m // "N/A"' | sed 's/\..*//')
    WEATHER_CODE=$(echo "$WEATHER_JSON" | jq -r '.current.weather_code // 0')
    IS_DAY=$(echo "$WEATHER_JSON" | jq -r '(.current.is_day // 1) | round')
  fi
fi

ICON=$(get_weather_icon "$WEATHER_CODE" "$IS_DAY")

sketchybar --set weather.icon icon="$ICON"
sketchybar --set weather.label label="${TEMP}°C"
