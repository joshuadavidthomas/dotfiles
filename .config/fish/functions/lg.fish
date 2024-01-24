function lg --wraps=lazygit --description 'alias lg=lazygit'
    # if the first argument is 'yadm', we want to call lazygit with a different
    # working directory and git directory
    if test "$argv[1]" = "yadm"
        # Set the desired working and git directories for 'yadm'
        set -l yadm_work_tree $HOME
        set -l yadm_git_dir  $HOME/.local/share/yadm/repo.git

        # Call lazygit without the first argument ('yadm')
        lazygit --git-dir=$yadm_git_dir --work-tree=$yadm_work_tree $argv[2..-1]
    else
        # Normal lazygit call with all arguments
        lazygit $argv
    end
end
