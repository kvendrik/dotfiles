#!/bin/bash

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
  local project_name template_name_or_url project_path

  project_name="$1"
  template_name_or_url="$2"

  if [ -z "$project_name" ]; then
    echo """
Usage: new <project_name> <template_name_or_git_clone_uri>

Template options:
react    https://create-react-app.dev/docs/adding-typescript/
node     https://github.com/kvendrik/project-template-node-ts

Will fall back to trying to clone the given value.
    """
    return 1
  fi

  project_path="$(rpse)/$project_name"

  if [ -n "$template_name_or_url" ]; then
    if [[ "$template_name_or_url" == "react" ]]; then
      nvm use 14.4.0 && npx create-react-app "$project_path" --template typescript && cd "$project_path"
      return
    elif [[ "$template_name_or_url" == "node" ]]; then
      create-app "node-ts" "$(rpse)/$project_name"
      return
    else
      cl "$template_name_or_url" "$project_name"
      return
    fi
  else
    mcd "$project_path"
    return
  fi
}

chpwd_functions=(chpwd_check_node)

function __parseVersion() {
  # https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
  printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ');
}

function chpwd_check_node() {
  local node_version
  local required_node_version

  if [ -f "package.json" ]; then
    required_node_version="$(cat package.json | jq '.engines.node' | grep -Eo '\d+')"

    if [ -n "$required_node_version" ]; then
      node_version="$(node -v | grep -Eo '[0-9\.]+')"

      if [ $(__parseVersion $node_version) -lt $(__parseVersion $required_node_version) ]; then
        nvm use 14.4.0
      fi
    fi
  fi
}
