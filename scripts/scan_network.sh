#!/bin/bash

echo ""
echo "NETWORK"

sudo arp-scan --localnet | grep -E "([0-9]{1,3}\.){3}" | while read line
do
    IP=$(echo $line | awk '{print $1}')
    MAC=$(echo $line | awk '{print $2}')
    VENDOR=$(echo $line | cut -d " " -f3-)

    printf "%-15s %-18s %s\n" "$IP" "$MAC" "$VENDOR"
done
