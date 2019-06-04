#!/bin/bash

__note_folder="$DOTFILES_DIRECTORY/.notes"

# Simular to ls but strips the file extensions
# Usage: __list_directory_as_items <path> <function_for_each_file_name>
# Example: __list_directory_as_items ~/Desktop 'echo'
function __list_directory_as_items() {
  if [ ! -d "$1" ]; then
    return
  fi
  find "$1" -name "*" -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' -maxdepth 1 | while read -r file_name; do
    if [ -z "$file_name" ]; then
      continue
    fi
    $2 "$file_name"
  done
}

function __add_to_compreply() {
  COMPREPLY+=("$1")
}

function note() {
  local help_message cmd item_name storage_folder arguments
  #shellcheck disable=SC2162
  read -d '' help_message << EOF
Simple note taking system for quick note taking while working that saves notes to a Github Gist.

Usage: note [<note_name>|rm|list|help|update|path|open] [--gist-folder=<folder_path>]

Commands and arguments:
  none           Prints help message. If no Gist has been configured it will walk you 
                 through setup.
  <note_name>    Will show the given note name or all you to create it if it doesn't exist.
                 Second argument will either be added to the note (if the note exists) or it will 
                 be the value for the newly created note: 'note "name of note" "note_value"'.
  edit           Allows you to edit the given note e.g. 'note edit name_of_note'.
  rm             Will delete the given file name.
  list           Will show a list of files.
  help           Prints this help message.
  open           Will open the Gist in a browser.
  update         Will pull from the remote Gist.
  path           Will print the path to the Gist folder. Remove folder
                 to delete all saved notes, this won't delet remote.
  --gist-folder  Can be used to set a custom storage folder. Especially
                 handy if you'd like to set up different commands
                 that utilize this CLI to save different categories of notes.
                 e.g. alias til="note --gist-folder='~/.til'"

Troubleshooting:
Running into trouble? You can reset your setup by removing your local copy
of you notes (run 'note path' to view the path).
EOF

  arguments=()
  storage_folder="$__note_folder"

  for argument in "$@"; do
    if echo "$argument" | grep -Eoq '\-\-gist-folder'; then
      storage_folder="$(echo "$argument" | grep -Eo '\=.+' | tr -d '=')"
      if [ -z "$storage_folder" ]; then
        echo "--gist-folder argument '$storage_folder' is invalid."
        return 1
      fi
      continue
    fi

    arguments+=("$argument")
  done

  cmd="${arguments[1]}"
  item_name="${arguments[2]}"

  if [[ "$cmd" == 'help' ]]; then
    echo "$help_message"
    return
  fi

  if [ ! -d "$storage_folder" ]; then
    cat << EndOfMessage
No Github Gist ID found. (Using folder '$storage_folder')

1. Head over to https://gist.github.com/ to create a Gist for your notes.
2. Paste the Gist ID (last part of the Gist URL) below and press enter.
3. Run the command again to save your first note, it will be saved to the Gist.

Run 'note help' for help.
EndOfMessage
    echo -n 'Gist ID: '
    local gist_id
    read -r gist_id
    mkdir -p "$storage_folder"
    git init "$storage_folder"
    git -C "$storage_folder" remote add origin "git@gist.github.com:$gist_id.git"
    git -C "$storage_folder" pull origin master
    return
  fi

  if [[ "$cmd" == 'path' ]]; then
    echo "$storage_folder"
    return
  fi

  if [[ "$cmd" == 'update' ]]; then
    git -C "$storage_folder" pull origin master
    return
  fi

  if [[ "$cmd" == 'open' ]]; then
    local gist_id
    gist_id="$(git -C "$storage_folder" remote -v | grep -Eo -m1 '\:([^\.]+)' | tr -d ':')"
    open "https://gist.github.com/$GITHUB_USERNAME/$gist_id"
    return
  fi

  if [[ "$cmd" == 'edit' ]]; then
    if [ -z "$item_name" ]; then
      echo "Usage: note edit <note_name>. Run 'note list' to see all notes."
      return 1
    fi
    if [ ! -f "$storage_folder/$item_name.md" ]; then
      echo "No note called '$item_name' found. Run 'note list' to see all notes."
      return
    fi
    vim "$storage_folder/$2.md"
    git -C "$storage_folder" add --all :/
    git -C "$storage_folder" commit -m "Edited $2"
    git -C "$storage_folder" push origin master
    return
  fi

  if [[ "$cmd" == 'rm' ]]; then
    if [ -z "$item_name" ]; then
      echo "Usage: note rm <note_name>. Run 'note list' to see all notes."
      return 1
    fi
    if [ ! -f "$storage_folder/$item_name.md" ]; then
      echo "No note called '$item_name' found. Run 'note list' to see all notes."
      return
    fi
    rm "$storage_folder/$2.md"
    git -C "$storage_folder" add --all :/
    git -C "$storage_folder" commit -m "Removed $2"
    git -C "$storage_folder" push origin master
    return
  fi

  if [[ "$1" == 'list' ]]; then
    __list_directory_as_items "$storage_folder" 'echo'
    return
  fi

  local file_name item_value
  file_name="$cmd"
  item_value="$item_name"

  if [ -f "$storage_folder/$file_name.md" ]; then
    if [ -z "$item_value" ]; then
      cat "$storage_folder/$file_name.md"
      return
    fi
    echo "$item_value" >> "$storage_folder/$file_name.md"
    git -C "$storage_folder" add --all :/
    git -C "$storage_folder" commit -m "Changed $full_file_name"
    git -C "$storage_folder" push origin master
    return
  fi

  local full_file_name
  file_name="$(echo "$cmd" | tr ' ' '-')"

  if [ -z "$file_name" ]; then
    echo "$help_message"
    return
  fi

  full_file_name="$file_name.md"

  if [ -z "$item_value" ]; then
    vim "$storage_folder/$full_file_name"
  else
    echo "$item_value" > "$storage_folder/$full_file_name"
  fi

  git -C "$storage_folder" add "$full_file_name"
  git -C "$storage_folder" commit -m "Added $full_file_name"
  git -C "$storage_folder" push origin master
}

function __note_autocomplete() {
  __list_directory_as_items "$__note_folder" __add_to_compreply
}

complete -F __note_autocomplete note
