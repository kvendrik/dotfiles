#!/bin/bash

if [ -z "$REPOSITORIES_DIRECTORY" ]; then
  echo "Warning: $REPOSITORIES_DIRECTORY directory is not set. Setting it to $HOME."
  REPOSITORIES_DIRECTORY="$HOME"
fi

rpse() {
  [ -z "$1" ] && echo "$REPOSITORIES_DIRECTORY" || echo "$REPOSITORIES_DIRECTORY/$1"
}

rps() {
  local folder_path repository_name
  repo_name="$1"
  folder_path="$(rpse "$repo_name")"

  if ! cd "$folder_path"; then
    if which cl &> /dev/null; then
      echo -n "\n'$repo_name' not found. Would you like to clone it? [Y/n] "

      local do_clone
      read -r do_clone

      if [[ "$do_clone" != "n" ]]; then
        cl "$repo_name"
        return
      fi
    fi
    return 1
  fi

  if [ -n "$2" ]; then
    git checkout "$2"
  fi
}

__rps_autocomplete_insert() {
  ls "$REPOSITORIES_DIRECTORY"
}

__rps_autocomplete() {
  complete -F __rps_autocomplete_insert "$1"
}

alias r='rps'

__rps_autocomplete rpse
__rps_autocomplete rps
