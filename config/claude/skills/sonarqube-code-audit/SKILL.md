---
name: sonarqube-code-audit
description: Audit code changes using SonarQube to identify quality and security issues before pushing or committing. Use this when the user wants to check code quality, audit changes, run SonarQube analysis, or verify code before pushing. Triggers on phrases like "audit my changes", "check code quality", "run SonarQube on my changes", "before I push check the code", or "quality check my uncommitted code". Also use proactively when the user is about to commit or push code and hasn't explicitly run a quality check.
---

# SonarQube Code Audit

Analyze code changes using SonarQube to identify bugs, vulnerabilities, code smells, and security issues in uncommitted, staged, or branch changes.

## When to Use This Skill

Use this skill when the user:

- Explicitly asks to audit code, check quality, or run SonarQube
- Is about to commit or push code without having run a quality check
- Wants to verify changes before creating a pull request
- Mentions code quality, technical debt, or security concerns about their changes

## Workflow

**Important**: This skill requires SonarQube MCP tools for automated analysis. If those tools are unavailable or permissions are denied, inform the user and stop. This skill is specifically for SonarQube analysis, not general code review.

### Step 1: Determine What to Analyze

Ask the user what changes to analyze if it's not clear from context:

- **Uncommitted changes** (default): All modifications in the working directory
- **Staged changes**: Only files added to the git index
- **Branch changes**: All changes since branching from the base branch (typically `develop` or `main`)

Use git commands to identify the changed files:

```bash
# Uncommitted changes (including staged)
git diff --name-only HEAD

# Staged changes only
git diff --cached --name-only

# Branch changes (detect base branch dynamically)
# Try develop first (common in many projects), fall back to main
git diff --name-only develop...HEAD 2>/dev/null || git diff --name-only main...HEAD
```

**Tip**: When comparing branches, detect the repository's default branch by checking:

1. Common patterns: `develop`, `main`, `master`
2. Git remote: `git symbolic-ref refs/remotes/origin/HEAD`
3. Ask the user if unclear from context

### Step 2: Resolve the SonarQube Project Key

The project key is required for all SonarQube API calls. Resolve it using this priority order:

1. Check for `.sonarlint/connectedMode.json` in the workspace root or parent directories - use the `projectKey` field
2. Search for `sonar.projectKey` in project config files: `sonar-project.properties`, `pom.xml`, `build.gradle`, `build.gradle.kts`, `package.json`
3. Search for `sonar.projectKey` in CI/CD pipeline files: `.github/workflows/*.yml`, `Jenkinsfile`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `.circleci/config.yml`
4. If the user mentions a project name, use `mcp__sonarqube__search_my_sonarqube_projects` to find it
5. If no key is found, use `mcp__sonarqube__search_my_sonarqube_projects` to list available projects and ask the user to select one

### Step 3: Analyze Each Changed File

**Important - Workspace Mount Modes:**

The SonarQube MCP server supports two modes:

- **Workspace mounted** (`-v /path/to/project:/app/mcp-workspace`): Server reads files directly from disk. Pass only `filePath` - the server will read the file content automatically.
- **Workspace NOT mounted**: Server cannot access files directly. You must pass both `filePath` and full file content.

**For this skill**: Always pass `codeSnippet` with the changed code only. This filters SonarQube issues to show only problems in the lines you modified, which is exactly what you want when auditing changes.

**Trade-off**: This means pre-existing issues in unchanged lines won't be reported. If the user wants a full file analysis, mention this limitation and offer to analyze the complete file separately.

For each changed file:

1. **Detect the language** from the file extension:
   - `.py` → `python`
   - `.js`, `.jsx` → `js`
   - `.ts`, `.tsx` → `ts`
   - `.java` → `java`
   - `.go` → `go`
   - `.php` → `php`
   - `.rb` → `ruby`
   - `.kt` → `kotlin`
   - `.xml` → `xml`
   - `.html` → `html`
   - `.css` → `css`
   - `.dockerfile`, `Dockerfile` → `docker`
   - `.tf` → `terraform`
   - `.yml`, `.yaml` (in CI/CD directories) → `kubernetes` or `ansible` (context-dependent)

2. **Get the changed code snippet**:

   **Critical**: The `codeSnippet` parameter requires **exact contiguous blocks** from the actual file, not reconstructed from git diff. Follow this workflow:

   a. **Identify changed line numbers** using git diff with no context:

   ```bash
   git diff -U0 HEAD -- <file_path>
   ```

   Parse the `@@` hunks to extract line numbers (e.g., `@@ -57,1 +57,1 @@` means line 57 changed).

   b. **Read the actual file content** with surrounding context (5-10 lines before and after):

   ```bash
   # If line 57 changed, read lines 52-67 (±5 lines context)
   Read(file_path, offset=52, limit=15)
   ```

   c. **Extract contiguous blocks** with exact whitespace:
   - Include the changed lines PLUS surrounding context
   - Must be continuous (no gaps)
   - Preserve exact indentation and whitespace
   - If multiple separate changes exist, extract each as a separate block

   **Why context is needed**: The tool locates the snippet within the file by exact string matching. Context ensures unique matching and prevents whitespace errors.

   **Example**:
   - Changed lines: 57, 63, 65 (within same function)
   - Extract: Lines 55-68 (covers all changes with context)
   - Result: One contiguous block that SonarQube can locate in the file

3. **Determine the file scope**:
   - `TEST` if the file path contains `test`, `tests`, `__tests__`, `spec`, or `specs`
   - `MAIN` otherwise

4. **Convert to project-relative path**: Remove any leading repository path to get the path relative to the project root (e.g., `src/main/java/MyClass.java` not `/Users/user/repo/src/main/java/MyClass.java`).

5. **Call the SonarQube analyzer**:

   Try to call `mcp__sonarqube__analyze_code_snippet`:

   ```text
   mcp__sonarqube__analyze_code_snippet(
     projectKey=<resolved_key>,
     filePath=<project_relative_path>,
     language=[<detected_language>],
     scope=[<MAIN_or_TEST>],
     codeSnippet=<changed_code>
   )
   ```

   **If SonarQube tools are unavailable or permissions are denied**: Stop the audit and inform the user:
   - SonarQube MCP tools are unavailable or permissions were denied
   - The audit cannot proceed without SonarQube integration
   - Suggest checking MCP server configuration and permissions in `~/.claude/settings.json`

6. **Enrich results with rule details**:

   For each unique rule found in the analysis, call `mcp__sonarqube__show_rule` to get comprehensive information:

   ```text
   mcp__sonarqube__show_rule(key=<rule_key>)
   ```

   This provides:
   - Detailed rule description and rationale
   - Impact explanation (why this matters)
   - Remediation guidance and best practices
   - Code examples showing correct patterns (when available)

   Include this enriched information in your audit report to make findings more educational and actionable. This helps users understand not just WHAT is wrong, but WHY it matters and HOW to fix it properly.

7. **Handle errors gracefully**:
   - If the file doesn't exist in SonarQube (new file), note that it can't be analyzed until after the first commit
   - If the language isn't supported, skip the file and note it
   - If the API returns an error, log it and continue with remaining files
   - **If MCP tools are blocked or unavailable**: Stop the audit and inform the user (see point 5 above)

### Step 4: Present Results

Format the results as a structured report:

```markdown
# SonarQube Code Audit Results

**Analyzed**: <N> files
**Issues Found**: <total_count>

---

## Summary by Severity

- 🔴 **BLOCKER**: <count>
- 🟠 **HIGH**: <count>
- 🟡 **MEDIUM**: <count>
- 🔵 **LOW**: <count>
- ⚪ **INFO**: <count>

---

## Issues by File

### <file_path>:<line_number>

**Severity**: <severity> | **Type**: <type> | **Impact**: <software_quality>

**Issue**: <message>

**Rule**: `<rule_key>` - [View Documentation](<rule_url_if_available>)

**Location**: Line <line_number>, Column <column_range>

<code_snippet_showing_issue>

**Why This Matters**: <detailed_explanation_from_show_rule>

**How to Fix**: <remediation_guidance_from_show_rule>

**Example** (if available from show_rule):

```<language>
<correct_pattern_example>
```

---

(Repeat for each issue)

Group issues by file, then by severity within each file. For each issue, include:

- The exact line number and column range
- The severity (BLOCKER, HIGH, MEDIUM, LOW, INFO)
- The issue type (BUG, VULNERABILITY, CODE_SMELL, SECURITY_HOTSPOT)
- The impacted software quality (MAINTAINABILITY, RELIABILITY, SECURITY)
- The rule key (for reference)
- A clear description of the problem
- **Enriched details from `show_rule`**: Why it matters, how to fix, examples of correct patterns

### Step 5: Provide Context and Next Steps

After presenting the results:

1. **If no issues found**: Congratulate the user and note that the code passes SonarQube quality checks for the analyzed files.

2. **If issues found**: Provide actionable guidance:
   - Prioritize BLOCKER and HIGH severity issues
   - Explain that security issues should be addressed before pushing
   - The report already includes detailed rule information from `show_rule` - reference this to help the user understand WHY each issue matters
   - Offer to help fix specific issues if the user asks

3. **Limitations to mention**:
   - New files (not yet in SonarQube) can't be analyzed until after the first commit
   - The analysis is based on SonarQube's existing project configuration
   - Some issues may only be detected after a full project scan

## Language Detection Reference

Comprehensive language mapping:

| Extension | Language |
|-----------|----------|
| .py | python |
| .js, .jsx | js |
| .ts, .tsx | ts |
| .java | java |
| .go | go |
| .php | php |
| .rb | ruby |
| .kt, .kts | kotlin |
| .xml | xml |
| .html, .htm | html |
| .css, .scss, .sass | css |
| .dockerfile, Dockerfile | docker |
| .tf, .tfvars | terraform |
| .yml, .yaml (ansible/k8s context) | ansible or kubernetes |
| .json (secrets context) | secrets |
| .jsp | jsp |

## Edge Cases

### Files Not in SonarQube

If a file doesn't exist in the SonarQube project yet (new file, or SonarQube hasn't scanned it):

- Note this in the output
- Explain that the file will be analyzed after it's committed and SonarQube scans the project
- Suggest running a full SonarQube scan if needed

### Binary or Unsupported Files

Skip binary files, images, and unsupported file types. Note them briefly in the output but don't treat as errors.

### Large Changesets

If there are more than 20 changed files, ask the user if they want to:

- Analyze all files (may take time)
- Analyze only specific files
- Focus on specific directories or file types

## Example Interactions

**Example 1: Before pushing**

```text
User: "Before I push this change, check the code quality"
Assistant: I'll audit your uncommitted changes with SonarQube. Let me identify the changed files...
[runs git diff, resolves project key, analyzes each file]
[presents detailed report with issues found]
```

**Example 2: Staged changes**

```text
User: "Run SonarQube on my staged changes"
Assistant: I'll analyze the files you've staged for commit...
[analyzes only staged files]
```

**Example 3: Branch comparison**

```text
User: "Audit all the code I've changed in this branch before I create the PR"
Assistant: I'll compare your branch to develop and analyze all changes...
[detects base branch, compares branch to develop, analyzes all differences]
```

## Tips for Success

- **Focus on changed code**: The skill uses code snippets to filter issues, so only problems in the changed lines are reported. This is intentional - when auditing changes, you want to see what your modifications introduced, not all pre-existing issues.
- **Filtering trade-off**: By filtering to changed lines only, pre-existing issues in unchanged code won't be reported. If a user wants a comprehensive file audit (not just changes), offer to analyze the complete file separately.
- **Workspace mount behavior**: If your SonarQube MCP server has the project directory mounted (`-v /path/to/project:/app/mcp-workspace`), the server reads files directly from disk. The `codeSnippet` parameter still works for filtering - it tells SonarQube to only report issues within those specific lines.
- **Project key matters**: An incorrect project key will return results from the wrong project
- **New files limitation**: Files not yet in SonarQube can't be analyzed - they need to be committed and scanned first
- **Language detection**: Ensure file extensions are standard - the skill relies on extensions to detect language
- **Be specific about scope**: If the user wants only staged or branch changes, clarify that upfront
