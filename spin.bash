#!/bin/bash

SPIN_CURRENT_INSTANCE=""

s() {
  local cmd instance_id do_destroy
  cmd="$1"

  [ -z "$cmd" ] && echo 'Usage: s <up|down>' && return 1

  if [[ "$cmd" == "up" ]]; then
    ([ -z "$2" ] || [ -z "$3" ]) && echo 'Usage: s up <repo> <name>' && return 1
    spin up "$2" --name="$3" && spin open && spin code && spin ssh
    return 0
  fi

  if [[ "$cmd" == "down" ]]; then
    for instance_id in `spin list | grep -Eo "^[^ ]+" | tail -n +2`; do
      printf "%s" "Destroy $instance_id? [y/N] "
      read -r do_destroy
      [[ "$do_destroy" != 'y' ]] && continue
      spin destroy "$instance_id"
    done
    spin list
    return 0
  fi

  [[ "$cmd" == "ssh" ]] && spin ssh
}
