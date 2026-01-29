#!/usr/bin/env bash

B=$(git branch --show-current)
B=${B//_/-}
B=${B^^}
B=$(cut -d '-' -f1-2 <<<"$B")

echo $B
