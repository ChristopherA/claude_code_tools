# Daily Workflow Example

This example demonstrates a typical daily development workflow using session-closure and session-resume.

---

## Scenario

You're working on a web application, implementing a new authentication feature. You work during the day, close your session at night, and resume the next morning.

---

## Day 1: End of Day

### Working Session

```
[Working on authentication feature]

User: I've completed the JWT token validation. Tests are passing.

Claude: Great! You've implemented:
- JWT token generation
- Token validation middleware
- Refresh token logic
- Unit tests (15 tests passing)

What's next?

User: I need to add rate limiting to the login endpoint tomorrow. Let's close for today.
```

### Session Closure

```
User: close context

Claude: Analyzing session and creating resume...

**Mode**: Full (sufficient context available)

**Step 1**: Archiving previous resume
✓ Archived to archives/CLAUDE_RESUME/2025-11-04-1430.md

**Step 2**: Creating CLAUDE_RESUME.md
✓ Resume created with:
  - Last Activity: JWT authentication implementation
  - Pending Tasks: Rate limiting, API docs, security review
  - Next Session Focus: Implement rate limiting

**Step 3**: Validating resume
✓ Resume validation passed

✅ Session closure complete.

Next session: Say "resume" to load this context.
```

**File created**: `CLAUDE_RESUME.md`

---

## Day 2: Morning Resume

### Session Start

```
[New Claude Code session starts]

📅 Today is Wednesday, November 05, 2025

📋 Previous session available. Say "resume" to continue.
```

### Load Context

```
User: resume

Claude: Loading session from November 4, 2025...

✓ Resume is fresh (< 1 day old)

## Last Session Summary

Completed authentication module with JWT token validation and refresh token logic.
All tests passing (15 tests). Ready to add rate limiting to login endpoint.

## Pending Tasks

- [ ] Add rate limiting to login endpoint (5 requests/minute)
- [ ] Write API documentation for /auth endpoints
- [ ] Security review with team on Friday

## Next Session Focus

Implement rate limiting using express-rate-limit package. Configure 5 requests
per minute for login endpoint with exponential backoff. Test with automated script.

Ready to continue where we left off!

User: Perfect! Let's start with the rate limiting.
```

---

## Benefits Demonstrated

1. **No Context Loss**: JWT work context fully preserved
2. **Clear Next Steps**: Rate limiting task immediately clear
3. **Pending Tasks Visible**: Team review reminder present
4. **Staleness Check**: Confirmed resume is fresh (< 1 day)
5. **Quick Resume**: < 5 seconds to restore context

---

## Files Involved

```
project/
├── CLAUDE_RESUME.md              # Current session (Nov 5)
└── archives/
    └── CLAUDE_RESUME/
        ├── 2025-11-04-1430.md    # Previous session (Nov 4)
        ├── 2025-11-03-1615.md    # Earlier session (Nov 3)
        └── 2025-11-02-0945.md    # Earlier session (Nov 2)
```

---

## Timeline

| Time | Event | Action |
|------|-------|--------|
| Nov 4, 2:30 PM | End of work | `close context` |
| Nov 4, 2:30 PM | Resume created | CLAUDE_RESUME.md written |
| Nov 4, 2:30 PM | Archive created | 2025-11-04-1430.md |
| Nov 5, 9:00 AM | Start work | New session |
| Nov 5, 9:01 AM | Load context | `resume` |
| Nov 5, 9:01 AM | Ready to work | Full context restored |

**Context loss**: 0 minutes 🎉

---

*Example workflow for session-skills v1.3.0*
