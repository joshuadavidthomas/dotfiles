if status is-interactive
    # Check if we are not already in a tmux session and if the terminal is not WezTerm
    if not set -q TMUX; and not string match -q WezTerm $TERM_PROGRAM
        exec tmux # Start tmux
    end
    # If the terminal is WezTerm or already in a tmux session, continue with normal fish initialization
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

# atuin
status --is-interactive; and atuin init fish | source

# mise
mise activate fish | source
