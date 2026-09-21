alias lg="lazygit"
if test -f "$HOME/.justfile"
    alias j="just --justfile ~/.justfile --working-directory ."
else
    alias j="just"
end
alias vim="nvim"
