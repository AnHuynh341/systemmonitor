#!/bin/bash

echo ""
echo "INTERNET"

PING=$(ping -c 1 -W 2 8.8.8.8 | grep time= | awk -F'time=' '{print $2}')

if [ -z "$PING" ]; then
    echo "Internet: DOWN"
else
    echo "Ping 8.8.8.8: $PING"
fi
