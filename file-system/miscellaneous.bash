#!/bin/bash

alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"

# Change working directory to the top-most Finder window location
# Source: https://github.com/mathiasbynens/dotfiles/blob/master/.functions#L8
alias cdf='cd $(osascript -e "tell app \"Finder\" to POSIX path of (insertion location as alias)")'
alias dt="cd ~/Desktop"

function co() {
  local open_path other_args
  open_path="$1"
  other_args=("${@:2}")

  if [ -z "$open_path" ]; then
    code . "${other_args[@]}"
    return
  fi

  if [ -d "$open_path" ] || [ -f "$open_path" ]; then
    code "$open_path" "${other_args[@]}"
    return
  fi

  local repository_path
  repository_path="$REPOSITORIES_DIRECTORY/$1"

  if [ -d "$repository_path" ]; then
    code "$repository_path" "${other_args[@]}"
    return
  fi

  code "$open_path" "${other_args[@]}"
}

__rps_autocomplete co

function o() {
  open -a Finder "$1"
}

function mcd() {
  mkdir "$1" && cd "$_" || return
}
