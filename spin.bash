#!/bin/bash

s() {
  local cmd instance_id do_destroy
  cmd="$1"

  [ -z "$cmd" ] && echo 'Usage: s <up|clean|ssh>' && return 1

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

  [[ "$cmd" == "ssh" ]] || [[ "$cmd" == "s" ]] && spin ssh "$2"
  [[ "$cmd" == "code" ]] || [[ "$cmd" == "c" ]] && spin code "$2"
}
