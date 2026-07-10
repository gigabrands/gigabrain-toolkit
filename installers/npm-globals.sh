#!/usr/bin/env bash
# npm-globals — company-stack npm CLIs (list lives in versions.yaml so doctor
# and this installer share one source of truth).
#
#   pm2                — process runtime used on gigabrands servers
#   vercel             — marketing-site deploys
#   @google/gemini-cli — adversarial second-model reviews + cheap-tier work
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

MANIFEST="$TOOLKIT_LITE_ROOT/versions.yaml"
PKGS="$(sed -n 's/^npm_globals:[[:space:]]*"\(.*\)".*/\1/p' "$MANIFEST")"
[ -n "$PKGS" ] || die "npm-globals: npm_globals missing from versions.yaml"

load_node
command -v npm >/dev/null 2>&1 || die "npm-globals: npm not available (run: ./install.sh --only node)"

for pair in $PKGS; do
  pkg="${pair%%:*}"; bin="${pair##*:}"
  if command -v "$bin" >/dev/null 2>&1; then
    ok "npm-globals: $bin present"
    continue
  fi
  log "npm-globals: npm install -g $pkg"
  npm install -g "$pkg" || warn "npm-globals: $pkg failed (continuing)"
done
