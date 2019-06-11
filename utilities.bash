#!/bin/bash

# Usage: __strip_flags <all_arguments>
function __strip_flags() {
  arguments=()
  for argument in "$@"; do
    if echo "$argument" | grep -Eoq "^-"; then
      continue
    fi
    arguments+=("$argument")
  done
  echo "${arguments[@]}"
}

# Usage: __extract_flag_value <all_arguments> <flag_name>
function __extract_flag_value() {
  echo "$1" | grep -Eo "$2\=\w+" | grep -Eo '[^\s\=]+$'
}

# Usage: __check_contains_flag <all_arguments> <flag_long_name> <flag_shorthand>
function __check_contains_flag() {
  echo "$1" | grep -Eo "(\s|^)\-\-$2(\s|$)"
  if [ -n "$3" ]; then
    echo "$1" | grep -Eo "(\s|^)\-$3(\s|$)"
  fi
}

function __safe_exec() {
  local do_install

  if [ -z "$(command -v "$1")" ]; then
    echo -n "Command $1 does not seem to exist. Want to try installing it using brew? [y/N] "
    read -r do_install

    if [[ "$do_install" == 'y' ]]; then
      brew install "$1"
    fi
  fi

  # shellcheck disable=SC2068
  $@
}
