#!/bin/bash

# utilities for custom zsh-users/zsh-autosuggestions results

if [ -n "$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" ] && [ -z "$ZSH_AUTOSUGGEST_STRATEGY" ]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history)
fi

__custom-zsh-suggestions() {
  local id

  if [ -z "$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" ]; then
    return 1
  fi

  id="$1"

  eval "_zsh_autosuggest_strategy_$id() {
    typeset -g suggestion='$id'
  }"

  ZSH_AUTOSUGGEST_STRATEGY+=($id)
}

__custom-zsh-autosuggestions "cake"
