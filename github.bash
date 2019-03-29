function _get_remote_url() {
  local remote_name=$([ ! -z "$1" ] && echo "$1" || echo origin)
  local remote_url="$(git config --get remote.${remote_name}.url)"
  echo $remote_url
}

function _remote_url_to_web_url() {
  local base=$(echo "$remote_url" | sed -e "s/.git$//" -e "s/^git\@//" -e "s/\(.*[:/].*\)/\1/" -e "s/https\:\/\///" -e "s/\:/\//")
  echo "https://$base"
}

# Usage: opr [<base_branch>] [<remote_name>]
function opr() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo 'Not a git repository.'
    return
  fi
  local base_branch_name=$([ ! -z "$1" ] && echo "$1" || echo master)
  local pr_branch_name="$(git symbolic-ref --short HEAD)"
  local remote_url=$(_get_remote_url "$2")
  if [ -z "$remote_url" ]; then
    echo "Remote $2 does not exist."
    return
  fi
  local repository_web_url=$(_remote_url_to_web_url "$remote_url")
  open "$repository_web_url/compare/$base_branch_name...$pr_branch_name"
}

# Usage: mpr [<remote_name>]
function mpr() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo 'Not a git repository.'
    return
  fi
  local remote_url=$(_get_remote_url "$1")
  if [ -z "$remote_url" ]; then
    echo "Remote $1 does not exist."
    return
  fi
  local repository_web_url="$(_remote_url_to_web_url "$remote_url")"
  open "$repository_web_url/pulls/$GITHUB_USERNAME"
}

# Usage: mi [<remote_name>]
function mi() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo 'Not a git repository.'
    return
  fi
  local remote_url=$(_get_remote_url "$1")
  if [ -z "$remote_url" ]; then
    echo "Remote $1 does not exist."
    return
  fi
  local repository_web_url="$(_remote_url_to_web_url "$remote_url")"
  open "$repository_web_url/issues/created_by/$GITHUB_USERNAME"
}

function create-app() {
  if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    echo 'Usage: create-app <template_name> <app_name>'
    return
  fi

  local status_code="$(get_http_status_code "https://github.com/$GITHUB_USERNAME/project-template-$1")"

  if [ "$status_code" -eq "404" ]; then
    echo "Project template '$1' does not exist"
    return
  fi

  if [ "$status_code" != "200" ]; then
    echo "Something went wrong. Make sure you have an internet connection."
    return
  fi

  if ! git clone "git@github.com:$GITHUB_USERNAME/project-template-$1.git" $2; then
    return
  fi

  cd $2
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
  cd polaris-react

  if [ "$(git_current_repo_name)" != "polaris-react" ]; then
    echo 'Could not switch to polaris-react folder'
    return
  fi

  if [ "$(git_check_uncommited_changes)" != "" ]; then
    echo 'Uncommited changes found. Please commit/stash those first.'
    return
  fi

  nvm use 10.11.0

  if [ "$(git_branch_exists $1)" -eq "" ]; then
    git fetch origin $1
  fi

  gco $1
  git pull

  code playground/Playground.tsx
  yarn
  yarn dev
}
