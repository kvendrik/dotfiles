#!/bin/bash

function __gbm_help() {
  cat << EndOfMessage
Git Project Bookmarks

An easy way to manage links related to a (Git) project. Within the project set related links using 
'gbm name_of_bookmark http://your/url.com' and open them using 'gbm name_of_bookmark'.

Why?
As a developer, my homebase for a project is often its Git repository. Things that belong to the project however
often go further than just its repository, think things like Trello boards and Invision projects. I wanted a quick
way to access those within the context of the project, hence this CLI which lets you bookmark URLs that are relevant 
to the project and you need quick access to.

Usage: gbm [<bookmark_name>|help|path|rm|clean] [<bookmark_value>]
EndOfMessage
}

function __gbm_repository_id() {
  git_get_remote_url | grep -oE "[^\/\:]+\/[^\.]+"
}

function __gbm_repository_folder_path() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    return
  fi

  local repository_folder_name repository_folder_path
  repository_folder_name="$(__gbm_repository_id | tr / '-')"
  repository_folder_path="$DOTFILES_DIRECTORY/.gbm-bookmarks/$repository_folder_name"

  echo "$repository_folder_path"
}

function __gbm_autocomplete() {  
  local repository_folder_path
  repository_folder_path="$(__gbm_repository_folder_path)"

  if [ -z "$repository_folder_path" ]; then
    return
  fi

  if [ ! -d "$repository_folder_path" ]; then
    return
  fi

  find "$repository_folder_path/" -name "*" -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' -maxdepth 1 | while read -r file_name; do
    if [ -z "$file_name" ]; then
      continue
    fi
    COMPREPLY+=("$file_name")
  done
}

function gbm() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo 'Not a git repository.'
    return
  fi

  local bookmark_name bookmark_value bookmark_file repository_folder_path

  if [[ "$1" == "help" ]]; then
    __gbm_help
    return
  fi

  bookmark_name="$1"
  bookmark_value="$2"

  repository_id="$(__gbm_repository_id)"
  repository_folder_path="$(__gbm_repository_folder_path)"

  if [[ "$1" == "path" ]]; then
    echo "$repository_folder_path"
    return
  fi

  if [[ "$1" == "clean" ]]; then
    if [ ! -d "$repository_folder_path" ]; then
      echo "No bookmarks for $repository_id have been set."
      return
    fi

    echo -n "This will remove all bookmarks for $repository_id by removing $repository_folder_path. Continue? [y/N] "

    local do_clean
    read -r do_clean

    if [ "$do_clean" != "y" ]; then
      echo 'Cancelled.'
      return
    fi

    rm -rf "$repository_folder_path"
    return
  fi

  if [[ "$bookmark_name" == "rm" ]]; then
    if [ -n "$bookmark_value" ]; then
      rm "$repository_folder_path/$bookmark_value.txt"
    else
      echo 'Usage: gbm rm [<bookmark_name>]'
    fi
  fi

  if [ ! -d "$repository_folder_path" ]; then
    if [ -z "$bookmark_value" ]; then
      echo "No bookmarks for $repository_id have been set."
      return
    else
      mkdir -p "$repository_folder_path"
    fi
  else
    if [ -z "$bookmark_name" ]; then
      echo "Bookmarks for $repository_id:"
      find "$repository_folder_path/" -name "*" -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' -maxdepth 1 | while read -r file_name; do
        if [ -z "$file_name" ]; then
          continue
        fi
        echo "$file_name $(cat "$repository_folder_path"/"$file_name".txt)"
      done
      return
    fi
  fi

  bookmark_file="$repository_folder_path/$bookmark_name.txt"

  if [ ! -f "$bookmark_file" ]; then
    if [ -z "$bookmark_value" ]; then
      echo "Bookmark $bookmark_name does not exist for $repository_id."
      return
    fi
  fi

  if [ -z "$bookmark_value" ]; then
    open "$(cat "$bookmark_file")"
  else
    echo "$bookmark_value" > "$bookmark_file"
  fi
}

complete -F __gbm_autocomplete gbm
