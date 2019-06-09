[![CircleCI](https://circleci.com/gh/kvendrik/dotfiles.svg?style=svg)](https://circleci.com/gh/kvendrik/dotfiles)

## Good to know
I try to keep my dotfiles a clean collection of aliases and methods that speed up my workflow without any side-effects (no configuration or settings changes without implicit request). They don't make any changes to how your command line works or looks as I leave most of those things to [Oh My ZSH](https://ohmyz.sh) and some other utilities and config files that won't be installed by default (see [`./bootstrap`](#bootstrap) for more info).

Most of the aliases and methods should be pretty self-explanatory: everything is grouped by category and either has self-explanatory code, a usage message, or a comment that that explains what it does and why. If you see anything that is unclear feel free to clear it up by e.g. adding an extra comment and opening up a pull request.

Everything is reusable as I keep things like usernames etc configurable, but as everything in here is primarely built and maintained for personal use I can't guarantee that everything will be relevant to you or will work out of the box. Feel free to make changes as needed and optionally contribute them back to here, to cherry-pick some methods or aliases that you like and add them to your own setup or to just use this for inspiration.

## Setup
1. Clone the dotfiles to your home folder (`~`).
2. Configure the files using environment variables and source the `index` file:

In your `~/.zshrc` (if you use ZSH like I do):
```bash
export GITHUB_USERNAME='kvendrik'
export REPOSITORIES_DIRECTORY='path/to/all/your/cloned/repositories'

source path_to_this_repo/index
```

## `./bootstrap`
By default these dotfiles are a clean collection of aliases and methods so that you don't have to fear any side effects when sourcing them. There are, however, backups and scripts in place that can be used to set up a new system with some of my own essential tools and preferences that I use on a dialy basis. This all lives in `./bootstrap` and this is what you should know about it:

- `./bootstrap/bootstrap` is a script that can be used to bootstrap a new machine. I try to keep it pretty minimal so that it only installs the very essentials.
- `./bootstrap/~` contains all backed up files relative to the home folder.
- `./bootstrap/~/.zshrc` is my RC file. You'll notice that it doesn't contain any info that is specific to me. This info I keep in a seperate file called `~/.rc-setup` (only exists on my machine) and gets sourced by my RC.
- `./bootstrap/config-backups` is a utility that helps me back up these files from my machine and to restore them as needed. Run `./bootstrap/config-backups` for more info on how this utility works.

## Contribute
1. Make your changes.
2. Run `path_to_this_repo/lint` to lint changes you make.
3. Open a PR.
