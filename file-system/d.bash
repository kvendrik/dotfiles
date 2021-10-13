#!/bin/bash

which d &> /dev/null && unset -f d

d() {
  local output
  output="$(cd-frecency $*)"

  if [ $? -eq 1 ]; then
    echo $output
    return $?
  fi

  cd $output
}
