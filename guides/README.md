# Session Skills Guides

Practical workflows for session-closure and session-resume skills.

## Quick Start

**End of session**:
```
User: close session
```
Creates `CLAUDE_RESUME.md` with session context.

**Start of session**:
```
User: resume
```
Loads previous session context.

## Available Guides

| Guide | Audience | Use Case |
|-------|----------|----------|
| [Solo Workflow](./solo-workflow.md) | Individual developers | Daily work across multiple sessions |
| [Team Workflow](./team-workflow.md) | Small teams (2-6) | Git-tracked handoffs and coordination |

## Common Patterns

### Pattern 1: End of Day

```
User: close session

Claude:
- Archived previous resume
- Created CLAUDE_RESUME.md
- Validated structure

Next session: Say "resume"
```

### Pattern 2: Morning Resume

```
User: resume

Claude:
- Resume is fresh (< 1 day old)
- [Session summary]
- [Pending tasks]

Ready to continue!
```

### Pattern 3: Archive Recovery

```
User: resume

Claude:
No current resume. Found archives:
- 2025-12-03-1430.md
- 2025-12-02-1615.md

Which would you like to load?
```

## Workflow Selection

| Situation | Recommended |
|-----------|-------------|
| Working alone | [Solo Workflow](./solo-workflow.md) |
| Small team (2-6) | [Team Workflow](./team-workflow.md) |
| Large team (7+) | Use project management tools |
| Multiple branches | Solo workflow per branch |

## Git Integration

Session-skills integrate with git:

- **Uncommitted changes**: Blocked until committed (ensures clean checkpoints)
- **Git-tracked resume**: Archives skipped (git history serves as backup)
- **Commit standards**: Enforced by `~/.claude/hooks/git-commit-compliance.py`

Required commit format:
```bash
git commit -S -s -m "Descriptive message"
```

## Tips

1. **Check staleness**: Resume age indicates relevance (fresh < 1 day, stale > 7 days)
2. **Use Project Status**: Track dependencies and blockers in resume
3. **Branch-specific**: Different branches can have different CLAUDE_RESUME.md files

---

*Guides for session-skills v1.4.0 (December 2025)*
