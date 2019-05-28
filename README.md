[![CircleCI](https://circleci.com/gh/kvendrik/dotfiles.svg?style=svg)](https://circleci.com/gh/kvendrik/dotfiles)

## Good to know
The files mostly just contain methods and aliases to speed up your workflow. They don't make any fundamental changes to how your command line works as I leave most of that stuff to [Oh My ZSH](https://ohmyz.sh).

I try to make these dotfiles reusable by keeping things like usernames etc configurable, but as they are primarely built and maintained for personal use I can't guarantee that everything will be relevant to you or will work out of the box. Feel free to make changes as needed and optionally contribute them back to here, to cherry-pick some methods or aliases that you like and add them to your own setup or to just use this for inspiration.

## Setup
1. Clone the dotfiles to your home folder (`~`).
2. Configure the files using environment variables and source the `index` file:

In your `~/.zshrc` (if you use [Oh My ZSH](http://ohmyz.sh) like I do):
```bash
export GITHUB_USERNAME='kvendrik'
export REPOSITORIES_DIRECTORY='path/to/all/your/cloned/repositories'

source path_to_this_repo/index
```

## Contibute
1. Make your changes.
2. Run `path_to_this_repo/lint` to lint changes you make to the dotfiles.
3. Open a PR.
