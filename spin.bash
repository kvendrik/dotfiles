#!/bin/bash

s() {
  local cmd instance_id do_destroy
  cmd="$1"

  [ -z "$cmd" ] && echo 'Usage: s <up|clean|ssh|gauth>' && return 1

  if [[ "$cmd" == "up" ]] || [[ "$cmd" == "u" ]]; then
    ([ -z "$2" ] || [ -z "$3" ]) && echo 'Usage: s up <repo> <name>' && return 1
    spin up "$2" --name="$3"
    return 0
  fi

  if [[ "$cmd" == "clean" ]] || [[ "$cmd" == "cl" ]]; then
    spin list

    printf "%s" "Destroy all instances? [y/N] "
    read -r do_destroy
    [[ "$do_destroy" != 'y' ]] && return 0

    for instance_id in `spin list | grep -Eo "^[^ ]+" | tail -n +2`; do
      echo ">>> Destroying $instance_id"
      spin destroy "$instance_id"
    done

    echo "Done."

    spin list
    return 0
  fi

  if [[ "$cmd" == "s" ]]; then
    spin ssh "$2"
    return 0
  fi

  if [[ "$cmd" == "c" ]]; then
    spin code "$2"
    return 0
  fi

  if [[ "$cmd" == "l" ]]; then
    spin list
    return 0
  fi

  if [[ "$cmd" == "o" ]]; then
    spin open "$2"
    return 0
  fi

  if [[ "$cmd" == "gauth" ]]; then
    [ -n "$SPIN" ] && echo "Run this locally, not on a Spin instance" && return 1
    [ -z "$2" ] && echo "Usage: s gauth <instance_id>" && return 1
    spin gauth 300 --full "$2"
    return 0
  fi

  spin $*
}
