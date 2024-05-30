#!/bin/bash

t() {
  local file_path
  file_path="$1"
  [ -z "$file_path" ] && echo "Usage: t <file_path>" && return 1
  pnpm test "$file_path" -- --watch
}

s() {
  local cmd instance_id do_destroy repository_name randomized_instance_name do_create
  cmd="$1"

  [ -z "$cmd" ] && spin ssh && return 0

  if [[ "$cmd" == "--help" ]] || [[ "$cmd" == "-h" ]]; then
    echo 'Usage: s <up|clean|ssh|gauth>. Default: spin ssh'
    return 0
  fi

  if [[ "$cmd" == "up" ]] || [[ "$cmd" == "u" ]]; then
    repository_name="$2"
    instance_id="$3"

    ([ -z "$repository_name" ]) && echo 'Usage: s up <repo> [<name>]' && return 1
    
    if [ -n "$instance_id" ]; then
      spin up "$repository_name" --name="$instance_id"
      return 0
    fi

    randomized_instance_id="$(_random_string 2)"

    if [ -n "$(spin list | grep \"$randomized_instance_id\")" ]; then
      s up "$repository_name"
      return 0
    fi

    printf "%s \033[0;34m%s\033[0m%s" "Create instance with ID" "'$randomized_instance_id'" "? [Y/n] "
    read -r do_create
    [[ "$do_create" == 'n' ]] && return 0

    spin up "$repository_name" --name="$randomized_instance_id"
    
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

  if [[ "$cmd" == "permit" ]]; then
    [ -n "$SPIN" ] && echo "Run this locally, not on a Spin instance" && return 1
    for permit_id in $@; do
      [[ "$permit_id" == "permit" ]] && continue
      echo "> Requesting $permit_id"
      open -a "Google Chrome" "https://clouddo.shopify.io/permits?request=$permit_id"
    done
    return 0
  fi

  if [[ "$cmd" == "db:migrate" ]]; then
    rake db:drop && rake db:create && rake db:migrate
    return 0
  fi

  spin $*
}
