#!/usr/bin/env zsh

read_mg_qfile.py --print-mappings
read -sk 1 "?> " _REPLY
echo "'${_REPLY}'"
_CHOICE=$(read_mg_qfile.py --choice="$_REPLY")
eval "$_CHOICE"
