#!/bin/bash

__D_HISTORY_PATH="$DOTFILES_DIRECTORY/.d_history"

if [ ! -f "$__D_HISTORY_PATH" ]; then
  touch "$__D_HISTORY_PATH"
fi

__D_VERBOSE=''
__D_CURRENT_POINTS=0
__D_CURRENT_TIMESTAMPS=''

unalias d
function d() {
  local path_regex verbose help_message

  read -d '' help_message << EOF
Directory Switcher
Usage: d <path_or_search_query>

cd's into a directory that matches the given regex. Uses frecency to determine what
to switch to based on how frequently and how recently you moved into the directory. This
allows for a quicker workflow than 'cd' offers.

Commands
path_or_search_query  regex of the path you'd like to move to

Flags
--clean|-c            cleans your history file from outdated timestamps and entries
--verbose|-v          prints debug data
--help|-h             prints this help message

How it works
When you run 'd some/path' we try to 'cd' you to the given path. If that works
we same the timestamp at which the move occured. For any moves you do after that
we will check if your path regex matches a record in history. If multiple records match
we use how recently the move occured and how frequently it occured to rank the results
and will pick the highest matching path as the one we move you into.

Isn't this (almost) the same as 'z'?
Yes, it was fun to write.
EOF

  __strip_flags $*
  path_regex="${CURRENT_CLEAN_ARGUMENTS[1]}"

  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ] || [ -z "$path_regex" ]; then
    echo $help_message
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'verbose' 'v')" ]; then
    __D_VERBOSE='true'
  else
    __D_VERBOSE=''
  fi

  if [ -n "$(__check_contains_flag "$*" 'clean' 'c')" ]; then
    __d_clean_history
    return
  fi

  local entries entry_path timestamps points matches most_points_path most_points_timestamps most_points_count now_timestamp clean_entry_path

  entries="$(cat $__D_HISTORY_PATH)"
  matches=''
  most_points_count=0
  now_timestamp="$(date +%s)"

  if cd $path_regex &> /dev/null; then
    __d_add_to_history "$(pwd)"
    return
  fi

  while IFS= read -r entry; do
    entry_path="$(echo $entry | grep -Eo '^[^:]+')"

    if [[ "$entry_path" =~ "$path_regex" ]]; then
      timestamps="$(echo $entry | grep -Eo '[^:]+$')"

      if [ -n "$__D_VERBOSE" ]; then
        echo "match $entry_path\n"
      fi

      __d_get_frecency_points $timestamps "$now_timestamp"
      points=$__D_CURRENT_POINTS

      if (( $points > $most_points_count )); then
        most_points_count=$points
        most_points_path=$entry_path
        most_points_timestamps="$__D_CURRENT_TIMESTAMPS"
      fi
    fi
  done < <(echo "$entries")

  if [ -n "$__D_VERBOSE" ]; then
    echo "winning path: '$most_points_path' (if empty it will add)\n"
  fi

  if [ -n "$most_points_path" ]; then
    if cd $most_points_path; then
      echo $entries | sed "s/$most_points_timestamps/$most_points_timestamps$now_timestamp,/" > "$__D_HISTORY_PATH"
      return
    else
      echo $entries | sed "s/$most_points_path:$most_points_timestamps//" > "$__D_HISTORY_PATH"
      echo "'$path_regex' matched '$most_points_path' but path doesn't exist."
      return 1
    fi
  fi

  echo "'cd $path_regex' failed and no history matches for '$path_regex'."
  return 1
}

function __d_add_to_history() {
  local entry_path clean_entry_path entries now_unix

  entry_path="$1"
  clean_entry_path="$(__escape_backslashes $entry_path)"
  now_unix="$(date +%s)"
  entries="$(cat $__D_HISTORY_PATH)"

  if [ -n "$(echo $entries | grep $entry_path)" ]; then
    echo $entries | sed "s/$clean_entry_path:/$clean_entry_path:$now_unix,/" > "$__D_HISTORY_PATH"
  else
    echo "$entries\n$entry_path:$now_unix,\n" > "$__D_HISTORY_PATH"
  fi
}

function __d_clean_history() {
  local entries entry_path timestamps escaped_path escaped_entry now_timestamp
  entries="$(cat $__D_HISTORY_PATH)"
  now_timestamp="$(date +%s)"

  while IFS= read -r entry; do
    if [ -z "$entry" ]; then
      continue
    fi

    entry_path="$(echo $entry | grep -Eo '^[^:]+')"
    timestamps="$(echo $entry | grep -Eo '[^:]+$')"
    escaped_path="$(__escape_backslashes "$entry_path")"
    escaped_entry="$escaped_path:$timestamps"

    __d_get_frecency_points $timestamps "$now_timestamp"

    if [ "$__D_CURRENT_POINTS" -eq 0 ]; then
      # Entry completely outdated, clean up all
      entries="$(echo $entries | sed "s/$escaped_entry//")"
    else
      # Clean up outdated timestamps
      entries="$(echo $entries | sed "s/$escaped_entry/$escaped_path:$__D_CURRENT_TIMESTAMPS/")"
    fi
  done < <(echo "$entries")

  echo $entries | grep -Eo '.+' > "$__D_HISTORY_PATH"
}

# Usage: __d_get_frecency_points <comma_seperated_timestamps_string> <now_unix_timestamp>
function __d_get_frecency_points() {
  local timestamps min_ms hour_ms now_unix points new_timestamps timestamp_entries

  min_ms=60
  hour_ms=3600
  day_ms=86400
  now_unix="$2"
  points=0
  timestamps="$1"
  new_timestamps="$timestamps"
  timestamp_entries="$(echo "$timestamps" | grep -Eo '[^,]+')"

  if [ -n "$__D_VERBOSE" ]; then
    echo "now: $now_unix\ntimestamps: $timestamps\n"
  fi

  while IFS= read -r timestamp; do
    if [[ $timestamp > $(($now_unix-$(($min_ms*5)))) ]]; then
      points=$(($points+4))
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' was last 5 min"
      fi
    elif [[ $timestamp > $(($now_unix-$hour_ms)) ]]; then
      points=$(($points+3))
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' was last hour"
      fi
    elif [[ $timestamp > $(($now_unix-$day_ms)) ]]; then
      points=$(($points+2))
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' was last day"
      fi
    elif [[ $timestamp > $(($now_unix-$(($day_ms*7)))) ]]; then
      points=$(($points+1))
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' was last week"
      fi
    else
      new_timestamps="$(echo $timestamps | sed "s/$timestamp,//")"
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' is outdated, removing from string..."
      fi
    fi
  done < <(echo "$timestamp_entries")

  __D_CURRENT_TIMESTAMPS="$new_timestamps"
  __D_CURRENT_POINTS=$points

  if [ -n "$__D_VERBOSE" ]; then
    echo "\npoints: $points\n---\n"
  fi
}


