#!/bin/bash
dir=~/.dotfiles
olddir=~/.dotfiles_old
files="bashrc bash_aliases zshrc"

# create $olddir in homedir
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/.$file $olddir
    echo "Creating symlink to $file in home directory."
    ln -sf $dir/.$file ~/.$file 
done