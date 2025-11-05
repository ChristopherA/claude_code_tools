#!/bin/bash
# archive_resume.sh - Archive CLAUDE_RESUME.md with timestamp
# Part of session-closure skill v1.3.0
#
# Usage: ./archive_resume.sh [--dry-run]
#
# Behavior:
# - If CLAUDE_RESUME.md is tracked in git: Skip archiving (git history is archive)
# - If CLAUDE_RESUME.md doesn't exist: Skip archiving (nothing to archive)
# - Otherwise: Move to archives/CLAUDE_RESUME/<timestamp>.md
#
# Exit codes:
# 0 - Success (archived or skipped appropriately)
# 1 - Error

set -e

# Configuration
ARCHIVE_DIR="archives/CLAUDE_RESUME"
SOURCE="CLAUDE_RESUME.md"
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
DRY_RUN=false

# Parse arguments
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
fi

# Function: Check if in git repo
in_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

# Function: Check if file is tracked in git
is_git_tracked() {
    local file="$1"
    git ls-files --error-unmatch "$file" >/dev/null 2>&1
}

# Main logic

# Check if source exists
if [ ! -f "$SOURCE" ]; then
    echo "✓ No previous resume to archive"
    exit 0
fi

# Check if in git repo and file is tracked
if in_git_repo && is_git_tracked "$SOURCE"; then
    echo "✓ Resume tracked in git - skipping archive (git history is archive)"
    exit 0
fi

# Archive the file
if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would archive: $SOURCE → $ARCHIVE_DIR/$TIMESTAMP.md"
    exit 0
fi

# Create archive directory
mkdir -p "$ARCHIVE_DIR"

# Move file to archive
mv "$SOURCE" "$ARCHIVE_DIR/$TIMESTAMP.md"
echo "📦 Archived to $ARCHIVE_DIR/$TIMESTAMP.md"

exit 0
