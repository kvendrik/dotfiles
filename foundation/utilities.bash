#!/bin/bash

# Usage: _strip_flags <...all_arguments>
# Results are stored in CURRENT_CLEAN_ARGUMENTS
# Example: _strip_flags -g hello there --open && echo $CURRENT_CLEAN_ARGUMENTS
CURRENT_CLEAN_ARGUMENTS=()
_strip_flags() {
  CURRENT_CLEAN_ARGUMENTS=()
  for argument in "$@"; do
    if [[ "$argument" =~ ^- ]]; then
      continue
    fi
    CURRENT_CLEAN_ARGUMENTS+=("$argument")
  done
}

# Usage: _extract_flag_value <all_arguments> <flag_name>
_extract_flag_value() {
  echo "$1" | grep -Eo "$2\=\w+" | grep -Eo '[^ \=]+$'
}

# Usage: _check_contains_flag <all_arguments> <flag_long_name> <flag_shorthand>
# Example: _check_contains_flag "$*" 'help' 'h'
_check_contains_flag() {
  if [[ "$1" =~ --$2 ]] || [[ "$1" =~ -$3 ]]; then
    echo 'true'
  fi
}

_escape_backslashes() {
  echo "$1" | sed 's/\//\\\//g'
}

_random_string() {
  local output
  [ -z "$1" ] && echo "Usage: _random_string <character_count>" && return 1
  output="$(openssl rand -base64 "$1" | grep -Eo "[a-zA-Z]{$1}" | head -1 | tr '[:upper:]' '[:lower:]')"
  
  if [ -z "$output" ]; then
    _random_string "$1"
    return 0
  fi

  echo "$output"
}