@~/.claude/swe-standards.md
@~/.claude/python-code-standards.md

### Skills

When working with Python, invoke the relevant /astral:<skill> for uv, ty, and ruff to ensure best practices are followed.

### CLI tools

| tool | replaces | usage |
|------|----------|-------|
| `rg` (ripgrep) | grep | `rg "pattern"` - 10x faster regex search |
| `fd` | find | `fd "*.py"` - fast file finder |
| `ast-grep` | - | `ast-grep --pattern '$FUNC($$$)' --lang py` - AST-based code search |
| `shellcheck` | - | `shellcheck script.sh` - shell script linter |
| `shfmt` | - | `shfmt -i 2 -w script.sh` - shell formatter |
| `pre-commit` | pre-commit | `pre-commit run` - fast git hooks (Rust, no Python) |
| `trash` | rm | `trash file` - moves to macOS Trash (recoverable). **Never use `rm -rf`** |
