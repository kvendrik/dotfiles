#!/bin/bash

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

alias gp='git push -u origin $(__git_current_branch)'
alias gpl="git pull"
alias gac="git add --all :/ && git commit"
alias gacp="git add --all :/ && git commit && gp"
alias grao="git remote add origin"
alias gs="git status"
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cgreen<%an>" --abbrev-commit'
alias gcom='git checkout master'
alias gco='git checkout'

function gcop() {
  [ -z "$1" ] && echo 'Usage: gcop <new_branch_name>' && return
  gco -b "$1" && gacp
}

function gcopl() {
  [ -z "$1" ] && echo 'Usage: gcopl <branch_name>' && return
  git fetch origin "$1" && git checkout "$1" && git merge "origin/$1"
}

function ub() {
  # Updates base_branch and merges it into your current branch
  # Usage: ub [<base_branch>]
  local base_branch='master'
  local original_branch="$(__git_current_branch)"
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
