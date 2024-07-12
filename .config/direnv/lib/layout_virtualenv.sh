#!/usr/bin/env bash

layout_virtualenv() {
  local pyversion=$1
  local pvenv=$2
  if [ -n "$(which pyenv virtualenv)" ]; then
    pyenv virtualenv --force --quiet "${pyversion}" "${pvenv}"-"${pyversion}"
  fi
  pyenv local --unset
}
