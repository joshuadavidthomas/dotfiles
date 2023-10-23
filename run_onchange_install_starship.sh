#!/usr/bin/env bash

set -euo pipefail

is_pkg_installed() {
	dpkg -l | grep -q "^ii  $1"
}

if ! is_pkg_installed 'curl'; then
	sudo apt update
	sudo apt install -y curl
fi

curl -sS https://starship.rs/install.sh | sh -s -- -y
