[![CircleCI](https://circleci.com/gh/kvendrik/dotfiles.svg?style=svg)](https://circleci.com/gh/kvendrik/dotfiles)

## Good to know
I try to keep my dotfiles a clean collection of aliases and methods that speed up my workflow without any side-effects (no configuration or settings changes without implicit request). They don't make any changes to how your command line works or looks as I leave most of those things to [Oh My ZSH](https://ohmyz.sh) and some other [plugins](#other-frameworks-plugins-and-tools-i-use) I use.

Most of the aliases and methods should be pretty self-explanatory: everything is grouped by category and either has self-explanatory code, a usage message, or a comment that that explains what it does and why. If you see anything that is unclear feel free to clear it up by e.g. adding an extra comment and opening up a pull request.

Everything is reusable as I keep things like usernames etc configurable, but as everything in here is primarely built and maintained for personal use I can't guarantee that everything will be relevant to you or will work out of the box. Feel free to make changes as needed and optionally contribute them back to here, to cherry-pick some methods or aliases that you like and add them to your own setup or to just use this for inspiration.

## Setup
1. Clone the dotfiles to your home folder (`~`).
2. Configure the files using environment variables and source the `index` file:

In your `~/.zshrc` (if you use [Oh My ZSH](http://ohmyz.sh) like I do):
```bash
export GITHUB_USERNAME='kvendrik'
export REPOSITORIES_DIRECTORY='path/to/all/your/cloned/repositories'

source path_to_this_repo/index
```

## Want more configs?
By default these dotfiles are a clean collection of aliases and methods so that you don't have to fear any side effects when sourcing them. There is, however, a backup system in place called `config-backups` that I use to back up and restore files from and to specific locations on my machine (things like my global `.gitignore` file and VSCode keyboard shortcuts). Have a look at the [`./config-backups/~`](https://github.com/kvendrik/dotfiles/tree/master/config-backups/~/) folder to see these files.

These backups come packaged with a utility called `config-backups` that allows you to back up files from your machine into this directory and restore them as needed. Have a look at the [utility itself](https://github.com/kvendrik/dotfiles/tree/master/config-backups/config-backups) for more details.

## Contibute
1. Make your changes.
2. Run `path_to_this_repo/lint` to lint changes you make.
3. Open a PR.

## Other frameworks, plugins and tools I use
This repo doesn't include any references to some of the other frameworks, plugins and tools that I use. Here are some of my favorite ones that I thought were worth mentioning:

- [Oh My ZSH](https://ohmyz.sh)
- [ZSH Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)
- [git_clone_find](https://github.com/kvendrik/git_clone_find)
