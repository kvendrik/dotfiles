#!/bin/bash

_git_current_branch() {
  git branch | grep '\*' | cut -d ' ' -f2
}

_git_check_uncommited_changes() {
  git diff-index --quiet HEAD -- || echo "uncommited changes found"
}

_folder_name_from_git_uri() {
  basename "$1" .git
}

_git_commit() {
  _strip_flags $*
  local message push_cmd commit_cmd

  message="${CURRENT_CLEAN_ARGUMENTS[@]}"

  if [ -n "$(_check_contains_flag "$*" 'push' 'p')" ]; then
    if [ -n "$(_check_contains_flag "$*" 'force' 'f')" ]; then
      push_cmd="&& gpf"
    else
      push_cmd="&& gp"
    fi
  fi

  if [ -n "$message" ]; then
    commit_cmd="git commit -m \"$message\""
  else
    commit_cmd="git commit"
  fi

  eval "git add --all && $commit_cmd $push_cmd"
}

_git_main_branch() {
  [[ "$(basename $(pwd))" == 'web' ]] && echo 'main' && return
  [ -n "$(git show-ref master)" ] && echo 'master' || echo 'main'
}

alias gp='git push -u origin $(_git_current_branch)'
alias gpf='git push --force origin +$(_git_current_branch)'
alias gpl="git pull"
alias gac="_git_commit"
alias gacp="_git_commit --push"
alias p="gacp"
alias grao="git remote add origin"
alias gs="git status"
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cgreen<%an>" --abbrev-commit'
alias gr="git rebase -i"
alias gcom='git checkout $(_git_main_branch)'
alias amend='git commit --amend'

squash() {
  local branch_name upstream_name commit_message

  if [[ "$1" == "continue" ]]; then
    [ -n "$(_git_check_uncommited_changes)" ] && git commit
    git rebase --continue
    return
  fi

  branch_name="$1"
  commit_message="${@:2}"

  [ -z "$branch_name" ] && echo "Please provide a branch name to rebase onto." && return 1
  [ -n "$(echo "$branch_name" | grep "/")" ] && echo "Please provide a name without the upstream. So ’main’ instead of ’origin/main’" && return 1

  if [ -n "$(_git_check_uncommited_changes)" ]; then
    [ -z "$commit_message" ] && echo "Please provide a commit message, or commit your changes before running the command again." && return 1
    git commit -m "$commit_message"
  fi

  [ -z "$commit_message" ] && echo "Please provide a commit message for the rebase." && return 1

  upstream_name="origin"

  git fetch "$upstream_name" "$branch_name" && GIT_EDITOR="sed -i -e '2 s/^#/$commit_message\''\n&/g'" GIT_SEQUENCE_EDITOR="sed -i -e '1 ! s/pick/squash/g'" git rebase -i "$upstream_name/$branch_name"
}

# Git Checkout Recent
# Shows list of recently used branches
which gcor &> /dev/null && unalias gcor

gcor() {
  git reflog | grep -Eo 'moving from [^ ]+' | grep -Eo '[^ ]+$' | awk '!a[$0]++' | head -n 20 | awk '{if(system("[ -z \"$(git branch --list "$0")\" ]")){print}}' | fzf | xargs git checkout
}

gccd() {
  if [ -z "$1" ]; then
    echo 'Usage: gccd <clone_url>'
    return
  fi
  if [ -z "$2" ]; then
    git clone "$1" && cd "$(_folder_name_from_git_uri "$1")"
    return
  fi
  git clone "$1" "$2" && cd "$2"
}

cl() {
  local dir_name clone_path clone_argument is_clone_uri is_github_id final_clone_uri github_id folder_argument

  _strip_flags $*
  clone_argument="${CURRENT_CLEAN_ARGUMENTS[1]}"
  folder_argument="${CURRENT_CLEAN_ARGUMENTS[2]}"

  if [ -z "$clone_argument" ] || [ -n "$(_check_contains_flag "$*" 'help' 'h')" ]; then
    echo """
Usage: cl <clone_argument> [<folder_name>]

Finds a repository and clones it to $(rpse)

Arguments
clone_argument     Can be a clone URI or Github ID (e.g. kvendrik/dotfiles)
folder_name        Will default to the repository name. If the used folder name already exists
                   then the shell will be moved into the folder.

Flags
--help|-h          Print this help message
"""
    return
  fi

  is_clone_uri="$(echo "$clone_argument" | grep -Eo "^git\@|^https?")"

  if [ -n "$is_clone_uri" ]; then
    final_clone_uri="$1"
  else
    is_github_id="$(echo "$clone_argument" | grep -o "/")"

    if [ -n "$is_github_id" ]; then
      final_clone_uri="git@github.com:$clone_argument.git"
    else
      echo "$clone_argument needs to be either a clone URI or a Github ID (e.g. kvendrik/dotfiles)"
    fi
  fi

  dir_name="$([ -z "$folder_argument" ] && _folder_name_from_git_uri "$final_clone_uri" || echo "$folder_argument")"
  clone_path="$(rpse)/$dir_name"

  if [ -d "$clone_path" ]; then
    echo "\n$clone_path already exists. Moving into folder..."
    cd "$clone_path"
    return
  fi

  gccd "$final_clone_uri" "$clone_path"
}
