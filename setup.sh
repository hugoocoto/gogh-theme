#!/bin/sh
# Ensures submodules and their dependencies are present and up to date.
set -e
cd "$(dirname "$0")"

echo "==> Syncing submodules"
git submodule sync --recursive
git submodule update --init --recursive

echo "==> Installing PHP builder dependencies"
if [ ! -d base16-builder-php/vendor ]; then
    (cd base16-builder-php && composer install --no-interaction)
else
    echo "    vendor/ already present, skipping composer install"
fi

echo "==> Installing palette generator dependencies"
if [ ! -d .venv-palette ]; then
    python3 -m venv .venv-palette
fi
# PyYAML isn't listed in the submodule's requirements.txt even though
# main.py imports it, so it's added explicitly here.
.venv-palette/bin/pip install -q -r base16-spectrum-generator/requirements.txt pyyaml

echo "==> Setup complete"
