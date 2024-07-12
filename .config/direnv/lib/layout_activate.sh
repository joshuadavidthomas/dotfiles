#!/usr/bin/env bash

layout_activate() {
  if [ -n "$(which pyenv)" ]; then
    PYENV_ROOT="$(pyenv root)"
    # shellcheck disable=SC1090
    source "$PYENV_ROOT"/versions/"$1"/bin/activate
  fi
}
