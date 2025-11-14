#!/bin/bash
# commit_resume.sh - Commit CLAUDE_RESUME.md after session closure
# Part of session-closure skill v1.3.7
#
# Usage: ./commit_resume.sh [PROJECT_ROOT]
#
# Arguments:
#   PROJECT_ROOT - Path to project root directory (defaults to current directory)
#                  Should contain CLAUDE_RESUME.md to commit
#
# Behavior:
# - Checks if in a git repository (skips if not)
# - Uses git status --porcelain=v2 for reliable change detection
# - Verifies ONLY CLAUDE_RESUME.md has uncommitted changes
# - Commits with standardized message and flags (-S -s)
# - Blocks if unexpected files changed (safety check)
#
# Exit codes:
# 0 - Success (committed or skipped appropriately)
# 1 - Error (unexpected changes or git failure)

set -e

# Parse arguments
PROJECT_ROOT="${1:-.}"

# Change to project root directory
cd "$PROJECT_ROOT" || {
    echo "❌ Error: Cannot access project root: $PROJECT_ROOT" >&2
    exit 1
}

# Verify we're in a project root (should have CLAUDE.md)
if [ ! -f "CLAUDE.md" ]; then
    echo "⚠️  Warning: No CLAUDE.md found - may not be project root" >&2
    echo "   Working directory: $(pwd)" >&2
fi

# Check if in git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "✓ Not a git repository (skipping commit)"
    exit 0
fi

# Check for changes using porcelain v2 (machine-parseable format)
CHANGES=$(git status --porcelain=v2 2>/dev/null)

if [ -z "$CHANGES" ]; then
    echo "✓ No uncommitted changes (resume may already be committed)"
    exit 0
fi

# Check for CLAUDE_RESUME.md changes
# Porcelain v2 formats:
# - Type 1 (ordinary changed): "1 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <path>"
#   Where XY can be: .M (unstaged), M. (staged), MM (both)
# - Type ? (untracked): "? <path>"
RESUME_CHANGES=$(echo "$CHANGES" | grep "CLAUDE_RESUME.md$" || true)

# Get all other changes (not CLAUDE_RESUME.md)
UNEXPECTED=$(echo "$CHANGES" | grep -v "CLAUDE_RESUME.md$" || true)

if [ -n "$UNEXPECTED" ]; then
    echo "❌ ERROR: Unexpected changes detected during closure" >&2
    echo "" >&2
    echo "Step 0.5 should have committed all pre-existing changes." >&2
    echo "These changes appeared DURING closure execution:" >&2
    echo "" >&2
    echo "$UNEXPECTED" >&2
    echo "" >&2
    echo "Full status:" >&2
    git status --short >&2
    exit 1
fi

# If RESUME_CHANGES is empty, no changes to commit
if [ -z "$RESUME_CHANGES" ]; then
    echo "✓ No changes to CLAUDE_RESUME.md"
    exit 0
fi

# Only CLAUDE_RESUME.md changed - safe to commit
git add CLAUDE_RESUME.md

# Commit with standardized message
# Note: This is a minimal template. Claude should enhance this message based on:
# - Workspace commit protocols (if CORE_PROCESSES.md exists)
# - Resume content (summarize what was accomplished)
# - Session significance (bug fixes, milestones, etc.)
git commit -S -s -m "Session closure: $(date +%Y-%m-%d-%H%M)

Resume created with session state."

echo "✅ Session resume committed"
exit 0
