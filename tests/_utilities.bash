#!/bin/bash
# shellcheck source=./tests/_utilities.bash

dotfiles_root=$(dirname "$(dirname "$(realpath "$0")")")

function get_all_scripts() {
  local exec_string
  exec_string="$1"
  if [ -n "$exec_string" ]; then
    find "$dotfiles_root" -name "*.bash" -exec bash -c "$1" \;
    find "$dotfiles_root" -type f -not -path "$dotfiles_root/.git/*" ! -name '*.*' -exec bash -c "$1" \;
  else
    find "$dotfiles_root" -name "*.bash"
    find "$dotfiles_root" -type f -not -path "$dotfiles_root/.git/*" ! -name '*.*'
  fi
}
