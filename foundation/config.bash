#!/bin/bash

autoload bashcompinit
bashcompinit

DOTFILES_DIRECTORY=$(dirname "$FOUNDATION_DIR")
alias dotfiles="cd $DOTFILES_DIRECTORY"
