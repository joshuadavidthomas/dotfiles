if status is-interactive
    # automatically start tmux if not already started
    and not set -q TMUX
        exec tmux
end

# disable intro fish greeting
set -g fish_greeting

# starship
starship init fish | source

# direnv
direnv hook fish | source

# pyenv
pyenv init - | source
status --is-interactive; and pyenv virtualenv-init - | source

# zoxide
zoxide init --cmd cd fish | source
