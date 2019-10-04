function tt() {
  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ] || [ -z "$1" ]; then
    read -d '' help_message << EOF
Tab Tasks
Opens Terminal tabs and executes shell commands in them

Usage: tt <commands>

Formula: repository_name1: command1, repository_name2: command 2
Example: intercom-react: echo hello, sketchlint: echo hi
EOF
    return
  fi

  local folder_names commands current_index
  folder_names=($(echo "$@" | grep -Eo '([^ \:]+)\:' | tr -d ':'))
  current_index=1
  commands=()

  while IFS= read -r line; do
    commands+=("$line")
  done < <(echo "$@" | grep -Eo '\:\s?[^\,]+' | grep -Eo '[^\:]+$')

  for folder_name in $folder_names; do
    echo "\`${commands[$current_index]}\` in $(rpse)/$folder_name"
    ttab "cd $(rpse)/$folder_name && ${commands[$current_index]}"
    current_index=$(($current_index+1))
  done
}

complete -W "$(find "$(rpse)" -type d -maxdepth 1 -execdir echo "{}:" \;)" tt
