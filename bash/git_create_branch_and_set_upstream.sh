#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.source.sh"

NEW_BRANCH_NAME="$1"

help() {
    echo -e "Usage: ${C_FG_BOLD}$0${C_FG_NOCOLOR} <new_branch_name>"
}

if [ -z "$NEW_BRANCH_NAME" ]; then
    echo -e "${C_FG_RED}Error: New branch name is required.${C_FG_NOCOLOR}"
    help
    exit 1
fi

if git checkout -b "$NEW_BRANCH_NAME" && git push --set-upstream origin "$NEW_BRANCH_NAME"; then
    echo -e "${C_FG_GREEN}Successfully created branch '${C_FG_BOLD}${NEW_BRANCH_NAME}${C_FG_NOCOLOR}${C_FG_GREEN}' and set upstream.${C_FG_NOCOLOR}"
else
    echo -e "${C_FG_RED}Failed to create branch or set upstream.${C_FG_NOCOLOR}"
    exit 1
fi