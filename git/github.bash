#!/bin/bash

if [ -z "$GITHUB_USERNAME" ]; then
  echo "Warning: GITHUB_USERNAME environment variable not set. Some Github tools might not work as expected. (Thrown by $0)"
fi

function __get_http_status_code() {
  curl -I "$1" | grep -Eo "Status\: \d+" | grep -Eo "\d+"
}

# Get a repository's web URL
# Usage: __get_repository_web_url [callback] [<repository_name>] [<remote_name>]
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

  if ! git_is_repository "$repository_path"; then
    echo 'Not a git repository.'
    return 1
  fi

  remote_url=$(git_get_remote_url "$3" "$repository_path")

  if [ -z "$remote_url" ]; then
    echo "Remote $2 does not exist."
    return 1
  fi

  repository_web_url=$(git_ssh_to_web_url "$remote_url")

  echo "$repository_web_url"
}

# Open the remote repository
# Usage: or [<repository_name>] [<remote_name>]
function or() {
  local result
  if ! result="$(__get_repository_web_url "$1" "$2")"; then
    echo "$result"
    return
  fi
  open "$result"
}

rps_autocomplete or

# Open a PR against <base_branch> (master by default) for the current branch
# on <remote_name> (origin by default)
# Usage: opr [<base_branch>] [<remote_name>]
function opr() {
  if ! git_is_repository; then
    echo 'Not a git repository.'
    return
  fi
  local base_branch_name pr_branch_name remote_url
  base_branch_name=$([ -n "$1" ] && echo "$1" || echo master)
  pr_branch_name="$(git symbolic-ref --short HEAD)"
  remote_url=$(git_get_remote_url "$2")
  if [ -z "$remote_url" ]; then
    echo "Remote $2 does not exist."
    return
  fi
  local repository_web_url
  repository_web_url=$(git_ssh_to_web_url "$remote_url")
  open "$repository_web_url/compare/$base_branch_name...$pr_branch_name"
}

# Open a list of your PRs on <remote_name> (origin by default)
# Usage: oprs [<remote_name>]
function oprs() {
  local result
  if ! result="$(__get_repository_web_url "$1" "$2")"; then
    echo "$result"
    return
  fi
  open "$result/pulls/$GITHUB_USERNAME"
}

rps_autocomplete oprs

# Open a list of your issues on <remote_name> (origin by default)
# Usage: mi [<repository_name>] [<remote_name>]
function mi() {
  if ! git_is_repository; then
    echo 'Not a git repository.'
    return
  fi
  local remote_url
  remote_url=$(git_get_remote_url "$1")
  if [ -z "$remote_url" ]; then
    echo "Remote $1 does not exist."
    return
  fi
  local repository_web_url
  repository_web_url="$(git_ssh_to_web_url "$remote_url")"
  open "$repository_web_url/issues/created_by/$GITHUB_USERNAME"
}

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

function polaris-tophat() {
  if [[ -z "$1" ]]; then
    echo 'Usage: polaris-tophat <branch_name>'
    return
  fi

  rps
  cd polaris-react || return

  if [ "$(git_current_repo_name)" != "polaris-react" ]; then
    echo 'Could not switch to polaris-react folder'
    return
  fi

  if [ "$(git_check_uncommited_changes)" != "" ]; then
    echo 'Uncommited changes found. Please commit/stash those first.'
    return
  fi

  nvm use 10.11.0

  if [ "$(git_branch_exists "$1")" -eq "" ]; then
    git fetch origin "$1"
  fi

  gco "$1"
  git pull

  code playground/Playground.tsx
  yarn
  yarn dev
}
