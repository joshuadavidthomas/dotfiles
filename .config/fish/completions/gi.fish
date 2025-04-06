function __fish_print_gitignore_list
    if ! set -q __FISH_PRINT_GITIGNORE_LIST
        set -g __FISH_PRINT_GITIGNORE_LIST (curl -sL https://www.toptal.com/developers/gitignore/api/list)
    end
    echo $__FISH_PRINT_GITIGNORE_LIST | string split ","
end

complete -xc gi -a '(__fish_print_gitignore_list)'
