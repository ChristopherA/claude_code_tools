#!/bin/bash
# list_archives.sh - List archived resumes sorted by date
# Part of session-resume skill v1.3.0
#
# Usage: ./list_archives.sh [--limit N] [--format short|detailed]
#
# Lists archived CLAUDE_RESUME.md files from archives/CLAUDE_RESUME/
# Sorted newest first
#
# Exit codes:
# 0 - Success (archives found or not found)

set -e

# Configuration
ARCHIVE_DIR="archives/CLAUDE_RESUME"
LIMIT=10
FORMAT="short"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if archive directory exists
if [ ! -d "$ARCHIVE_DIR" ]; then
    echo "No archives found"
    exit 0
fi

# Count archives
ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$ARCHIVE_COUNT" -eq 0 ]; then
    echo "No archives found"
    exit 0
fi

# List archives
if [ "$FORMAT" = "detailed" ]; then
    echo "Found $ARCHIVE_COUNT archived session(s):"
    echo ""
    ls -lt "$ARCHIVE_DIR"/*.md 2>/dev/null | head -n "$LIMIT" | while read -r line; do
        # Extract filename from ls output
        filename=$(echo "$line" | awk '{print $NF}')
        basename=$(basename "$filename" .md)
        size=$(echo "$line" | awk '{print $5}')

        # Parse timestamp (YYYY-MM-DD-HHMM format)
        year=$(echo "$basename" | cut -d'-' -f1)
        month=$(echo "$basename" | cut -d'-' -f2)
        day=$(echo "$basename" | cut -d'-' -f3)
        time=$(echo "$basename" | cut -d'-' -f4)
        hour="${time:0:2}"
        minute="${time:2:2}"

        echo "- $year-$month-$day $hour:$minute ($size bytes)"
    done
else
    # Short format: just timestamps
    ls -t "$ARCHIVE_DIR"/*.md 2>/dev/null | head -n "$LIMIT" | while read -r file; do
        basename "$file" .md
    done
fi

exit 0
