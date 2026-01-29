#!/usr/bin/env bash

PROGRESS_FS="{progress}"
REMAINING_FS="{remaining}"
ICON_FS="{icon}"
FORMAT_STRING="${1:-"$ICON_FS  $REMAINING_FS%"}"


DAY=$(date +%d)
DAYS_IN_MONTH=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%d)
ICON=" "

# force base-10 to avoid octal issue
PROGRESS=$(( 10#$DAY * 100 / 10#$DAYS_IN_MONTH ))
REMAINING=$(( 100 - PROGRESS ))


OUTPUT="$FORMAT_STRING"

OUTPUT=${OUTPUT//$PROGRESS_FS/$PROGRESS}
OUTPUT=${OUTPUT//$REMAINING_FS/$REMAINING}
OUTPUT=${OUTPUT//$ICON_FS/$ICON}
echo "$OUTPUT"
