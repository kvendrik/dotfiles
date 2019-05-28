#!/bin/bash

# shellcheck disable=SC2139
alias o="open -a Finder $(if [[ -z "$1" ]]; then echo '.'; else echo "$1"; fi)"
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"

function mcd() {
  mkdir "$1" && cd "$_" || return
}
