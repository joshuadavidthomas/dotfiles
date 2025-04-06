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
        log_status "No virtual environment exists. Executing \`uv venv\` to create one."
        uv venv --seed
    fi

    if [[ -f "uv.lock" ]]; then
        log_status "Syncing with project lock file"
        uv sync --quiet

        export_alias "uva" "uv add"
        export_alias "uve" "uv export"
        export_alias "uvi" "uv pip install"
        export_alias "uvl" "uv lock"
        export_alias "uvr" "uv run"
        export_alias "uvs" "uv sync"
        export_alias "uvt" "uv tree"

        log_status "Aliases:"
        log_status "  uva [packages...] - Add package(s) as project dependency"
        log_status "  uve - Export project requirements"
        log_status "  uvi [packages...] - Install package(s) in project environment"
        log_status "  uvl - Lock project dependencies"
        log_status "  uvr [args...] - Run Python in project environment"
        log_status "  uvs - Sync project environment"
        log_status "  uvt - Show project dependency tree"
    fi

    PATH_add "$VIRTUAL_ENV/bin"
    export UV_ACTIVE=1
    export VIRTUAL_ENV
}

layout_uvscript() {
    log_prefix="layout uvscript"

    local all_scripts=()
    local script_paths=()
    local missing_paths=()

    mapfile -t all_scripts < <(fd -d 1 '\.py$' --strip-cwd-prefix 2>/dev/null || echo "")

    if [[ ${#all_scripts[@]} -eq 0 ]]; then
        log_error "No Python scripts found in this directory."
        return 1
    fi

    log_status "Adding script environments to PYTHONPATH"
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

    export_alias "uvas" "uv add --script"
    export_alias "uves" "uv export --script"
    export_alias "uvis" "uv pip install --script"
    export_alias "uvls" "uv lock --script"
    export_alias "uvrs" "uv run --script"
    export_alias "uvss" "uv sync --script"
    export_alias "uvts" "uv tree --script"

    log_status "Aliases:"
    log_status "  uvas [script.py] [packages...] - Add package(s) as dependency to script"
    log_status "  uves [script.py] - Export requirements for a script"
    log_status "  uvis [script.py] [packages...] - Install package(s) in script's environment"
    log_status "  uvls [script.py] - Lock dependencies for a script"
    log_status "  uvrs [script.py] [args...] - Run a script"
    log_status "  uvss [script.py] - Sync a script's environment"
    log_status "  uvts [script.py] - Show dependency tree for a script"
}
