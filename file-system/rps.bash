REPOSITORY_DIRECTORY="$HOME/Desktop/repos"

function rps() {
  [ -z "$1" ] && cd "$REPOSITORY_DIRECTORY" || cd "$REPOSITORY_DIRECTORY/$1"
}

complete -W "$(ls "$REPOSITORY_DIRECTORY")" rps
