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

  cd $output
}
