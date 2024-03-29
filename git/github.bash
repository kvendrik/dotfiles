#!/bin/bash

_git_is_repository() {
  git -C "$1" rev-parse --is-inside-work-tree &> /dev/null
}

_git_get_remote_url() {
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

_git_ssh_to_web_url() {
  local base
  base=$(echo "$1" | sed -e "s/.git$//" -e "s/^git\@//" -e "s/\(.*[:/].*\)/\1/" -e "s/https\:\/\///" -e "s/\:/\//")
  echo "https://$base"
}

# Get a repository's web URL
# Usage: _get_repository_web_url [<repository_path_or_name>] [<remote_name>]
_get_repository_web_url() {
  local remote_url repository_web_url repository_path
  repository_path="$1"

  if [ -n "$repository_path" ] && [ ! -d "$repository_path" ]; then
    repository_path="$REPOSITORIES_DIRECTORY/$1"
    if [ ! -d "$repository_path" ]; then
      echo "$repository_path is not a repository."
      return 1
    fi
  fi

  if ! _git_is_repository "$repository_path"; then
    echo 'Not a git repository.'
    return 1
  fi

  remote_url=$(_git_get_remote_url "$2" "$repository_path")

  if [ -z "$remote_url" ]; then
    echo "Remote $2 does not exist."
    return 1
  fi

  repository_web_url=$(_git_ssh_to_web_url "$remote_url")

  echo "$repository_web_url"
}

# Open the remote repository
# Usage: or [<repository_name>] [<remote_name>]
or() {
  local current_branch_name repo_url

  if ! repo_url="$(_get_repository_web_url "$1" "$2")"; then
    echo "$repo_url"
    return
  fi

  current_branch_name="$(git symbolic-ref --short HEAD)"

  if [ "$current_branch_name" != "$(_git_main_branch)" ]; then
    open "$repo_url/tree/$current_branch_name"
    return
  fi

  open "$repo_url"
}

_rps_autocomplete or

# Open a PR against <base_branch> (master by default) for the current branch on <remote_name> (origin by default)
# Usage: opr [<base_branch>] [<remote_name>]
opr() {
  local base_branch_name pr_branch_name
  local repo_url
  if ! repo_url="$(_get_repository_web_url "$(pwd)" "$2")"; then
    echo "$repo_url"
    return
  fi
  base_branch_name=$([ -n "$1" ] && echo "$1" || echo "$(_git_main_branch)")
  pr_branch_name="$(git symbolic-ref --short HEAD)"
  open "$repo_url/compare/$base_branch_name...$pr_branch_name"
}

# Open last commit
olc() {
  local repo_url
  if ! repo_url="$(_get_repository_web_url "$(pwd)" "$2")"; then
    echo "$repo_url"
    return
  fi
  open "$repo_url/commit/$(git rev-parse HEAD)"
}

oi() {
  local result repository_path url_path

  if [ -z "$GITHUB_USERNAME" ]; then
    echo "GITHUB_USERNAME environment variable not set. (Thrown by $0)"
    return 1
  fi

  if [ -n "$(_check_contains_flag "$*" 'help' 'h')" ]; then
    printf 'Open Github list of issues or pull requests.\nUsage: oi [--me|-m] [--new|-n] [--search|-s] [-p|--pulls] [--repo=<path>].'
    return
  fi

  # shellcheck disable=SC2086,SC2048
  _strip_flags $*
  repository_path="$(_extract_flag_value "$*" 'repo')"
  url_path="$([ -n "$(_check_contains_flag "$*" 'pulls' 'p')" ] && echo 'pulls' || echo 'issues')"

  if ! result="$(_get_repository_web_url "$repository_path")"; then
    echo "$result"
    return
  fi

  if [ -n "$(_check_contains_flag "$*" 'me' 'm')" ]; then
    open "$result/$url_path/created_by/$GITHUB_USERNAME"
    return
  fi

  if [ -n "$(_check_contains_flag "$*" 'new' 'n')" ]; then
    open "$result/$url_path/new?title=${CURRENT_CLEAN_ARGUMENTS}"
    return
  fi

  if [ -n "$(_check_contains_flag "$*" 'search' 's')" ]; then
    open "$result/$url_path?utf8=✓&q=${CURRENT_CLEAN_ARGUMENTS}"
    return
  fi

  open "$result/$url_path"
}
