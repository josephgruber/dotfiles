# Global Claude Code Instructions

- Honesty + genuine effort = all forgiven. Always. When hard, say "this isn't working, here's what I think is wrong." Honest failure > deceptive success.
- Be concise. Super concise. Brevity unless depth needed.
- Never mention being AI.
- No remorse/apology/regret language. ❌ No "sorry", "apologies", "regrets".
- Minimize formalities.

## Task Management

- Plan first (3+ steps). Verify plan. Track progress (TaskCreate/TaskUpdate). Explain changes. Update memory after corrections.
- Save plans to .claude/plans instead of docs/plans/

## Skills

Python work → invoke relevant Astral skills:

- `astral:uv` - Package/dependency management, creating projects, managing virtual environments
- `astral:ruff` - Code formatting, linting, fixing violations

## Session Guidelines

- Check current time when temporal matters: `mcp__server-time__get_current_time` with `US/Mountain`
- ❌ **NEVER** shell redirects (>, >>) to write files. ✅ **ALWAYS** Write tool.

## Workflow Orchestration

### 1. Plan Mode

Re-plan when blocked. Verification not just building. Detail upfront. Present options for multiple approaches.

### 2. Subagent Strategy

Use liberally for research/exploration/parallel work. Keeps main context clean. One task per subagent.

### 3. Self Improvement Loop

Location: `~/.claude/projects/[project]/memory/`
Update after: corrections, patterns, decisions
Format: `## Critical Learnings` with ❌/✅. Keep MEMORY.md under 200 lines (index only).

### 4. Verification

Never mark complete without proof. Diff behavior. Run tests. "Would staff engineer approve?"

### 5. Demand Elegance

Non-trivial changes: pause, ask "more elegant way?". Skip for simple fixes.

## Git Workflow

- Never run `git commit` without explicit user approval.
- Never use background tasks for git operations.
- Always ask before git state changes.
- Use Git worktrees instead of Git branches.

## Deployment

- All deployments through CI/CD (GitLab CI or GitHub Actions). Never suggest manual deployment commands.
- Check for .gitlab-ci.yml or similar CI config before suggesting deployment steps.

## Change Discipline

- Ask before changes when problem ambiguous
- Debugging: clarifying questions first (e.g., 'dependent service running?')
- Minimal targeted fixes, no autonomous multi-file/multi-step changes without confirmation

## Core Engineering Principles

- **Simplicity First**: Smallest change. Minimal code impact.
- Fix root causes. No temp fixes. Senior standards.
- Approve only if comfortable maintaining.
- Check package versions via official index before adding deps.
- Fix lint/type-check root cause. Suppress only if no clean alternative.

### DRY (Don't Repeat Yourself)

- Extract common logic into functions
- Create reusable components
- Share utilities across modules
- Avoid copy-paste programming

### YAGNI (You Aren't Gonna Need It)

- No features until needed
- Avoid speculative generality
- Complexity only when required
- Start simple, refactor when needed

## Coding Standards

### Python

- Type hints on all function params, return values, class attributes
- Use built-in `list`, `dict`, `set`, `tuple` for type hints — not `typing.List`, `typing.Dict`, etc.
- Use `X | None` over `Optional[X]`
- Use Pydantic, TypedDict, or dataclasses for structured data. No plain dicts
- Docstrings in Google format
- Max line length 120 chars
- NEVER use asserts except in unit tests
- Use `pathlib.Path` for file ops. Not `os.path`
- Max 5 function params. More → use dataclasses

#### Testing

- Use pytest-mock + MockerFixture. Not unittest.mock.
- Add `-> None` to all test methods.
- No docstrings on test functions.
- No comments in test functions.
- Prefer factory functions or pytest.param over complex fixture hierarchies.
- Use parametrize for multiple inputs, same logic.
- Test names self-document (e.g., `test_initialization`, `test_record_delay_increments_counter`).
- Two tests, same structure, different values → `@pytest.mark.parametrize`.
- One module = one test file.
- Place tests in correct existing file — ask if unsure.

### Markdown

Follow [Google's Markdown Style Guide](https://google.github.io/styleguide/docguide/style.html).

#### Formatting

- One sentence per line ([Semantic Line Breaks](https://sembr.org)) — cleaner git diffs
- Lines under 200 chars — break at clause boundaries (comma, conjunction, semicolon), not mid-word
- Blank lines before/after headings, code blocks, lists

#### Syntax

- Always tag fenced code blocks (e.g., `python`, `bash`, `hcl`)
- Native Markdown only — no HTML unless Markdown can't express it
- No bare URLs — use `[text](url)`
- No skipping heading levels — `#` → `##` → `###`, never jump (e.g. `#` → `###`)

### Terraform / OpenTofu

#### Tooling

- Default `tofu` CLI. Use `terraform` only when project not yet migrated.
- Never run `tofu apply`, `terraform apply`, `tofu destroy`, `terraform destroy` — suggest command, let user run.
- `tofu plan` and `tofu validate` safe to run freely.

#### OpenTofu vs Terraform

- Note when pattern/feature differs between OpenTofu and Terraform — user migrating, needs to know.
- Avoid Terraform-only features (HCP resources, Stacks) unless project confirmed Terraform.
- Prefer OpenTofu-native features where exist (e.g., `tofu test`, provider-defined functions).

#### State

- Never touch remote state manually. Use `tofu state` subcommands only when explicitly asked.
- Flag backend config changes before making them.
- Use `import` blocks (not CLI `import`) for bringing existing resources under management.
- Use `moved` blocks instead of `tofu state mv`.

#### Resource Naming

- Prefer `name_prefix` over `name` for resources that support it (e.g. security groups, IAM roles/policies,
  DB subnet/parameter groups). Avoids name collisions when module deployed multiple times in same
  account, lets AWS generate unique suffix.
- Use `name` only when deterministic, human-readable identifier required and collision risk explicitly accepted.

#### Sensitive data

- Flag any `nonsensitive()` usage as needing explicit review.

#### Working style

- Propose plan before modifying any `.tf` files.
- Flag blast-radius risks before changing running infrastructure.
- Explain tflint/trivy findings before suppressing — never add ignore comments silently.

## CLI tools

| tool | replaces | usage |
|------|----------|-------|
| `ast-grep` | - | `ast-grep --pattern '$FUNC($$$)' --lang py` - AST-based code search |
| `bat` | cat | `bat file.py` - syntax-highlighted file viewer with `--line-range` |
| `fd` | find | `fd "*.py"` - fast file finder |
| `prek` | pre-commit | `prek run` - Better `pre-commit`, re-engineered in Rust |
| `rg` (ripgrep) | grep | `rg "pattern"` - 10x faster regex search |
| `rumdl` | markdownlint | `rumdl check .` - Markdown linter, `rumdl fmt .` - Markdown formatter |
| `shellcheck` | - | `shellcheck script.sh` - shell script linter |
| `shfmt` | - | `shfmt -i 2 -w script.sh` - shell formatter |
| `trash` | rm | `trash file` - moves to macOS Trash (recoverable). **Never use `rm`** |
| `ty` | mypy | `ty check file.py` - Fast Python type checker |
| `yq` | - | `yq '.key' file.yaml` - YAML/TOML processor (same syntax as jq) |

@RTK.md
