# file runs once at login

# ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  # Check for a currently running instance of the agent
  RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
  if [ "$RUNNING_AGENT" = "0" ]; then
      # Launch a new instance of the agent
      ssh-agent -s &> $HOME/.ssh/ssh-agent > /dev/null 2>&1
  fi
  eval `cat $HOME/.ssh/ssh-agent`
fi

export GPG_TTY=$(tty)

export PIP_CERT=$HOME/.certs/cacert.pem

export REQUESTS_CA_BUNDLE=$HOME/.certs/cacert.pem

export ORACLE_HOME=/opt/oracle/instantclient_21_1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME

# disable upower
# http://blog.miguelalexcantu.com/2020/12/fixing-upower-warning-wslzshspaceship.html
export SPACESHIP_BATTERY_SHOW=false

export NVM_DIR="$HOME/.nvm"
