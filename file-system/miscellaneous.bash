#!/bin/bash

# shellcheck disable=SC2139
alias o="open -a Finder $(if [[ -z "$1" ]]; then echo '.'; else echo "$1"; fi)"
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"

function mcd() {
  mkdir "$1" && cd "$_" || return
}

# Simular to ls but strips the file extensions
# Usage: __list_directory_as_items <path> <function_for_each_file_name>
# Example: __list_directory_as_items ~/Desktop 'echo'
function __list_directory_as_items() {
  if [ ! -d "$1" ]; then
    return
  fi
  find "$1" -name "*" -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' -maxdepth 1 | while read -r file_name; do
    if [ -z "$file_name" ]; then
      continue
    fi
    $2 "$file_name"
  done
}

function __add_to_compreply() {
  COMPREPLY+=("$1")
}
