# Team Coordination Example

This example demonstrates how to use session-skills for team coordination by tracking CLAUDE_RESUME.md in git.

---

## Scenario

Team of 3 developers working on shared project. They use CLAUDE_RESUME.md tracked in git to communicate project status and handoffs.

---

## Setup

**Add to `.gitignore`** (don't ignore resume):
```gitignore
# Track resume for team coordination
# CLAUDE_RESUME.md  # <- commented out or removed

# But still ignore archives (personal)
archives/
```

**Result**: CLAUDE_RESUME.md is tracked and shared, archives/ stay local.

---

## Developer A: Monday Afternoon

### Working Session

```
Developer A working on API endpoints...

User: I've completed the /users endpoint. Ready to hand off to the team.

Claude: Great work! You've implemented:
- GET /users (list with pagination)
- GET /users/:id (single user)
- POST /users (create)
- PUT /users/:id (update)
- Tests passing (12 tests)

User: Let's close this session and commit so the team can continue.
```

### Session Closure with Git

```
User: close context

Claude: [Creates CLAUDE_RESUME.md]

✅ Session closure complete.

User: (Commits to git for team)
```

**Git operations**:
```bash
git add CLAUDE_RESUME.md
git commit -S -s -m "Session: Completed /users endpoint implementation

- All CRUD operations implemented
- 12 tests passing
- Ready for /products endpoint next

See CLAUDE_RESUME.md for details."
git push
```

---

## Developer B: Tuesday Morning

### Pull Latest Changes

```bash
git pull
# Updated CLAUDE_RESUME.md with Developer A's work
```

### Resume Team Context

```
User: resume

Claude: Loading session from November 4, 2025...

✓ Resume is fresh (< 1 day old)

## Last Session Summary

[Developer A's work from Monday]

Completed /users endpoint with full CRUD operations. All tests passing (12 tests).
Ready to implement /products endpoint following same pattern.

## Project Status

- **Current State**: 🔄 IN PROGRESS - User endpoints complete
- **Key Changes**: Implemented /users CRUD operations
- **Next Priority**: Implement /products endpoint
- **Dependencies**: None
- **Project Health**: Good - on track for Friday deployment

## Pending Tasks

- [ ] Implement /products endpoint (CRUD operations)
- [ ] Add authentication middleware to all endpoints
- [ ] Write API documentation
- [ ] Integration testing

## Next Session Focus

Start with /products endpoint. Follow same pattern as /users:
1. GET /products (list + pagination)
2. GET /products/:id (single)
3. POST /products (create)
4. PUT /products/:id (update)
5. DELETE /products/:id (delete)

Ready to continue the team's work!

User: Perfect! I'll take the /products endpoint.
```

### Developer B Works

```
Developer B implements /products endpoint...

[Several hours later]

User: close context

Claude: [Updates CLAUDE_RESUME.md with Developer B's work]
```

**Git operations**:
```bash
git add CLAUDE_RESUME.md src/routes/products.js
git commit -S -s -m "Session: Completed /products endpoint

- All CRUD operations implemented
- 10 tests passing
- Pattern consistent with /users

Next: Authentication middleware"
git push
```

---

## Developer C: Tuesday Afternoon

### Pull and Check Status

```bash
git pull
# See Developer B's updates
```

### Quick Status Check

```
User: resume

Claude: Loading session from November 5, 2025 (earlier today)...

✓ Resume is fresh (< 1 day old)

## Last Session Summary

[Developer B's work from Tuesday morning]

Completed /products endpoint. Pattern consistent with /users endpoint.
20 tests passing total (12 + 10). Ready for authentication middleware.

## Project Status

- **Current State**: 🔄 IN PROGRESS - Core endpoints complete
- **Key Changes**: Added /products CRUD operations
- **Next Priority**: Authentication middleware for all endpoints
- **Dependencies**: None
- **Project Health**: Excellent - ahead of schedule

User: Great! I'll add the authentication middleware.
```

---

## Benefits Demonstrated

### Team Awareness
- Everyone sees current project state
- Clear handoffs between developers
- No duplicate work

### Project Status Tracking
- Current state visible
- Dependencies tracked
- Health assessment shared

### Communication
- Resume serves as team log
- Git history shows progression
- Clear next steps for anyone

---

## Git History

```bash
git log --oneline --all

3f7a2b1 Session: Completed authentication middleware (Developer C)
2e6c9a4 Session: Completed /products endpoint (Developer B)
1d5b8c3 Session: Completed /users endpoint (Developer A)
```

---

## Resume Evolution

**Monday** (Developer A):
```markdown
## Last Session Summary
Completed /users endpoint...

## Pending Tasks
- [ ] Implement /products endpoint
- [ ] Add authentication middleware
```

**Tuesday Morning** (Developer B):
```markdown
## Last Session Summary
Completed /products endpoint...

## Pending Tasks
- [ ] Add authentication middleware  # <- Moved up
- [ ] Write API documentation
```

**Tuesday Afternoon** (Developer C):
```markdown
## Last Session Summary
Completed authentication middleware...

## Pending Tasks
- [ ] Write API documentation  # <- Only task left
- [ ] Integration testing
```

**Progression visible** through git commits.

---

## Best Practices

### DO

✅ **Commit after meaningful work**:
```bash
git commit -m "Session: Completed X feature"
```

✅ **Update Project Status**:
```markdown
## Project Status
- **Current State**: 🔄 IN PROGRESS - Feature X complete
- **Key Changes**: Implemented X
- **Next Priority**: Implement Y
```

✅ **Clear Pending Tasks**:
- Remove completed tasks
- Add new discovered tasks
- Prioritize remaining work

✅ **Handoff Notes**:
```markdown
## Next Session Focus

For next developer: Start with Y. Reference X implementation
in src/routes/x.js as pattern to follow.
```

### DON'T

❌ **Don't commit WIP resume**:
```bash
# Bad: Partial work, unclear state
git commit -m "Working on X..."  # <- Too vague
```

❌ **Don't leave stale tasks**:
```markdown
# Bad: Completed tasks still listed
- [x] Implement X  # <- Remove completed from Pending
- [ ] Implement Y
```

❌ **Don't forget Project Status**:
```markdown
# Bad: No status update
## Last Session Summary
Completed X

## Pending Tasks
...

# Missing: Project Status section!
```

---

## Conflict Resolution

**If two developers work simultaneously**:

**Developer A** pushes:
```markdown
## Pending Tasks
- [ ] Task X
- [ ] Task Y
```

**Developer B** has locally:
```markdown
## Pending Tasks
- [ ] Task Y
- [ ] Task Z
```

**On `git pull`**: Conflict in CLAUDE_RESUME.md

**Resolution**:
1. Both developers communicate
2. Merge pending tasks:
   ```markdown
   ## Pending Tasks
   - [ ] Task X  # Developer A
   - [ ] Task Y  # Both
   - [ ] Task Z  # Developer B
   ```
3. Update Project Status with both changes
4. Commit merged version

---

## Team Size Considerations

### 2-3 Developers
✅ **Recommended**: Shared CLAUDE_RESUME.md works well

### 4-6 Developers
⚠️ **Possible**: May need more coordination

### 7+ Developers
❌ **Not Recommended**: Too many conflicts, use project management tools instead

---

*Team coordination example for session-skills v1.3.0*
