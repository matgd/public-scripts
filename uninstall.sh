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
BIN_DIR="$HOME/.local/bin/mg"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mg"

# =========================
# HELPERS
# =========================
info()    { echo -e "${BLUE}==>${RESET} $1"; }
success() { echo -e "${GREEN}✔${RESET}  $1"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $1"; }
error()   { echo -e "${RED}✖${RESET}  $1"; }

# =========================
# CONFIRMATION
# =========================
echo -e "${BOLD}This will remove the following:${RESET}"
echo -e "  ${BOLD}Bin:${RESET}    $BIN_DIR"
echo -e "  ${BOLD}Config:${RESET} $CONFIG_DIR"
echo

read -rp "Are you sure you want to uninstall? [y/N] " answer
case "$answer" in
  [yY]|[yY][eE][sS]) ;;
  *)
    warn "Aborted."
    exit 0
    ;;
esac

echo

# =========================
# REMOVE BIN DIR
# =========================
if [[ -d "$BIN_DIR" ]]; then
  info "Removing installed scripts from $BIN_DIR"
  rm -rf "$BIN_DIR"
  success "removed $BIN_DIR"
else
  warn "Bin directory not found, skipped: $BIN_DIR"
fi

# =========================
# REMOVE CONFIG DIR
# =========================
if [[ -d "$CONFIG_DIR" ]]; then
  echo
  echo -e "${YELLOW}Config directory found:${RESET} $CONFIG_DIR"
  read -rp "Remove config files too? [y/N] " answer
  case "$answer" in
    [yY]|[yY][eE][sS])
      rm -rf "$CONFIG_DIR"
      success "removed $CONFIG_DIR"
      ;;
    *)
      warn "Kept config directory: $CONFIG_DIR"
      ;;
  esac
else
  warn "Config directory not found, skipped: $CONFIG_DIR"
fi

# =========================
# DONE
# =========================
echo
success "Uninstall complete!"