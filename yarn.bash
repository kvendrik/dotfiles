alias yt="yarn test"

function yre {
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
  COMPREPLY=($(jq '.scripts | keys | join(" ")' package.json | tr -d '"'))
}

complete -F get_npm_package_scripts yre
complete -F get_npm_package_scripts yr
