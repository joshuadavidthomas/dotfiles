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
  ssh-agent
  virtualenv
  z
  # zsh-autosuggestions
  # zsh-autocomplete
  # zsh-syntax-highlighting
)

# ssh-agent plugin config
zstyle :omz:plugins:ssh-agent identities hetzner id_ed25519 id_ed25519_do id_ed25519_twc

source $ZSH/oh-my-zsh.sh

for file in ${DOTFILES}/utils/*; do
  source $file
done

# zstyle ':completion:*' menu select

ZSH_COLORIZE_STYLE="material"

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# export SSH_KEY_PATH="~/.ssh/id_ed25519:~/.ssh/id_ed25519_twc:~/.ssh/id_ed25519_do"

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# github cli
if [[ ! -d "$ZSH/completions" || ! -f "$ZSH/completions/_gh" ]]; then
    mkdir -pv $ZSH/completions >/dev/null 2>&1
    gh completion --shell zsh > $ZSH/completions/_gh
fi
# autoload -U compinit
# compinit -i

# zsh-autocomplete
# zstyle ':autocomplete:*' min-input 1

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# tmuxp autocompletions
if ! [ -x "$(command -v tmuxp)" ]; then
    eval "$(_TMUXP_COMPLETE=zsh_source tmuxp)"
fi
