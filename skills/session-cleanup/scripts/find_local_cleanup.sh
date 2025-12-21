#!/bin/bash
# find_local_cleanup.sh - Check for project-specific cleanup checklist
# Usage: find_local_cleanup.sh [PROJECT_ROOT]

PROJECT_ROOT="${1:-$PWD}"
LOCAL_FILE="$PROJECT_ROOT/claude/processes/local-session-cleanup.md"

if [ -f "$LOCAL_FILE" ]; then
    echo "FOUND: $LOCAL_FILE"
else
    echo "INFO: No project-specific cleanup checklist"
    echo "INFO: Looked for: $LOCAL_FILE"
fi

exit 0
