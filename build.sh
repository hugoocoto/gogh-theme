#!/bin/sh
# Builds every template in ./templates against every scheme in ./schemes.
set -e
cd "$(dirname "$0")"

./setup.sh

echo "==> Building templates"
mkdir -p output

# base16-build-all.sh does `find schemes` / `find templates` on these paths,
# and find does not descend into a symlinked directory given as a start
# point. So instead of symlinking the directories themselves, make real
# directories inside the submodule and symlink each file into them.
rm -rf base16-builder-php/schemes base16-builder-php/templates
mkdir -p base16-builder-php/schemes base16-builder-php/templates
for f in schemes/*.yaml; do
    [ -f "$f" ] || continue
    ln -sfn "../../$f" "base16-builder-php/schemes/$(basename "$f")"
done
find templates -name "*.mustache" | while read -r f; do
    rel=${f#templates/}
    mkdir -p "base16-builder-php/templates/$(dirname "$rel")"
    # Symlink lives at base16-builder-php/templates/$rel; walk back up out of
    # base16-builder-php/templates/<subdirs of rel> (2 levels) plus one level
    # per subdirectory in $rel, then back down through $f from the repo root.
    up_levels=$(($(echo "$rel" | tr -cd '/' | wc -c) + 2))
    prefix=""
    i=0
    while [ "$i" -lt "$up_levels" ]; do
        prefix="../$prefix"
        i=$((i + 1))
    done
    ln -sfn "$prefix$f" "base16-builder-php/templates/$rel"
done
ln -sfn ../output base16-builder-php/output

(cd base16-builder-php && ./base16-build-all.sh)

echo "==> Installing nvim colorscheme files"
mkdir -p colors
if [ -d output/colors ]; then
    for f in output/colors/*.lua; do
        [ -f "$f" ] || continue
        cp "$f" "colors/$(basename "$f")"
        echo "Installed colors/$(basename "$f")"
    done
fi

mkdir -p lua
cp templates/lua/base16-colorscheme.lua lua/base16-colorscheme.lua
echo "Installed lua/base16-colorscheme.lua"

echo "==> Generating palette previews"
mkdir -p palette
for f in schemes/*.yaml; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .yaml)
    .venv-palette/bin/python3 base16-spectrum-generator/main.py "$f" "palette/$name.png"
    echo "Generated palette/$name.png"
done

echo "==> Build complete"
