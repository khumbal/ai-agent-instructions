#!/bin/bash
# PreCompact hook — save important context before conversation compaction
set -euo pipefail

INPUT=$(cat /dev/stdin)

SESSION_DIR="$HOME/.copilot/session-backups"
mkdir -p "$SESSION_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Extract transcript path if available
TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "import sys,json;print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null || echo "")

# Save transcript backup
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  cp "$TRANSCRIPT_PATH" "$SESSION_DIR/transcript_$TIMESTAMP.json"
fi

# Save current git state for context recovery
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  {
    echo "=== Compaction backup $TIMESTAMP ==="
    echo "Branch: $(git branch --show-current 2>/dev/null)"
    echo "Recent commits:"
    git log --oneline -5 2>/dev/null
    echo "Modified files:"
    git diff --name-only 2>/dev/null
    echo "Staged files:"
    git diff --cached --name-only 2>/dev/null
  } > "$SESSION_DIR/git-state_$TIMESTAMP.txt"
fi

# Cleanup old backups (keep last 10)
ls -t "$SESSION_DIR"/transcript_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
ls -t "$SESSION_DIR"/git-state_*.txt 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null

echo '{"systemMessage":"Context compaction detected — session state backed up."}'
