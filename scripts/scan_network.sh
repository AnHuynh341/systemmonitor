#!/bin/bash

BASE_DIR="$HOME/sys-mon"
STATE_DIR="$BASE_DIR/state"

EVENT_FILE="$STATE_DIR/net_event.log"
DEVICES_LAST="$STATE_DIR/devices_last"
KNOWN_DEVICES="$STATE_DIR/devices_known"
INTERNET_STATE="$STATE_DIR/net_state"
PING_HISTORY="$STATE_DIR/ping.log"

NOW=$(date "+%Y-%m-%d %H:%M:%S")

################################
# PING CHECK	
################################

P1=$(ping -c 1 -W 2 8.8.8.8 | grep time= | awk -F'time=' '{print $2}' | awk '{print $1}')
P2=$(ping -c 1 -W 2 1.1.1.1 | grep time= | awk -F'time=' '{print $2}' | awk '{print $1}')

if [ ! -z "$P1" ]; then
    echo "$NOW 8.8.8.8 $P1" >> "$PING_HISTORY"
fi

if [ ! -z "$P2" ]; then
    echo "$NOW 1.1.1.1 $P2" >> "$PING_HISTORY"
fi

################################
# INTERNET UP/DOWN DETECTION
################################

if [ -z "$P1" ] && [ -z "$P2" ]; then
    CURRENT_STATE="DOWN"
else
    CURRENT_STATE="UP"
fi

if [ ! -f "$INTERNET_STATE" ]; then
    echo "$CURRENT_STATE" > "$INTERNET_STATE"
fi

LAST_STATE=$(cat "$INTERNET_STATE")

if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
    if [ "$CURRENT_STATE" = "DOWN" ]; then
        echo "! $(date '+%H:%M') Internet DOWN" >> "$EVENT_FILE"
    else
        echo "! $(date '+%H:%M') Internet RESTORED" >> "$EVENT_FILE"
    fi
    echo "$CURRENT_STATE" > "$INTERNET_STATE"
fi

################################
# DEVICE SCAN
################################

TMP_SCAN="/tmp/devices_now"

sudo arp-scan --localnet 2>/dev/null \
| awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {
    if($3 ~ /^\(Unknown/) print $1
    else print $1, substr($0,index($0,$3))
}' \
| sort > "$TMP_SCAN"

[ -f "$DEVICES_LAST" ] || cp "$TMP_SCAN" "$DEVICES_LAST"
[ -f "$KNOWN_DEVICES" ] || touch "$KNOWN_DEVICES"

LAST_COUNT=$(wc -l < "$DEVICES_LAST")
NOW_COUNT=$(wc -l < "$TMP_SCAN")

# if almost all devices disappeared suddenly
if [ "$LAST_COUNT" -gt 3 ] && [ "$NOW_COUNT" -le 1 ]; then
    echo "! $(date '+%H:%M') Possible router reboot detected" >> "$EVENT_FILE"
fi

################################
# DEVICE CONNECT EVENTS
################################

comm -13 "$DEVICES_LAST" "$TMP_SCAN" | while read line
do
    echo "+ $(date '+%H:%M') $line connected" >> "$EVENT_FILE"

    # add to permanent inventory if new
    grep -qxF "$line" "$KNOWN_DEVICES" || echo "$line" >> "$KNOWN_DEVICES"
done

################################
# DEVICE DISCONNECT EVENTS
################################

comm -23 "$DEVICES_LAST" "$TMP_SCAN" | while read line
do
    echo "- $(date '+%H:%M') $line disconnected" >> "$EVENT_FILE"
done

################################
# UPDATE LAST SNAPSHOT
################################

cp "$TMP_SCAN" "$DEVICES_LAST"
