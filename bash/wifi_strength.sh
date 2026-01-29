#!/usr/bin/env bash

WIFI_INTERFACE=$(iwconfig 2> /dev/null | grep ESSID | awk '{ print $1 }')
iwconfig $WIFI_INTERFACE | grep -ioP 'quality=\K\d{1,2}/\d{1,2}' | awk -F '/' '{ printf("%.0f%%\n", $1*100/$2) }'
