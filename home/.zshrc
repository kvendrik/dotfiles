if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell_with_host"
  plugins=(git)
  source $ZSH/oh-my-zsh.sh
fi

[ -f "$HOME/.rc-config" ] && source "$HOME/.rc-config"

source "$HOME/dotfiles/index"

[ -d "$HOME/.zsh/zsh-autosuggestions" ] && source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f "$HOME/.rc-extra" ] && source "$HOME/.rc-extra"
