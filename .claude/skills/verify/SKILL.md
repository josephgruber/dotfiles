---
name: verify
description: Use when you need to lint and validate shell scripts in the dotfiles repo, or before committing shell changes
---

You MUST use the Bash tool to run shellcheck and shfmt — manual code review is not a substitute. If Bash is denied, stop and tell the user you need Bash permission to run the linting tools.

## 1. Find shell files

Exclude third-party (Alfred) and local overrides — only lint user-authored files:
```bash
fd -e sh -e zsh --exclude .local --exclude .git --exclude Alfred.alfredpreferences . /Users/josephgruber/.dotfiles
```
Also include these root dotfiles (not caught by fd): `.zshrc`, `.bashrc`, `.profile`, `.zprofile`.

## 2. shellcheck (.sh files only)

Do NOT run shellcheck on .zsh or .zshrc files — shellcheck does not support zsh syntax.
```bash
shellcheck -x <file>
```

**Known false positives to ignore:**
- SC1083 warnings on git `@{upstream}` syntax in statusline.sh — this is valid git refspec, not a shell error

## 3. shfmt (all shell files)

Check all files for 2-space indent compliance:
```bash
shfmt -i 2 -d <file>
```

## 4. Report

Group issues by file. For each issue, include the line number and shellcheck code or shfmt diff. If everything passes, confirm all checks passed.
