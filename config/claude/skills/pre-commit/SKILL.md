---
name: pre-commit
description: Intercept and run pre-commit hooks before any commit happens. Trigger on: (1) explicit `/pre-commit` command, (2) any phrase signaling commit intent — "let's commit", "ready to commit", "committing now", "ship it", "done with changes", "time to push", "gonna commit", or finishing implementation work and mentioning a commit in the same message, (3) a code review request that also involves committing. Run `pre-commit run --all-files` BEFORE any git commit workflow begins — even if the user didn't mention pre-commit. That's the point: catching issues before they're committed.
---

# Pre-commit Checks

Run code quality hooks before the user commits.

## Step 1: Locate the repo root

```bash
git rev-parse --show-toplevel
```

Check whether `.pre-commit-config.yaml` exists at that path. If it doesn't, tell the user pre-commit is not configured in this repo and stop — nothing to run.

## Step 2: Run all hooks

```bash
pre-commit run --all-files
```

## Step 3: Report results clearly

**Hooks pass** — tell the user all checks passed and they're clear to commit.

**Hooks fail** — show the full output as-is. Point out which hooks failed. Then stop — do not attempt to fix issues or proceed to commit. The user will address the failures and re-run when ready.

**`pre-commit` not installed** — show the error as-is and stop. Don't suggest fixes.
