#!/usr/bin/env bash

set -euo pipefail

is_pkg_installed() {
	dpkg -l | grep -q "^ii  $1"
}

if ! is_pkg_installed 'curl'; then
	sudo apt update
	sudo apt install -y \
		curl \
		build-essential \
		libssl-dev \
		zlib1g-dev \
		libbz2-dev \
		libreadline-dev \
		libsqlite3-dev \
		libncursesw5-dev \
		xz-utils \
		tk-dev \
		libxml2-dev \
		libxmlsec1-dev \
		libffi-dev \
		liblzma-dev
fi

if [ -d "$HOME/.pyenv" ]; then
	mkdir -p /tmp/.pyenv-versions-bak
	mv $HOME/.pyenv/versions/* /tmp/.pyenv-versions-bak/
	rm -rf $HOME/.pyenv
fi

curl https://pyenv.run | bash

if ! [ -d "/tmp/.pyenv-versions-bak" ]; then
	pyenv install 3.11
	pyenv global 3.11
else
	mkdir -p $HOME/.pyenv/versions
	mv /tmp/.pyenv-versions-bak/* $HOME/.pyenv/versions/
	rm -rf /tmp/.pyenv-versions-bak
fi
