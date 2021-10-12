#!/bin/bash

ZSH_AUTOSUGGEST_STRATEGY=(history custom)

__zsh_autosuggestion_custom_suggestions=''

_zsh_autosuggest_strategy_custom() {
  local current_input current_suggestion
  current_input="$1"

  while read -r current_suggestion
  do
    [[ "$current_suggestion" == "$current_input"* ]] && typeset -g suggestion="$current_suggestion"
  done < <(echo "$__zsh_autosuggestion_custom_suggestions")
}

__add_custom_zsh_autosuggestion() {
  __zsh_autosuggestion_custom_suggestions+="$1\n"
}
