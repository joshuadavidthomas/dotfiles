export ZSH=${HOME}/.oh-my-zsh
export DOTFILES=${HOME}/.dotfiles

ZSH_DISABLE_COMPFIX="true"

plugins=(
  docker
  git
  nvm
  python
  pyenv
  virtualenv
  zsh-z
)

source $ZSH/oh-my-zsh.sh
source $DOTFILES/utils/update

zstyle ':completion:*' menu select

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/id_ed25519:~/.ssh/id_ed25519_twc:~/.ssh/id_ed25519_do"

if [ -f ~/.aliases ]; then
  source ${HOME}/.aliases
fi

if [ -f ~/.functions ]; then
  source ${HOME}/.functions
fi

# starship
eval "$(starship init zsh)"

# direnv
eval "$(direnv hook zsh)"
