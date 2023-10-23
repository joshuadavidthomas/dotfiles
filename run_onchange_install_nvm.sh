#!/usr/bin/env bash

set -euo pipefail

is_pkg_installed() {
	dpkg -l | grep -q "^ii  $1"
}

if ! is_pkg_installed 'curl'; then
	sudo apt update
	sudo apt install -y curl
fi

PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
