#!/usr/bin/env bash
# toolkit-bin — expose the `toolkit` fleet command on PATH.
#
# Symlinks ~/.local/bin/toolkit -> <repo>/bin/toolkit so the checked-out repo
# stays the single source of truth (a `git pull` updates the command itself).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

SOURCE="$TOOLKIT_LITE_ROOT/bin/toolkit"
TARGET="$HOME/.local/bin/toolkit"
[ -f "$SOURCE" ] || die "toolkit-bin: missing $SOURCE"
chmod +x "$SOURCE"

mkdir -p "$HOME/.local/bin"
if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
  ok "toolkit-bin: $TARGET already linked"
else
  [ -e "$TARGET" ] || [ -L "$TARGET" ] && rm -f "$TARGET"
  ln -s "$SOURCE" "$TARGET"
  ok "toolkit-bin: $TARGET → $SOURCE"
fi
ok "toolkit-bin: try 'toolkit doctor'"
