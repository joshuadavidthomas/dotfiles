#!/usr/bin/env bash

set -oue pipefail

export_alias() {
    local name=$1
    shift

    alias_dir="$PWD/.direnv/aliases"
    [[ ! -d "$alias_dir" ]] && rm -rf "$alias_dir"

    local alias_file="$alias_dir/$name"
    local oldpath="$PATH"

    if ! [[ ":$PATH:" == *":$alias_dir:"* ]]; then
        mkdir -p "$alias_dir" || {
            log_error "Failed to create alias directory"
            return 1
        }
        PATH_add "$alias_dir"
    fi

    cat <<EOF >"$alias_file"
#!/usr/bin/env bash
set -euo pipefail
PATH="$oldpath"
$@ "\$@"
EOF

    chmod +x "$alias_file" || {
        log_error "Failed to set execute permission on alias file"
        return 1
    }
}

gitignore_local() {
    local log_prefix="gitignore_local"

    watch_file .gitignore.local

    if [ -f ".gitignore.local" ] && [ -d ".git" ]; then
        log_status "Found .gitignore.local file"
        mkdir -p ".git/info" || {
            log_error "Failed to create .git/info directory"
            return 1
        }

        log_status "Updating exclude file with .gitignore.local contents"
        {
            echo ".gitignore.local"
            cat ".gitignore.local"
        } >".git/info/exclude" || {
            log_error "Failed to write to .git/info/exclude"
            return 1
        }

        local pattern_count=$(grep -v "^#" ".git/info/exclude" | grep -v "^$" | wc -l | tr -d ' ')
        log_status "Applied $pattern_count ignore patterns"
    fi
}

eval "original_$(declare -f log_status)"
eval "original_$(declare -f log_error)"

log_status() {
    local current_prefix="${log_prefix:-}"

    # If a log_prefix_override is passed as first arg (starts with @), use it instead
    if [[ "${1:-}" == @* ]]; then
        current_prefix="${1#@}"
        shift
    fi

    if [[ -n "$current_prefix" ]]; then
        original_log_status "$current_prefix: $*"
    else
        original_log_status "$*"
    fi
}

log_error() {
    local current_prefix="${log_prefix:-}"

    # If a log_prefix_override is passed as first arg (starts with @), use it instead
    if [[ "${1:-}" == @* ]]; then
        current_prefix="${1#@}"
        shift
    fi

    if [[ -n "$current_prefix" ]]; then
        original_log_error "$current_prefix: $*"
    else
        original_log_error "$*"
    fi
}
