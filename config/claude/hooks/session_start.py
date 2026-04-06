#!/usr/bin/env python3
"""SessionStart hook - loads project context."""

# /// script
# requires-python = ">=3.14"
# dependencies = []
# ///

import json
import os
import subprocess
from datetime import datetime
from pathlib import Path


def run_cmd(cmd: list[str], timeout: int = 2) -> str:
    """Run command and return output, empty string on error."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False,
            timeout=timeout,
        )
        return result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return ""


def get_git_info() -> dict[str, str | int]:
    """Get git branch and status."""
    branch = run_cmd(["git", "symbolic-ref", "--short", "HEAD"])
    if not branch:
        return {"branch": "not a git repo", "staged": 0, "unstaged": 0, "untracked": 0}

    staged = run_cmd(["git", "diff", "--cached", "--numstat"])
    unstaged = run_cmd(["git", "diff", "--numstat"])
    untracked = run_cmd(["git", "ls-files", "--others", "--exclude-standard"])

    return {
        "branch": branch,
        "staged": len(staged.splitlines()) if staged else 0,
        "unstaged": len(unstaged.splitlines()) if unstaged else 0,
        "untracked": len(untracked.splitlines()) if untracked else 0,
    }


def get_docker_services() -> int:
    """Count running Docker Compose services."""
    output = run_cmd(["docker", "compose", "ps", "--format", "json"])
    if not output:
        return 0

    try:
        services = json.loads(f"[{output.replace('}\n{', '},{')}]")
        return sum(1 for s in services if s.get("State") == "running")
    except json.JSONDecodeError:
        return 0


def get_remote_type() -> str:
    """Detect remote type: gitlab, github, or empty."""
    remote = run_cmd(["git", "remote", "get-url", "origin"])
    if not remote:
        return ""

    if "gitlab" in remote.lower():
        return "gitlab"
    elif "github" in remote.lower():
        return "github"

    return ""


def get_ci_pipeline_status(remote_type: str, branch: str) -> str:
    """Get CI pipeline status based on remote type."""
    if not branch or branch == "not a git repo":
        return ""

    if remote_type == "gitlab":
        # Use glab for GitLab (longer timeout for API calls)
        result = run_cmd(["glab", "ci", "status", "--branch", branch], timeout=5)
        if not result:
            return ""

        # Parse simple status output
        if "success" in result.lower() or "passed" in result.lower():
            return "✅ Pipeline: passed"
        elif "failed" in result.lower():
            return "❌ Pipeline: failed"
        elif "running" in result.lower():
            return "🔄 Pipeline: running"
        elif "pending" in result.lower():
            return "⏳ Pipeline: pending"
        elif "canceled" in result.lower():
            return "🚫 Pipeline: canceled"

        return f"Pipeline: {result.split()[0] if result else 'unknown'}"

    elif remote_type == "github":
        # Use gh for GitHub (longer timeout for API calls)
        result = run_cmd(
            ["gh", "run", "list", "--branch", branch, "--limit", "1", "--json", "status,conclusion"], timeout=5
        )
        if not result:
            return ""

        try:
            runs = json.loads(result)
            if not runs:
                return ""

            run = runs[0]
            status = run.get("status", "")
            conclusion = run.get("conclusion", "")

            if status == "completed":
                if conclusion == "success":
                    return "✅ Actions: passed"
                elif conclusion == "failure":
                    return "❌ Actions: failed"
                else:
                    return f"Actions: {conclusion}"
            elif status == "in_progress":
                return "🔄 Actions: running"
            elif status == "queued":
                return "⏳ Actions: queued"

            return f"Actions: {status}"
        except json.JSONDecodeError:
            return ""

    return ""


def get_branch_warning(branch: str) -> str:
    """Warn if on protected branch."""
    if branch in ["main", "develop", "master"]:
        return f"⚠️  WARNING: On protected branch '{branch}'"

    return ""


def get_recent_commits() -> str:
    """Get last 3 commits on current branch."""
    result = run_cmd(["git", "log", "-3", "--pretty=format:%h %s", "--no-merges"])

    if not result:
        return ""

    commits = result.strip().split("\n")
    return "Recent commits:\n  " + "\n  ".join(commits)


def get_python_env() -> str:
    """Detect active Python environment."""
    # Check for VIRTUAL_ENV (pipenv/venv)
    venv = os.getenv("VIRTUAL_ENV")
    if venv:
        venv_path = Path(venv)
        return f"🐍 {venv_path.name}"

    # Check for pipenv in current directory
    if Path("Pipfile").exists():
        result = run_cmd(["pipenv", "--venv"])
        if result and "No virtualenv" not in result:
            venv_path = Path(result)
            return f"🐍 pipenv ({venv_path.name})"

    # Check for uv project
    if Path("pyproject.toml").exists():
        result = run_cmd(["uv", "venv", "--show-path"])
        if result:
            venv_path = Path(result)
            return f"🐍 uv ({venv_path.name})"

    return ""


def main() -> None:
    """Build and output session context."""
    cwd = Path.cwd()
    git_info = get_git_info()
    branch = git_info["branch"]
    remote_type = get_remote_type()
    services = get_docker_services()
    current_time = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z")

    # Get additional context
    branch_warning = get_branch_warning(branch)
    ci_status = get_ci_pipeline_status(remote_type, branch)
    recent_commits = get_recent_commits()
    python_env = get_python_env()

    # Format git status
    git_status = ""
    if any(git_info[k] for k in ["staged", "unstaged", "untracked"]):
        git_status = (
            f" ({git_info['staged']} staged, {git_info['unstaged']} unstaged, {git_info['untracked']} untracked)"
        )

    # Build context lines
    lines = []

    # Show warning first if present
    if branch_warning:
        lines.append(branch_warning)

    lines.extend(
        [
            f"Working directory: {cwd}",
            f"Git branch: {branch}{git_status}",
        ]
    )

    if ci_status:
        lines.append(ci_status)

    lines.append(f"Docker services running: {services}")

    if python_env:
        lines.append(python_env)

    if recent_commits:
        lines.append(recent_commits)

    lines.append(f"Current time: {current_time}")

    context = "\n".join(lines)

    output = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context,
        }
    }

    print(json.dumps(output))


if __name__ == "__main__":
    main()
