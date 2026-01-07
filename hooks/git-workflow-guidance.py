#!/usr/bin/env python3
"""
Git Workflow Guidance Hook

Enforces git workflow best practices:
- Separate git add from git commit (don't combine in one command)
- Run git status/diff before staging

This provides guidance, not hard blocking.
"""
from __future__ import annotations  # Python 3.9 compatibility (PEP 563)

import json
import re
import sys
from typing import Optional


def is_git_command(command: str) -> bool:
    """Check if this is a git command we should validate.

    Returns True for:
    - Direct git commands: git status, git add, etc.
    - Shell-wrapped: bash -c "git ...", /bin/zsh -c 'git ...'
    - With sudo: sudo git push

    Returns False for:
    - Commands that merely mention git in text: gh issue create --body "git workflow"
    - Non-git commands
    """
    # Direct git command (optionally with sudo)
    if re.match(r'^\s*(?:sudo\s+)?git\s+', command):
        return True
    # Shell-wrapped git command (bash/sh/zsh -c "git ..." or 'git ...')
    if re.match(r'^\s*(?:sudo\s+)?(?:/[\w/]*)?(?:ba|z)?sh\s+-c\s+["\'](?:sudo\s+)?git\s+', command):
        return True
    return False


def check_combined_add_commit(command: str) -> Optional[str]:
    """Check if command combines git add and git commit."""
    # Only check git commands
    if not is_git_command(command):
        return None

    # Check for combined add+commit patterns
    if re.search(r'git\s+add\s+.*&&.*git\s+commit', command) or \
       re.search(r'git\s+add\s+.*;.*git\s+commit', command):
        return (
            "⚠️  Workflow guidance: Separate git add from git commit\n\n"
            "Recommended workflow:\n"
            "1. git status          # See what changed\n"
            "2. git diff            # Review changes\n"
            "3. git add <files>     # Stage specific files\n"
            "4. git diff --staged   # Verify staged changes\n"
            "5. git commit -S -s -m \"message\"  # Commit\n\n"
            "This allows reviewing changes before committing.\n"
            "Run git add first, then git commit separately."
        )
    return None


def main():
    # Read hook input from stdin
    try:
        hook_input = json.load(sys.stdin)
    except json.JSONDecodeError:
        # If we can't parse input, allow the command
        print(json.dumps({"proceed": True}))
        return

    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})

    # Only check Bash tool
    if tool_name != "Bash":
        print(json.dumps({"proceed": True}))
        return

    command = tool_input.get("command", "")

    # Skip if not a git command
    if not is_git_command(command):
        print(json.dumps({"proceed": True}))
        return

    # Check for combined add+commit
    guidance = check_combined_add_commit(command)
    if guidance:
        print(json.dumps({
            "proceed": False,
            "reason": guidance
        }))
        return

    # All checks passed
    print(json.dumps({"proceed": True}))


if __name__ == "__main__":
    main()
