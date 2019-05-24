function find_closest_npm_package {
  if [ -f 'package.json' ]; then
    echo 'package.json'
    return
  fi
  current_relative_path=''
  while [ ! -f "package.json" ]; do
    if [[ "$(pwd)" == '/' ]]; then
      return
    fi
    cd ../
    current_relative_path="$current_relative_path../"
  done
  echo "$(echo $current_relative_path)package.json"
}

function get_npm_package_scripts_autocomplete {
  closest_package_path="$(find_closest_npm_package)"
  if [ -z "$closest_package_path" ]; then
    return
  fi
  COMPREPLY=($(jq '.scripts | keys | join(" ")' $closest_package_path | tr -d '"'))
}

function yre {
  closest_package_path="$(find_closest_npm_package)"
  if [ -z "$closest_package_path" ]; then
    echo 'package.json not found.'
    return
  fi
  if [ -z "$1" ]; then
    jq ".scripts" $closest_package_path
  else
    jq ".scripts[\"$1\"]" $closest_package_path
  fi
}

function yr {
  yarn run $@
}

alias yt="yarn test"

complete -F get_npm_package_scripts_autocomplete yre
complete -F get_npm_package_scripts_autocomplete yr
