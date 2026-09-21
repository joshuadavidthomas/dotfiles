# Homebrew packages may be installed by mise without the brew executable.
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source
else if test -d /opt/homebrew/bin
    fish_add_path --global --move /opt/homebrew/bin /opt/homebrew/sbin
else if test -d /home/linuxbrew/.linuxbrew/bin
    fish_add_path --global --move /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin
end

fish_add_path --global "$HOME/.local/bin"

set -g fish_greeting

if status is-interactive
# >>> mise:activate >>> managed by mise - do not edit between markers
mise activate fish | source
# <<< mise:activate <<<
    command -q zoxide; and zoxide init fish | source
    command -q atuin; and atuin init fish | source
    command -q starship; and starship init fish | source
    fish_config theme choose tokyonight_moon
end

# Resolve the editor after mise has activated its tools.
if command -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR vi
end
