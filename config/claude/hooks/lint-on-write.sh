#!/usr/bin/env bash
# Lint files after Write/Edit

f=$(cat | jq -r '.tool_input.file_path // .tool_response.filePath')

case "$f" in
  *.md)
    rumdl check --fix --output-format=concise --color never "$f" 1>&2
    rc=$?
    exit $((rc ? 2 : 0))
    ;;
  *.py)
    ruff check --fix --output-format=concise --no-show-fixes --color never "$f" 1>&2
    ruff_rc=$?

    ty check --fix --output-format=concise --color never "$f" 1>&2
    ty_rc=$?

    if [ $ruff_rc -ne 0 ] || [ $ty_rc -ne 0 ]; then
      exit 2
    fi
    exit 0
    ;;
  *.tf)
    tofu validate -compact-warnings -no-color 1>&2
    rc=$?
    exit $((rc ? 2 : 0))
    ;;
esac

exit 0
