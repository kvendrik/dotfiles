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

complete -W "$(jq '.scripts | keys | join(" ")' package.json | tr -d '"')" yre
complete -W "$(jq '.scripts | keys | join(" ")' package.json | tr -d '"')" yr
