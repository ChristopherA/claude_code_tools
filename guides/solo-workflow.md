# Solo Workflow Guide

Daily development workflow for individual developers using session-skills.

## Scenario

You're implementing a feature across multiple days. End sessions cleanly, resume with full context.

## Day 1: End of Day

### Working Session

```
[Working on authentication feature]

User: Completed JWT validation. Tests passing. Let's close for today.
```

### Session Closure

```
User: close session

Claude:
- Archived previous resume
- Created CLAUDE_RESUME.md
- Validated structure

Resume contains:
- Last Activity: JWT authentication implementation
- Pending Tasks: Rate limiting, API docs
- Next Focus: Implement rate limiting

Next session: Say "resume"
```

## Day 2: Morning Resume

### Session Start

```
[New Claude Code session]

Today is Thursday, December 05, 2025
Previous session available. Say "resume" to continue.
```

### Load Context

```
User: resume

Claude:
Resume is fresh (< 1 day old)

Last Session: Completed JWT authentication with token validation.
All tests passing. Ready for rate limiting.

Pending Tasks:
- [ ] Add rate limiting (5 requests/minute)
- [ ] Write API documentation

Next Focus: Implement rate limiting using express-rate-limit.

Ready to continue!

User: Let's start with rate limiting.
```

## Benefits

| Benefit | Description |
|---------|-------------|
| **No context loss** | Previous work fully preserved |
| **Clear next steps** | Immediate focus on resume |
| **Task tracking** | Pending items visible |
| **Quick resume** | < 5 seconds to restore |

## File Structure

```
project/
├── CLAUDE_RESUME.md              # Current session
└── archives/
    └── CLAUDE_RESUME/
        └── 2025-12-04-1430.md    # Previous sessions
```

## Commit Your Work

Before closing, commit any code changes:

```bash
git add <files>
git commit -S -s -m "Implement JWT token validation"
```

Session-closure will detect uncommitted changes and prompt you to commit first.

---

*Solo workflow for session-skills v1.4.0*
