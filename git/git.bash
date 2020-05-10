#!/bin/bash

function __git_current_branch() {
  git branch | grep '\*' | cut -d ' ' -f2
}

function __git_check_uncommited_changes() {
  git diff-index --quiet HEAD -- || echo "uncommited changes found"
}

function __folder_name_from_git_uri() {
  basename "$1" .git
}

alias gp='git push -u origin $(__git_current_branch)'
alias gpl="git pull"
alias gac="git add --all :/ && git commit"
alias gacp="git add --all :/ && git commit && gp"
alias grao="git remote add origin"
alias gs="git status"
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cgreen<%an>" --abbrev-commit'
alias gcom='git checkout master'

function ub() {
  # Updates base_branch and merges it into your current branch
  # Usage: ub [<base_branch>]
  local base_branch original_branch
  base_branch='master'
  original_branch="$(__git_current_branch)"
  if [ "$1" != "" ]; then
    base_branch="$1"
  fi
  git checkout "$base_branch"
  git pull
  git checkout "$original_branch"
  git merge "$base_branch"
}

function reset-branch() {
  local branch_name
  branch_name="$(__git_current_branch)"

  if [ "$(__git_check_uncommited_changes)" != "" ]; then
    echo 'Uncommited changes found. Please commit/stash those first.'
    return
  fi

  echo -n "This will do a hard reset on your current branch ($branch_name). Continue? [y/N] "

  local do_reset
  read -r do_reset

  if [ "$do_reset" != "y" ]; then
    return
  fi

  git checkout master
  git branch -D "$branch_name"
  git fetch origin "$branch_name"
  git checkout "$branch_name"
}

function branch-diff() {
  local commit_base branch_name base_branch

  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ]; then
    echo 'Usage: branch-diff [<base_branch>] [<branch_name>] [--files|-f]

Get the diff between a branch and some base branch.

Arguments
base_branch            name of the branch to compare to. master by default.
branch_name            name of the branch to compare. HEAD by default.

Flags
--files|-f             only show file paths'
    return
  fi

  # shellcheck disable=SC2086,SC2048
  __strip_flags $*
  base_branch="${CURRENT_CLEAN_ARGUMENTS[1]:-master}"
  branch_name="${CURRENT_CLEAN_ARGUMENTS[2]:-HEAD}"
  commit_base="$(git merge-base "$base_branch" "$branch_name")"

  if [ -n "$(__check_contains_flag "$*" 'files' 'f')" ]; then
    git diff --name-only "$commit_base" "$branch_name"
    return
  fi

  git diff "$commit_base" "$branch_name"
}

# Git Checkout Recent
# Shows list of recently used branches
function gcor() {
  git reflog | grep -Eo 'moving from [^ ]+' | grep -Eo '[^ ]+$' | awk '!a[$0]++' | head -n 20 | awk '{if(system("[ -z \"$(git branch --list "$0")\" ]")){print}}' | fzf | xargs git checkout
}

function gccd() {
  if [ -z "$1" ]; then
    echo 'Usage: gccd <clone_url>'
    return
  fi
  if [ -z "$2" ]; then
    git clone "$1" && cd "$(__folder_name_from_git_uri "$1")"
    return
  fi
  git clone "$1" "$2" && cd "$2"
}

function cl() {
  local dir_name clone_path
  dir_name="$([ -z "$2" ] && __folder_name_from_git_uri "$1" || echo "$2")"
  clone_path="$(rpse)/$dir_name"
  if [ -d "$clone_path" ]; then
    echo "$clone_path already exists."
    return
  fi
  gccd "$1" "$(rpse)/$dir_name"
}
