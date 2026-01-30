#!/bin/bash

# SOURCE ME
#
function avenv {
  if [[ $# == 0 ]]; then
    FOUND=$(find -L . -maxdepth 3 -path '*/bin/activate' | head -n 1)  # -L follows symlinks
    if [[ ! -z "${FOUND}" ]]; then
      source "${FOUND}"
    fi
  else 
    source "${1}/bin/activate"
  fi
}
