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

function new() {
  local project_name template_name project_path

  __strip_flags $*

  template_name="$(__extract_flag_value "$*" 't')"
  project_name="${CURRENT_CLEAN_ARGUMENTS[1]}"

  if [ -z "$project_name" ]; then
    echo """
Usage: new <project_name> [-t=<template>]

Template options
react    https://create-react-app.dev/docs/adding-typescript/
node     https://github.com/kvendrik/project-template-node-ts
    """
    return 1
  fi

  project_path="$(rpse)/$project_name"

  if [ -n "$template_name" ]; then
    if [[ "$template_name" == "react" ]]; then
      nvm use 14.4.0 && npx create-react-app "$project_path" --template typescript && cd "$project_path"
      return
    elif [[ "$template_name" == "node" ]]; then
      create-app "node-ts" "$(rpse)/$project_name"
      return
    fi
  else
    mcd "$project_path"
    return
  fi
}
