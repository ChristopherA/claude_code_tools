#!/bin/bash
# validate_resume.sh - Validate CLAUDE_RESUME.md structure
# Part of session-closure skill v1.3.0
#
# Usage: ./validate_resume.sh [RESUME_FILE]
#
# Validates that a resume file contains required sections:
# - Header with "Last Session:"
# - "Last Activity" section
# - "Pending Tasks" section
# - "Next Session Focus" section
# - Footer with "Resume created by session-closure"
#
# Exit codes:
# 0 - Validation passed
# 1 - Validation failed (missing required sections)
# 2 - File not found

set -e

# Default to CLAUDE_RESUME.md if no argument provided
RESUME="${1:-CLAUDE_RESUME.md}"

# Check if file exists
if [ ! -f "$RESUME" ]; then
    echo "❌ Resume not found: $RESUME"
    exit 2
fi

# Required sections (pattern matching - handles markdown bold with **)
REQUIRED_SECTIONS=(
    "Last Session"
    "Last Activity"
    "Pending"
    "Project Status"
    "Next Session Focus"
    "Resume created by session-closure"
)

# Optional sections (recognized but not required)
# - Key Decisions Made
# - Insights & Learnings
# - Sync Status (only for projects with authoritative sources)

# Validate
MISSING=0
MISSING_LIST=()

for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -q "$section" "$RESUME"; then
        MISSING_LIST+=("$section")
        MISSING=1
    fi
done

# Report results
if [ $MISSING -eq 0 ]; then
    echo "✅ Resume validation passed: $RESUME"
    exit 0
else
    echo "❌ Resume validation failed: $RESUME"
    echo ""
    echo "Missing sections:"
    for section in "${MISSING_LIST[@]}"; do
        echo "  - $section"
    done
    exit 1
fi
