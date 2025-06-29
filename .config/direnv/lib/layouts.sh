#!/usr/bin/env bash

set -oue pipefail

layout_bun() {
    log_prefix="layout bun"

    watch_file bun.lock

    log_status "Installing project dependencies"
    bun --silent install &>/dev/null
}

layout_uv() {
    log_prefix="layout uv"

    watch_file uv.lock

    VIRTUAL_ENV="$(pwd)/.venv"

    if [[ ! -d "$VIRTUAL_ENV" ]]; then
        log_status "No virtual environment exists."
        log_status "Executing \`uv venv\` to create one."
        uv venv --seed
    fi

    if [[ -f "uv.lock" ]]; then
        log_status "Syncing with project lock file"
        uv sync --quiet

        log_status "Aliases:"

        log_status "  uva [packages...] - Add package(s) as project dependency"
        export_alias "uva" "uv add"

        log_status "  uve - Export project requirements"
        export_alias "uve" "uv export"

        log_status "  uvi [packages...] - Install package(s) in project environment"
        export_alias "uvi" "uv pip install"

        log_status "  uvl - Lock project dependencies"
        export_alias "uvl" "uv lock"

        log_status "  uvr [args...] - Run Python in project environment"
        export_alias "uvr" "uv run"

        log_status "  uvs - Sync project environment"
        export_alias "uvs" "uv sync"

        log_status "  uvt - Show project dependency tree"
        export_alias "uvt" "uv tree"

    elif [[ -f "requirements.txt" ]]; then
        log_status "Syncing with requirements.txt"
        uv pip install -r requirements.txt --quiet

        log_status "Aliases:"

        log_status "  uvi [packages...] - Install package(s) in project environment"
        export_alias "uvi" "uv pip install"

        log_status "  uvl [pyproject.toml|requirements.in] - Lock project dependencies"
        export_alias "uvl" "uv pip compile"

        log_status "  uvr [args...] - Run Python in project environment"
        export_alias "uvr" "uv run"

        log_status "  uvs - Sync project environment"
        export_alias "uvs" "uv pip install -r requirements.txt"
    fi

    PATH_add "$VIRTUAL_ENV/bin"
    export UV_ACTIVE=1
    export VIRTUAL_ENV
}

layout_uvscript() {
    log_prefix="layout uvscript"

    local script_dir="${1:-.}"
    if [[ ! -d "$script_dir" ]]; then
        log_error "Directory '$script_dir' does not exist, falling back to current directory"
        script_dir="."
    fi

    local all_scripts=()
    mapfile -t all_scripts < <(fd -d 1 '\.py$' "$script_dir" 2>/dev/null || echo "")
    if [[ ${#all_scripts[@]} -eq 0 ]]; then
        log_error "No Python scripts found in directory: $script_dir"
        return 1
    fi

    local default_python_path=$(uv python find 2>/dev/null || echo "")
    for script in "${all_scripts[@]}"; do
        local script_python_path=$(uv python find --script "$script" 2>/dev/null || echo "")

        if [[ "$script_python_path" == "$default_python_path" ]]; then
            log_status "No virtual environment exists for $script."
            log_status "Executing \`uv sync --script $script\` to create one."
            uv sync --script "$script" --quiet
        fi
    done

    log_status "Adding script environments to PYTHONPATH"
    local script_paths=()
    for script in "${all_scripts[@]}"; do
        local script_venv_path=$(uv python find --script "$script" 2>/dev/null || echo "")

        if [[ -n "$script_venv_path" ]]; then
            local script_venv=$(dirname "$(dirname "$script_venv_path")")
            local site_packages=$(fd -t d "site-packages" "$script_venv/lib" --max-depth 2 | head -n 1)

            if [[ -n "$site_packages" ]]; then
                path_add PYTHONPATH $site_packages
                script_paths+=("$site_packages")
            fi
        fi
    done

    local tool_name="Pyright"
    local docs_link="https://github.com/microsoft/pyright/blob/main/docs/configuration.md#execution-environment-options"
    local config_file=""
    if [[ -f "pyrightconfig.json" ]]; then
        config_file="pyrightconfig.json"
    elif [[ -f "pyproject.toml" ]]; then
        config_file="pyproject.toml"
        if rg -q "\[tool\.basedpyright\]" pyproject.toml; then
            tool_name="Basedpyright"
            docs_link="https://docs.basedpyright.com/latest/configuration/config-files/#execution-environment-options"
        fi
    fi

    local missing_paths=()
    if [[ -n "$config_file" ]] && [[ ${#script_paths[@]} -gt 0 ]]; then
        for path in "${script_paths[@]}"; do
            local escaped_path=$(echo "$path" | sed 's/[\/&]/\\&/g')
            if ! rg -q "$escaped_path" "$config_file"; then
                missing_paths+=("$path")
            fi
        done
    elif [[ ${#script_paths[@]} -gt 0 ]]; then
        missing_paths=("${script_paths[@]}")
    fi

    if [[ ${#missing_paths[@]} -gt 0 ]]; then
        log_status "${tool_name}:"
        log_status "  Config missing script paths in executionEnvironments"
        log_status "  Missing paths:"
        for path in "${missing_paths[@]}"; do
            log_status "    * ${path}"
        done
        log_status "  Reference: ${docs_link}"
    fi

    if [[ ${#all_scripts[@]} -eq 1 ]]; then
        local script="${all_scripts[0]}"

        log_status "Aliases:"

        log_status "  uva [packages...] - Add package(s) as dependency to $script"
        export_alias "uva" "uv add --script $script"

        log_status "  uve - Export requirements for $script"
        export_alias "uve" "uv export --script $script"

        log_status "  uvi [packages...] - Install package(s) in $script's environment"
        export_alias "uvi" "uv pip install --script $script"

        log_status "  uvl - Lock dependencies for $script"
        export_alias "uvl" "uv lock --script $script"

        log_status "  uvr [args...] - Run $script"
        export_alias "uvr" "uv run --script $script"

        log_status "  uvs - Sync $script's environment"
        export_alias "uvs" "uv sync --script $script"

        log_status "  uvt - Show dependency tree for $script"
        export_alias "uvt" "uv tree --script $script"

    else
        log_status "Aliases:"

        log_status "  uvas [script.py] [packages...] - Add package(s) as dependency to script"
        export_alias "uvas" "cd $script_dir && uv add --script"

        log_status "  uves [script.py] - Export requirements for a script"
        export_alias "uves" "cd $script_dir && uv export --script"

        log_status "  uvis [script.py] [packages...] - Install package(s) in script's environment"
        export_alias "uvis" "cd $script_dir && uv pip install --script"

        log_status "  uvls [script.py] - Lock dependencies for a script"
        export_alias "uvls" "cd $script_dir && uv lock --script"

        log_status "  uvrs [script.py] [args...] - Run a script"
        export_alias "uvrs" "cd $script_dir && uv run --script"

        log_status "  uvss [script.py] - Sync a script's environment"
        export_alias "uvss" "cd $script_dir && uv sync --script"

        log_status "  uvts [script.py] - Show dependency tree for a script"
        export_alias "uvts" "cd $script_dir && uv tree --script"
    fi
}
