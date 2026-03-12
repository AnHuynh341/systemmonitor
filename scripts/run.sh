#!/bin/bash

BASE_DIR="$HOME/sys-mon"
LOG_DIR="$BASE_DIR/logs"
STATE_DIR="$BASE_DIR/state"

DATE=$(date "+%G-week%V")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

LOGFILE="$LOG_DIR/monitor-$DATE.log"

echo "--------------------------------------------------" >> "$LOGFILE"
echo "Time: $TIMESTAMP" >> "$LOGFILE"
echo "" >> "$LOGFILE"

################################
# SYSTEM
################################

$BASE_DIR/scripts/collect_system.sh >> "$LOGFILE"

################################
# NETWORK
################################

echo "" >> "$LOGFILE"
echo "NETWORK" >> "$LOGFILE"
echo "" >> "$LOGFILE"

echo "Connected devices:" >> "$LOGFILE"
cat "$STATE_DIR/devices_last" >> "$LOGFILE"

echo "" >> "$LOGFILE"
echo "Events this hour:" >> "$LOGFILE"

if [ -s "$STATE_DIR/net_event.log" ]; then
    cat "$STATE_DIR/net_event.log" >> "$LOGFILE"
else
    echo "No events this hour." >> "$LOGFILE"
fi

echo "" >> "$LOGFILE"
echo "Average latency:" >> "$LOGFILE"

awk '$3=="8.8.8.8"{sum+=$4;count++} END {if(count>0) print "8.8.8.8",sum/count,"ms"}' "$STATE_DIR/ping.log" >> "$LOGFILE"

awk '$3=="1.1.1.1"{sum+=$4;count++} END {if(count>0) print "1.1.1.1",sum/count,"ms"}' "$STATE_DIR/ping.log" >> "$LOGFILE"

################################
# WEATHER
################################

echo "" >> "$LOGFILE"

$BASE_DIR/scripts/collect_weather.sh >> "$LOGFILE"

echo "" >> "$LOGFILE"

################################
# CLEAR HOURLY BUFFERS
################################

> "$STATE_DIR/net_event.log"
> "$STATE_DIR/ping.log"



