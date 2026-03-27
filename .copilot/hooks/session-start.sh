#!/bin/bash
# SessionStart hook — inject project context so agent doesn't waste tokens exploring
set -euo pipefail

CONTEXT_PARTS=()

# Git context
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "no commits")
  CONTEXT_PARTS+=("Branch: $BRANCH | Last commit: $LAST_COMMIT")
fi

# Java version
if command -v java &>/dev/null; then
  JAVA_VER=$(java -version 2>&1 | head -1 | sed 's/.*"\(.*\)".*/\1/')
  CONTEXT_PARTS+=("Java: $JAVA_VER")
fi

# Node version
if command -v node &>/dev/null; then
  NODE_VER=$(node --version 2>/dev/null)
  CONTEXT_PARTS+=("Node: $NODE_VER")
fi

# Build tool detection
if [ -f "pom.xml" ]; then
  CONTEXT_PARTS+=("Build: Maven")
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  CONTEXT_PARTS+=("Build: Gradle")
elif [ -f "package.json" ]; then
  CONTEXT_PARTS+=("Build: npm/bun")
fi

# --- Trading project: Risk snapshot ---
if [ -f "positions/pnl_state.json" ]; then
  PNL_INFO=$(python3 -c "
import json, sys
try:
    with open('positions/pnl_state.json') as f:
        d = json.load(f)
    parts = []
    if 'daily_pnl_pct' in d: parts.append(f\"Daily PnL: {d['daily_pnl_pct']:.2%}\")
    if 'max_drawdown_pct' in d: parts.append(f\"Max DD: {d['max_drawdown_pct']:.2%}\")
    paused = d.get('paused_today', False)
    stopped = d.get('system_stopped', False)
    if stopped: parts.append('SYSTEM STOPPED')
    elif paused: parts.append('PAUSED TODAY')
    else: parts.append('Trading OK')
    print(' | '.join(parts))
except Exception:
    pass
" 2>/dev/null || true)
  [ -n "$PNL_INFO" ] && CONTEXT_PARTS+=("Risk: $PNL_INFO")
fi

# --- Trading project: Signal queue health ---
SIGNAL_WARNINGS=""
for dir in signals/pending signals/executing signals/failed; do
  if [ -d "$dir" ]; then
    count=$(find "$dir" -maxdepth 1 -name "*.json" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
      SIGNAL_WARNINGS="${SIGNAL_WARNINGS}${dir##*/}=$count "
    fi
  fi
done
[ -n "$SIGNAL_WARNINGS" ] && CONTEXT_PARTS+=("Signals: ${SIGNAL_WARNINGS% }")

# Join context
CONTEXT=$(IFS=' | '; echo "${CONTEXT_PARTS[*]}")

if [ -n "$CONTEXT" ]; then
  python3 -c "
import json, sys
out = {'hookSpecificOutput': {'hookEventName': 'SessionStart', 'additionalContext': sys.argv[1]}}
print(json.dumps(out))
" "$CONTEXT"
fi
