#!/bin/bash
# PreCompact hook — save git state before conversation compaction
set -euo pipefail

INPUT=$(cat /dev/stdin)

SESSION_DIR="$HOME/.copilot/session-backups"
mkdir -p "$SESSION_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Save current git state for context recovery
GIT_CONTEXT=""
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  GIT_CONTEXT=$(cat <<GITEOF
Branch: $(git branch --show-current 2>/dev/null || echo "detached")
Recent commits:
$(git log --oneline -5 2>/dev/null || echo "none")
Modified files:
$(git diff --name-only 2>/dev/null || echo "none")
Staged files:
$(git diff --cached --name-only 2>/dev/null || echo "none")
GITEOF
)
  echo "=== Compaction backup $TIMESTAMP ===" > "$SESSION_DIR/git-state_$TIMESTAMP.txt"
  echo "$GIT_CONTEXT" >> "$SESSION_DIR/git-state_$TIMESTAMP.txt"
fi

# Cleanup old backups (keep last 10)
ls -t "$SESSION_DIR"/git-state_*.txt 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true

# Inject git context as system message so agent retains awareness after compaction
python3 -c "
import json, sys
ctx = sys.argv[1] if len(sys.argv) > 1 else ''
msg = 'Pre-compaction state saved.'
if ctx:
    msg += ' Git state:\\n' + ctx
print(json.dumps({'systemMessage': msg}))
" "$GIT_CONTEXT"
