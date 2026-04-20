---
name: Markdown Standards
paths:
  - "**/*.md"
---

# Markdown Standards

Follow [Google's Markdown Style Guide](https://google.github.io/styleguide/docguide/style.html) as the baseline standard.

## Formatting

- Use one sentence per line ([Semantic Line Breaks](https://sembr.org)) for cleaner git diffs
- Keep lines under 200 characters — break long sentences at natural clause boundaries (comma, conjunction, semicolon) rather than mid-word wrapping
- Use blank lines before and after headings, code blocks, and lists

## Syntax

- Always add language tags to fenced code blocks (e.g. ```python,```bash, ```hcl)
- Use native Markdown syntax — no HTML unless Markdown genuinely cannot express it
- No bare URLs — always use `[text](url)` format
- Never skip heading levels — `#` → `##` → `###`, never jump (e.g. `#` → `###`)
