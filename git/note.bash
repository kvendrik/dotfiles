#!/bin/bash

__note_folder="$DOTFILES_DIRECTORY/.notes"

function __note_help() {
cat << EndOfMessage
Note
Simple note taking system for quick note taking while working that saves notes to a Github Gist.

Usage: note [<note_name>|rm|list|help|update|path|open]

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

Troubleshooting:
Running into trouble? You can reset your setup by removing your local copy
of you notes (run 'note path' to view the path).
EndOfMessage
}

function __note_list() {
  find "$__note_folder" -name "*" -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' -maxdepth 1 | while read -r file_name; do
    if [ -z "$file_name" ]; then
      continue
    fi
    $1 "$file_name"
  done
}

function __note_add_compreply() {
  COMPREPLY+=("$1")
}

function __note_autocomplete() {
  __note_list __note_add_compreply
}

function note() {
  if [[ "$1" == 'help' ]]; then
    __note_help
    return
  fi

  if [ ! -d "$__note_folder" ]; then
    cat << EndOfMessage

No Github Gist ID found.

1. Head over to https://gist.github.com/ to create a Gist for your notes.
2. Paste the Gist ID (last part of the Gist URL) below and press enter.
3. Run the command again to save your first note, it will be saved to the Gist.

Run 'note help' for help.
EndOfMessage
    echo -n 'Gist ID: '
    local gist_id
    read -r gist_id
    mkdir -p "$__note_folder"
    git init "$__note_folder"
    git -C "$__note_folder" remote add origin "git@gist.github.com:$gist_id.git"
    git -C "$__note_folder" pull origin master
    return
  fi

  if [[ "$1" == 'path' ]]; then
    echo "$__note_folder"
    return
  fi

  if [[ "$1" == 'update' ]]; then
    git -C "$__note_folder" pull origin master
    return
  fi

  if [[ "$1" == 'open' ]]; then
    local gist_id
    gist_id="$(git -C "$__note_folder" remote -v | grep -Eo -m1 '\:([^\.]+)' | tr -d ':')"
    open "https://gist.github.com/$GITHUB_USERNAME/$gist_id"
    return
  fi

  if [[ "$1" == 'edit' ]]; then
    if [ -z "$2" ]; then
      echo "Usage: note edit <note_name>. Run 'note list' to see all notes."
      return 1
    fi
    if [ ! -f "$__note_folder/$2.md" ]; then
      echo "No note called '$2' found. Run 'note list' to see all notes."
      return
    fi
    vim "$__note_folder/$2.md"
    git -C "$__note_folder" add --all :/
    git -C "$__note_folder" commit -m "Edited $2"
    git -C "$__note_folder" push origin master
    return
  fi

  if [[ "$1" == 'rm' ]]; then
    if [ -z "$2" ]; then
      echo "Usage: note rm <note_name>. Run 'note list' to see all notes."
      return 1
    fi
    if [ ! -f "$__note_folder/$2.md" ]; then
      echo "No note called '$2' found. Run 'note list' to see all notes."
      return
    fi
    rm "$__note_folder/$2.md"
    git -C "$__note_folder" add --all :/
    git -C "$__note_folder" commit -m "Removed $2"
    git -C "$__note_folder" push origin master
    return
  fi

  if [[ "$1" == 'list' ]]; then
    __note_list 'echo'
    return
  fi

  local file_name
  file_name="$1"

  if [ -f "$__note_folder/$file_name.md" ]; then
    if [ -z "$2" ]; then
      cat "$__note_folder/$file_name.md"
      return
    fi
    echo "$2" >> "$__note_folder/$file_name.md"
    git -C "$__note_folder" add "$full_file_name"
    git -C "$__note_folder" commit -m "Added $full_file_name"
    git -C "$__note_folder" push origin master
    return
  fi

  local full_file_name
  file_name="$(echo "$1" | tr ' ' '-')"

  if [ -z "$file_name" ]; then
    __note_help
    return
  fi

  full_file_name="$file_name.md"

  if [ -z "$2" ]; then
    vim "$__note_folder/$full_file_name"
  else
    echo "$2" > "$__note_folder/$file_name.md"
  fi

  git -C "$__note_folder" add "$full_file_name"
  git -C "$__note_folder" commit -m "Added $full_file_name"
  git -C "$__note_folder" push origin master
}

complete -F __note_autocomplete note
