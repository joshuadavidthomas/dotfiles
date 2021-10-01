#!/usr/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace

INSTALL_DIR=${HOME}/.dotfiles

git clone git@github.com:joshuadavidthomas/dotfiles.git ${INSTALL_DIR}

ln -sf ${INSTALL_DIR}/.aliases ${HOME}/.aliases 
ln -sf ${INSTALL_DIR}/.gitconfig ${HOME}/.gitconfig 
ln -sf ${INSTALL_DIR}/.npmrc ${HOME}/.npmrc 
ln -sf ${INSTALL_DIR}/.zprofile ${HOME}/.zprofile 
ln -sf ${INSTALL_DIR}/.zshenv ${HOME}/.zshenv 
ln -sf ${INSTALL_DIR}/.zshrc ${HOME}/.zshrc 

for binary in ${INSTALL_DIR}/bin/*
do
  ln -sf ${binary} ${HOME}/.local/bin
done
