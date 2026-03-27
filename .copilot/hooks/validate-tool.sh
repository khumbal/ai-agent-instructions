#!/bin/bash
# PreToolUse hook — block destructive commands, audit tool usage
set -euo pipefail

INPUT=$(cat /dev/stdin)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")

# --- Audit logging with rotation ---
AUDIT_LOG="$HOME/.copilot/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
# Rotate if > 1MB
if [ -f "$AUDIT_LOG" ]; then
  LOG_SIZE=$(stat -f%z "$AUDIT_LOG" 2>/dev/null || stat -c%s "$AUDIT_LOG" 2>/dev/null || echo "0")
  if [ "$LOG_SIZE" -gt 1048576 ] 2>/dev/null; then
    mv "$AUDIT_LOG" "${AUDIT_LOG}.$(date +%Y%m%d%H%M%S).old" 2>/dev/null || true
    # Keep only last 5 rotated logs
    ls -t "${AUDIT_LOG}".*.old 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
  fi
fi
TS=$(date +%Y-%m-%dT%H:%M:%S)
echo "[$TS] tool=$TOOL_NAME" >> "$AUDIT_LOG" 2>/dev/null || true

# --- Guard: protect sensitive files from Write/Edit ---
if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then
  FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
if isinstance(ti, str):
    import json as j; ti = j.loads(ti)
print(ti.get('file_path', ''))
" 2>/dev/null || echo "")

  if echo "$FILE_PATH" | grep -qE '\.env$|credentials|\.secret|id_rsa|\.pem$'; then
    echo "[$TS]   ASK: Write to sensitive file $FILE_PATH" >> "$AUDIT_LOG" 2>/dev/null || true
    python3 -c "
import json
print(json.dumps({'hookSpecificOutput':{'hookEventName':'PreToolUse','permissionDecision':'ask','permissionDecisionReason':'Writing to sensitive file — requires confirmation'}}))"
    exit 0
  fi
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

# --- Guard: only check Bash commands ---
if [ "$TOOL_NAME" != "Bash" ]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
if isinstance(ti, str):
    import json as j; ti = j.loads(ti)
print(ti.get('command', ''))
" 2>/dev/null || echo "")

echo "[$TS]   cmd=$COMMAND" >> "$AUDIT_LOG" 2>/dev/null || true

# --- Pattern-based guards (most dangerous first) ---
BLOCK_REASON=""

# Destructive filesystem / database / git
if echo "$COMMAND" | grep -qEi 'rm\s+-rf\s+[/~]|DROP\s+(TABLE|DATABASE)|--force\s+push|push\s+--force|git\s+reset\s+--hard|TRUNCATE\s+TABLE'; then
  BLOCK_REASON="Destructive command detected"

# Credential / secret exposure
elif echo "$COMMAND" | grep -qEi 'echo\s+\$[A-Z_]*(KEY|SECRET|TOKEN|PASSWORD|CREDENTIAL)|printenv.*(KEY|SECRET|TOKEN|PASSWORD)'; then
  BLOCK_REASON="Potential credential exposure"

# Remote code execution (pipe to shell, chmod 777)
elif echo "$COMMAND" | grep -qEi 'curl\s+.*\|\s*(ba)?sh|wget\s+.*\|\s*(ba)?sh|chmod\s+777'; then
  BLOCK_REASON="Unsafe remote execution pattern"

# Publishing / deployment (accidental releases)
elif echo "$COMMAND" | grep -qEi 'npm\s+publish|mvn\s+deploy|gradle\s+publish|docker\s+push'; then
  BLOCK_REASON="Publishing/deployment command"
fi

if [ -n "$BLOCK_REASON" ]; then
  echo "[$TS]   ASK: $BLOCK_REASON" >> "$AUDIT_LOG" 2>/dev/null || true
  python3 -c "
import json, sys
print(json.dumps({'hookSpecificOutput':{'hookEventName':'PreToolUse','permissionDecision':'ask','permissionDecisionReason':sys.argv[1]+' — requires confirmation'}}))
" "$BLOCK_REASON"
  exit 0
fi

# Allow
echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
