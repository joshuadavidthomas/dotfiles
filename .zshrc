# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/josh/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"

SPACESHIP_PROMPT_ADD_NEWLINE='false'
SPACESHIP_VENV_PREFIX='(venv) '

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# [oh-my-zsh] Insecure completion-dependent directories detected:
# drwxr-xr-x  11 josh josh  4096 Feb 28 18:32 /home/josh/.oh-my-zsh
# drwxr-xr-x 262 josh josh 12288 Feb 28 18:32 /home/josh/.oh-my-zsh/plugins
# drwxr-xr-x   2 josh josh  4096 Feb 28 18:32 /home/josh/.oh-my-zsh/plugins/git
# drwxr-xr-x   2 josh josh  4096 Feb 28 18:32 /home/josh/.oh-my-zsh/plugins/vscode

# [oh-my-zsh] For safety, we will not load completions from these directories until
# [oh-my-zsh] you fix their permissions and ownership and restart zsh.
# [oh-my-zsh] See the above list for directories with group or other writability.

# [oh-my-zsh] To fix your permissions you can do so by disabling
# [oh-my-zsh] the write permission of "group" and "others" and making sure that the
# [oh-my-zsh] owner of these directories is either root or your current user.
# [oh-my-zsh] The following command may help:
# [oh-my-zsh]     compaudit | xargs chmod g-w,o-w

# [oh-my-zsh] If the above didn't help or you want to skip the verification of
# [oh-my-zsh] insecure directories you can set the variable ZSH_DISABLE_COMPFIX to
# [oh-my-zsh] "true" before oh-my-zsh is sourced in your zshrc file.
ZSH_DISABLE_COMPFIX="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  docker
  git
  pyenv
  virtualenv
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

if [ -f ~/.aliases ]; then
  source $HOME/.aliases
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
