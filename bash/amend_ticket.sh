#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.source.sh"

# check if mg.branch_to_ticket in path exists
if ! command -v mg.branch_to_ticket &> /dev/null
then
    echo_red "mg.branch_to_ticket could not be found in PATH"
    exit 1
fi

TICKET_ID=$(mg.branch_to_ticket)
if [ -z "$TICKET_ID" ]; then
    echo_red "No ticket ID found for the current branch."
    exit 1
fi

MESSAGE_BEFORE=$(git log -1 --pretty=%B)

if [[ "$MESSAGE_BEFORE" == "$TICKET_ID:"* ]]; then
    echo "Commit message already starts with ticket ID: $TICKET_ID"
    git log -1 --pretty=%B
    exit 0
fi

git commit --amend -m "$TICKET_ID: $(git log -1 --pretty=%B)"

echo "Message before amend:"
echo_yellow "$MESSAGE_BEFORE"
echo
echo "Message after amend:"
echo_yellow "$(git log -1 --pretty=%B)"
echo
echo "Commit message amended successfully."

