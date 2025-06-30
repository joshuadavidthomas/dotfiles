set -l local_env "$HOME/.local/env.fish"
set -l local_bin_env "$HOME/.local/share/../bin/env.fish"
test -f $local_env; and source $local_env
test -f $local_bin_env; and source $local_bin_env
