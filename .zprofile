# file runs once at login

# ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  # Check for a currently running instance of the agent
  RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
  if [ "$RUNNING_AGENT" = "0" ]; then
      # Launch a new instance of the agent
      ssh-agent -s &> $HOME/.ssh/ssh-agent
  fi
  # eval `cat $HOME/.ssh/ssh-agent`
fi

if [ -d "$HOME/.pyenv" ] ; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export GPG_TTY=$(tty)

export PIP_CERT=$HOME/.certs/cacert.pem

export REQUESTS_CA_BUNDLE=$HOME/.certs/cacert.pem

export ORACLE_HOME=/opt/oracle/instantclient_21_1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME

# disable upower
# http://blog.miguelalexcantu.com/2020/12/fixing-upower-warning-wslzshspaceship.html
export SPACESHIP_BATTERY_SHOW=false

export NVM_DIR="$HOME/.nvm"
