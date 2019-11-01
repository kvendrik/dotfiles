#!/bin/bash

if [ ! -f "$DOTFILES_DIRECTORY/.local_commands" ]; then
  touch "$DOTFILES_DIRECTORY/.local_commands"
fi

function lc() {
  local folder_name command_name second_arg storage_path found_command entry_path

  # shellcheck disable=SC2086,SC2048
  __strip_flags $*

  folder_name="$(basename "$(pwd)")"
  command_name="${CURRENT_CLEAN_ARGUMENTS[1]}"
  second_arg=("${CURRENT_CLEAN_ARGUMENTS[@]:1}")
  storage_path="$DOTFILES_DIRECTORY/.local_commands"

  if [[ "$command_name" =~ .+\/.+ ]]; then
    entry_path="$command_name"
  else
    entry_path="$folder_name/$command_name"
  fi

  found_command="$(grep -Eo "$entry_path\: .+$" "$storage_path" | grep -Eo "\: .+" | grep -Eo "[^:]+$")"

  if [ -n "$(__check_contains_flag "$*" 'path' 'p')" ]; then
    echo "$storage_path"
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'list' 'l')" ]; then
    cat "$storage_path"
    return
  fi

  if [ -z "$command_name" ]; then
    echo "Local Commands
Usage: lc <command> [<...shell_string>|<additional_arguments>]

Looks up commands from $storage_path and executes them.

Entries in $storage_path have a basename/command_name format. Example file:
v8/build: tools/dev/gm.py x64.release
v8/test: out/x64.release/d8

Commands
command                  the command to execute
shell_string             command to add with 'command' as it's alias
additional_arguments     arguments to add to the command

Flags
--path|-p                path to the storage file
--list|-l                list the commands
--remove|-r              remove the given command
--add|-a                 add the given shell string under the given name"
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'remove' 'r')" ]; then
    local entry entries new_entries
    entries="$(cat "$storage_path")"
    entry="$(echo "$entries" | grep -Eo "$entry_path\:(.+)")"
    if [ -z "$entry" ]; then
      echo "No entry found that matches $entry_path. Run 'lc --list' to learn more."
      return 1
    fi
    new_entries="$(echo "${entries//entry/""}" | grep .)"
    # TODO: fix removal
    echo "$new_entries" > "$storage_path"
    return
  fi

  if [ -n "${second_arg[*]}" ] && [ -n "$(__check_contains_flag "$*" 'add' 'a')" ]; then
    if [ -n "$found_command" ]; then
      echo "$entry_path is already defined. Run 'lc --list' to learn more."
      return 1
    fi
    echo "$entry_path: ${second_arg[*]}" >> "$storage_path"
    return
  fi

  if [ -z "$found_command" ]; then
    echo "Command $entry_path not found."
    return 1
  fi

  eval "$found_command ${second_arg[*]}"
}

function __get_lc_autocomplete {
  local storage_path folder_name
  folder_name="$(basename "$(pwd)")"
  storage_path="$DOTFILES_DIRECTORY/.local_commands"
  grep -Eo '[^\:]+\:' | grep -Eo '^[^\:]+' < "$storage_path"
  grep -Eo "$folder_name/[^\:]+\:" | grep -Eo '^[^\:]+' | sed s/"$folder_name\/"//g < "$storage_path"
}

complete -F __get_lc_autocomplete lc
