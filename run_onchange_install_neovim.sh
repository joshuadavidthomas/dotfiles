#!/usr/bin/env bash

set -euo pipefail

is_pkg_installed() {
	dpkg -l | grep -q "^ii  $1"
}

if ! is_pkg_installed 'curl'; then
	sudo apt update
	sudo apt install -y software-properties-common
fi

sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update
sudo apt-get install neovim -y
