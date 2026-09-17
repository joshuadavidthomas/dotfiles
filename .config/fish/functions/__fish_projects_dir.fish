function __fish_projects_dir
    if set -q PROJECTS_DIR; and test -n "$PROJECTS_DIR"
        printf '%s\n' "$PROJECTS_DIR"
    else if test -d "$HOME/Code"
        printf '%s\n' "$HOME/Code"
    else
        printf '%s\n' "$HOME/projects"
    end
end
