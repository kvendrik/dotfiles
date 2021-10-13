#!/bin/bash

__git_current_branch() {
  git branch | grep '\*' | cut -d ' ' -f2
}

__git_check_uncommited_changes() {
  git diff-index --quiet HEAD -- || echo "uncommited changes found"
}

__folder_name_from_git_uri() {
  basename "$1" .git
}

__git_commit() {
  __strip_flags $*
  local message push_cmd commit_cmd

  message="${CURRENT_CLEAN_ARGUMENTS[@]}"

  if [ -n "$(__check_contains_flag "$*" 'push' 'p')" ]; then
    if [ -n "$(__check_contains_flag "$*" 'force' 'f')" ]; then
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

__git_main_branch() {
  [ -n "$(git show-ref master)" ] && echo 'master' || echo 'main'
}

alias gp='git push -u origin $(__git_current_branch)'
alias gpf='git push --force origin +$(__git_current_branch)'
alias gpl="git pull"
alias gac="__git_commit"
alias gacp="__git_commit --push"
alias grao="git remote add origin"
alias gs="git status"
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cgreen<%an>" --abbrev-commit'
alias gr="git rebase -i"
alias gcom='git checkout $(__git_main_branch)'

amend() {
  __git_commit "amend" && git fetch origin "$(__git_main_branch)" && git rebase -i "origin/$(__git_main_branch)"
}

ub() {
  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ]; then
    echo "Usage: ub [--merge|-m] [<base_branch>]. Updates base_branch and rebases it on top of your current branch."
    return
  fi

  # shellcheck disable=SC2086,SC2048
  __strip_flags $*

  local base_branch
  base_branch="${CURRENT_CLEAN_ARGUMENTS[1]:-$(__git_main_branch)}"

  if [ -n "$(__check_contains_flag "$*" 'merge' 'm')" ]; then
    git fetch origin "$base_branch" && git merge "$base_branch"
    return
  fi

  git fetch origin "$base_branch" && git rebase -i "$base_branch"
}

reset-branch() {
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

  git checkout "$(__git_main_branch)"
  git branch -D "$branch_name"
  git fetch origin "$branch_name"
  git checkout "$branch_name"
}

branch-diff() {
  local commit_base branch_name base_branch

  if [ -n "$(__check_contains_flag "$*" 'help' 'h')" ]; then
    echo "Usage: branch-diff [<base_branch>] [<branch_name>] [--files|-f]

Get the diff between a branch and some base branch.

Arguments
base_branch            name of the branch to compare to. $(__git_main_branch) by default.
branch_name            name of the branch to compare. HEAD by default.

Flags
--files|-f             only show file paths"
    return
  fi

  # shellcheck disable=SC2086,SC2048
  __strip_flags $*
  base_branch="${CURRENT_CLEAN_ARGUMENTS[1]:-$(__git_main_branch)}"
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
    git clone "$1" && cd "$(__folder_name_from_git_uri "$1")"
    return
  fi
  git clone "$1" "$2" && cd "$2"
}

cl() {
  local dir_name clone_path clone_argument is_clone_uri is_github_id final_clone_uri github_id folder_argument

  __strip_flags $*
  clone_argument="${CURRENT_CLEAN_ARGUMENTS[1]}"
  folder_argument="${CURRENT_CLEAN_ARGUMENTS[2]}"

  if [ -z "$clone_argument" ] || [ -n "$(__check_contains_flag "$*" 'help' 'h')" ]; then
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

  dir_name="$([ -z "$folder_argument" ] && __folder_name_from_git_uri "$final_clone_uri" || echo "$folder_argument")"
  clone_path="$(rpse)/$dir_name"

  if [ -d "$clone_path" ]; then
    echo "\n$clone_path already exists. Moving into folder..."
    cd "$clone_path"
    return
  fi

  gccd "$final_clone_uri" "$clone_path"
}
