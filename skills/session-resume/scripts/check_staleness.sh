#!/bin/bash
# check_staleness.sh - Check resume age and return staleness level
# Part of session-resume skill v1.2.1
#
# Usage: ./check_staleness.sh [RESUME_FILE]
#
# Extracts session date from resume and calculates age in days.
# Returns staleness category: fresh|recent|stale|very_stale
#
# v1.2.1 fix: Added directory traversal to find CLAUDE_RESUME.md when
# script is called from skills subdirectory (common in skill invocation)
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

# Default to CLAUDE_RESUME.md if no argument provided
RESUME="${1:-CLAUDE_RESUME.md}"

# If RESUME is a relative path and doesn't exist, try looking in project root
# (Script may be called from skills directory)
if [ ! -f "$RESUME" ]; then
    # Try to find project root by looking for CLAUDE_RESUME.md up the directory tree
    CURRENT_DIR="$PWD"
    while [ "$CURRENT_DIR" != "/" ]; do
        if [ -f "$CURRENT_DIR/$RESUME" ]; then
            RESUME="$CURRENT_DIR/$RESUME"
            break
        fi
        CURRENT_DIR=$(dirname "$CURRENT_DIR")
    done
fi

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

# Calculate age in days (macOS compatible date command)
TODAY=$(date +%s)
SESSION_EPOCH=$(date -j -f "%B %d, %Y" "$SESSION_DATE" +%s 2>/dev/null || echo "0")

if [ "$SESSION_EPOCH" -eq 0 ]; then
    # Try alternate format: Month DD YYYY (without comma)
    SESSION_EPOCH=$(date -j -f "%B %d %Y" "$SESSION_DATE" +%s 2>/dev/null || echo "0")
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
