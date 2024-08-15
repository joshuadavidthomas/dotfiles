function ly --wraps=lazygit --description "alias for lazygit with custom CLI flags for working with yadm"
    set -l yadm_lg_config $HOME/.config/yadm/lazygit.yml
    set -l yadm_git_dir $HOME/.local/share/yadm/repo.git
    set -l yadm_work_tree $HOME

    lazygit --use-config-file="$yadm_lg_config,$(lazygit --print-config-dir)/config.yml" --git-dir=$yadm_git_dir --work-tree=$yadm_work_tree $argv[2..-1]
end
