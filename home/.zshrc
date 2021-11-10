export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell_with_host"
plugins=(git)

source "$HOME/.rc-config"
source $ZSH/oh-my-zsh.sh
source "$HOME/dotfiles/index"

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f "$HOME/.rc-extra" ] && source "$HOME/.rc-extra"

export PATH="$PATH:$HOME/dotfiles/bin"

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }

[[ -x /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)
