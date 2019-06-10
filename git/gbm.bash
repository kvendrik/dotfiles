#!/bin/bash

__gbm_folder="$DOTFILES_DIRECTORY/.gbm-bookmarks"

function __gbm_help() {
  cat << EndOfMessage
Git Project Bookmarks
An easy way to store links related to a (Git) project.

Why?
As a developer, my homebase for a project is often its Git repository. Things that belong to the project however
often go further than just its repository, think things like Trello boards and Invision projects. I wanted a quick
way to access those within the context of the project, hence this CLI which lets you bookmark URLs that are relevant
to the project and you need quick access to.

Getting started
Within your project set related links using 'gbm edit' (opens up a file you can edit. Use a name_of_bookmark: bookmark_url
format, every bookmark should be on a new line) and display them using 'gbm'. Use 'gbm name_of_bookmark' to directly open
one in your browser.

Usage: gbm [edit|path|help|clean|nuke|<bookmark_name>]
EndOfMessage
}

function __gbm_repository_id() {
  __git_get_remote_url | grep -oE "[^\/\:]+\/[^\.]+"
}

function __gbm_repository_file_path() {
  if ! __git_is_repository; then
    return 1
  fi

  local repository_file_name repository_file_path
  repository_file_name="$(__gbm_repository_id | tr / '-')"
  repository_file_path="$__gbm_folder/$repository_file_name.txt"

  echo "$repository_file_path"
}

function __gbm_autocomplete() {
  if ! __git_is_repository; then
    return 1
  fi

  local repository_file_path
  repository_file_path="$(__gbm_repository_file_path)"

  if [ ! -f "$repository_file_path" ]; then
    return 1
  fi

  # shellcheck disable=SC2207
  COMPREPLY=($(grep -oE "^[^\:]+" "$repository_file_path" | tr '\n' ' '))
}

function gbm() {
  local cmd
  cmd="$1"

  if [[ "$cmd" == 'help' ]]; then
    __gbm_help
    return
  fi

  if [[ "$cmd" == 'nuke' ]]; then
    echo -n "This will remove all bookmarks for all repositories by removing $__gbm_folder. Continue? [y/N] "

    local do_clean
    read -r do_clean

    if [ "$do_clean" != "y" ]; then
      echo 'Cancelled.'
      return
    fi

    rm -rf "$__gbm_folder"
    return
  fi

  if ! __git_is_repository; then
    echo 'Not a git repository.'
    return 1
  fi

  local repository_file_path repository_id no_bookmarks_message
  repository_id="$(__gbm_repository_id)"
  repository_file_path="$(__gbm_repository_file_path)"
  no_bookmarks_message="No bookmarks for $repository_id. Run 'gbm edit' to create them. Run 'gbm help' for help."

  if [[ "$cmd" == 'edit' ]]; then
    mkdir -p "$__gbm_folder"
    vim "$repository_file_path"
    if [ -z "$(cat "$repository_file_path")" ]; then
      rm "$repository_file_path"
    fi
    return
  fi

  if [ ! -f "$repository_file_path" ]; then
    echo "$no_bookmarks_message"
    return
  fi

  if [[ "$cmd" == 'path' ]]; then
    echo "$repository_file_path"
    return
  fi

  if [[ "$cmd" == 'clean' ]]; then
    echo -n "This will remove all bookmarks for $repository_id by removing $repository_file_path. Continue? [y/N] "

    local do_clean
    read -r do_clean

    if [ "$do_clean" != "y" ]; then
      echo 'Cancelled.'
      return
    fi

    rm "$repository_file_path"
    return
  fi

  if [ -n "$cmd" ]; then
    local url
    url="$(grep -oE "$cmd\: (.+)$" "$repository_file_path" | cut -d ' ' -f2)"
    if [ -z "$url" ]; then
      echo "Bookmark '$cmd' not found. Run 'gbm help' for help."
      return 1
    fi
    open "$url"
    return
  fi

  echo -e "Bookmarks for $repository_id:\n"
  cat "$repository_file_path"
}

complete -F __gbm_autocomplete gbm
