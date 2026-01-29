#!/usr/bin/env bash
set -euo pipefail

# =========================
# COLORS
# =========================
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
BOLD="\033[1m"
RESET="\033[0m"

# =========================
# PATHS
# =========================
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

BIN_DIR="$HOME/.local/bin/mg"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mg"

GO_SRC_DIR="$ROOT_DIR/go"
BASH_SRC_DIR="$ROOT_DIR/bash"
PYTHON_SRC_DIR="$ROOT_DIR/python"
CONFIG_SRC_DIR="$ROOT_DIR/config"

# =========================
# HELPERS
# =========================
info()    { echo -e "${BLUE}==>${RESET} $1"; }
success() { echo -e "${GREEN}✔${RESET}  $1"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $1"; }
error()   { echo -e "${RED}✖${RESET}  $1"; }

# =========================
# PREPARE DIRS
# =========================
info "Preparing directories"
mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"

# =========================
# GO SCRIPTS
# =========================
if [[ -d "$GO_SRC_DIR" ]]; then
  info "Installing Go scripts"

  for DIR in "$GO_SRC_DIR"/*; do
    [[ -f "$DIR/main.go" ]] || continue

    NAME="$(basename "$DIR")"
    TMP_BIN="$(mktemp)"

    echo -e "  ${BOLD}→${RESET} building ${NAME}"
    go build -trimpath -ldflags="-s -w" -o "$TMP_BIN" "$DIR"

    install -Dm755 "$TMP_BIN" "$BIN_DIR/$NAME"
    rm "$TMP_BIN"

    success "installed $NAME"
  done
fi

# =========================
# BASH SCRIPTS
# =========================
if [[ -d "$BASH_SRC_DIR" ]]; then
  info "Installing Bash scripts"

  for FILE in "$BASH_SRC_DIR"/*.sh; do
    [[ -f "$FILE" ]] || continue

    NAME="$(basename "$FILE" .sh)"
    install -Dm755 "$FILE" "$BIN_DIR/$NAME"

    success "installed $NAME"
  done
fi

# =========================
# PYTHON SCRIPTS
# =========================
if [[ -d "$PYTHON_SRC_DIR" ]]; then
  info "Installing Python scripts"

  for FILE in "$PYTHON_SRC_DIR"/*.py; do
    [[ -f "$FILE" ]] || continue

    NAME="$(basename "$FILE" .py)"
    install -Dm755 "$FILE" "$BIN_DIR/$NAME"

    success "installed $NAME"
  done
fi

# =========================
# CONFIG FILES (.example)
# =========================
if [[ -d "$CONFIG_SRC_DIR" ]]; then
  info "Installing config templates"

  for FILE in "$CONFIG_SRC_DIR"/*.example; do
    [[ -f "$FILE" ]] || continue

    NAME="$(basename "$FILE" .example)"
    DEST="$CONFIG_DIR/$NAME"

    if [[ -f "$DEST" ]]; then
      warn "config exists, skipped: $DEST"
    else
      install -Dm644 "$FILE" "$DEST"
      success "created config $DEST"
    fi
  done
fi

# =========================
# DONE
# =========================
echo
success "All done!"
echo -e "${BOLD}Bin:${RESET}    $BIN_DIR"
echo -e "${BOLD}Config:${RESET} $CONFIG_DIR"

