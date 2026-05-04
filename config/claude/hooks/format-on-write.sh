#!/usr/bin/env bash
# Format files after Write/Edit

INPUT=$(cat)
f=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath')

case "$f" in
  *.md)
    rumdl fmt --silent "$f" 2>/dev/null || true
    ;;
  *.py)
    ruff format --silent "$f" 2>/dev/null || true
    ;;
  *.tf)
    tofu fmt -list=false "$f" 2>/dev/null || true
    ;;
esac
