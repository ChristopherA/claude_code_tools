# Claude Code Hooks

Claude Code hooks for session initialization and git workflow enforcement.

## Hooks Included

### Git Enforcement Hooks (Python)

#### git-commit-compliance.py
Enforces commit standards for Claude-assisted development:
- **Required flags**: -S (GPG signing), -s (signoff)
- **Blocks**: Claude attribution in commit messages
- **Validates**: Meaningful commit messages (≥10 chars)
- **Python 3.9+ compatible** (uses `from __future__ import annotations`)

#### git-workflow-guidance.py
Enforces git workflow best practices:
- **Blocks**: Combined `git add && git commit` commands
- **Guides**: Separate staging from committing for review
- **Skips**: Non-git commands (avoids false positives on `gh` CLI)

### Session-Start Hooks (Bash)

#### session-start.sh
Persists `PROJECT_ROOT` environment variable throughout the session, ensuring consistent path handling even when Claude changes directories.

#### session-start-git-context.sh
Provides git repository awareness at session start:
- Current branch name
- Uncommitted changes count
- Recent commits (last 5)
- Stash count
- Remote tracking status (ahead/behind)
- Foundation hook detection (warns if git enforcement hooks missing)

## Installation

### Option 1: Plugin Installation (Git Enforcement Hooks)

```bash
# Add marketplace (if not already added)
/plugin marketplace add ChristopherA/claude_code_tools

# Install git enforcement hooks
/plugin install git-enforcement-hooks@claude-code-tools
```

### Option 2: Manual Installation (All Hooks)

```bash
# Copy all hooks to user-level hooks directory
cp hooks/*.sh hooks/*.py ~/.claude/hooks/
chmod +x ~/.claude/hooks/session-start*.sh ~/.claude/hooks/git-*.py
```

**Note**: Session-start hooks (`.sh` files) require manual installation. Git enforcement hooks can be installed via plugin or manually.

**Hooks location**: `~/.claude/hooks/` (different from skills which go to `~/.claude/skills/`)

**Requirements**:
- Python 3.9+ for git enforcement hooks
- Bash for session-start hooks

## Testing

Run the test suite:

```bash
./hooks/tests/test_hooks.sh
```

Tests cover:
- Python syntax validation (Python 3.9+ compatibility)
- `is_git_command()` detection (true positives and false positives)
- Hook behavior (blocking, allowing, skipping non-git commands)

Expected: 13 tests, all passing

## Hook vs Skill Distinction

| Type | Location | Purpose |
|------|----------|---------|
| **Hooks** | `~/.claude/hooks/` | Automatic execution at events (SessionStart, PreToolUse, etc.) |
| **Skills** | `~/.claude/skills/` | User-invoked capabilities with SKILL.md protocols |

These session-start hooks complement the session-closure/session-resume skills by providing:
- Early warning about uncommitted changes (before user says "resume")
- Consistent PROJECT_ROOT for all bash commands
- Git context without requiring skill invocation

## Ownership

All hooks in this directory are owned by the claude-code-tools project.

---

*Hooks v1.2 - January 2026*
