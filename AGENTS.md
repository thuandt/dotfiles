# Repository Guidelines

## Project Structure & Module Organization
- Tool-specific configs live in top-level folders like `zsh/`, `tmux/`, `nvim/`, `mpv/`, and `wezterm/`.
- Dotbot configuration is under `meta/`: `meta/base.yaml` sets defaults/clean rules and `meta/configs/*.yaml` links each tool.
- Installer scripts sit at the root: `install` (full run) and `install-standalone` (selected configs).
- The Dotbot submodule lives in `meta/dotbot/` and contains its own source and tests.
- Helper scripts for PATH live in `bin/`.

## Build, Test, and Development Commands
- `./install` updates the Dotbot submodule and applies `meta/base.yaml` plus all configs.
- `./install-standalone zsh tmux git` runs the base config, then only the named configs.
- `cd meta/dotbot && hatch test` runs Dotbot’s pytest suite.
- `cd meta/dotbot && hatch fmt` formats and lints Dotbot (Ruff).
- `cd meta/dotbot && hatch run types:check` runs mypy for Dotbot.

## Coding Style & Naming Conventions
- YAML uses 2-space indentation; keep config files in `meta/configs/` named to match the target folder (for example, `meta/configs/zsh.yaml` -> `zsh/`).
- Shell scripts are bash; keep them POSIX-leaning and runnable from repo root.
- New private or machine-specific files should follow the `private_*` pattern (ignored by `.gitignore`).

## Testing Guidelines
- Tests live under `meta/dotbot/tests/` and use pytest (`test_*.py`).
- There are no repo-wide tests for configs; validate by running `./install-standalone <tool>` against a test home directory.

## Commit & Pull Request Guidelines
- Commit messages are short and imperative, often lowercase, and avoid prefixes (examples in `git log`).
- PRs should describe which tools/configs changed, note any new dependencies, and include the install command used for validation.

## Security & Configuration Tips
- `meta/base.yaml` can remove broken links in common config directories; review it before running on a new machine.
- Avoid committing secrets; prefer `private_*` files and local overrides.
