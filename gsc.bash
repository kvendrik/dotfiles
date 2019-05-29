#!/bin/bash

function gsc_help() {
  echo 'Git Project Shortcuts'
  echo 'Usage: gsc [<name>] [<url>]'
  cat << EndOfMessage
Git Project Shortcuts

An easy way to manage links related to a (Git) project. Within the project set related links using 
'gsc name_of_shortcut http://your/url.com' and open them using 'gsc name_of_shortcut'.

Usage: gsc [<name_of_shortcut>|help|path|rm] [<value_of_shortcut>]
EndOfMessage
}

function gsc() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo 'Not a git repository.'
    return
  fi

  local shortcut_name shortcut_value shortcuts_dir shortcut_file repository_id repository_dir

  if [[ "$1" == "help" ]]; then
    gsc_help
    return
  fi

  shortcuts_dir="$DOTFILES_DIRECTORY/.gsc-shortcuts"

  if [[ "$1" == "path" ]]; then
    echo "$shortcuts_dir"
    return
  fi

  shortcut_name="$1"
  shortcut_value="$2"

  repository_id="$(_get_remote_url | grep -oE "[^\/\:]+\/[^\.]+" | tr / '-')"
  repository_dir="$shortcuts_dir/$repository_id"

  if [[ "$shortcut_name" == "rm" ]]; then
    if [ -n "$shortcut_value" ]; then
      rm "$repository_dir/$shortcut_value.txt"
    fi
    return
  fi

  if [ ! -d "$repository_dir" ]; then
    if [ -z "$shortcut_value" ]; then
      echo "No shortcuts for $repository_id have been set."
      return
    else
      mkdir -p "$repository_dir"
    fi
  else
    if [ -z "$shortcut_name" ]; then
      echo "Shortcuts for $repository_id:"
      find "$repository_dir/" -name "*" -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' -maxdepth 1
      return
    fi
  fi

  shortcut_file="$repository_dir/$shortcut_name.txt"

  if [ ! -f "$shortcut_file" ]; then
    if [ -z "$shortcut_value" ]; then
      echo "Shortcut $shortcut_name does not exist for $repository_id."
      return
    fi
  fi

  if [ -z "$shortcut_value" ]; then
    open "$(cat "$shortcut_file")"
  else
    echo "$shortcut_value" > "$shortcut_file"
  fi
}
