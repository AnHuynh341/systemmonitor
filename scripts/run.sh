#!/bin/bash

BASE_DIR="$HOME/sys-mon/"
LOG_DIR="$HOME/sys-mon/logs/"

DATE=$(date "+%Y-%m")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

LOGFILE="$LOG_DIR/monitor-$DATE.log"

echo "--------------------------------------------------" >> "$LOGFILE"
echo "Time: $TIMESTAMP" >> "$LOGFILE"
echo "" >> "$LOGFILE"

$BASE_DIR/scripts/collect_system.sh >> "$LOGFILE"

$BASE_DIR/scripts/scan_network.sh >> "$LOGFILE"

$BASE_DIR/scripts/collect_weather.sh >> "$LOGFILE"

$BASE_DIR/scripts/check_net.sh >> "$LOGFILE"

echo "" >> "$LOGFILE"


