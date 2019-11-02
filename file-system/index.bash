#!/bin/bash
# shellcheck source=./file-system/index.bash

FILE_SYSTEM_DIR=$(dirname "$0")

source "$FILE_SYSTEM_DIR/miscellaneous.bash"
source "$FILE_SYSTEM_DIR/local_command.bash"
source "$FILE_SYSTEM_DIR/d.bash"

unset FILE_SYSTEM_DIR
