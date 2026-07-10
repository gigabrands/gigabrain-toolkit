# GigaBrands Engineering — Shared Agent Context

This file is the single source of truth for AI coding agents on every GigaBrands
dev box. It is symlinked into each harness (`~/.claude/CLAUDE.md`,
`~/.codex/AGENTS.md`) by the toolkit installer, so every developer's agents —
Claude Code, Codex, and friends — read the same standard. Update it here,
commit, and the fleet syncs on the next `toolkit update`.

Project-specific instructions live in each repo's own CLAUDE.md/AGENTS.md and
take precedence over this file.

## Environment standard

- Repos live in `~/environment/`.
- Node is managed by **nvm** — never brew/apt node. The pinned major version is
  in `versions.yaml` at the toolkit root (`toolkit root`). If node behaves
  unexpectedly, run `toolkit doctor` before debugging by hand.
- Python is managed by **uv**; the pinned default is in `versions.yaml`.
  Use `uv venv` / `uv pip` — never system pip.
- tmux sessions are managed with the `dev` command (`dev <name>`, `dev list`).
- If a required tool is missing, the fix is `toolkit update` or
  `./install.sh --only <component>` — do not hand-install fleet-managed tools.

## Agent conduct

- **Never hardcode secrets, API keys, or external service IDs** — use env vars.
- **Never commit `.env` files.**
- Prefer parameterized queries; never interpolate strings into SQL.
- Use `https://` for all external connections.
- When a box behaves differently than expected, run `toolkit doctor` and read
  its output before ad-hoc debugging — the standard is machine-checked.

## Model / harness configuration

- Disable automatic model switching in Claude Code (`/config`) — silent
  mid-session fallbacks break long multi-agent runs and burn quota.
- Multi-model review is encouraged: have a second harness (Codex, `gemini`)
  adversarially review nontrivial diffs — different models catch different bugs.
- For cheap execution-tier or fallback work, prefer routing through an
  aggregator (e.g. OpenRouter via `OPENROUTER_API_KEY`) rather than hardcoding
  a single vendor — vendor access can degrade or vanish mid-session.

## Engineering practices (fleet standard)

- **Tests:** prefer emulated-DOM tests (e.g. happy-dom) for breadth — they are
  ~100x faster and parallelize; reserve real-browser E2E (Playwright) for the
  1-2 core user journeys only.
- **Repetitive LLM calls are a smell:** if an agent does the same
  transformation on a schedule, replace it with a deterministic script + cron;
  keep LLMs for judgment, not reconciliation.
- **Structure beats model quality:** define per-step success criteria and hard
  stops in agent loops before reaching for a bigger model.
- **Secrets stay in the vault:** use `op run` / `op read` (1Password CLI) to
  inject credentials at runtime; never write them into files or shell history.
