#!/usr/bin/env bash
# power-tools — the vetted GigaBrands power stack (quality-of-life + pipeline
# CLIs every dev box gets). The list lives in versions.yaml (power_tools) so
# doctor and this installer can never drift apart.
#
#   eza, git-delta, lazygit, htop, zoxide, atuin  — daily-driver upgrades
#   ffmpeg, yt-dlp, pandoc                        — media/document pipelines
#   git-filter-repo, scc                          — repo surgery + code stats
#   op (1Password CLI, macOS)                     — secrets stay in the vault
#
# Optional tools (versions.yaml optional_tools, e.g. tailscale) are installed
# only when TOOLKIT_INSTALL_OPTIONAL=1 — tailnet access is invite-only and NOT
# part of the fleet standard.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

MANIFEST="$TOOLKIT_LITE_ROOT/versions.yaml"
TOOLS="$(sed -n 's/^power_tools:[[:space:]]*"\(.*\)".*/\1/p' "$MANIFEST")"
[ -n "$TOOLS" ] || die "power-tools: power_tools missing from versions.yaml"
if [ "${TOOLKIT_INSTALL_OPTIONAL:-0}" = "1" ]; then
  TOOLS="$TOOLS $(sed -n 's/^optional_tools:[[:space:]]*"\(.*\)".*/\1/p' "$MANIFEST")"
fi

for pair in $TOOLS; do
  pkg="${pair%%:*}"; bin="${pair##*:}"
  if command -v "$bin" >/dev/null 2>&1; then
    ok "power-tools: $bin present"
    continue
  fi
  log "power-tools: installing $pkg"
  pkg_install "$pkg" || warn "power-tools: $pkg failed (continuing)"
done

# 1Password CLI — cask on macOS; Linux needs 1Password's apt/dnf repo, which we
# don't add automatically (point the dev at the doc instead).
if ! command -v op >/dev/null 2>&1; then
  if [ "$(os)" = "macos" ]; then
    log "power-tools: installing 1password-cli (cask)"
    ensure_brew_on_path && brew install --cask 1password-cli || warn "power-tools: 1password-cli failed"
  else
    warn "power-tools: install 1Password CLI manually on Linux: https://developer.1password.com/docs/cli/get-started/"
  fi
else
  ok "power-tools: op present"
fi
