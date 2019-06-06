export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

if [ -f "$HOME/.rc-setup" ]; then
  source "$HOME/.rc-setup"
fi

export REPOSITORIES_DIRECTORY="$HOME/Desktop/repos"
source "$HOME/dotfiles/index"

if [ ! -d "$HOME/git_clone_find" ]; then
  git clone git@github.com:kvendrik/git_clone_find.git "$HOME/git_clone_find"
fi

source "$HOME/git_clone_find/git_clone_find"
unalias gcf
alias gcf='git_clone_find'

if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
