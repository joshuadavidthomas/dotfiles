[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

export PATH="/usr/local/go/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

export FLYCTL_INSTALL="/home/josh/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

skip_global_compinit=1

[ -d "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export PATH="$HOME/.luarocks/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"
