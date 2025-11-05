# Usage Examples - session-resume

This document provides real-world usage examples and scenarios for the session-resume skill.

---

## Basic Usage

### Example 1: Resume After Overnight Break

**Scenario**: You ended work yesterday with `close context`, now starting today.

**User workflow**:
```
[Session starts]
📅 Today is Wednesday, November 05, 2025

📋 Previous session available. Say "resume" to continue.

User: resume
```

**Claude response**:
```
Loading session from November 4, 2025...

✓ Resume is fresh (< 1 day old)

## Last Session Summary

Completed authentication module with JWT token validation and refresh logic.
All tests passing. Deployed to staging environment for QA review.

## Pending Tasks

- [ ] Add rate limiting to login endpoint
- [ ] Write API documentation for /auth endpoints
- [ ] Security review with team on Friday

## Next Session Focus

Implement rate limiting using express-rate-limit package. Configure 5 requests
per minute for login endpoint with exponential backoff. Test with automated script.

Ready to continue!
```

---

### Example 2: Resume After Several Days

**Scenario**: Returned to project after weekend + Monday off (4 days).

**User workflow**:
```
User: resume
```

**Claude response**:
```
Loading session from November 1, 2025...

⚠️ Resume is recent (4 days old) - project may have evolved since then.

## Last Session Summary

Started database migration from MySQL to PostgreSQL. Schema conversion complete
for users and sessions tables. Need to migrate remaining tables and update
connection strings.

## Pending Tasks

- [ ] Migrate products and orders tables
- [ ] Update database connection config
- [ ] Run migration tests
- [ ] Update deployment scripts

## Next Session Focus

Complete remaining table migrations. Focus on products table first (most complex).
Test with sample data before proceeding to orders table.

Note: Since this resume is 4 days old, you may want to verify project status
and check for any changes made by team members.

Ready to continue!
```

---

### Example 3: Resume When Project Has Dependencies

**Scenario**: Resume shows you're waiting on another team/project.

**User workflow**:
```
User: resume
```

**Claude response**:
```
Loading session from November 4, 2025...

✓ Resume is fresh (< 1 day old)

## Last Session Summary

Completed API client implementation for new backend endpoints. Ready for integration
but blocked pending backend deployment.

## Project Status

- **Current State**: 🔄 IN PROGRESS - API client ready, waiting on backend
- **Key Changes**: Implemented all CRUD endpoints with error handling
- **Next Priority**: Integration testing once backend deployed
- **Dependencies**: ⚠️ Waiting on backend team to deploy v2.0 API (ETA: Nov 5)
- **Project Health**: Good - on schedule, dependency known

## Pending Tasks

- [ ] Integration testing with live backend (blocked)
- [ ] Write API documentation
- [ ] Update example app

## Next Session Focus

Once backend team deploys v2.0 API (expected today), run integration tests and
verify all endpoints working. Document any issues for backend team.

⚠️ **Dependency Alert**: You're blocked on backend deployment. You may want to
check with backend team on their ETA before proceeding.

Ready to continue!
```

---

### Example 4: No Current Resume, Archives Available

**Scenario**: CLAUDE_RESUME.md missing, but archives exist.

**User workflow**:
```
User: resume
```

**Claude response**:
```
No CLAUDE_RESUME.md found in current directory.

However, I found these archived sessions:

📦 Available Archives:
1. 2025-11-04-1430.md (November 4, 2025 at 2:30 PM) - 3.2 KB
2. 2025-11-03-1615.md (November 3, 2025 at 4:15 PM) - 2.8 KB
3. 2025-11-02-0945.md (November 2, 2025 at 9:45 AM) - 3.1 KB

Would you like me to:
1. Load the most recent archive (Nov 4)?
2. Tell me which archive to load
3. Start a fresh session (no context loaded)

What would you prefer?
```

**User**: Load the most recent

**Claude**: *[Loads archives/CLAUDE_RESUME/2025-11-04-1430.md and processes as normal resume]*

---

### Example 5: Very Stale Resume

**Scenario**: Resume is over a month old.

**User workflow**:
```
User: resume
```

**Claude response**:
```
Loading session from September 28, 2025...

❌ Resume is very stale (38 days old) - treat as historical reference only.

## Last Session Summary (September 28, 2025)

Working on user authentication system. Implemented login/logout with session
management. Planning to add OAuth integration next.

## Pending Tasks (from 38 days ago)

- [ ] Add OAuth 2.0 integration
- [ ] Write authentication tests
- [ ] Update user documentation

## Next Session Focus (from 38 days ago)

Research OAuth 2.0 providers and select best option for integration.

⚠️ **Strong Warning**: This resume is over a month old. The project has likely
evolved significantly since then. I recommend:

1. Checking current project state (git log, recent commits)
2. Reviewing recent changes by team members
3. Verifying if pending tasks are still relevant
4. Checking if architecture or approach has changed

Treat this information as historical context, not current work state.

Would you like me to help you assess the current project state instead of
relying on this old resume?
```

---

## Advanced Usage

### Example 6: Resume with Sync Status

**Scenario**: Project syncs from Google Docs (authoritative master).

**User workflow**:
```
User: resume
```

**Claude response**:
```
Loading session from November 4, 2025...

✓ Resume is fresh (< 1 day old)

## Last Session Summary

Updated API specification based on design review feedback. Synced changes to
Google Docs (authoritative master). Implementation ready to begin.

## Sync Status

**Authoritative Sources**:
- **API Specification**: https://docs.google.com/document/d/abc123
  (synced 2025-11-04 at 2:15 PM)
- **Architecture Decisions**: https://hackmd.io/@team/architecture
  (synced 2025-11-03 at 9:30 AM)

**Sync Health**: ⚠️ Architecture doc 1 day behind

## Pending Tasks

- [ ] Implement new /users/batch endpoint from spec
- [ ] Update API client library
- [ ] Write integration tests

## Next Session Focus

Start implementing /users/batch endpoint per latest spec in Google Docs.
Reference section 4.2 for request/response format.

⚠️ **Sync Alert**: Architecture doc is 1 day behind. You may want to check
if any relevant decisions were made recently.

Ready to continue!
```

---

### Example 7: Resume from Different Branch Context

**Scenario**: Working on feature branch, have resume from main branch work.

**User workflow**:
```
User: resume
```

**Claude response**:
```
Loading session from November 3, 2025...

⚠️ Resume is recent (2 days old)

## Last Session Summary

Completed refactoring of authentication module on main branch. All tests passing.
Merged PR #147. Ready for deployment.

## Pending Tasks

- [ ] Deploy to production
- [ ] Monitor error rates
- [ ] Update changelog

⚠️ **Context Notice**: This resume appears to be from work on the main branch,
but you're currently on the feature/api-v2 branch. The context may not be
relevant to your current work.

Would you like to:
1. Continue with this context (if working on related features)
2. Start fresh session for feature/api-v2 work
3. Check if there's a resume specific to this branch

What would you prefer?
```

---

## Integration Examples

### Example 8: Combined with session-closure

**Scenario**: Complete session management workflow.

**End of day**:
```
User: close context

[session-closure creates CLAUDE_RESUME.md]

Archived previous resume to archives/CLAUDE_RESUME/2025-11-04-1430.md

Created CLAUDE_RESUME.md with:
- Session summary
- Pending tasks
- Next session focus

✅ Session closure complete.
```

**Next morning**:
```
[Session starts]
📅 Today is Wednesday, November 05, 2025

📋 Previous session available. Say "resume" to continue.

User: resume

[session-resume loads CLAUDE_RESUME.md]

✓ Resume is fresh (< 1 day old)

[Full context restored]

Ready to continue where you left off!
```

---

### Example 9: Manual Archive Selection

**Scenario**: Multiple archives, user wants specific one.

**User workflow**:
```
User: resume
```

**Claude**: *[Shows archive list]*

**User**: Load the one from November 2

**Claude**:
```
Loading archives/CLAUDE_RESUME/2025-11-02-0945.md...

⚠️ Resume is recent (3 days old)

[Processes selected archive as normal resume]
```

---

## Troubleshooting Examples

### Example 10: Resume File Not Found

**User workflow**:
```
User: resume
```

**Claude response**:
```
No CLAUDE_RESUME.md found in current directory.

I also checked for archived sessions but found none.

This could mean:
1. This is a new project (no sessions yet)
2. Resumes are in a different directory
3. Files were cleaned up

To create a session resume, work on your project and then say "close context"
at the end of your session. This will create a CLAUDE_RESUME.md file for next time.

Would you like to start a fresh session?
```

---

### Example 11: Date Parsing Error

**Scenario**: Resume has unexpected date format.

**User workflow**:
```
User: resume
```

**Claude response**:
```
Found CLAUDE_RESUME.md, but I couldn't determine the session date.

Expected format: **Last Session**: Month DD, YYYY (e.g., November 5, 2025)

I'll load the resume content anyway, but I can't assess staleness.

[Loads resume content without staleness check]
```

---

## Command Line Examples

### Example 12: Direct Script Usage

**Check staleness manually**:
```bash
cd ~/.claude/skills/session-resume/scripts
./check_staleness.sh ~/project/CLAUDE_RESUME.md
# Output: fresh
```

**List archives manually**:
```bash
./list_archives.sh --limit 3
# Output:
# 2025-11-05-1430.md (November 5, 2025 at 2:30 PM, 3.2 KB)
# 2025-11-04-1615.md (November 4, 2025 at 4:15 PM, 2.8 KB)
# 2025-11-03-0945.md (November 3, 2025 at 9:45 AM, 3.1 KB)
```

**Short format**:
```bash
./list_archives.sh --format short
# Output:
# 2025-11-05-1430.md
# 2025-11-04-1615.md
# 2025-11-03-0945.md
```

---

## Team Collaboration Examples

### Example 13: Shared Resume in Git

**Scenario**: Team tracks CLAUDE_RESUME.md in git for coordination.

**Developer A (end of day)**:
```
User: close context

[Creates CLAUDE_RESUME.md]

User: (Commits to git)
git add CLAUDE_RESUME.md
git commit -m "Update session resume: completed auth module"
git push
```

**Developer B (next morning)**:
```
(Pulls latest changes)
git pull

User: resume

[session-resume loads team's shared context]

✓ Resume is fresh (< 1 day old)

## Last Session Summary

[Developer A's work from yesterday]

Ready to continue the team's work!
```

---

*Usage examples for session-resume v1.3.0*
