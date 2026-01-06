#!/bin/bash
# status-line.sh - Claude Code context monitor
# Version: 0.1.0
#
# Displays: [Model] XX% [$0.00]
#
# Thresholds (remaining context):
#   >40%  - Green (normal)
#   21-40% - Yellow (caution)
#   <=20% - Red + warning (critical)
#
# Environment variables:
#   CLAUDE_CONTEXT_OVERHEAD - Token overhead for system prompt/tools (default: 42000)
#   CLAUDE_SHOW_COST        - Set to any value to show session cost (hidden by default)

set -euo pipefail

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Configurable overhead to match Claude's "until auto-compact" calculation
# Default 42000 accounts for system prompt, tools, and reserved buffer
SYSTEM_OVERHEAD="${CLAUDE_CONTEXT_OVERHEAD:-42000}"

# Read JSON from stdin
input=$(cat)

# Check if jq is available
if ! command -v jq &>/dev/null; then
    echo "jq required"
    exit 0
fi

# Extract data from JSON
session_id=$(echo "$input" | jq -r '.session_id // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_creation=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Handle null values from jq
[[ "$context_window_size" == "null" ]] && context_window_size=200000
[[ "$input_tokens" == "null" ]] && input_tokens=0
[[ "$cache_read" == "null" ]] && cache_read=0
[[ "$cache_creation" == "null" ]] && cache_creation=0
[[ "$total_cost" == "null" ]] && total_cost=0
[[ "$model_name" == "null" ]] && model_name=""

# Format model prefix
model_prefix=""
if [[ -n "$model_name" ]]; then
    model_prefix="[${model_name}] "
fi

# Format cost suffix (only show if CLAUDE_SHOW_COST is set and cost > 0)
cost_suffix=""
if [[ -n "${CLAUDE_SHOW_COST:-}" && "$total_cost" != "0" ]]; then
    # Format cost to 2 decimal places
    cost_formatted=$(printf "%.2f" "$total_cost")
    cost_suffix=" \$${cost_formatted}"
fi

# Skip if no real token data (avoids flicker on incomplete status updates)
if [[ "$input_tokens" -eq 0 && "$cache_read" -eq 0 && "$cache_creation" -eq 0 ]]; then
    # Read last known value from file if available
    if [[ -n "$session_id" && -f "/tmp/claude-${session_id}-context-remaining" ]]; then
        last_pct=$(cat "/tmp/claude-${session_id}-context-remaining" 2>/dev/null)
        if [[ -n "$last_pct" && "$last_pct" =~ ^[0-9]+$ ]]; then
            # Apply color based on cached value
            if [[ $last_pct -le 20 ]]; then
                echo -e "${model_prefix}${RED}${last_pct}%${RESET} ⚠️${cost_suffix}"
            elif [[ $last_pct -le 40 ]]; then
                echo -e "${model_prefix}${YELLOW}${last_pct}%${RESET}${cost_suffix}"
            else
                echo -e "${model_prefix}${GREEN}${last_pct}%${RESET}${cost_suffix}"
            fi
        fi
    fi
    exit 0
fi

# Calculate total tokens used
total_tokens=$((input_tokens + cache_read + cache_creation + SYSTEM_OVERHEAD))

# Calculate remaining percentage (integer math)
if [[ "$context_window_size" -gt 0 ]]; then
    used_pct=$((total_tokens * 100 / context_window_size))
    remaining_pct=$((100 - used_pct))
    # Clamp to 0-100
    [[ $remaining_pct -lt 0 ]] && remaining_pct=0
    [[ $remaining_pct -gt 100 ]] && remaining_pct=100
else
    remaining_pct=100
fi

# Write to session-specific temp file for skills to read
if [[ -n "$session_id" ]]; then
    echo "$remaining_pct" > "/tmp/claude-${session_id}-context-remaining"
fi

# Apply color based on remaining thresholds
if [[ $remaining_pct -le 20 ]]; then
    # Critical - red with warning icon (emoji after %, before cost)
    echo -e "${model_prefix}${RED}${remaining_pct}%${RESET} ⚠️${cost_suffix}"
elif [[ $remaining_pct -le 40 ]]; then
    # Caution - yellow
    echo -e "${model_prefix}${YELLOW}${remaining_pct}%${RESET}${cost_suffix}"
else
    # Normal - green
    echo -e "${model_prefix}${GREEN}${remaining_pct}%${RESET}${cost_suffix}"
fi
