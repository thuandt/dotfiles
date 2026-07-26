# Dotfiles Repository & Agent Guidelines

## 1. Project Architecture & Tool Map

This repository manages cross-platform dotfiles for Linux/macOS environments using **Dotbot**.

### Top-Level Tool Directories
* **`zsh/`**: Core shell configuration (`zshenv`, `zshrc`, `zprofile`, `zlogout`, `p10k.zsh`).
* **`k9s/`**: Kubernetes TUI config & custom skins (`skins/selenized-dark.yaml`).
* **`vivid/`**: LS_COLORS generator themes (`themes/selenized-dark.yml`).
* **`wezterm/`**: WezTerm terminal emulator configuration (`wezterm.lua`).
* **`btop/`**: Resource monitor config (`btop.conf`).
* **`doomemacs/`**: Doom Emacs setup (`config.el`, `init.el`, `packages.el`).
* **`git/`** & **`tig/`**: Git client configurations.
* **`ssh/`**: SSH configuration (`config`, `config.d/*`).
* **`mise/`**: Polyglot tool version manager (`config.toml`).
* **`mpv/`**: Media player settings.
* **`systemd/`**: User-level systemd service units.
* **`bin/`**: User executables linked to `~/.local/bin`.

### Dotbot Framework (`meta/`)
* **`meta/base.yaml`**: Core clean rules, symlink defaults, and global directory creations.
* **`meta/configs/*.yaml`**: Individual tool link specs (e.g., `zsh.yaml`, `misc.yaml`, `wezterm.yaml`).
* **`meta/configs/misc.yaml`**: Consolidated links for auxiliary tools (`k9s`, `btop`, `lsd`, `mc`, `pip`, `vivid`, `wireplumber`, `htop`, `pgcli`, `youtube-dl`).
* **`meta/dotbot/`**: Submodule containing Dotbot Python source.

---

## 2. Shell & Performance Standards

### Zsh Execution Rules
1. **`zshenv` Strict Latency Budget**:
   - `zshenv` executes on **every subshell, script, and non-interactive shell** (`zsh -c`).
   - **NEVER** run un-guarded D-Bus calls (`secret-tool`, `systemctl`), network requests, or subshells inside `zshenv`.
   - Guard keyring lookups: `[[ -z "$VAR" ]] && export VAR="$(secret-tool ...)"`.
   - Use native Zsh unique array assignment for PATH: `typeset -gU path PATH; path=( ... $path )`.
2. **`zshrc` Plugin Management**:
   - Use **Zinit** with Turbo mode (`wait'...' lucid light-mode`) for deferred plugins.
   - Synchronous loading is reserved exclusively for vi-mode (`zsh-vi-mode`) and prompt theme (`powerlevel10k`).
   - Use `_lazy_cache_completion` for CLI tool completion generation.
3. **`zshaddhistory` Filter**:
   - Discards invalid command typos via `whence "$cmd"`.
   - Discards bare 1–2 char commands without arguments while expanding aliases (`k` → `kubectl`).

---

## 3. Design System & Theme Standards (Selenized Dark)

All tool themes must adhere strictly to Jan Warchol's canonical **Selenized Dark** color palette:

| Token | Hex Value | Usage |
| :--- | :--- | :--- |
| `bg_0` | `#103c48` | Main terminal & UI background |
| `bg_1` | `#184956` | Current line & highlight background |
| `bg_2` | `#2d5b69` | Selection & frame borders |
| `dim_0` | `#72898f` | Comments & muted text |
| `fg_0` | `#adbcbc` | Primary text |
| `fg_1` | `#cad8d9` | Bright text |
| `blue` | `#4695f7` | Primary accent, logos, active tabs |
| `cyan` | `#41c7b9` | Status, sorters, indicators |
| `green` | `#75b938` | Success, additions, diff additions |
| `red` | `#fa5750` | Errors, deletions, diff removals |
| `orange` | `#ed8649` | Prompt suggestions, highlights |
| `magenta` | `#f275be` | Keys, keywords, section headers |

---

## 4. Build, Validation & Commit Guidelines

### Validation Commands
- **Validate Zsh Syntax**: `zsh -n zsh/zshrc && zsh -n zsh/zshenv`
- **Validate Dotbot Symlinks**: `./install-standalone <config_name>` (e.g. `./install-standalone misc`)
- **Run Dotbot Unit Tests**: `cd meta/dotbot && hatch test`

### Commit Message Rules
- **Format**: Short, imperative, lowercase, no prefixes (e.g. `refactor zshrc and zshenv for performance`).
- **Review**: Always present the commit message to the user for approval before committing.
