#!/usr/bin/bash

INSTALL_DIR=${HOME}/.dotfiles

git clone https://github.com/joshuadavidthomas/dotfiles ${INSTALL_DIR}

ln -sf ${INSTALL_DIR}/.aliases ${HOME}/.aliases 
ln -sf ${INSTALL_DIR}/.gitconfig ${HOME}/.gitconfig 
ln -sf ${INSTALL_DIR}/.npmrc ${HOME}/.npmrc 
ln -sf ${INSTALL_DIR}/.zprofile ${HOME}/.zprofile 
ln -sf ${INSTALL_DIR}/.zshenv ${HOME}/.zshenv 
ln -sf ${INSTALL_DIR}/.zshrc ${HOME}/.zshrc 
