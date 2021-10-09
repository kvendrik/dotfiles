#!/bin/bash

# Change working directory to the top-most Finder window location
# Source: https://github.com/mathiasbynens/dotfiles/blob/master/.functions#L8
alias cdf='cd $(osascript -e "tell app \"Finder\" to POSIX path of (insertion location as alias)")'
alias dt="cd ~/Desktop"

co() {
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

o() {
  open -a Finder "$1"
}

rc() {
  local option
  option="$(echo "dotfiles\n.zshrc\n.rc-extra\n.rc-config" | fzf)"

  if [ -n "$(echo ".zshrc .rc-config .rc-extra" | grep "$option")" ]; then
    code "$HOME/$option"
    return
  fi

  cd "$HOME/$option"
}

mcd() {
  mkdir "$1" && cd "$_" || return
}

rn() {
  local new_name
  new_name="$1"

  if [ -z "$new_name" ]; then
    echo 'Rename the current directory.\nUsage: rn <new_name>'
    return
  fi

  local old_name
  old_name="$(basename $(pwd))"

  cd ../ && mv "$old_name" "$new_name" && cd "$new_name"
}

new() {
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
