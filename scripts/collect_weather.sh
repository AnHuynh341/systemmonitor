#!/bin/bash

echo ""
echo "ENVIRONMENT"

WEATHER=$(curl -s --max-time 5 "wttr.in/Ho+Chi+Minh?format=j1")

read TEMP FEELS HUMIDITY DESC <<< $(echo "$WEATHER" | jq -r '.current_condition[0] | "\(.temp_C) \(.FeelsLikeC) \(.humidity) \(.weatherDesc[0].value)"')

echo "Temperature: ${TEMP}C"
echo "Feels like: ${FEELS}C"
echo "Humidity: ${HUMIDITY}%"
echo "Condition: $DESC"
