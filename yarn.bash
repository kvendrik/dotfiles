#!/bin/bash

function __find_closest_npm_package {
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

function __package_lookup {
  closest_package_path="$(__find_closest_npm_package)"
  if [ -z "$closest_package_path" ]; then
    return
  fi
  # shellcheck disable=SC2207
  COMPREPLY=($(jq "$1 | keys | join(\" \")" "$closest_package_path" | tr -d '"'))
}

function __get_npm_package_scripts_autocomplete {
  __package_lookup '.scripts'
}

function __get_package_dependencies {
  __package_lookup '.dependencies, .devDependencies'
}

function yre {
  closest_package_path="$(__find_closest_npm_package)"
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

function yr {
  # shellcheck disable=SC2068
  yarn run $@
}

complete -F __get_npm_package_scripts_autocomplete yr

function yu {
  yarn remove $@
}

complete -F __get_package_dependencies yu

function yua {
  yarn remove $1 && yarn add $1
}

complete -F __get_package_dependencies yua

alias yt="yarn test"
alias ya="yarn add"
