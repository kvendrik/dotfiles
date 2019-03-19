[![CircleCI](https://circleci.com/gh/kvendrik/dotfiles.svg?style=svg)](https://circleci.com/gh/kvendrik/dotfiles)

To be used with [Oh My ZSH](http://ohmyz.sh/).

In your `~/.zshrc`:
```bash
export GITHUB_USERNAME='kvendrik'
export GITHUB_ORGS_USERNAMES=('my_org1' 'my_org2')
source path_to_this_repo/index
```

Run `path_to_this_repo/lint` to lint changes you make to the dotfiles.
