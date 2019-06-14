#!/bin/bash

function server() {
  local port
  port="${1:-3000}"
  open "http://localhost:$port"
  python -m SimpleHTTPServer "$port"
}

function data_url() {
  if [ -z "$1" ]; then
    cat << EndOfMessage
Create a data URL that can be directly used in HTML.
Usage: data_url <path_to_file>
EndOfMessage
    return
  fi
	local mime_type base64
  mime_type=$(file -b --mime-type "$1")
  if [[ "$mime_type" == 'image/svg' ]]; then
    mime_type='image/svg+xml'
  fi
  base64=$(base64 "$1")
	echo "data:$mime_type;base64,$base64";
}

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

  local do_kill_pid
  read -r do_kill_pid

  if [ "$do_kill_pid" != "y" ]; then
    return
  fi

  kill "$pid"
}
