# https://treyhunner.com/2024/10/switching-from-virtualenvwrapper-to-direnv-starship-and-uv/
function venv
    set -l force false
    set -l venv_name
    set -l dir_name (basename $PWD)
    set -l uv_args
    set -l python_version

    # Parse options
    set -l options
    for arg in $argv
        switch $arg
            case -f --force
                set force true
            case --python
                set -a options $arg
                set python_version true
            case '*'
                if test "$python_version" = true
                    set -a options $arg
                    set python_version false
                else
                    set -a options $arg
                end
        end
    end

    # Determine venv name
    if test (count $options) -eq 0
        set venv_name $dir_name
    else if test -n "$python_version"
        set venv_name $dir_name
    else
        set venv_name $options[-1]
        set -e options[-1]
    end

    # Check if .envrc already exists
    if test -f .envrc; and test $force = false
        echo "Error: .envrc already exists. Use --force or -f to recreate." >&2
        return 1
    end

    # Remove existing .envrc and venv if force is true
    if test $force = true
        test -f .envrc && rm .envrc
        test -d $venv_name && rm -rf $venv_name
    end

    # Prepare uv arguments
    set -a uv_args --seed
    set -a uv_args --prompt $venv_name
    set -a uv_args $options
    set -a uv_args $venv_name

    # Create venv using uv with all passed arguments
    if not uv venv $uv_args
        echo "Error: Failed to create venv" >&2
        return 1
    end

    # Check for uv.lock and run uv sync if it exists
    if test -f uv.lock
        echo "Found uv.lock, running uv sync..."
        if not uv sync
            echo "Warning: uv sync failed" >&2
        end
    end

    # Create .envrc
    echo "layout python" >.envrc

    # Update ~/.projects without duplication
    set -l projects_file ~/.projects
    set -l project_entry "$dir_name = $PWD"
    if test -f $projects_file
        # Remove any existing entries for this project
        set -l temp_file (mktemp)
        grep -v "^$dir_name =" $projects_file >$temp_file
        mv $temp_file $projects_file
    end
    echo $project_entry >>$projects_file

    # Allow direnv to immediately activate the virtual environment
    direnv allow
end
