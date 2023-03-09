export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell_with_host"
plugins=(git)

export SCAFFOLD_GIST_CLONE_URL="git@gist.github.com:5feb8a8f1463bcb1c4811b04246fd018.git"
export SCAFFOLD_FOLDER="$HOME/Desktop"

[ -f "$HOME/.rc-config" ] && source "$HOME/.rc-config"
source $ZSH/oh-my-zsh.sh
source "$HOME/dotfiles/index"

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f "$HOME/.rc-extra" ] && source "$HOME/.rc-extra"

export PATH="$PATH:$HOME/dotfiles/bin"
