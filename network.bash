#!/bin/bash

server() {
  local port
  port="${1:-3000}"
  open "http://localhost:$port"
  python -m SimpleHTTPServer "$port"
}

data_url() {
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

ntp() {
  if [ "$1" != "" ]; then
    netstat -vanp tcp | grep "$1"
  else
    netstat -vanp tcp
  fi
}

kill_port() {
  if [ -z "$1" ]; then
    echo "Usage: kill_port <port_number>"
    return
  fi
  lsof -i "tcp:$1" | awk 'NR!=1 {print $2}' | xargs kill
}
