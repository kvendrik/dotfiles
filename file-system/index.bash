#!/bin/bash
# shellcheck source=/dev/null

FILE_SYSTEM_DIR=$(dirname "$0")

source "$FILE_SYSTEM_DIR/miscellaneous.bash"
source "$FILE_SYSTEM_DIR/rps.bash"

unset FILE_SYSTEM_DIR
