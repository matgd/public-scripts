#!/usr/bin/env bash

# check if branch_to_ticket.sh in path exists
if ! command -v branch_to_ticket.sh &> /dev/null
then
    echo "branch_to_ticket.sh could not be found in PATH"
    exit 1
fi

TICKET_ID=$(branch_to_ticket.sh)
if [ -z "$TICKET_ID" ]; then
    echo "No ticket ID found for the current branch."
    exit 1
fi

MESSAGE_BEFORE=$(git log -1 --pretty=%B)

if [[ "$MESSAGE_BEFORE" == "$TICKET_ID:"* ]]; then
    echo "Commit message already starts with ticket ID: $TICKET_ID"
    git log -1 --pretty=%B
    exit 0
fi

git commit --amend -m "$TICKET_ID: $(git log -1 --pretty=%B)"

echo "Message before amend: $MESSAGE_BEFORE"
echo "Message after amend: $(git log -1 --pretty=%B)"
echo "Commit message amended successfully."

