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

# Join context
CONTEXT=$(IFS=' | '; echo "${CONTEXT_PARTS[*]}")

if [ -n "$CONTEXT" ]; then
  # Output JSON with additionalContext
  python3 -c "
import json, sys
out = {'hookSpecificOutput': {'hookEventName': 'SessionStart', 'additionalContext': sys.argv[1]}}
print(json.dumps(out))
" "$CONTEXT"
fi
