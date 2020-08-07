#!/bin/bash

__D_HISTORY_PATH="$DOTFILES_DIRECTORY/.d_history"

__D_VERBOSE=''
__D_CURRENT_POINTS=0
__D_CURRENT_TIMESTAMPS=''

which d &> /dev/null && unset d

function d() {
  if [ ! -f "$__D_HISTORY_PATH" ]; then
    touch "$__D_HISTORY_PATH"
  fi

  local path_regex

  # shellcheck disable=SC2086,SC2048
  __strip_flags $*
  path_regex="${CURRENT_CLEAN_ARGUMENTS[1]}"

  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ] || [ -z "$path_regex" ]; then
    # shellcheck disable=SC1112,SC2016
    echo 'Usage: d <path> [--verbose|-v] [--help|-h]

Change directories using frecency

Arguments
  path                           the path you’d like to move to. if it doesn’t exist we’ll
                                 use this to search through your history and will determine
                                 where to move to using frecency.

Flags
  --verbose|-v                   prints debug data
  --help|-h                      prints this help message

Example
  1. Build up your history by moving around
     d ~/Desktop
     d ~/your/projects
     d client

  2. Now when you navigate to a path that doesn’t exist we’ll search through your history
     using frecency to determine where to move to. E.g. `d pro` would move you to `~/your/projects`.

  Interested in learning more about how this works? Try running the above with the --verbose flag.

Isn’t this a more basic version of github.com/rupa/z?
  Yes, it was fun to write.'
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'verbose' 'v')" ]; then
    __D_VERBOSE='true'
  else
    __D_VERBOSE=''
  fi

  local entries
  entries="$(cat "$__D_HISTORY_PATH")"

  if cd "$path_regex" &> /dev/null; then
    __d_add_to_history "$entries" "$(pwd)" > "$__D_HISTORY_PATH"
    return
  fi

  local entry_path timestamps points most_points_path most_points_timestamps most_points_count now_timestamp
  most_points_count=0
  now_timestamp="$(date +%s)"

  while IFS= read -r entry; do
    entry_path="$(echo "$entry" | grep -Eo '^[^:]+')"

    if [[ "$entry_path" =~ $path_regex ]]; then
      timestamps="$(echo "$entry" | grep -Eo '[^:]+$')"

      if [ -n "$__D_VERBOSE" ]; then
        printf "match %s\n\n" "$entry_path"
      fi

      if [ ! -d "$entry_path" ]; then
        if [ -n "$__D_VERBOSE" ]; then
          printf "%s doesn't exist anymore, removing...\n---\n" "$entry_path"
        fi
        entries="$(__d_remove_from_history "$entries" "$entry_path")"
        continue
      fi

      __d_get_frecency_points "$timestamps" "$now_timestamp"
      points=$__D_CURRENT_POINTS

      if [ "$__D_CURRENT_POINTS" -eq 0 ]; then
        if [ -n "$__D_VERBOSE" ]; then
          printf "\n%s outdated, removing..." "$entry_path"
        fi
        entries="$(__d_remove_from_history "$entries" "$entry_path")"
      else
        entries="$(__d_replace_timestamps_for_entry "$entries" "$entry_path" "$__D_CURRENT_TIMESTAMPS")"
      fi

      if [ -n "$__D_VERBOSE" ]; then
        printf "\n---\n\n"
      fi

      if ((points > most_points_count)); then
        most_points_count=$points
        most_points_path=$entry_path
        most_points_timestamps="$__D_CURRENT_TIMESTAMPS"
      fi
    fi
  done < <(echo "$entries")

  if [ -n "$most_points_path" ]; then
    if [ -n "$__D_VERBOSE" ]; then
      printf "winning path: '%s'\n" "$most_points_path"
    fi

    if cd "$most_points_path"; then
       __d_replace_timestamps_for_entry "$entries" "$most_points_path" "$most_points_timestamps$now_timestamp," > "$__D_HISTORY_PATH"
      return
    else
      echo "'$path_regex' matched '$most_points_path' but could not cd to it. Unknown error (exit code $?)."
      echo "$entries" > "$__D_HISTORY_PATH"
      return $?
    fi
  fi

  echo "Could not find '$path_regex'."

  if [ -n "$__D_VERBOSE" ]; then
    echo "'cd $path_regex' failed and no history matches for '$path_regex'."
  fi

  echo "$entries" > "$__D_HISTORY_PATH"
  return 1
}

function __d_replace_timestamps_for_entry() {
  local entries clean_entry_path new_timestamps
  entries="$1"
  clean_entry_path="$(__escape_backslashes "$2")"
  new_timestamps="$3"
  echo "$entries" | sed -E "s/($clean_entry_path:).+/\1$new_timestamps/"
}

function __d_add_to_history() {
  local entry_path entries now_unix

  entries="$1"
  entry_path="$2"
  now_unix="$(date +%s)"

  if echo "$entries" | grep -q "$entry_path"; then
    echo "${entries//"$entry_path:"/"$entry_path:$now_unix,"}"
  else
    printf "%s\n%s:%s,\n" "$entries" "$entry_path" "$now_unix"
  fi
}

function __d_remove_from_history() {
  local entries clean_entry_path
  entries="$1"
  clean_entry_path="$(__escape_backslashes "$2")"
  echo "$entries" | sed -E "s/$clean_entry_path:.+//" | grep -Eo '.+'
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
    printf "now: %s\ntimestamps: %s\n\n" "$now_unix" "$timestamps"
  fi

  while IFS= read -r timestamp; do
    if [[ $timestamp > $((now_unix-$((min_ms*5)))) ]]; then
      points=$((points+4))
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' was last 5 min"
      fi
    elif [[ $timestamp > $((now_unix-hour_ms)) ]]; then
      points=$((points+3))
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' was last hour"
      fi
    elif [[ $timestamp > $((now_unix-day_ms)) ]]; then
      points=$((points+2))
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' was last day"
      fi
    elif [[ $timestamp > $((now_unix-$((day_ms*7)))) ]]; then
      points=$((points+1))
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' was last week"
      fi
    else
      new_timestamps="${timestamps//"$timestamp,"/""}"
      if [ -n "$__D_VERBOSE" ]; then
        echo "- '$timestamp' is outdated, removing from string..."
      fi
    fi
  done < <(echo "$timestamp_entries")

  __D_CURRENT_TIMESTAMPS="$new_timestamps"
  __D_CURRENT_POINTS=$points

  if [ -n "$__D_VERBOSE" ]; then
    printf "\npoints: %s" "$points"
  fi
}
