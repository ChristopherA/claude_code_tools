# Session Skills Examples

Real-world workflow examples demonstrating how to use session-closure and session-resume skills effectively.

---

## Available Examples

### 1. [Daily Workflow](./daily-workflow.md)
**Scenario**: Individual developer working on a feature across multiple days

**Demonstrates**:
- End-of-day session closure
- Next-morning session resume
- Context preservation
- Archive management

**Best for**: Solo developers, personal projects

---

### 2. [Team Coordination](./team-coordination.md)
**Scenario**: Team of developers using shared CLAUDE_RESUME.md for coordination

**Demonstrates**:
- Git-tracked resume for team visibility
- Handoffs between developers
- Project Status tracking
- Conflict resolution

**Best for**: Small teams (2-6 developers), collaborative projects

---

## Quick Start

### Daily Workflow

**End of day**:
```
User: close context
[CLAUDE_RESUME.md created]
```

**Next morning**:
```
User: resume
[Context restored]
```

**Time to resume**: < 5 seconds

---

### Team Coordination

**After completing work**:
```bash
git add CLAUDE_RESUME.md
git commit -m "Session: Completed X feature"
git push
```

**Starting new work**:
```bash
git pull
# Say "resume" in Claude Code
[Team context loaded]
```

---

## Example Selection Guide

| Your Situation | Recommended Example |
|----------------|---------------------|
| Working alone | [Daily Workflow](./daily-workflow.md) |
| Small team (2-6) | [Team Coordination](./team-coordination.md) |
| Large team (7+) | Use project management tools instead |
| Multiple branches | [Daily Workflow](./daily-workflow.md) (per branch) |
| Consulting/freelance | [Daily Workflow](./daily-workflow.md) |

---

## Common Patterns

### Pattern 1: End of Day Closure

```
User: close context

Claude:
✓ Archived previous resume
✓ Created new CLAUDE_RESUME.md
✓ Validated resume structure

Next session: Say "resume"
```

**When**: End of work session
**Time**: ~2 seconds
**Files**: Creates/updates CLAUDE_RESUME.md

---

### Pattern 2: Morning Resume

```
User: resume

Claude:
✓ Resume is fresh (< 1 day old)

[Session summary]
[Pending tasks]
[Next focus]

Ready to continue!
```

**When**: Start of work session
**Time**: ~3 seconds
**Context**: Full previous session restored

---

### Pattern 3: Archive Browsing

```
User: resume

Claude:
No current resume, but found archives:
- 2025-11-04-1430.md (Nov 4, 2:30 PM)
- 2025-11-03-1615.md (Nov 3, 4:15 PM)

Which would you like to load?
```

**When**: CLAUDE_RESUME.md missing
**Use**: Recover old session context

---

## Tips and Tricks

### Tip 1: Use Staleness Warnings

Resume age indicators help assess relevance:
- ✓ **fresh** (< 1 day): Safe to use
- ⚠️ **recent** (1-6 days): Review before acting
- ⚠️ **stale** (7-29 days): Verify project state
- ❌ **very_stale** (30+ days): Treat as historical

### Tip 2: Project Status for Dependencies

```markdown
## Project Status

- **Dependencies**: ⚠️ Waiting on backend API (ETA: Nov 5)
```

Reminds you of blockers on resume.

### Tip 3: Sync Status for External Sources

```markdown
## Sync Status

**Authoritative Sources**:
- API Spec: https://docs.google.com/... (synced Nov 4)

**Sync Health**: ⚠️ Check for updates
```

Reminds you to check external docs.

### Tip 4: Branch-Specific Resumes

Different branches = different contexts:

```bash
# feature/auth branch
git checkout feature/auth
# Create CLAUDE_RESUME_auth.md for this branch

# feature/api branch
git checkout feature/api
# Create CLAUDE_RESUME_api.md for this branch
```

Keeps contexts separate.

---

## Troubleshooting Examples

### Problem: Resume Too Old

```
Claude: ⚠️ Resume is stale (14 days old)
```

**Solution**: Check recent git commits to see what changed:
```bash
git log --since="14 days ago" --oneline
```

---

### Problem: Multiple Developers Modified Resume

```
git pull
# CONFLICT in CLAUDE_RESUME.md
```

**Solution**: Merge manually, keeping both changes:
1. Edit CLAUDE_RESUME.md
2. Combine both developers' pending tasks
3. Update Project Status with both changes
4. Commit merged version

---

### Problem: Archive Not Created

```
Claude: ✓ Resume tracked in git - skipping archive
```

**Explanation**: Not a problem! Archives skipped when resume tracked in git (git history serves as archive).

**If you want archives anyway**: Add CLAUDE_RESUME.md to .gitignore.

---

## Advanced Workflows

### Multi-Project Workflow

Working on multiple projects:

```
project-a/
├── CLAUDE_RESUME.md  # Project A context

project-b/
├── CLAUDE_RESUME.md  # Project B context
```

Each project maintains separate context.

### Context Handoff

Handing off to another developer:

```markdown
## Next Session Focus

FOR ALICE: Please implement rate limiting on /login endpoint.
Reference implementation in /register endpoint (lines 45-67).
Test with scripts/test_ratelimit.sh.

Config needed:
- 5 requests/minute
- Exponential backoff
- IP-based tracking
```

Clear instructions for next person.

---

## More Examples

Want more examples? Check the skills' reference documentation:

- **session-resume**: `references/EXAMPLES.md` (13 detailed examples)
- **session-closure**: `references/TROUBLESHOOTING.md` (common issues)
- **Both skills**: `references/CONFIGURATION.md` (setup examples)

---

## Contributing Examples

Have a workflow example to share? We'd love to include it!

**Submit via**:
- GitHub PR: https://github.com/ChristopherA/claude_code_tools/pulls
- GitHub Issue: https://github.com/ChristopherA/claude_code_tools/issues

**Good examples include**:
- Real-world scenario
- Step-by-step walkthrough
- Expected outcomes
- Common variations

---

*Examples for session-skills v1.3.0*
*Last updated: November 5, 2025*
