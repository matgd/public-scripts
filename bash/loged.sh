#!/bin/bash

set -e

DOCKER_CONT=$1
TAIL_LEN=10000

if [[ -z $DOCKER_CONT ]]; then
    # Check if fzf is installed
    if ! command -v fzf &> /dev/null; then
        echo "Usage: loged <docker_container_name>"
        exit 1
    fi

    DOCKER_CONT=$(docker container ls --format "{{.Names}}" | fzf --prompt "Select a Docker container: ")
fi

TEMPF=$(mktemp)
mv "$TEMPF" "$TEPMF".log
TEMPF="$TEMPF".log

# Get logs
docker logs --tail "${TAIL_LEN}" "${DOCKER_CONT}" &> "$TEMPF"
# Strip from color codes
sed -i -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" "$TEMPF"

if [[ $EDITOR == "nvim" ]]; then
    # Open in nvim clean instance for better speed
    # --clean -> no plugins for performance
    # + -> place cursor at the end
    # -c -> commands to run
    nvim --clean + -c "set nu" "$TEMPF"
else
    $EDITOR "$TEMPF"
fi

rm "$TEMPF"  # might result in early deletion if editor is detached from shell
