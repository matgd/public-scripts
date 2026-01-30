#!/bin/bash

# Help message
HELP_MESSAGE="Usage: ./gafzf.sh
Use TAB or Shift+TAB to select multiple files, and ENTER to confirm."

# Check for --help argument
if [[ "$1" == "--help" ]]; then
    echo "$HELP_MESSAGE"
    exit 0
fi

# Get the root directory of the Git repository
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

# Check if we're in a Git repository
if [ -z "$GIT_ROOT" ]; then
    echo "Error: Not in a Git repository."
    exit 1
fi

# Move to the Git root directory
pushd "$GIT_ROOT" >/dev/null || exit 1

# Define markers for different Git statuses
UNSTAGED_MARK=' M '
MODIFIED_AFTER_STAGED='MM '
UNTRACKED_MARK='?? '
RENAMED_MARK='R '

# Get the list of changed files (unstaged, modified after staged, untracked, and renamed)
CHANGED_FILES=$(git status --porcelain | grep -e "${UNSTAGED_MARK}" -e "${MODIFIED_AFTER_STAGED}" -e "${UNTRACKED_MARK}" -e "${RENAMED_MARK}" | awk '{print $2}')

# Use fzf to select files (with multiselect)
SELECTED_FILES=$(echo "$CHANGED_FILES" | fzf --multi --preview '
    FILE={}
    if git ls-files --error-unmatch "$FILE" >/dev/null 2>&1; then
        if git diff --quiet -- "$FILE"; then
            # File is staged, show cached diff
            git diff --cached --color=always -- "$FILE"
        else
            # File is modified but not staged, show working tree diff
            git diff --color=always -- "$FILE"
        fi
    else
        # File is untracked, show its content
        cat "$FILE"
    fi
')

# Check if any files were selected
if [ -n "$SELECTED_FILES" ]; then
    # Stage the selected files
    echo "$SELECTED_FILES" | xargs git add
    echo "Staged the following files:"
    echo "$SELECTED_FILES"
else
    echo "No files were selected."
fi

# Return to the original directory
popd >/dev/null || exit 1
