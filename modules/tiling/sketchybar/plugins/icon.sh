#!/usr/bin/env bash

source "$CONFIG_DIR/icons/apps.sh"
source "$CONFIG_DIR/icons/widget.sh"
source "$CONFIG_DIR/icons/weather.sh"

# Variable set by __icon_map in apps.sh and __widget_icon_map in widget.sh
icon_result=""

get_app_icon() {
  local app_name="$1"
  __icon_map "$app_name"
  echo "$icon_result"
}

get_widget_icon() {
  local icon_name="$1"
  __widget_icon_map "$icon_name"
  echo "$icon_result"
}

get_weather_icon() {
  local code="$1"
  local is_day="$2"
  local icon_name
  local suffix

  suffix=$([ "$is_day" -eq 1 ] && echo "_day" || echo "_night")

  # WMO weather interpretation codes (Open-Meteo)
  case "$code" in
  0 | 1)
    icon_name="weather_clear${suffix}"
    ;;
  2)
    icon_name="weather_partly_cloudy${suffix}"
    ;;
  3)
    icon_name="weather_cloudy${suffix}"
    ;;
  45 | 48)
    icon_name="weather_fog${suffix}"
    ;;
  51 | 53 | 55 | 61 | 63 | 65 | 80 | 81 | 82)
    icon_name="weather_rain${suffix}"
    ;;
  56 | 57 | 66 | 67)
    icon_name="weather_sleet${suffix}"
    ;;
  71 | 73 | 75 | 77 | 85 | 86)
    icon_name="weather_snow${suffix}"
    ;;
  95)
    icon_name="weather_thunderstorm${suffix}"
    ;;
  96 | 99)
    icon_name="weather_hail${suffix}"
    ;;
  *)
    icon_name="weather_default"
    ;;
  esac

  __weather_icon_map "$icon_name"
  echo "$icon_result"
}
