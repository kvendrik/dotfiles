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
  echo "$1" | grep -Eo "$2\=\w+" | grep -Eo '[^ \=]+$'
}

# Usage: __check_contains_flag <all_arguments> <flag_long_name> <flag_shorthand>
# Example: __check_contains_flag "$*" 'help' 'h'
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

# Usage: __capture_regex [-g|--global] [-r|--recursive] <string> <pattern> <for_each_exec>
# {} in the command is replaced with the current value
# Example: __capture_regex --global 'repo1: hi, repo2: hello' '([^\,]+)' echo {}
# Example: __capture_regex --recursive "hello: 21, ok: 2" ': ([0-9])' echo {}
function __capture_regex() {
  setopt local_options BASH_REMATCH
  local results command_string full_command_string help_message capture_string pattern

  __strip_flags $*
  capture_string="${CURRENT_CLEAN_ARGUMENTS[1]}"
  pattern="${CURRENT_CLEAN_ARGUMENTS[2]}"
  command_string="${CURRENT_CLEAN_ARGUMENTS[@]:2}"

  if [ -z "$capture_string" ] || [ -z "$pattern" ] || [ -z "$command_string" ]; then
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'recursive' 'r')" ]; then
    __capture_regex -g "$capture_string" "$pattern" "__capture_regex '{}' '$pattern' '$command_string'"
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'global' 'g')" ]; then
    while IFS= read -r line; do
      full_command_string="$(echo $command_string | sed "s/{}/$line/")"
      eval $full_command_string
    done < <(echo "$capture_string" | grep -Eo "$pattern")
    return
  fi

  if [[ "$capture_string" =~ $pattern ]]; then
    for result in ${BASH_REMATCH[@]:1}; do
      full_command_string="$(echo $command_string | sed "s/{}/$result/")"
      eval $full_command_string
    done
  fi
}
