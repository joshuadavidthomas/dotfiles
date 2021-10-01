[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

if [ -d "$HOME/.pyenv" ] ; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"