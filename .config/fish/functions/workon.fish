function workon --argument-names project_name
    set -l projects_dir "$HOME/projects"
    set -l projects_file "$projects_dir/.projects"

    if not test -f $projects_file
        touch $projects_file
    end

    if test -z "$project_name"
        set project_name (basename (pwd))
    end

    set -l repo_url ""

    if string match -q 'gh:*' -- $project_name
        set repo_url (string replace 'gh:' 'https://github.com/' $project_name)
    else if string match -q -r '^https?://' -- $project_name
        set repo_url $project_name
    end

    if test -n "$repo_url"
        set project_name (string replace -r '^.*/([^/]+?)(?:\.git)?$' '$1' $repo_url)
    end

    set -l dir_name $projects_dir/$project_name

    if not test -d $dir_name
        if test -n "$repo_url"
            git clone $repo_url $dir_name
            if test $status -ne 0
                echo "Failed to clone repository." >&2
                return 1
            end
            echo "Cloned repository to: $dir_name"
        else
            echo "Project '$project_name' does not exist."
            echo "Options:"
            echo "  1) create - Create a new empty project"
            echo "  2) clone  - Clone a git repository"
            echo "  3) cancel - Cancel operation"
            read -l -P "Choose ([1]create/[2]clone/[3]cancel): " action

            switch $action
                case 1 create
                    mkdir -p $dir_name
                    echo "Created new project directory: $dir_name"

                case 2 clone
                    read -l -P "Enter the git repository URL: " repo_url
                    git clone $repo_url $dir_name
                    if test $status -ne 0
                        echo "Failed to clone repository." >&2
                        return 1
                    end
                    echo "Cloned repository to: $dir_name"

                case 3 cancel
                    echo "Operation cancelled."
                    return 1

                case '*'
                    echo "Invalid option. Operation cancelled."
                    return 1
            end
        end
    end

    set -l current_time (date "+%Y-%m-%d %H:%M:%S")

    # Escape commas in project_name and dir_name if they exist
    set project_name (string replace ',' '\\,' $project_name)
    set dir_name (string replace ',' '\\,' $dir_name)

    echo "$project_name,$dir_name,$current_time" >>$projects_file

    cd $dir_name
    echo "Switched to project: $project_name"
end
