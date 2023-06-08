-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  
  -- Telescope.nvim provides an interface for easily browsing and navigating
  -- through files and directories in a project.
  -- It provides a fuzzy finder, a previewer, and a file browser.
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.0',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  -- Treesitter is a parser generator tool and an incremental parsing library.
  -- It can parse source code and provides an interface to efficiently navigate
  -- the abstract syntax tree. Treesitter is used by Neovim to provide syntax
  -- highlighting and code navigation.
  use({'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'})
  use('nvim-treesitter/playground')

  -- GitHub Copilot is an AI-powered programming assistant that helps 
  -- developers write code faster and more accurately by providing code 
  -- completions, inline documentation, error suggestions, and other helpful
  -- features.
  use("github/copilot.vim")

  -- obligatory tpope section of plugins
  --
  -- sensible.vim is a plugin that provides a set of defaults that everyone can
  -- agree on.
  use('tpope/vim-sensible')
  -- fugitive.vim is a Git wrapper so awesome, it should be illegal (according
  -- to the author). It provides a Git porcelain inside Vim. It provides a set
  -- of commands that allow you to do almost everything you can do with Git
  -- from the command line, but from inside Vim.
  use('tpope/vim-fugitive')
  -- commentary.vim is a plugin that allows you to quickly comment and
  -- uncomment lines in Vim. It supports commenting out a single line, a
  -- visual selection, or a motion.
  use('tpope/vim-commentary')
  -- surround.vim is a plugin that allows you to easily surround text with
  -- quotes, parentheses, brackets, and more. It provides mappings to easily
  -- delete, change, and add such surroundings in pairs.
  use('tpope/vim-surround')
  -- repeat.vim is a plugin that enables repeating supported plugin maps with
  -- the dot command. It provides a :Repeat command that can be used to repeat
  -- a plugin map.
  use('tpope/vim-repeat')
  --
  -- end of obligatory tpope section of plugins

  -- Harpoon is a plugin that allows you to mark files and jump to them easily.
  use('ThePrimeagen/harpoon')
end)
