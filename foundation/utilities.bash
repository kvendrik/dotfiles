#!/bin/bash

# Usage: __strip_flags <...all_arguments>
# Results are stored in CURRENT_CLEAN_ARGUMENTS
# Example: __strip_flags -g hello there --open && echo $CURRENT_CLEAN_ARGUMENTS
CURRENT_CLEAN_ARGUMENTS=()
function __strip_flags() {
  CURRENT_CLEAN_ARGUMENTS=()
  for argument in "$@"; do
    if [[ "$argument" =~ ^- ]]; then
      continue
    fi
    CURRENT_CLEAN_ARGUMENTS+=("$argument")
  done
}

# Usage: __extract_flag_value <all_arguments> <flag_name>
function __extract_flag_value() {
  echo "$1" | grep -Eo "$2\=\w+" | grep -Eo '[^ \=]+$'
}

# Usage: __check_contains_flag <all_arguments> <flag_long_name> <flag_shorthand>
# Example: __check_contains_flag "$*" 'help' 'h'
function __check_contains_flag() {
  if [[ "$1" =~ --$2 ]] || [[ "$1" =~ -$3 ]]; then
    echo 'true'
  fi
}

function __escape_backslashes() {
  echo "$1" | sed 's/\//\\\//g'
}
