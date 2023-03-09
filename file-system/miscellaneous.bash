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

_rps_autocomplete co

o() {
  open -a Finder "$1"
}

rc() {
  cd "$HOME/dotfiles"
  code "$HOME/dotfiles"
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

scaffold() {
  export SCAFFOLD_RUN="1"  
  scaffold_project $@ && [ -n "$1" ] && [ -n "$2" ] && [ "$1" != "nvm" ] && cd "$HOME/Desktop/$(ls -t "$HOME/Desktop" | head -1)"
  unset SCAFFOLD_RUN
}
