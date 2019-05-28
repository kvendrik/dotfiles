#!/bin/bash

function ntp() {
  if [ "$1" != "" ]; then
    netstat -vanp tcp | grep "$1"
  else
    netstat -vanp tcp
  fi
}

function kill_port() {
  if [[ -z "$1" ]]; then
    echo 'Usage: kill_port <port>'
    return
  fi

  local match
  match="$(netstat -vanp tcp | grep -Ei "192\.168\.\d+\.\d+\.$1" | grep -Ei '\s\d{2,5}[^\.0-9]')"

  if [[ -z "$match" ]]; then
    echo "No netstat processes found for $1. Try running 'ntp $1' to manually check for processes matching $1."
    return
  fi

  local pid
  pid="$(echo "$match" | grep -Eio -m 1 '\s\d{2,5}[^\.0-9]' | tr -d ' ')"

  printf "Found the following matches:\n%s\n" "$match"

  echo -n "Are you sure you would like to kill pid id $pid? [y/N] "

  # shellcheck disable=SC2034
  read -r local do_kill_pid

  if [ "$do_kill_pid" != "y" ]; then
    return
  fi

  kill "$pid"
}
