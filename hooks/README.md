# Session-Start Hooks

Claude Code hooks for session initialization. These run automatically at session start.

## Hooks Included

### session-start.sh
Persists `PROJECT_ROOT` environment variable throughout the session, ensuring consistent path handling even when Claude changes directories.

### session-start-git-context.sh
Provides git repository awareness at session start:
- Current branch name
- Uncommitted changes count
- Recent commits (last 5)
- Stash count
- Remote tracking status (ahead/behind)
- Foundation hook detection (warns if git enforcement hooks missing)

## Installation

```bash
# Copy hooks to user-level hooks directory
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/session-start*.sh
```

**Note**: Hooks deploy to `~/.claude/hooks/` (different from skills which go to `~/.claude/skills/`).

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

These hooks are owned by the session-skills project. For git enforcement hooks (git-commit-compliance.py, git-workflow-guidance.py), see the claude-code-foundation project.

---

*Session-start hooks v1.0 - December 2025*
