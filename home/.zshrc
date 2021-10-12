export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell_with_host"
plugins=(git)

source $ZSH/oh-my-zsh.sh

source "$HOME/.rc-config"

source "$HOME/dotfiles/index"
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

eval `dircolors ~/.dircolors`

[ -f "$HOME/.rc-extra" ] && source "$HOME/.rc-extra"
