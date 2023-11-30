# file runs once at login

# ssh-agent
# if [ -z "$SSH_AUTH_SOCK" ]; then
#   # Check for a currently running instance of the agent
#   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
#   if [ "$RUNNING_AGENT" = "0" ]; then
#       # Launch a new instance of the agent
#       ssh-agent -s &> $HOME/.ssh/ssh-agent
#   fi
#   eval `cat $HOME/.ssh/ssh-agent`
# fi

export PYENV_DIR="$HOME/.pyenv"
if [ -d "$PYENV_DIR" ] ; then
  export PATH="$PYENV_DIR/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ] ; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

export NODE_EXTRA_CA_CERTS=$HOME/.certs/cacert.pem

export GPG_TTY=$(tty)

# export PIP_CERT=$HOME/.certs/cacert.pem

# export REQUESTS_CA_BUNDLE=$HOME/.certs/cacert.pem

# export PANTS_CA_CERTS_PATH=$HOME/.certs/cacert.pem

export ORACLE_HOME=/opt/oracle/instantclient_21_1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME

# disable upower
# http://blog.miguelalexcantu.com/2020/12/fixing-upower-warning-wslzshspaceship.html
export SPACESHIP_BATTERY_SHOW=false

export PYTHONSTARTUP=$HOME/.pythonrc

# https://askubuntu.com/a/454663
stty icrnl

export DISABLE_AUTO_TITLE='true'

if [ -d "$HOME/linuxbrew" ] ; then
  # Set PATH, MANPATH, etc., for Homebrew.
  eval "$($HOME/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
