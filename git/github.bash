#!/bin/bash

if [ -z "$GITHUB_USERNAME" ]; then
  echo "Warning: GITHUB_USERNAME environment variable not set. Some Github tools might not work as expected. (Thrown by $0)"
fi

function __git_is_repository() {
  git -C "$1" rev-parse --is-inside-work-tree &> /dev/null
}

function __git_get_remote_url() {
  local remote_name remote_url repository_path
  remote_name=$([ -n "$1" ] && echo "$1" || echo origin)
  repository_path="$2"
  if [ -n "$repository_path" ]; then
    remote_url="$(git -C "$repository_path" config --get remote."${remote_name}".url)"
  else
    remote_url="$(git config --get remote."${remote_name}".url)"
  fi
  echo "$remote_url"
}

function __git_ssh_to_web_url() {
  local base
  base=$(echo "$1" | sed -e "s/.git$//" -e "s/^git\@//" -e "s/\(.*[:/].*\)/\1/" -e "s/https\:\/\///" -e "s/\:/\//")
  echo "https://$base"
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

function oi() {
  local result repository_path url_path

  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ]; then
    printf 'Open Github list of issues or pull requests.\nUsage: oi [--me|-m] [--new|-n] [--search|-s] [-p|--pulls] [--repo=<path>].'
    return
  fi

  # shellcheck disable=SC2086,SC2048
  __strip_flags $*
  repository_path="$(__extract_flag_value "$*" 'repo')"
  url_path="$([ -n "$(__check_contains_flag "$*" 'pulls' 'p')" ] && echo 'pulls' || echo 'issues')"

  if ! result="$(__get_repository_web_url "$repository_path")"; then
    echo "$result"
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'me' 'm')" ]; then
    open "$result/$url_path/created_by/$GITHUB_USERNAME"
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'new' 'n')" ]; then
    open "$result/$url_path/new?title=${CURRENT_CLEAN_ARGUMENTS}"
    return
  fi

  if [ -n "$(__check_contains_flag "$*" 'search' 's')" ]; then
    open "$result/$url_path?utf8=✓&q=${CURRENT_CLEAN_ARGUMENTS}"
    return
  fi

  open "$result/$url_path"
}

function create-app() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo 'Usage: create-app <template_name> <app_name>'
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

function ghf() {
  if [ -z "$1" ]; then
    echo """
Usage: ghf <search_query>. ghf @ <search_query> to only search your own accounts and organizations.

Flags
--no-open|-n    Do not open the URL when a result is selected
"""
    return
  fi

  __strip_flags $*
  local repo_path raw_query url_query

  raw_query="${CURRENT_CLEAN_ARGUMENTS[@]}"
  if [ -n "$(echo "$raw_query "| grep "@ ")" ]; then
    raw_query="$GITHUB_SEARCH_USERNAMES $(echo "$raw_query" | tr -d '@ ')"
  fi

  url_query="$(echo "$raw_query" | tr ' ' '+')"
  repo_path="$(curl -s -u $GITHUB_USERNAME:$GITHUB_SEARCH_TOKEN https://api.github.com/search/repositories\?q\=$url_query\&order\=desc | jq ".items[].full_name" | fzf | tr -d '\"')"

  if [ -n "$repo_path" ]; then
    if [ -n "$(__check_contains_flag "$*" 'no-open' 'n')" ]; then
      echo "$repo_path"
    else
      open "https://github.com/$repo_path"
    fi
  fi
}
