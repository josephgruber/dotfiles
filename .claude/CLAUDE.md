# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for macOS. Configuration files are symlinked from this repo to their expected locations across the system.

## Structure

- `config/<tool>/` — tool-specific configs (git, claude, ssh, python, direnv, etc.)
- `.local/` — machine-specific overrides, gitignored, never committed
- `themes/` — Oh-My-Posh prompt theme
- `setup.sh` — **obsolete, ignore this file**

## Key Conventions

- Shell files (.sh, .zsh) use **2-space indentation** (enforced by shfmt)
- GPG commit signing uses **1Password SSH agent** — do not change SSH_AUTH_SOCK or GPG config
- `.local/` directory holds per-machine overrides (gitconfig, ssh, zshrc) — never modify or commit these
- The global `.gitignore` at `config/git/.gitignore` is comprehensive (node, python, terraform, macos, direnv) — check it before adding ignore rules

## Shell Environment

- Primary shell: **zsh** with zsh-autocomplete, zsh-autosuggestions, fzf
- Prompt: **Oh-My-Posh** (theme at `themes/oh-my-posh.json`)
- Performance: nvm and pyenv are **lazy-loaded** — don't add eager initialization
- Key env vars are set in `.zshrc`; login-time paths in `.profile`

## Tools

- **Shell**: shellcheck (lint), shfmt (format, 2-space indent)
- **Python**: ruff (lint/format), mypy (type check), uv (package management)
- **Markdown**: rumdl (lint/format)
- **Infrastructure**: OpenTofu (not Terraform), standards in `config/claude/terraform-standards.md`

## Commands

```bash
# Lint all shell scripts
shellcheck config/**/*.sh

# Format all shell scripts (check only)
shfmt -i 2 -d .

# Format all shell scripts (write)
shfmt -i 2 -w .

# Lint Python files
ruff check .

# Format Python files
ruff format .

# Lint Markdown files
rumdl check .

# Format Markdown files
rumdl fmt .
```
