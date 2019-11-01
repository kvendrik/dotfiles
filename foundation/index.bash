#!/bin/bash
# shellcheck source=./foundation/index.bash

FOUNDATION_DIR=$(dirname "$0")

source "$FOUNDATION_DIR/config.bash"
source "$FOUNDATION_DIR/utilities.bash"

unset FOUNDATION_DIR
