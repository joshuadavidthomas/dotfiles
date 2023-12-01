if status is-interactive
    # Commands to run in interactive sessions can go here
end

# starship
starship init fish | source

# direnv
direnv hook fish | source

# zoxide
zoxide init fish | source

# pyenv
pyenv init - | source
status --is-interactive; and pyenv virtualenv-init - | source
