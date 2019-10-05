function tt() {
  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ] || [ -z "$1" ]; then
    read -d '' help_message << EOF
Tab Tasks
Opens Terminal tabs and executes shell commands in them.

Usage: tt <Commands>

Commands formula
repository_name1: command1, repository_name2: command2

It attempts to find the repositories in your 'rpse' folder. Run 'rpse' to figure
out what you have that configured to.

Example
intercom-react: echo hello, sketchlint: echo hi
EOF
    echo $help_message
    return
  fi

  local folder_names commands current_index
  folder_names=($(echo "$@" | grep -Eo '([^ \:\,]+)\:' | sed 's/\:$//g'))
  current_index=1
  commands=()

  while IFS= read -r line; do
    commands+=("$line")
  done < <(echo "$@" | grep -Eo '\:\s?[^\,]+' | grep -Eo '[^\:]+$' | sed 's/^ //g')

  echo '\e[34mOpening tabs\e[0m'

  for folder_name in $folder_names; do
    echo "\`${commands[$current_index]}\` \e[90min\e[0m $(rpse)/$folder_name"
    ttab "cd $(rpse)/$folder_name && ${commands[$current_index]}"
    current_index=$(($current_index+1))
  done
}

function __get_tt_autocomplete() {
  find "$(rpse)" -type d -maxdepth 1 -execdir echo "{}:" \;
}

complete -F __get_tt_autocomplete tt
