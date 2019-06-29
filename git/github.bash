#!/bin/bash

if [ -z "$GITHUB_USERNAME" ]; then
  echo "Warning: GITHUB_USERNAME environment variable not set. Some Github tools might not work as expected. (Thrown by $0)"
fi

function __get_http_status_code() {
  curl -I "$1" | grep -Eo "Status\: \d+" | grep -Eo "\d+"
}

# Get a repository's web URL
# Usage: __get_repository_web_url [<repository_path_or_name>] [<remote_name>]
function __get_repository_web_url() {
  local remote_url repository_web_url repository_path
  repository_path="$1"

  if [ -n "$repository_path" ] && [ ! -d "$repository_path" ]; then
    repository_path="$REPOSITORIES_DIRECTORY/$1"
    if [ ! -d "$repository_path" ]; then
      echo "$repository_path is not a repository."
      return 1
    fi
  fi

  if ! __git_is_repository "$repository_path"; then
    echo 'Not a git repository.'
    return 1
  fi

  remote_url=$(__git_get_remote_url "$2" "$repository_path")

  if [ -z "$remote_url" ]; then
    echo "Remote $2 does not exist."
    return 1
  fi

  repository_web_url=$(__git_ssh_to_web_url "$remote_url")

  echo "$repository_web_url"
}

# Open the remote repository
# Usage: or [<repository_name>] [<remote_name>]
function or() {
  local repo_url
  if ! repo_url="$(__get_repository_web_url "$1" "$2")"; then
    echo "$repo_url"
    return
  fi
  open "$repo_url"
}

__rps_autocomplete or

# Open a PR against <base_branch> (master by default) for the current branch on <remote_name> (origin by default)
# Usage: opr [<base_branch>] [<remote_name>]
function opr() {
  local base_branch_name pr_branch_name
  local repo_url
  if ! repo_url="$(__get_repository_web_url "$(pwd)" "$2")"; then
    echo "$repo_url"
    return
  fi
  base_branch_name=$([ -n "$1" ] && echo "$1" || echo master)
  pr_branch_name="$(git symbolic-ref --short HEAD)"
  open "$repo_url/compare/$base_branch_name...$pr_branch_name"
}

# Open a list of your PRs on <remote_name> (origin by default)
# Usage: oprs [<repository_name>] [<remote_name>]
function oprs() {
  local repo_url
  if ! repo_url="$(__get_repository_web_url "$1" "$2")"; then
    echo "$repo_url"
    return
  fi
  open "$repo_url/pulls/$GITHUB_USERNAME"
}

__rps_autocomplete oprs

# Open list of issues
# Usage: oi [<repository_name>] [--me|-m] [--new|-n]
function oi() {
  local result repository_path arguments

  # shellcheck disable=SC2207
  arguments=($(__strip_flags "$@"))
  repository_path="${arguments[1]}"

  if ! result="$(__get_repository_web_url "$repository_path")"; then
    echo "$result"
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'me' 'm')" ]; then
    open "$result/issues/created_by/$GITHUB_USERNAME"
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'new' 'n')" ]; then
    open "$result/issues/new"
    return
  fi

  open "$result/pulls/issues"
}

__rps_autocomplete oi

function create-app() {
  if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    echo 'Usage: create-app <template_name> <app_name>'
    return
  fi

  local status_code
  status_code="$(__get_http_status_code "https://github.com/$GITHUB_USERNAME/project-template-$1")"

  if [ "$status_code" -eq "404" ]; then
    echo "Project template '$1' does not exist"
    return
  fi

  if [ "$status_code" != "200" ]; then
    echo "Something went wrong. Make sure you have an internet connection."
    return
  fi

  if ! git clone "git@github.com:$GITHUB_USERNAME/project-template-$1.git" "$2"; then
    return
  fi

  cd "$2" || return
  rm -rf .git
  rm README.md
  yarn install
}
