#!/bin/bash

which d &> /dev/null && unset -f d

d() {
  local output exit_code

  output="$(cd-frecency $*)"
  exit_code=$?

  if [ $exit_code -gt 0 ]; then
    echo $output
    return $exit_code
  fi

  if [ -n "$(_check_contains_flag "$*" 'verbose' 'v')" ]; then
    echo "$output"
    cd "$(echo "$output" | tail -1)"
    return
  fi

  cd $output
}
