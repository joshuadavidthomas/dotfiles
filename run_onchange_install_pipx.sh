#!/usr/bin/env bash

set -euo pipefail

if [ -x "$(command -v python)" ]; then
	PYTHON=python
else
	PYTHON=python3
fi

$PYTHON -m pip install --user pipx
$PYTHON -m pipx ensurepath
