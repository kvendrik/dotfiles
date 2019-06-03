#!/bin/bash

__til_folder="$DOTFILES_DIRECTORY/.til"

function __til_help() {
cat << EndOfMessage
Usage: til [<name_of_learning>|rm|list|help|update|path|open]

Commands:
  none           Will create a learning with the given name. Name can
                 be written plainly e.g. 'til some new thing'. If no Gist 
                 has been configured it will walk you through setup.
  rm             Will delete the given file name.
  list           Will show a list of files.
  help           Prints this help message.
  open           Will open the Gist in a browser.
  update         Will pull from the remote Gist.
  path           Will print the path to the Gist folder. Remove folder
                 to delete all saved learnings, this won't delet remote.
Troubleshooting:
Running into trouble? You can reset your setup by removing your local copy
of you learnings (run 'til path' to view the path).
EndOfMessage
}

function __til_autocomplete() {
  find "$__til_folder" -name "*" -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' -maxdepth 1 | while read -r file_name; do
    if [ -z "$file_name" ]; then
      continue
    fi
    COMPREPLY+=("$file_name")
  done
}

function til() {
  if [[ "$1" == 'help' ]]; then
    __til_help
    return
  fi

  if [ ! -d "$__til_folder" ]; then
    __til_help
    cat << EndOfMessage

No Github Gist ID found.

1. Head over to https://gist.github.com/ to create a Gist for your learnings.
2. Paste the Gist ID (last part of the Gist URL) below and press enter.
3. Run the command again to save your first learning, it will be saved to the Gist.

EndOfMessage
    echo -n 'Gist ID: '
    local gist_id
    read -r gist_id
    mkdir -p "$__til_folder"
    git init "$__til_folder"
    git -C "$__til_folder" remote add origin "git@gist.github.com:$gist_id.git"
    git -C "$__til_folder" pull origin master
    return
  fi

  if [[ "$1" == 'path' ]]; then
    echo "$__til_folder"
    return
  fi

  if [[ "$1" == 'update' ]]; then
    git -C "$__til_folder" pull origin master
    return
  fi

  if [[ "$1" == 'open' ]]; then
    local gist_id
    gist_id="$(git -C "$__til_folder" remote -v | grep -Eo -m1 '\:([^\.]+)' | tr -d ':')"
    open "https://gist.github.com/$GITHUB_USERNAME/$gist_id"
    return
  fi

  if [[ "$1" == 'rm' ]]; then
    if [ -z "$2" ]; then
      echo "Usage: til rm <file_name>. Run 'til list' to see all files."
      return 1
    fi
    if [ ! -f "$__til_folder/$2" ]; then
      echo "No learning called '$2' found. Run 'til list' to see all learnings."
      return
    fi
    rm "$__til_folder/$2"
    git -C "$__til_folder" add --all :/
    git -C "$__til_folder" commit -m "Removed $2"
    git -C "$__til_folder" push origin master
    return
  fi

  if [[ "$1" == 'list' ]]; then
    find "$__til_folder" -type f -exec basename {} \; -maxdepth 1
    return
  fi

  local file_name
  file_name="$1"

  if [ -f "$__til_folder/$file_name.md" ]; then
    cat "$__til_folder/$file_name.md"
    return
  fi

  local full_file_name
  file_name="$(echo "$@" | tr ' ' '-')"

  if [ -z "$file_name" ]; then
    __til_help
    return
  fi

  full_file_name="$file_name.md"

  vim "$__til_folder/$full_file_name"
  git -C "$__til_folder" add "$full_file_name"
  git -C "$__til_folder" commit -m "Added $full_file_name"
  git -C "$__til_folder" push origin master
}

complete -F __til_autocomplete til
