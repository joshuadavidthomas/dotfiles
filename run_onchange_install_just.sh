#!/usr/bin/env bash

set -euo pipefail

LOCAL_BIN_DIR=${HOME}/bin

is_pkg_installed() {
	dpkg -l | grep -q "^ii  $1"
}

if ! is_pkg_installed 'curl'; then
	sudo apt update
	sudo apt install -y curl
fi

curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --force --to ${LOCAL_BIN_DIR}
