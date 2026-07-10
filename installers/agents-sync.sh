#!/usr/bin/env bash
# agents-sync — point every AI harness at the toolkit's shared AGENTS.md.
#
# Symlinks:
#   ~/.claude/CLAUDE.md  -> <toolkit>/agents/AGENTS.md
#   ~/.codex/AGENTS.md   -> <toolkit>/agents/AGENTS.md
#
# One source of truth for agent context across the whole fleet: edit
# agents/AGENTS.md in the repo, commit, and every dev picks it up on their
# next `toolkit update`. Existing real files are backed up (timestamped),
# matching the convention used by claude-code.sh / codex.sh.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

SOURCE="$TOOLKIT_LITE_ROOT/agents/AGENTS.md"
[ -f "$SOURCE" ] || die "agents-sync: missing $SOURCE"

link_context() {
  local target="$1"
  local dir; dir="$(dirname "$target")"
  mkdir -p "$dir"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$SOURCE" ]; then
    ok "agents-sync: $target already linked"
    return 0
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    local bak="${target}.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$bak"
    warn "agents-sync: existing $target backed up to $bak"
  fi
  ln -s "$SOURCE" "$target"
  ok "agents-sync: $target → $SOURCE"
}

link_context "$HOME/.claude/CLAUDE.md"
link_context "$HOME/.codex/AGENTS.md"
