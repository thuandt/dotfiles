---
name: dotfiles-management
description: Comprehensive workflow skill for managing dotfiles, creating Dotbot links, optimizing Zsh performance, maintaining Selenized Dark color consistency, and running validation suites.
---

# Dotfiles Management & Maintenance Skill

This skill provides step-by-step procedures for AI agents operating on this dotfiles repository.

## 1. Adding a New Tool or Config Directory

When adding or configuring a new tool (e.g. `foo`):
1. **Create Tool Directory**: Place configuration files in a dedicated top-level directory `~/dotfiles/foo/`.
2. **Update Dotbot Config**:
   - For major standalone tools, create `meta/configs/foo.yaml`.
   - For auxiliary CLI tools, append the link mapping `~/.config/foo: foo` to `meta/configs/misc.yaml`.
3. **Verify Links**: Execute `./install-standalone misc` or `./install-standalone foo`.
4. **Validate Target Path**: Confirm symlink creation with `ls -ld ~/.config/foo`.

---

## 2. Maintaining Zsh Performance & Latency

When modifying `zsh/zshenv` or `zsh/zshrc`:
1. **Check Execution Context**:
   - `zshenv` is loaded on **all** shell invocations (`zsh -c`, git hooks, scripts). Keep it lean.
   - Guard external binary lookups (`secret-tool`, `systemctl`) so they only run if the target variable is unset.
2. **Zsh Native Constructs**:
   - Use `typeset -gU path PATH` for path array deduplication.
   - Use `whence` for executable checks rather than calling external binaries.
3. **Benchmark Startup**:
   - Run Python startup benchmark:
     ```bash
     python3 -c '
     import time, subprocess
     times = []
     for _ in range(10):
         s = time.perf_counter()
         subprocess.run(["zsh", "-i", "-c", "exit"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
         times.append((time.perf_counter() - s) * 1000)
     print(f"Average: {sum(times)/len(times):.2f} ms")
     '
     ```
4. **Syntax Validation**: Run `zsh -n zsh/zshrc && zsh -n zsh/zshenv`.

---

## 3. Applying the Selenized Dark Color Palette

When creating or editing themes for tools (`k9s`, `vivid`, `wezterm`, `tmux`, `less`):
- Use the official **Selenized Dark** sRGB hex values:
  - Background: `#103c48`
  - Current Line / Selection: `#184956` / `#2d5b69`
  - Text / Muted Text: `#adbcbc` / `#72898f`
  - Accents: Blue `#4695f7`, Cyan `#41c7b9`, Green `#75b938`, Red `#fa5750`, Orange `#ed8649`, Magenta `#f275be`.

---

## 4. Git Commit Protocol

- Stage files explicitly: `git add <files>`.
- Always present the proposed commit message to the user before running `git commit`.
- Keep commit messages short, imperative, lowercase, and without prefixes.
