REPOSITORIES_DIRECTORY="$HOME/Desktop/repos"

function rpse() {
  [ -z "$1" ] && echo "$REPOSITORIES_DIRECTORY" || echo "$REPOSITORIES_DIRECTORY/$1"
}

function rps() {
  cd "$(rpse $@)"
}

complete -W "$(ls "$REPOSITORIES_DIRECTORY")" rpse
complete -W "$(ls "$REPOSITORIES_DIRECTORY")" rps
