# disable intro fish greeting
set -g fish_greeting
set -gx EDITOR vim

# starship
starship init fish | source

# direnv
direnv hook fish | source

# mise
mise activate fish | source

# zoxide
zoxide init fish | source

# atuin
status --is-interactive; and atuin init fish | source

# homebrew completions
if command -q brew; and test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end
