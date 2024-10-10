function __fish_workon_projects
    set -l projects_file "$HOME/projects/.projects"
    if test -f $projects_file
        while read -l line
            set -l parts (string split ',' $line)
            set -l project_name $parts[1]
            set -l last_access $parts[3]
            if test -n "$last_access"
                echo $project_name\t"Last accessed: $last_access"
            else
                echo $project_name
            end
        end <$projects_file
    end
end

complete -c workon -f -a "(__fish_workon_projects)"
