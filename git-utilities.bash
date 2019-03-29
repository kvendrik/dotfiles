alias gp="git push -u origin $(git_current_branch)"
alias gpl="git pull"
alias gac="git add --all :/ && git commit"
alias gacp="git add --all :/ && git commit && git push"
alias grao="git remote add origin"
alias gs="git status"
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cgreen<%an>" --abbrev-commit'
alias gco='git checkout'

function git_current_branch() {
  echo "$(git branch | grep \* | cut -d ' ' -f2)"
}

function git_current_repo_name() {
  echo -e $(basename `git rev-parse --show-toplevel`)
}

function git_check_uncommited_changes() {
  echo $(git diff-index --quiet HEAD -- || echo "uncommited changes found")
}

function get_http_status_code() {
  echo "$(curl -I $1 | grep -Eo "Status\: \d+" | grep -Eo "\d+")"
}

function git_branch_exists() {
  echo "$(git branch | grep $1)"
}

function ub() {
  # Merges the latest given branch (origin/master by default) into the current branch
  # Usage: ub [<remote_name>] [<branch_name>]
  local branch="$(git symbolic-ref --short -q HEAD)"
  local remote_name='origin'
  local base_branch='master'
  if [ "$1" != "" ]; then
    remote_name="$1"
  fi
  if [ "$2" != "" ]; then
    base_branch="$2"
  fi
  git fetch $remote_name $base_branch
  git merge $remote_name/$base_branch
}

function reset-branch() {
  local branch_name="$(git_current_branch)"

  if [ "$(git_check_uncommited_changes)" != "" ]; then
    echo 'Uncommited changes found. Please commit/stash those first.'
    return
  fi

  echo -n "This will do a hard reset on your current branch ($branch_name). Continue? [y/N] "
  read local do_reset

  if [ "$do_reset" != "y" ]; then
    return
  fi

  git checkout master
  git branch -D $branch_name
  git fetch origin $branch_name
  git checkout $branch_name
}