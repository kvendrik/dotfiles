#!/bin/bash
# shellcheck source=./tests/_utilities.bash

dotfiles_root=$(cd "$(dirname "$(dirname "$0")")" && pwd)

get_all_scripts() {
  local exec_string
  exec_string="$1"
  if [ -n "$exec_string" ]; then
    find "$dotfiles_root" -name "*.bash" -exec bash -c "$exec_string" \;
    find "$dotfiles_root" -type f -not -path "$dotfiles_root/.git/*" ! -name '*.*' -exec bash -c "$exec_string" \;
  else
    find "$dotfiles_root" -name "*.bash"
    find "$dotfiles_root" -type f -not -path "$dotfiles_root/.git/*" ! -name '*.*'
  fi
}
