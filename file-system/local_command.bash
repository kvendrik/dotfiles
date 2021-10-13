#!/bin/bash

if [ ! -f "$DOTFILES_DIRECTORY/.local_commands" ]; then
  touch "$DOTFILES_DIRECTORY/.local_commands"
fi

lc() {
  local folder_name command_name second_arg storage_path found_command entry_path

  # shellcheck disable=SC2086,SC2048
  _strip_flags $*

  folder_name="$(basename "$(pwd)")"
  command_name="${CURRENT_CLEAN_ARGUMENTS[1]}"
  second_arg=("${CURRENT_CLEAN_ARGUMENTS[@]:1}")
  storage_path="$DOTFILES_DIRECTORY/.local_commands"

  if [[ "$command_name" =~ .+\/.+ ]]; then
    entry_path="$command_name"
  else
    entry_path="$folder_name/$command_name"
  fi

  found_command="$( grep -Eo "$entry_path\: .+$" "$storage_path" | grep -Eo "\: .+" | grep -Eo "\s.+$" | sed 's/ //')"

  if [ -n "$(_check_contains_flag "$*" 'path' 'p')" ]; then
    echo "$storage_path"
    return
  fi

  if [ -n "$(_check_contains_flag "$*" 'list' 'l')" ]; then
    cat "$storage_path"
    return
  fi

  if [ -n "$(_check_contains_flag "$*" 'help' 'h')" ]; then
    echo "Local Commands
Usage: lc [flag] <alias> [<command>]

Allows you to store and execute folder specific commands.

Example
cd my_project
lc --add start 'yarn start'
lc start # executes 'yarn start'
cd ../other_project
lc start # command not found

Commands
alias                    alias for the command
command                  command to execute when the alias get called

Flags
--help|-h                print this help message
--path|-p                path to the storage file
--list|-l                list the commands
--remove|-r              remove the given command
--set|-s                 set the given alias to a new command
--add|-a                 add the given command under the given alias

Commands are stored in $storage_path. Entries have a folder_name/alias format. Example file:
v8/build: tools/dev/gm.py x64.release
v8/test: out/x64.release/d8"
    return
  fi

  if [ -n "$(_check_contains_flag "$*" 'remove' 'r')" ]; then
    local entry entries new_entries
    entries="$(cat "$storage_path")"
    entry="$(echo "$entries" | grep -Eo "$entry_path\:(.+)")"
    if [ -z "$entry" ]; then
      echo "No entry found that matches $entry_path. Run 'lc --list' to learn more."
      return 1
    fi
    new_entries="$(echo "${entries//$entry/""}" | grep .)"
    echo "$new_entries" > "$storage_path"
    return
  fi

  if [ -n "${second_arg[*]}" ] && [ -n "$(_check_contains_flag "$*" 'add' 'a')" ]; then
    if [ -n "$found_command" ]; then
      echo "$entry_path is already defined. Run 'lc --list' to learn more."
      return 1
    fi
    echo "$entry_path: ${second_arg[*]}" >> "$storage_path"
    return
  fi

  if [ -n "${second_arg[*]}" ] && [ -n "$(_check_contains_flag "$*" 'set' 's')" ]; then
    if [ -n "$found_command" ]; then
      lc --remove "$entry_path"
    fi
    lc --add "$entry_path" "${second_arg[*]}"
    return
  fi

  if [ -z "$command_name" ]; then
    local results
    results="$(cat "$storage_path" | grep "$folder_name/")"
    if [ -z "$results" ]; then
      echo "No commands for \`$folder_name\`. Run \`lc --help\` for help."
    else
      echo "$(echo "$results" | grep -Eo '[^\/]+\:.+')"
    fi
    return
  fi

  if [ -z "$found_command" ]; then
    echo "Command $entry_path not found."
    return 1
  fi

  eval "$found_command ${second_arg[*]}"
}

_get_lc_autocomplete() {
  local storage_path folder_name
  folder_name="$(basename "$(pwd)")"
  storage_path="$DOTFILES_DIRECTORY/.local_commands"
  cat "$storage_path" | grep -Eo "^$folder_name\/[^\:]+" | sed s/"$folder_name\/"//g
}

complete -F _get_lc_autocomplete lc
