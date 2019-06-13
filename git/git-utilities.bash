#!/bin/bash

alias gp='git push -u origin $(__git_current_branch)'
alias gpl="git pull"
alias gac="git add --all :/ && git commit"
alias gacp="git add --all :/ && git commit && gp"
alias grao="git remote add origin"
alias gs="git status"
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cgreen<%an>" --abbrev-commit'
alias gco='git checkout'
alias gcom='git checkout master'

function gcop() {
  if [ -z "$1" ]; then
    echo 'Usage: gcop <new_branch_name>'
    return 1
  fi
  gco -b $1 && gacp
}

function __git_is_repository() {
  git -C "$1" rev-parse --is-inside-work-tree &> /dev/null
}

function __git_current_branch() {
  git branch | grep '\*' | cut -d ' ' -f2
}

function __git_current_repo_name() {
  echo -e "$(basename "$(git rev-parse --show-toplevel)")"
}

function __git_check_uncommited_changes() {
  git diff-index --quiet HEAD -- || echo "uncommited changes found"
}

function __git_branch_exists() {
  git branch | grep "$1"
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

function ub() {
  # Merges the latest given branch (origin/master by default) into the current branch
  # Usage: ub [<remote_name>] [<branch_name>]
  local remote_name='origin'
  local base_branch='master'
  if [ "$1" != "" ]; then
    remote_name="$1"
  fi
  if [ "$2" != "" ]; then
    base_branch="$2"
  fi
  git fetch "$remote_name" "$base_branch"
  git merge "$remote_name/$base_branch"
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
