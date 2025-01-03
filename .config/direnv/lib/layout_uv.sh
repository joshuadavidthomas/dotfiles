#!/usr/bin/env bash

set -oue pipefail

layout_uv() {
        VIRTUAL_ENV="$(pwd)/.venv"

        if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
                log_status "No virtual environment exists. Executing \`uv venv\` to create one."
                uv venv --seed
                VIRTUAL_ENV="$(pwd)/.venv"
        fi

        if [[ -f "uv.lock" ]]; then
                uv sync
        fi

        PATH_add "$VIRTUAL_ENV/bin"
        export UV_ACTIVE=1 # or VENV_ACTIVE=1
        export VIRTUAL_ENV

        export_alias "uvr" "uv run"
}
