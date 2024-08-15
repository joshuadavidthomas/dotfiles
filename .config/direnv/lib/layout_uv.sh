#!/usr/bin/env bash

layout_uv() {
  if [[ -d ".venv" ]]; then
    VIRTUAL_ENV="$(pwd)/.venv"
  fi

  if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
    log_status "No virtual environment exists. Executing \`uv venv\` to create one."
    if [[ -f ".mise*.toml" ]]; then
      log_status "mise detected, using it's Python version"
      uv venv --python-preference installed --seed
    else
      uv venv --seed
    fi
    VIRTUAL_ENV="$(pwd)/.venv"
  fi

  PATH_add "$VIRTUAL_ENV/bin"
  export UV_ACTIVE=1
  export VIRTUAL_ENV
}
