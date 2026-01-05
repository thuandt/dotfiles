# dotfiles

Managed with Dotbot. The install scripts create symlinks for each tool's config listed under `meta/configs`.

## Requirements
- Git (clone with submodules) and Bash
- Python 3 (Dotbot runtime)
- Run from the repo root; existing configs may be replaced by symlinks

## Quick install (everything)
```bash
git clone --recursive <repo-url> ~/dotfiles
cd ~/dotfiles
./install
```
`./install` updates the Dotbot submodule, applies the `meta/base.yaml` defaults/clean-up, then runs every config in `meta/configs`.

## Selective install
If you only want certain configs, use the standalone script (base still runs first):
```bash
git clone --recursive <repo-url> ~/dotfiles
cd ~/dotfiles
./install-standalone zsh tmux git
```
Available config names: `doomemacs`, `fontconfig`, `git`, `gnupg`, `misc`, `mise`, `mpv`, `tmux`, `userbin`, `vim`, `wezterm`, `zsh`.

## Notes
- `meta/base.yaml` cleans the home, `.gnupg`, `.config`, `.local/bin`, `.config/htop`, `.config/pgcli`, and `.config/youtube-dl` directories of broken links/old Dotbot entries before linking.
- Edit or add `meta/configs/*.yaml` to customize what gets linked.
