[![CircleCI](https://circleci.com/gh/kvendrik/dotfiles.svg?style=svg)](https://circleci.com/gh/kvendrik/dotfiles)

## Good to know
I try to keep my dotfiles a clean collection of aliases and methods that speed up my workflow without any side-effects (no configuration or settings changes without implicit request). They don't make any changes to how your command line works or looks as I leave most of those things to [Oh My ZSH](https://ohmyz.sh) and some other [plugins](https://github.com/kvendrik/dotfiles#other-frameworks-plugins-and-tools-i-use) I use.

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

## Other frameworks, plugins and tools I use
I try to keep the files in this repo a clean collection of things that speed up my workflow without any side effects (no configuration or settings changes without implicit request). Therefor it doesn't include any references to some of the other frameworks, plugins and tools that I use. Here are some of my favorite ones that I thought were worth mentioning:

- [Oh My ZSH](https://ohmyz.sh)
- [ZSH Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)
- [git_clone_find](https://github.com/kvendrik/git_clone_find)
