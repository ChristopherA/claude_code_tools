# Team Workflow Guide

Using session-skills for team coordination with git-tracked CLAUDE_RESUME.md.

## Scenario

Team of 3 developers sharing project context through git-tracked resume.

## Setup

Track CLAUDE_RESUME.md in git (don't gitignore it):

```gitignore
# .gitignore
# Track resume for team coordination
archives/    # Keep archives local
```

## Developer A: Monday

### Complete Work

```
Developer A: Completed /users endpoint. All tests passing.

User: close session
```

### Commit and Push

```bash
git add CLAUDE_RESUME.md src/routes/users.js
git commit -S -s -m "Implement /users endpoint

- CRUD operations complete
- 12 tests passing
- Ready for /products endpoint"
git push
```

## Developer B: Tuesday

### Pull and Resume

```bash
git pull
```

```
User: resume

Claude:
Resume is fresh (< 1 day old)

Last Session: Completed /users endpoint with CRUD operations.
12 tests passing.

Pending Tasks:
- [ ] Implement /products endpoint
- [ ] Add authentication middleware
- [ ] Write API documentation

Next Focus: /products endpoint following /users pattern.

User: I'll take /products.
```

### Complete and Push

```bash
git add CLAUDE_RESUME.md src/routes/products.js
git commit -S -s -m "Implement /products endpoint

- CRUD operations complete
- Pattern matches /users
- 10 tests passing"
git push
```

## Developer C: Tuesday Afternoon

```bash
git pull
```

```
User: resume

Claude:
Last Session: Completed /products endpoint. 22 tests passing total.

Pending Tasks:
- [ ] Add authentication middleware
- [ ] Write API documentation

User: I'll add authentication.
```

## Benefits

| Benefit | Description |
|---------|-------------|
| **Team awareness** | Everyone sees project state |
| **Clear handoffs** | No duplicate work |
| **Git history** | Progression tracked in commits |
| **Status tracking** | Dependencies and blockers visible |

## Conflict Resolution

If two developers work simultaneously:

```bash
git pull
# CONFLICT in CLAUDE_RESUME.md
```

**Resolution**:
1. Communicate with teammate
2. Merge pending tasks from both versions
3. Update Project Status with both changes
4. Commit merged version

## Best Practices

**Do**:
- Commit after completing meaningful work
- Update Project Status section
- Clear completed tasks from Pending
- Write clear Next Session Focus for handoffs

**Don't**:
- Commit partial/WIP resume
- Leave completed tasks in Pending
- Skip Project Status updates

## Team Size

| Size | Recommendation |
|------|----------------|
| 2-3 | Works well |
| 4-6 | Needs coordination |
| 7+ | Use project management tools instead |

---

*Team workflow for session-skills v1.4.0*
