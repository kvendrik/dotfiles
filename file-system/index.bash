#!/bin/bash
# shellcheck source=./file-system/index.bash

FILE_SYSTEM_DIR=$(dirname "$0")

source "$FILE_SYSTEM_DIR/rps.bash"
source "$FILE_SYSTEM_DIR/miscellaneous.bash"

unset FILE_SYSTEM_DIR
