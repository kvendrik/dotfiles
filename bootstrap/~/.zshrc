export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

source "$HOME/.rc-config"

export REPOSITORIES_DIRECTORY="$HOME/repos"
source "$HOME/dotfiles/index"

source "$HOME/git_clone_find/git_clone_find"
unalias gcf
alias gcf='git_clone_find'

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/z/z.sh

source "$HOME/.rc-extra"
