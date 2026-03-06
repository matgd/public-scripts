#!/usr/bin/env bash

export C_FG_RED="\033[0;31m"
export C_FG_GREEN="\033[0;32m"
export C_FG_YELLOW="\033[0;33m"
export C_FG_BLUE="\033[0;34m"
export C_FG_BOLD="\033[1m"
export C_FG_NOCOLOR="\033[0m"

function echo_red() {
    echo -e "${C_FG_RED}$1${C_FG_NOCOLOR}"
}

function echo_green() {
    echo -e "${C_FG_GREEN}$1${C_FG_NOCOLOR}"
}

function echo_yellow() {
    echo -e "${C_FG_YELLOW}$1${C_FG_NOCOLOR}"
}

function echo_blue() {
    echo -e "${C_FG_BLUE}$1${C_FG_NOCOLOR}"
}
