#!/bin/bash

which d &> /dev/null && unset -f d

d() {
  local output exit_code extra_output

  output="$(cd-frecency $*)"
  exit_code=$?

  if [ $exit_code -gt 0 ]; then
    echo $output
    return $exit_code
  fi

  extra_output="$(echo "$output" | sed '$d')"

  if [ -n "$extra_output" ]; then
    echo "$extra_output"
  fi

  cd "$(echo "$output" | tail -1)"
}

_get_d_autocomplete() {
  cat "$(cd-frecency -p)" | grep -Eo '^.+\:' | grep -Eo '[^:]+' | sed "s/$(echo "$HOME" | sed 's/\//\\\//g')//" | grep -Eo '[^/]+' | awk '{print tolower($0)}'
}

complete -F _get_d_autocomplete d
