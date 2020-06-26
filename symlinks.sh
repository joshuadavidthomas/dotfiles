#!/bin/bash
dir=~/dotfiles
olddir=~/dotfiles_old
files="aliases bashrc gitconfig vimrc zshrc"

# create $olddir in homedir
if [ ! -d $olddir ]; then 
  echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
  mkdir -p $olddir
  echo "done"
fi

for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/.$file $olddir
    echo "Creating symlink to $file in home directory."
    ln -sf $dir/.$file ~/.$file 
done