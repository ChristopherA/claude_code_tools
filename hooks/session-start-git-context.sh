#!/bin/bash
# Git context hook for Claude Code SessionStart event.
# Provides git repository awareness on session start.
#
# Owner: session-skills project
# Deploy to: ~/.claude/hooks/session-start-git-context.sh
#
# Output goes to Claude's context via stdout (exit 0).
# Only runs if current directory is a git repository.

set -euo pipefail

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    # Not a git repo - exit silently (no context to add)
    exit 0
fi

# Build context output
echo "=== Git Repository Context ==="
echo ""

# Current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "detached HEAD")
echo "Branch: $BRANCH"

# Check for uncommitted changes
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    CHANGES=$(git status --short | wc -l | tr -d ' ')
    echo "Status: $CHANGES uncommitted change(s) - commit before new work"
else
    echo "Status: Clean working tree"
fi

echo ""

# Recent commits (last 5, one line each)
echo "Recent commits:"
git log --oneline -5 2>/dev/null | sed 's/^/  /'

echo ""

# Show any stashes
STASH_COUNT=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
if [ "$STASH_COUNT" -gt 0 ]; then
    echo "Stashes: $STASH_COUNT stash(es) available"
    echo ""
fi

# Remote tracking status (ahead/behind)
UPSTREAM=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)
if [ -n "$UPSTREAM" ]; then
    AHEAD=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo "0")
    if [ "$AHEAD" -gt 0 ] || [ "$BEHIND" -gt 0 ]; then
        echo "Remote: $AHEAD ahead, $BEHIND behind $UPSTREAM"
        echo ""
    fi
fi

# =============================================================================
# Foundation Hook Detection (WARNING only - session-skills doesn't enforce)
# =============================================================================
# Session-skills is responsible for session management, not git enforcement.
# Git enforcement is owned by claude-code-foundation project.
# This check WARNS if enforcement infrastructure is missing.

check_foundation_hooks() {
    local missing=()

    [ ! -f "$HOME/.claude/hooks/git-commit-compliance.py" ] && \
        missing+=("git-commit-compliance.py")
    [ ! -f "$HOME/.claude/hooks/git-workflow-guidance.py" ] && \
        missing+=("git-workflow-guidance.py")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Warning: Git enforcement hooks not installed:"
        printf "  - %s\n" "${missing[@]}"
        echo "  Install from: claude-code-foundation project"
        echo ""
    fi
}

check_foundation_hooks

echo "=== End Git Context ==="

exit 0
