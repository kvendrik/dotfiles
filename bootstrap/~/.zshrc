export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

source "$HOME/.rc-config"

export REPOSITORIES_DIRECTORY="$HOME/repos"
source "$HOME/dotfiles/index"

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

source "$HOME/.rc-extra"
