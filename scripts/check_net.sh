#!/bin/bash

echo ""
echo "INTERNET"

PING1=$(ping -c 1 -W 2 8.8.8.8 | grep time= | awk -F'time=' '{print $2}')
PING2=$(ping -c 1 -W 2 1.1.1.1 | grep time= | awk -F'time=' '{print $2}')

if [ -z "$PING1" ] && [ -z "$PING2" ]; then
    echo "Internet: DOWN"
else
	[ -n "$PING1" ] && echo "Ping Google DNS (8.8.8.8): $PING1"
	[ -n "$PING2" ] && echo "Ping Cloudflare DNS (1.1.1.1): $PING2"
fi
