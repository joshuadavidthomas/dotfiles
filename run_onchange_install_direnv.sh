#!/usr/bin/env bash

set -euo pipefail

is_pkg_installed() {
	dpkg -l | grep -q "^ii  $1"
}

if ! is_pkg_installed 'curl'; then
	sudo apt update
	sudo apt install -y curl
fi

curl -sfL https://direnv.net/install.sh | bash
