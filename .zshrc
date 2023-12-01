export ZSH=${HOME}/.oh-my-zsh

# ZSH_DISABLE_COMPFIX="true"

# update oh-my-zsh automatically without asking
zstyle ':omz:update' mode auto
# how often to auto-update oh-my-zsh (in days).
zstyle ':omz:update' frequency 13

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
function ssh_identities() {
    local identities=()
    for i in ~/.ssh/*.pub; do
        local filename="${i##*/}"
        identities+=("${filename%.pub}")
    done

    local identity_string=$(IFS=" "; echo "${identities[*]}")
    echo "$identity_string"
}
zstyle :omz:plugins:ssh-agent identities $(ssh_identities)

# colorize plugin config
ZSH_COLORIZE_STYLE="material"

source $ZSH/oh-my-zsh.sh

[ -f "${HOME}/.aliases" ] && source "${HOME}/.aliases"
[ -f "${HOME}/.functions" ] && source "${HOME}/.functions"

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='nvim'
fi

# 1password SSH agent
[ -x "$(command -v 1password)" ] && export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

# starship
[ -x "$(command -v starship)" ] && eval "$(starship init zsh)"

# direnv
[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"

# atuin
[ -x "$(command -v atuin)" ] && eval "$(atuin init zsh)"

# fzf
if [ -f ~/.fzf.zsh ]; then 
  source ~/.fzf.zsh
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# github cli
if [[ ! -d "$ZSH/completions" || ! -f "$ZSH/completions/_gh" ]]; then
  mkdir -pv $ZSH/completions >/dev/null 2>&1
  gh completion --shell zsh > $ZSH/completions/_gh
fi

# bun
if [ -d "$HOME/.bun" ]; then
  # bun completions
  [ -s "/home/josh/.bun/_bun" ] && source "/home/josh/.bun/_bun"
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# yadm completions
# doesn't seem to work atm
# TODO: investigate further
# [ -x "$(command -v yadm)" ] && [ -f "$ZSH/completions/_yadm" ] && source "$ZSH/completions/_yadm"
