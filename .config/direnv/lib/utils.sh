#!/usr/bin/env bash

set -oue pipefail

export_alias() {
    local name=$1
    shift

    alias_dir="$PWD/.direnv/aliases"
    [[ ! -d "$VIRTUAL_ENV" ]] && rm -rf "$alias_dir"

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

eval "original_$(declare -f log_status)"
eval "original_$(declare -f log_error)"

log_status() {
    if [[ -n "${log_prefix:-}" ]]; then
        original_log_status "$log_prefix: $*"
    else
        original_log_status "$*"
    fi
}

log_error() {
    if [[ -n "${log_prefix:-}" ]]; then
        original_log_error "$log_prefix: $*"
    else
        original_log_error "$*"
    fi
}
