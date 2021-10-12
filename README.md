[![CircleCI](https://circleci.com/gh/kvendrik/dotfiles.svg?style=svg)](https://circleci.com/gh/kvendrik/dotfiles)

These dotfiles...
- **Are a collection of utilities to speed up your workflow**<br>_Optimized for a front-end web development workflow._
- **Contain no side-effects**<br>_They don't make any changes to your machine without explicit request._
- **Are configurable where needed**<br>_They don't contain info that's specific to myself and are configurable using env variables._
- **Work best with [Oh My ZSH](https://github.com/robbyrussell/oh-my-zsh) on OS X**<br>_As that's what I use myself._

Wait, there's more...
- [Option for quickly bootstrapping a new machine](#setup)
- [Cherry-picking option available](#cherry-picking)

> Disclaimer: These dotfiles are primarely maintained for personal use so I can't guarantee everything will work out of the box. It's possible you'll run into errors because you use a different shell, have missing dependencies, or because of other reasons. Feel free to resolve the errors in whatever way is most convenient and optionally [contribute](#️-contribute) them back to here.

## What's in it?
Most of the aliases and methods should be pretty self-explanatory. Everything is grouped by category and either has self-explanatory code, a usage message, or a comment that explains what it does and why. If you see anything that is unclear feel free to clear it up by e.g. adding an extra comment and [opening up a pull request](#️-contribute). If you like some things but not others you can also [cherry-pick](#cherry-picking) the parts you like.

## Setup
1. Clone the dotfiles to your home folder.
1. (Optional) Run `./setup` if you'd like to use the home files `./home/*`, use the provided ZSH and Terminal themes, and/or want to install several (optional) dependencies.
1. Configure the utilities using environment variables and source the `index` file:

> If you decide to symlink the provided `./home/.zshrc` file in the `./setup` step: you can create a `~/.rc-config` file to export these variables from.

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

## Directories
- `./home/`<br>Contains files that can be symlinked to your home folder by running `./setup`

- `./scripts/`<br>
Standalone executables to speed up various tasks

- `./tests/`<br>Contains various tests for these dotfiles that are ran on CI or manually by running `./tests/run-all`

- Everything else is utility code that can be used by sourcing `./index` (see setup instructions) or is self-explanatory (e.g. `./.circleci/`, `./zsh-themes/`)

## 🏗️ Contribute
1. Make your changes.
2. Run `./tests/run-all` to test the changes you make.
3. Open a PR.
