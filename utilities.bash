#!/bin/bash

# Usage: __strip_flags <...all_arguments>
# echo $CURRENT_CLEAN_ARGUMENTS
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
  echo "$1" | grep -Eo "$2\=\w+" | grep -Eo '[^\s\=]+$'
}

# Usage: __check_contains_flag <all_arguments> <flag_long_name> <flag_shorthand>
function __check_contains_flag() {
  if [[ "$1" =~ --$2 ]] || [[ "$1" =~ -$3 ]]; then
    echo 'true'
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

function __capture_regex() {
  setopt local_options BASH_REMATCH
  local results command_string full_command_string help_message capture_string pattern

  read -d '' help_message << EOF
Usage: __capture_regex [-g|--global] <string> <pattern> <for_each_exec>

Arguments
string: a string to capture in
pattern: a regex pattern, passed as a string
for_each_exec: a command string. {} in the command is replaced with the current value

Example: __capture_regex "repo1: echo hi, repo2: echo hello" '\: ([^\,]+)' echo {}
EOF

  __strip_flags $*
  capture_string="${CURRENT_CLEAN_ARGUMENTS[1]}"
  pattern="${CURRENT_CLEAN_ARGUMENTS[2]}"
  command_string="${CURRENT_CLEAN_ARGUMENTS[@]:2}"

  if [ -z "$capture_string" ] || [ -z "$pattern" ] || [ -z "$command_string" ]; then
    echo $help_message
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'global' 'g')" ]; then
    while IFS= read -r line; do
      full_command_string="$(echo $command_string | sed "s/{}/$line/g")"
      eval $full_command_string
    done < <(echo "$capture_string" | grep -Eo "$pattern")
    return
  fi

  if [[ "$capture_string" =~ $pattern ]]; then
    for result in ${BASH_REMATCH[@]:1}; do
      full_command_string="$(echo $command_string | sed "s/{}/$result/g")"
      eval $full_command_string
    done
  fi
}
