#!/usr/bin/env bash

set -euo pipefail

KERNAL=$(uname -s | tr "[:upper:]" "[:lower:]")
MACHINE=amd64
LOCAL_BIN_DIR=${HOME}/bin

is_pkg_installed() {
	dpkg -l | grep -q "^ii  $1"
}

if ! is_pkg_installed 'curl'; then
	sudo apt update
	sudo apt install -y curl
fi

version=$(curl "https://api.github.com/repos/cli/cli/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)
curl -sSL https://github.com/cli/cli/releases/download/v${version}/gh_${version}_${KERNAL}_${MACHINE}.tar.gz -o gh_${version}_${KERNAL}_${MACHINE}.tar.gz
tar xvf gh_${version}_${KERNAL}_${MACHINE}.tar.gz
mv gh_${version}_${KERNAL}_${MACHINE}/bin/gh ${LOCAL_BIN_DIR}/gh
sudo mv gh_${version}_${KERNAL}_${MACHINE}/share/man/man1/* /usr/share/man/man1/
chmod +x "${LOCAL_BIN_DIR}/gh"
