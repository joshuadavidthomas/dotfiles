export ZSH=${HOME}/.oh-my-zsh
export DOTFILES=${HOME}/.dotfiles

ZSH_DISABLE_COMPFIX="true"

plugins=(
  colorize
  docker
  git
  nvm
  python
  pyenv
  virtualenv
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

for file in ${DOTFILES}/utils/*; do
  source $file
done

zstyle ':completion:*' menu select

ZSH_COLORIZE_STYLE="material"

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
  export EDITOR='nvim'
fi

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
