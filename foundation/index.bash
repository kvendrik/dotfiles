#!/bin/bash
# shellcheck source=./foundation/index.bash

FOUNDATION_DIR=$(dirname "$0")
DOTFILES_DIRECTORY=$(dirname "$FOUNDATION_DIR")

source "$FOUNDATION_DIR/config.bash"
source "$FOUNDATION_DIR/utilities.bash"
source "$FOUNDATION_DIR/rps.bash"

unset FOUNDATION_DIR
