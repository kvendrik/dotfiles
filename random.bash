#!/bin/bash

alias c=clear

# Reload the shell (i.e. invoke as a login shell)
# Source: https://github.com/mathiasbynens/dotfiles/blob/5368015b53467949c36f1e386582ac066b0d0ae6/.aliases#L148
alias reload='exec ${SHELL} -l'

alias config-backups='$DOTFILES_DIRECTORY/bootstrap/config-backups'

function show() {
  [ -z "$1" ] && echo 'Show definition for an alias or method. Usage: show <alias_or_method_name>' && return
  alias "$1"
  declare -f "$1"
}
