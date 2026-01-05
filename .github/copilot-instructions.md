# Copilot / AI agent instructions — dotfiles

This repository is a home-dotfiles collection managed with Dotbot. These notes give an AI coding agent the minimal, concrete context needed to be productive here.

- **Big picture**: the repo uses Dotbot (bundled under `meta/dotbot`) to create symlinks and manage per-tool configuration. The install entrypoints are `install` (full) and `install-standalone` (select configs). Dotbot configs live under `meta/configs/*.yaml` and `meta/base.yaml` contains cleanup/defaults.

- **Key files / commands**
  - Install everything: `./install` (runs `meta/base.yaml` then every `meta/configs/*.yaml`). See [install](../install).
  - Install selected configs: `./install-standalone zsh tmux git`. See [install-standalone](../install-standalone).
  - Dotbot binary used: [meta/dotbot/bin/dotbot](../meta/dotbot/bin/dotbot) invoked with `-d <repo-root> -c <config.yaml>` (exact invocations are in the scripts above).

- **Project layout (important directories)**
  - [meta/configs](../meta/configs) — Dotbot manifests for each component (zsh, tmux, git, etc.).
  - [meta/base.yaml](../meta/base.yaml) — base cleanup and defaults (it removes broken links and cleans certain directories like `.gnupg`, `.config`, `.local/bin` before linking).
  - `zsh/`, `nvim/`, `tmux/`, `git/`, `gnupg/`, `bin/` — per-tool config fragments that the Dotbot manifests symlink into the home directory.

- **Common workflows an agent may need to perform**
  - Add or change a tool config: add/edit `meta/configs/<name>.yaml` and place files under the corresponding directory (for example, update `zsh/` and then run `./install-standalone zsh`).
  - Update Dotbot submodule: the full `./install` script runs `git submodule update --init --recursive --remote`; if editing the Dotbot tool itself run the same command first.
  - Debugging installs: run the install scripts from the repo root (they `cd` into repo root). You can run them with `bash -x ./install` for verbose tracing.

- **Conventions & patterns specific to this repo**
  - Config names used by the scripts are the basename of `meta/configs/*.yaml`. Example names available: `doomemacs`, `fontconfig`, `git`, `gnupg`, `misc`, `mise`, `mpv`, `tmux`, `userbin`, `vim`, `wezterm`, `zsh` (see [README.md](../README.md) for the authoritative list).
  - The repo treats home-managed files as symlink targets; do not assume copying — changes to files under `meta/*` are propagated to the home via Dotbot symlinks.
  - `meta/base.yaml` performs cleanup of home directories before linking. Be conservative when editing it; it intentionally removes stale/broken links in sensitive locations like `.gnupg`.

- **Safe edit guidance for AI edits**
  - Do not modify secrets or GPG key files under `.gnupg` or `Yubikey/` unless the user explicitly asks. Those are sensitive and managed by the user.
  - When adding a new config, update `meta/configs/<name>.yaml`, include a short README under the new component dir, and document the config name in the root `README.md`.

- **Examples to copy/paste**
  - Full install: `git clone --recursive <repo-url> ~/dotfiles && cd ~/dotfiles && ./install`
  - Partial install: `./install-standalone zsh tmux git`
  - Dotbot invocation (from scripts): `meta/dotbot/bin/dotbot -d "$(pwd)" -c meta/configs/zsh.yaml`

If anything here is unclear or you want more examples (e.g., a new-component checklist or typical Dotbot manifest snippets from this repo), tell me which area to expand.
<!-- Purpose: guidance for AI coding agents working on this dotfiles repo -->

# Copilot instructions for this repository

This repository is a personal dotfiles collection driven by Dotbot. The guidance below focuses on the concrete, discoverable patterns and workflows that make an AI agent productive here.

1. Purpose & big picture

- **Repo role:** manages user configuration (shell, editors, apps) via declarative Dotbot YAML under `meta/`.
- **Primary flow:** YAML config files in `meta/configs/` declare `link`/`create` actions that map repository files into the home directory; `meta/base.yaml` contains global Dotbot defaults.

2. Key files and examples (read these before editing)

- `meta/base.yaml`: Dotbot defaults (e.g., `force`, `relink`, `ignore-missing`).
- `meta/configs/*.yaml`: component-specific Dotbot manifests. Example: `meta/configs/misc.yaml` links `~/.config/pgcli/config` → `apps/pgcli/config`.
- `install` and `install-standalone`: wrappers that invoke Dotbot. `install` updates submodules and applies all `meta/configs/*`; `install-standalone` applies only supplied profiles.
- `meta/dotbot/bin/dotbot`: the Dotbot CLI used by the scripts (submodule bundled under `meta/dotbot`).

3. Typical developer tasks and exact commands

- Apply all configs (recommended on a fresh machine):

  ./install

- Apply a single config/profile (fast, used in CI or tasks):

  ./install-standalone <profile>

- Workspace Task: use the VS Code task labeled `install-misc` which runs:

  ./install-standalone misc

4. Conventions and patterns to preserve

- Each component has a YAML in `meta/configs/` named as the profile. Add a new profile by creating `meta/configs/<name>.yaml`, then run `./install-standalone <name>` to test.
- Files under `apps/`, `shells/`, `tools/`, `terminals/` are authoritative sources — prefer editing those and updating the corresponding YAML link targets.
- Dotbot links are repository-relative; do not hardcode absolute host paths in YAMLs.

5. Integration points & sensitive areas

- `meta/dotbot/`: bundled dotbot implementation — changes here affect all installs.
- `~/.ssh` and `~/.gnupg` are present in the workspace for convenience. Do not expose or modify key material; AI agents must not suggest adding secrets into the repo.

6. When modifying the repo

- Update or add `meta/configs/<name>.yaml` to change which files are linked.
- Run `./install-standalone <name>` locally (or the `install-<name>` task if added) to validate links.
- If adding binaries or tools, place them in `userbin`/`tools` and reference them from YAMLs.

7. Quick code pointers for AI edits

- For small edits to configuration files, prefer changing files under `apps/` or `shells/` and then adjust `meta/configs/*.yaml` to point the symlinked target.
- To see what will be linked, inspect the YAML keys in `meta/configs/*.yaml`.
- To update submodules (dotbot or bundled plugins) rely on `install` which runs `git submodule update --init --recursive --remote`.

8. What _not_ to change

- Do not commit private keys, passphrases, or exported secrets from `~/.gnupg` or `~/.ssh` into tracked files.
- Avoid changing `meta/base.yaml` defaults unless you understand Dotbot's `link` semantics (it sets `force`/`relink` behavior).

9. Where to look for more context

- Dotbot docs are available in `meta/dotbot/README.md` inside the repository and online — read `meta/dotbot/README.md` before changing dotbot behavior.

If anything above is unclear or you'd like more examples (e.g., a step-by-step add-profile walkthrough), tell me which area to expand and I will update this file.
