#!/bin/bash

EVENT_FILE="state/net_event.log"
DEVICES_LAST="state/devices_last"
INTERNET_STATE="state/net_state"
PING_HISTORY="state/ping.log"

NOW=$(date "+%Y-%m-%d %H:%M:%S")

################################
# INTERNET LATENCY CHECK
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
        echo "$NOW Internet DOWN" >> "$EVENT_FILE"
    else
        echo "$NOW Internet RESTORED" >> "$EVENT_FILE"
    fi
    echo "$CURRENT_STATE" > "$INTERNET_STATE"
fi

################################
# DEVICE SCAN
################################

TMP_SCAN="/tmp/devices_now"

arp-scan --localnet 2>/dev/null | awk '/^[0-9]/ {print $1,$2,$3,$4,$5}' | sort > "$TMP_SCAN"

if [ ! -f "$DEVICES_LAST" ]; then
    cp "$TMP_SCAN" "$DEVICES_LAST"
fi

# new devices
comm -13 "$DEVICES_LAST" "$TMP_SCAN" | while read line
do
    echo "$NOW Device connected: $line" >> "$EVENT_FILE"
done

# disconnected devices
comm -23 "$DEVICES_LAST" "$TMP_SCAN" | while read line
do
    echo "$NOW Device disconnected: $line" >> "$EVENT_FILE"
done

cp "$TMP_SCAN" "$DEVICES_LAST"
