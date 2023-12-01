# file runs once at login

export PYENV_DIR="$HOME/.pyenv"
if [ -d "$PYENV_DIR" ] ; then
  export PATH="$PYENV_DIR/bin:$PATH"
  # load pyenv and plugins
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  # load pyenv completions
  [ -s "$PYENV_DIR/completions/pyenv.zsh" ] && source "$PYENV_DIR/completions/pyenv.zsh"
fi

export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ] ; then
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

if [ -f "$HOME/.certs/cacert.pem" ] ; then
  export NODE_EXTRA_CA_CERTS=$HOME/.certs/cacert.pem
  export PIP_CERT=$HOME/.certs/cacert.pem
  export REQUESTS_CA_BUNDLE=$HOME/.certs/cacert.pem
fi

export GPG_TTY=$(tty)

export ORACLE_HOME=/opt/oracle/instantclient_21_1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME

# disable upower
# http://blog.miguelalexcantu.com/2020/12/fixing-upower-warning-wslzshspaceship.html
export SPACESHIP_BATTERY_SHOW=false

export PYTHONSTARTUP=$HOME/.pythonrc

# https://askubuntu.com/a/454663
stty icrnl

export DISABLE_AUTO_TITLE='true'

# Set PATH, MANPATH, etc., for Homebrew.
[ -d "$HOME/linuxbrew" ] && eval "$($HOME/linuxbrew/.linuxbrew/bin/brew shellenv)"
