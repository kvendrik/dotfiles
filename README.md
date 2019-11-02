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

source ./dotfiles/index
```

> Note: It's possible that while using the dotfiles you'll run into errors because of dependencies that are not installed on your machine. If this happens feel free to install them using a package manager of your choosing.

### Cherry-picking
Like some things but not others? Feel free to cherry-pick the files that contain the methods and/or aliases that you like:

```bash
# import the foundation (contains basic settings and utilities)
source './dotfiles/foundation/index.bash'
# import files you like
source './dotfiles/file/you/like.bash'
```

## `./bootstrap`
These dotfiles are a clean collection of aliases and methods so that you don't have to fear any side effects when sourcing them.

There are two drawbacks to this:
- There are utilities that I use on my machine that aren't referenced in these dotfiles but I would like to be installed on a new machine.
- There wasn't a way for me to backup and restore config files that require a specific location on my machine.

To address these two issues I created the `./bootstrap` folder:

- `./bootstrap/bootstrap` is a script that can be used to bootstrap a new machine. I try to keep it pretty minimal so that it only installs the very essentials.
- `./bootstrap/~` contains all backed up files relative to the home folder.
- `./bootstrap/~/.zshrc` is my RC file. You'll notice that it doesn't contain any info that is specific to me. This info I keep in a seperate file called `~/.rc-config` (only exists on my machine) and gets sourced by my RC. The RC file also imports an `~/.rc-extra` file (only exists on my machine) that contains setup logic that is very specific to my own workflow.
- `./bootstrap/config-backups` is a utility that helps me back up these files from my machine and to restore them as needed. Run `./bootstrap/config-backups` for more info on how this utility works.

## Contribute
1. Make your changes.
2. Changes should:
    - Contain no big side-effects<br>_Don't: automatically install dependencies. Do: Check if env required variable is set._
    - Prefix utility methods with a double underscore<br>_For example: `__some-utility`_
    - Keep utility methods local to the file they're used in as much as possible<br>_If they're used across the codebase add them to `./foundation`. The idea here is to only require consumers to have to import `./foundation` and to then be able to source any other file (cherry-picking)._
3. Run `./lint` to lint changes you make.
4. Open a PR.
