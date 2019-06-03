#!/bin/bash
# shellcheck source=./git/index.bash

GIT_DIR=$(dirname "$0")

source "$GIT_DIR/git-utilities.bash"
source "$GIT_DIR/github.bash"
source "$GIT_DIR/gbm.bash"
source "$GIT_DIR/note.bash"

unset GIT_DIR
