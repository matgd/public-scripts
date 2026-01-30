#!/usr/bin/env bash

# =========================
# CONFIG HELPER LIBRARY
# =========================
# Source this file in your scripts to load user configs from ~/.config/mg/
#
# Usage:
#   source "$(dirname "$0")/lib/config.source.sh"
#   mg_load_config "workspace_apps.sh"
#
# Or after installation:
#   source "$HOME/.local/bin/mg/lib/config.source.sh"
#   mg_load_config "workspace_apps.sh"

MG_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mg"

# Load a config file from the mg config directory
# Arguments:
#   $1 - config filename (e.g., "workspace_apps.sh")
#   $2 - (optional) "required" - exit with error if config doesn't exist
# Returns:
#   0 if config was loaded successfully
#   1 if config doesn't exist (and not required)
mg_load_config() {
    local CONFIG_NAME="$1"
    local REQUIRED="${2:-}"
    local CONFIG_PATH="$MG_CONFIG_DIR/$CONFIG_NAME"

    if [[ -f "$CONFIG_PATH" ]]; then
        # shellcheck source=/dev/null
        source "$CONFIG_PATH"
        return 0
    else
        if [[ "$REQUIRED" == "required" ]]; then
            echo "Error: Required config not found: $CONFIG_PATH" >&2
            echo "Copy the example config and customize it:" >&2
            echo "  cp ${CONFIG_PATH}.example $CONFIG_PATH" >&2
            exit 1
        fi
        return 1
    fi
}

# Check if a config file exists
# Arguments:
#   $1 - config filename
# Returns:
#   0 if exists, 1 otherwise
mg_config_exists() {
    local CONFIG_NAME="$1"
    [[ -f "$MG_CONFIG_DIR/$CONFIG_NAME" ]]
}

# Get the full path to a config file
# Arguments:
#   $1 - config filename
# Outputs:
#   Full path to the config file
mg_config_path() {
    local CONFIG_NAME="$1"
    echo "$MG_CONFIG_DIR/$CONFIG_NAME"
}