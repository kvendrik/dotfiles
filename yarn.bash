#!/bin/bash

_find_closest_npm_package() {
  if [ -f 'package.json' ]; then
    echo 'package.json'
    return
  fi
  current_relative_path=''
  while [ ! -f "package.json" ]; do
    if [[ "$(pwd)" == '/' ]]; then
      return
    fi
    cd ../ || return
    current_relative_path="$current_relative_path../"
  done
  echo "$current_relative_path"package.json
}

_package_lookup() {
  closest_package_path="$(_find_closest_npm_package)"
  if [ -z "$closest_package_path" ]; then
    return
  fi
  # shellcheck disable=SC2207
  COMPREPLY=($(jq "$1 | keys | join(\" \")" "$closest_package_path" | tr -d '"'))
}

_get_npm_package_scripts_autocomplete() {
  _package_lookup '.scripts'
}

_get_package_dependencies() {
  _package_lookup '.dependencies, .devDependencies'
}

yre() {
  closest_package_path="$(_find_closest_npm_package)"
  if [ -z "$closest_package_path" ]; then
    echo 'package.json not found.'
    return
  fi
  if [ -z "$1" ]; then
    jq ".scripts" "$closest_package_path"
  else
    jq ".scripts[\"$1\"]" "$closest_package_path"
  fi
}

yr() {
  # shellcheck disable=SC2068
  yarn run $@
}

complete -F _get_npm_package_scripts_autocomplete yr

yu() {
  # shellcheck disable=SC2068
  yarn remove $@
}

complete -F _get_package_dependencies yu

yua() {
  yarn remove "$1" && yarn add "$1"
}

complete -F _get_package_dependencies yua

alias yt="yarn test"
alias ya="yarn add"
