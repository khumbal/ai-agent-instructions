#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COPILOT_SOURCE="$SCRIPT_DIR/.copilot"
PROMPTS_SOURCE="$SCRIPT_DIR/.vscode-prompts"

COPILOT_TARGET="$HOME/.copilot"
PROMPTS_TARGET="$HOME/Library/Application Support/Code/User/prompts"

CHECK_ONLY=false
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

# --- Pre-flight validation ---
errors=0

if [ ! -d "$COPILOT_SOURCE" ]; then
  echo "✗ Missing source: $COPILOT_SOURCE"
  errors=$((errors + 1))
fi

if [ ! -d "$PROMPTS_SOURCE" ]; then
  echo "✗ Missing source: $PROMPTS_SOURCE"
  errors=$((errors + 1))
fi

# Validate key files exist
for f in "$COPILOT_SOURCE/AGENTS.md" "$PROMPTS_SOURCE/My Super Developer.instructions.md"; do
  if [ ! -f "$f" ]; then
    echo "✗ Missing required file: $f"
    errors=$((errors + 1))
  fi
done

# Validate hooks are executable
for hook in "$COPILOT_SOURCE"/hooks/*.sh; do
  if [ -f "$hook" ] && [ ! -x "$hook" ]; then
    echo "⚠ Hook not executable: $hook"
    if [ "$CHECK_ONLY" = false ]; then
      chmod +x "$hook"
      echo "  → Fixed: made executable"
    else
      errors=$((errors + 1))
    fi
  fi
done

# Validate SKILL.md files have frontmatter
for skill in "$COPILOT_SOURCE"/skills/*/SKILL.md; do
  if [ -f "$skill" ] && ! head -1 "$skill" | grep -q '^---'; then
    echo "⚠ Missing YAML frontmatter: $skill"
    errors=$((errors + 1))
  fi
done

if [ "$errors" -gt 0 ] && [ "$CHECK_ONLY" = true ]; then
  echo ""
  echo "✗ Validation failed with $errors error(s)"
  exit 1
fi

if [ "$CHECK_ONLY" = true ]; then
  echo "✓ All checks passed"
  exit 0
fi

# --- Linking ---
link() {
  local source="$1" target="$2" label="$3"

  if [ -L "$target" ]; then
    current="$(readlink "$target")"
    if [ "$current" = "$source" ]; then
      echo "✓ $label already linked"
      return
    fi
    echo "⚠ $label symlink exists → $current"
    echo "  Replacing with → $source"
    rm "$target"
  elif [ -e "$target" ]; then
    echo "⚠ $label exists as regular file/directory — backing up to ${target}.bak"
    mv "$target" "${target}.bak"
  fi

  ln -s "$source" "$target"
  echo "✓ $label linked → $source"
}

echo "=== AI Agent Instructions Setup ==="
echo ""

link "$COPILOT_SOURCE" "$COPILOT_TARGET" "~/.copilot"
link "$PROMPTS_SOURCE" "$PROMPTS_TARGET" "VS Code prompts"

echo ""
echo "Done!"
