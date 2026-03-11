#!/bin/bash

echo "SYSTEM"

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
UPTIME=$(uptime -p)

TEMP=$(sensors 2>/dev/null | grep -m 1 'Package' | awk '{print $4}')

BATTERY=$(acpi -b 2>/dev/null | awk -F', ' '{print $2}')
POWER=$(cat /sys/class/power_supply/AC*/online 2>/dev/null)

if [ "$POWER" = "1" ]; then
    POWER_STATE="AC"
else
    POWER_STATE="Battery"
fi


echo "CPU: $CPU%"
echo "CPU Temp: ${TEMP:-N/A}"
echo "RAM: $RAM"
echo "Battery: ${BATTERY:-N/A}"
echo "Power: $POWER_STATE"
echo "Uptime: $UPTIME"

