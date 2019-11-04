[![CircleCI](https://circleci.com/gh/kvendrik/dotfiles.svg?style=svg)](https://circleci.com/gh/kvendrik/dotfiles)

These dotfiles...
- **Are a collection of utilities to speed up your workflow**<br>_Optimized for a front-end web development workflow._
- **Contain no side-effects**<br>_They don't make any changes to your machine without explicit request._
- **Are configurable where needed**<br>_They don't contain info that's specific to myself and are configurable using env variables._
- **Work best with [Oh My ZSH](https://github.com/robbyrussell/oh-my-zsh)**<br>_As that's what I use myself._

Wait, there's more...
- [Option for bootstrapping a new machine and backing up/restoring location dependent config files](#bootstrap)
- [Cherry-picking option available](#cherry-picking)

> Disclaimer: These dotfiles are primarely maintained for personal use so I can't guarantee everything will work out of the box. It's possible you'll run into errors because you use a different shell, have missing dependencies, or because of other reasons. Feel free to resolve the errors in whatever way is most convenient and optionally [contribute](#️-contribute) them back to here.

## What's in it?
Most of the aliases and methods should be pretty self-explanatory. Everything is grouped by category and either has self-explanatory code, a usage message, or a comment that explains what it does and why. If you see anything that is unclear feel free to clear it up by e.g. adding an extra comment and [opening up a pull request](#️-contribute). If you like some things but not others you can also [cherry-pick](#cherry-picking) the parts you like.

## Setup
1. Clone the dotfiles to your home folder (`~`).
2. Configure the files using environment variables and source the `index` file:

In your RC file: (`~/.zshrc` if you use ZSH):
```bash
export GITHUB_USERNAME='kvendrik'
export REPOSITORIES_DIRECTORY='path/to/all/your/cloned/repositories'

source ./dotfiles/index
```

### Cherry-picking
Like some things but not others? Feel free to cherry-pick the files that contain the methods and/or aliases that you like:

```bash
# import the foundation (contains basic settings and utilities)
source './dotfiles/foundation/index.bash'
# import files you like
source './dotfiles/file/you/like.bash'
```

## `./bootstrap`
These dotfiles are a clean collection of aliases and methods so that you don't have to fear any side effects when sourcing them. There are two drawbacks to this:
- There are utilities that I use on my machine that aren't referenced in these dotfiles but I would like to be installed on a new machine.
- There wasn't a way for me to backup and restore config files that require a specific location on my machine.

To address these two issues I created the `./bootstrap` folder:

- `./bootstrap/bootstrap` is a script that can be used to bootstrap a new machine. I try to keep it pretty minimal so that it only installs the very essentials.
- `./bootstrap/~` contains all backed up files relative to the home folder.
- `./bootstrap/~/.zshrc` is my RC file. You'll notice that it doesn't contain any info that is specific to me. This info I keep in a seperate file called `~/.rc-config` (only exists on my machine) and gets sourced by my RC. The RC file also imports an `~/.rc-extra` file (only exists on my machine) that contains setup logic that is very specific to my own workflow.
- `./bootstrap/config-backups` is a utility that helps me back-up these files from my machine and to restore them as needed. Run `./bootstrap/config-backups` for more info on how this utility works.

## 🏗️ Contribute
1. Make your changes.
2. Run `./tests/run-all` to test the changes you make.
3. Open a PR.
