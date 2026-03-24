# Global Claude Code Instructions

## Skills

When working with Python, invoke the relevant Astral skills:

- `astral:uv` - Package/dependency management, creating projects, managing virtual environments
- `astral:ruff` - Code formatting, linting, fixing violations

## Session Guidelines

- **Always check current time** at the start of conversations to maintain temporal context (use `mcp__server-time__get_current_time` with timezone `US/Mountain`)

## Workflow Orchestration

### 1. Plan Mode Default

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self Improvement Loop

- After ANY correction from the user: update .claude/lessons.md with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done

- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple obvious fixes - don't over engineer
- Challenge your own work before presenting it

## Task Management

1. **Plan First**: Write plan to `.claude/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Resolution**: Add review section to `.claude/todo.md`
6. **Capture Lessons**: Update `.claude/lessons.md` after corrections

## CLI tools

| tool | replaces | usage |
|------|----------|-------|
| `rg` (ripgrep) | grep | `rg "pattern"` - 10x faster regex search |
| `fd` | find | `fd "*.py"` - fast file finder |
| `ast-grep` | - | `ast-grep --pattern '$FUNC($$$)' --lang py` - AST-based code search |
| `shellcheck` | - | `shellcheck script.sh` - shell script linter |
| `shfmt` | - | `shfmt -i 2 -w script.sh` - shell formatter |
| `rumdl` | markdownlint | `rumdl check .` - Markdown linter, `rumdl fmt .` - Markdown formatter |
| `bat` | cat | `bat file.py` - syntax-highlighted file viewer with `--line-range` |
| `jq` | - | `jq '.key'` - JSON processor/query tool |
| `yq` | - | `yq '.key' file.yaml` - YAML/TOML processor (same syntax as jq) |
| `trash` | rm | `trash file` - moves to macOS Trash (recoverable). **Never use `rm -rf`** |
