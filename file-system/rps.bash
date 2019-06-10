#!/bin/bash

if [ -z "$REPOSITORIES_DIRECTORY" ]; then
  REPOSITORIES_DIRECTORY="$HOME"
fi

function rpse() {
  [ -z "$1" ] && echo "$REPOSITORIES_DIRECTORY" || echo "$REPOSITORIES_DIRECTORY/$1"
}

function rps() {
  cd "$(rpse "$@")" || return
}

function __rps_autocomplete() {
  complete -W "$(ls "$REPOSITORIES_DIRECTORY")" "$1"
}

__rps_autocomplete rpse
__rps_autocomplete rps
