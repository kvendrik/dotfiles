#!/bin/bash

if [ -z "$REPOSITORIES_DIRECTORY" ]; then
  REPOSITORIES_DIRECTORY="$HOME"
fi

function rpse() {
  [ -z "$1" ] && echo "$REPOSITORIES_DIRECTORY" || echo "$REPOSITORIES_DIRECTORY/$1"
}

function rps() {
  cd "$(rpse "$1")" || return
  if [ -n "$2" ]; then
    git checkout "$2"
  fi
}

function __rps_autocomplete() {
  complete -W "$(ls "$REPOSITORIES_DIRECTORY")" "$1"
}

alias r='rps'

__rps_autocomplete rpse
__rps_autocomplete rps
