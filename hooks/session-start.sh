#!/bin/bash
# SessionStart hook: Capture project root for session-wide availability
# This ensures PROJECT_ROOT persists throughout the session even when Claude changes directories
#
# Owner: session-skills project
# Deploy to: ~/.claude/hooks/session-start.sh

# CLAUDE_PROJECT_DIR is available in hooks (contains project root where 'claude .' was run)
# CLAUDE_ENV_FILE is the session-specific environment file for persisting variables

if [ -n "$CLAUDE_ENV_FILE" ]; then
  # Persist PROJECT_ROOT for all bash commands in this session
  echo "export PROJECT_ROOT=\"$CLAUDE_PROJECT_DIR\"" >> "$CLAUDE_ENV_FILE"
fi

exit 0
