#!/bin/bash

alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"

# Change working directory to the top-most Finder window location
# Source: https://github.com/mathiasbynens/dotfiles/blob/master/.functions#L8
alias cdf='cd $(osascript -e "tell app \"Finder\" to POSIX path of (insertion location as alias)")'

function co() {
  code "${@:-.}"
}

function o() {
  open -a Finder "$1"
}

function mcd() {
  mkdir "$1" && cd "$_" || return
}
