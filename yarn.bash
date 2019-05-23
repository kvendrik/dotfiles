alias yt="yarn test"

function yre {
  if [ ! -f 'package.json' ]; then
    echo './package.json not found.'
    return
  fi
  if [ -z "$1" ]; then
    jq ".scripts" package.json
  else
    jq ".scripts[\"$1\"]" package.json
  fi
}

function yr {
  yarn run $@
}

function get_npm_package_scripts {
  if [ ! -f 'package.json' ]; then
    return
  fi
  COMPREPLY=($(jq '.scripts | keys | join(" ")' package.json | tr -d '"'))
}

complete -F get_npm_package_scripts yre
complete -F get_npm_package_scripts yr
