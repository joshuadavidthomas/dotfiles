#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace

INSTALL_DIR=${HOME}/.dotfiles
OH_MY_ZSH_DIR=${HOME}/.oh-my-zsh

if [ ! -d $INSTALL_DIR ]; then
  echo "Cloning dotfiles in to $INSTALL_DIR"
  mkdir -p $INSTALL_DIR
  git clone git@github.com:joshuadavidthomas/dotfiles.git ${INSTALL_DIR}
else
  echo "Updating dotfiles"
  cd ${INSTALL_DIR}
  git pull
fi

if [ ! -d $OH_MY_ZSH_DIR ]; then
  echo "Cloning oh-my-zsh in to $OH_MY_ZSH_DIR"
  umask g-w,o-w
  git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    --depth=1 --branch master git clone https://github.com/ohmyzsh/ohmyzsh ${OH_MY_ZSH_DIR}
else
  echo "Updating oh-my-zsh"
  cd ${OH_MY_ZSH_DIR}
  git pull
fi

sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

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

for config in ${INSTALL_DIR}/.config/*
do
  ln -sf ${config} ${HOME}/.config
done
