#!/bin/bash
# PostToolUse hook — auto-lint Python files after Write/Edit
set -euo pipefail

INPUT=$(cat /dev/stdin)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
if isinstance(ti, str):
    import json as j; ti = j.loads(ti)
print(ti.get('file_path', ''))
" 2>/dev/null || echo "")

# Only lint .py files
if [[ "$FILE_PATH" == *.py ]] && command -v ruff &>/dev/null; then
  ruff check --fix --quiet "$FILE_PATH" 2>/dev/null || true
  ruff format --quiet "$FILE_PATH" 2>/dev/null || true
fi
