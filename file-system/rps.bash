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

function rps_autocomplete() {
  complete -W "$(ls "$REPOSITORIES_DIRECTORY")" "$1"
}

rps_autocomplete rpse
rps_autocomplete rps
