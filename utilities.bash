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

  if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo $help_message
    return
  fi

  if [[ "$1" == '-g' ]] || [[ "$1" == '--global' ]]; then
    while IFS= read -r line; do
      full_command_string="$(echo ${@:4} | sed "s/{}/$line/g")"
      eval $full_command_string
    done < <(echo "$2" | grep -Eo "$3")
    return
  fi

  if [[ "$1" =~ $2 ]]; then
    for result in ${BASH_REMATCH[@]:1}; do
      command_string="$(echo ${@:3} | sed "s/{}/$result/g")"
      eval $command_string
    done
  fi
}
