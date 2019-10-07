function t() {
  local help_message
  read -d '' help_message << EOF
Tab Tasks
Opens Terminal tabs and executes shell commands in them.

Usage: t <Commands> [-a|--all] [-v|--verbose]

Commands:
repository_name1: command1, repository_name2: command2

It attempts to find the repositories in your 'rpse' folder. Run 'rpse' to figure
out what you have that configured to.

example:
intercom-react: echo hello, sketchlint: echo hi

Flags:
-a|--all        Open all commands in a new tab
-v|--verbose    Verbose messaging
-h|--help       Print this help message
EOF

  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ] || [ -z "$1" ]; then
    echo $help_message
    return
  fi

  local args folder_names commands current_index message all_in_new_tab current_command verbose

  args="$(__strip_flags $@)"
  all_in_new_tab="$(__check_contains_flag "$*" 'all' 'a')"
  verbose="$(__check_contains_flag "$*" 'verbose' 'v')"
  folder_names=($(echo "$args" | grep -Eo '([^ \:\,]+)\:' | sed 's/\:$//g'))
  current_index=1
  commands=()

  while IFS= read -r line; do
    commands+=("$line")
  done < <(echo "$args" | grep -Eo '\:\s?[^\,]+' | grep -Eo '[^\:]+$' | sed 's/^ //g')

  if [ -z "$folder_names" ] || [ -z "$commands" ]; then
    echo $help_message
    return
  fi

  for folder_name in $folder_names; do
    message="\`${commands[$current_index]}\` \e[90min\e[0m $(rpse)/$folder_name"
    current_command="cd $(rpse)/$folder_name && ${commands[$current_index]}"

    if [ $current_index -ne 1 ] || [ -n "$all_in_new_tab" ]; then
      [ -n "$verbose" ] && echo "$message \e[90m(new tab)\e[0m"
      ttab $current_command
    else
      [ -n "$verbose" ] && echo "$message \e[90m(current tab)\e[0m"
      eval $current_command
    fi

    current_index=$(($current_index+1))
  done
}

function __get_t_autocomplete() {
  find "$(rpse)" -type d -maxdepth 1 -execdir echo "{}:" \;
}

complete -F __get_t_autocomplete t
