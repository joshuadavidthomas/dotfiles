#!/usr/bin/env bash

set -euo pipefail

sudo apt-get update

sudo apt-get install -y --no-install-recommends \
	build-essential \
	curl \
	ripgrep \
	tmux \
	unzip \
	zsh

chsh -s $(which zsh)
