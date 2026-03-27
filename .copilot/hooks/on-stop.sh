#!/bin/bash
# Stop hook — log session end and check for uncommitted work
set -euo pipefail

AUDIT_LOG="$HOME/.copilot/audit.log"
TS=$(date +%Y-%m-%dT%H:%M:%S)
echo "[$TS] === SESSION END ===" >> "$AUDIT_LOG" 2>/dev/null || true

# Warn about uncommitted changes
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  DIRTY=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  if [ "$DIRTY" -gt 0 ] || [ "$STAGED" -gt 0 ]; then
    echo "[$TS]   uncommitted: $DIRTY modified, $STAGED staged" >> "$AUDIT_LOG" 2>/dev/null || true
  fi
fi
