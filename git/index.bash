#!/bin/bash
# shellcheck source=./git/index.bash

GIT_DIR=$(dirname "$0")

source "$GIT_DIR/git.bash"
source "$GIT_DIR/github.bash"

unset GIT_DIR
