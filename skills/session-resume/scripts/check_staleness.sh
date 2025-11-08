#!/bin/bash
# check_staleness.sh - Check resume age and return staleness level
# Part of session-resume skill v1.3.1
#
# Usage: ./check_staleness.sh [PROJECT_ROOT]
#
# Arguments:
#   PROJECT_ROOT - Path to project root directory (defaults to current directory)
#                  Resume file should be at PROJECT_ROOT/CLAUDE_RESUME.md
#
# Extracts session date from resume and calculates age in days.
# Returns staleness category: fresh|recent|stale|very_stale
#
# v1.3.1 updates:
# - Accept PROJECT_ROOT parameter for working directory independence
# - Change to project root before operating
# - Verify project root (check for CLAUDE.md)
#
# v1.3.0 updates:
# - Added cross-platform date command support (macOS BSD + Linux GNU)
#
# Staleness levels:
# - fresh: <1 day
# - recent: 1-6 days
# - stale: 7-29 days
# - very_stale: 30+ days
#
# Exit codes:
# 0 - Success (staleness determined)
# 1 - Error (file not found or date parsing failed)

set -e

# Parse arguments
PROJECT_ROOT="${1:-.}"

# Change to project root directory
cd "$PROJECT_ROOT" || {
    echo "error" >&2
    exit 1
}

# Verify we're in a project root (should have CLAUDE.md)
if [ ! -f "CLAUDE.md" ]; then
    echo "error" >&2
    exit 1
fi

# Resume file is always CLAUDE_RESUME.md in project root
RESUME="CLAUDE_RESUME.md"

# Check if file exists
if [ ! -f "$RESUME" ]; then
    echo "error"
    exit 1
fi

# Extract session date from resume
# Looks for "**Last Session**: October 27, 2025" or "Last Session: October 27, 2025"
SESSION_DATE_LINE=$(grep -i "Last Session" "$RESUME" | head -1 || echo "")

if [ -z "$SESSION_DATE_LINE" ]; then
    echo "error"
    exit 1
fi

# Extract date portion (handles both **Last Session**: and Last Session:)
SESSION_DATE=$(echo "$SESSION_DATE_LINE" | sed 's/.*Last Session[*:]*: *//' | sed 's/ (.*//' | cut -d' ' -f1-3)

if [ -z "$SESSION_DATE" ]; then
    echo "error"
    exit 1
fi

# Calculate age in days (cross-platform date command)
TODAY=$(date +%s)

# Detect OS and use appropriate date command
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD date)
    SESSION_EPOCH=$(date -j -f "%B %d, %Y" "$SESSION_DATE" +%s 2>/dev/null || echo "0")

    if [ "$SESSION_EPOCH" -eq 0 ]; then
        # Try alternate format: Month DD YYYY (without comma)
        SESSION_EPOCH=$(date -j -f "%B %d %Y" "$SESSION_DATE" +%s 2>/dev/null || echo "0")
    fi
else
    # Linux/GNU date
    SESSION_EPOCH=$(date -d "$SESSION_DATE" +%s 2>/dev/null || echo "0")
fi

if [ "$SESSION_EPOCH" -eq 0 ]; then
    echo "error"
    exit 1
fi

AGE_DAYS=$(( (TODAY - SESSION_EPOCH) / 86400 ))

# Determine staleness level
if [ "$AGE_DAYS" -lt 1 ]; then
    echo "fresh"
elif [ "$AGE_DAYS" -lt 7 ]; then
    echo "recent"
elif [ "$AGE_DAYS" -lt 30 ]; then
    echo "stale"
else
    echo "very_stale"
fi

exit 0
