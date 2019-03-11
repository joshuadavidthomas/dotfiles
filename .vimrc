set nocompatible              " be iMproved, required
filetype off                  " required

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'mileszs/ack.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'flazz/vim-colorschemes'
Plugin 'tpope/vim-fugitive'

call vundle#end()
filetype plugin indent on
" End Vundle

inoremap jk <ESC>
let mapleader = ","

syntax enable " enable syntax processing
colorscheme badwolf
set termguicolors 
set tabstop=4 " number of visual spaces per TAB
set softtabstop=4 " number of spaces in tab when editing
set expandtab " tabs are spaces
