#!/bin/bash

# utilities for custom zsh-users/zsh-autosuggestions results

ZSH_AUTOSUGGEST_STRATEGY=(history custom)

__zsh_autosuggestion_custom_suggestions=''

_zsh_autosuggest_strategy_custom() {
  local current_suggestion
  while read -r current_suggestion
  do
    [ -z "$current_suggestion" ] && continue
    [[ "$current_suggestion" == "$1"* ]] && typeset -g suggestion="$current_suggestion"
  done < <(echo "$__zsh_autosuggestion_custom_suggestions")
}

__add_custom_zsh_autosuggestion() {
  __zsh_autosuggestion_custom_suggestions+="$1\n"
}
