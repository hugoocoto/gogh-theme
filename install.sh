#!/bin/sh
# Copies the built theme for one scheme into a dotfiles repo, so the
# dotfiles carry the colours themselves instead of pointing at this repo.
# Run ./build.sh first.
#
# Usage: ./install.sh [dotfiles dir] [scheme]   (defaults: ~/dotfiles gogh)
set -e
cd "$(dirname "$0")"

DOTS=${1:-$HOME/dotfiles}
SCHEME=${2:-gogh}

[ -d "$DOTS" ] || { echo "No such dotfiles dir: $DOTS" >&2; exit 1; }
[ -f "output/templates/$SCHEME.foot" ] || { echo "Missing build output for $SCHEME; run ./build.sh" >&2; exit 1; }

install_file() {
    mkdir -p "$(dirname "$DOTS/$2")"
    cp "$1" "$DOTS/$2"
    echo "Installed $DOTS/$2"
}

echo "==> Installing $SCHEME into $DOTS"
# foot and tmux get scheme-independent names so their configs don't change
# when switching schemes; nvim needs the scheme name for :colorscheme.
install_file "output/templates/$SCHEME.foot" .config/foot/theme.ini
install_file "output/templates/$SCHEME.tmux" .config/tmux/theme.conf
install_file "colors/$SCHEME.lua" ".config/nvim/colors/$SCHEME.lua"
install_file lua/base16-colorscheme.lua .config/nvim/lua/base16-colorscheme.lua
