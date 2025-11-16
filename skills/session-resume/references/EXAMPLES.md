# Usage Examples - session-resume

---

## Basic Usage

### Fresh Resume (< 1 day)
```
User: resume

✓ Resume is fresh
Last Activity: Completed auth module with JWT validation
Pending Tasks: Add rate limiting, write docs, security review
Next Focus: Implement rate limiting with express-rate-limit package
```

### Recent Resume (2-7 days)
```
User: resume

⚠️ Resume is recent (4 days old) - project may have evolved

Last Activity: Database migration from MySQL to PostgreSQL
Pending Tasks: Migrate remaining tables, update config, run tests
Warning: Verify project status and check for team changes
```

### Stale Resume (> 30 days)
```
User: resume

❌ Resume is very stale (38 days old) - treat as historical reference only

Last Activity: [September work context]
Strong Warning: Project likely evolved significantly
Recommendation: Check git log, review recent commits, verify tasks still relevant
```

---

## Resume States

| Age | Status | Recommendation |
|-----|--------|---------------|
| < 1 day | ✓ Fresh | Continue normally |
| 1-7 days | ⚠️ Recent | Verify no major changes |
| 7-30 days | ⚠️ Old | Check project status first |
| > 30 days | ❌ Very stale | Historical reference only |

---

## Special Cases

### No Resume Found
```
User: resume

No CLAUDE_RESUME.md found.
Checked archives: None found.
Recommendation: Start fresh session, use "close context" to create resume.
```

### Archives Available
```
User: resume

No current resume, but found archives:
1. 2025-11-04-1430.md (Nov 4, 2:30 PM)
2. 2025-11-03-1615.md (Nov 3, 4:15 PM)

Options: Load most recent / Select specific / Start fresh
```

### Resume with External Sources
```
User: resume

Sync Status:
- Google Docs: synced 2025-11-04 (current)
- HackMD: synced 2025-11-03 (⚠️ 1 day behind)

Alert: Architecture doc may need sync before starting work
```

### Uncommitted Changes
```
User: resume

❌ Cannot resume: Uncommitted changes detected

Files with changes:
  M CLAUDE_RESUME.md
  M src/auth.js

Action Required: Commit changes before resuming
Why: Keeps your changes separate from new session work
```

---

## Workflow Integration

### Complete Session Cycle
```
End of day:
  User: close context
  → Creates CLAUDE_RESUME.md
  → Archives previous resume

Next morning:
  User: resume
  → Loads CLAUDE_RESUME.md
  → Restores context
  → Ready to continue
```

### Team Collaboration
```
Developer A (end of day):
  close context → commit CLAUDE_RESUME.md → push

Developer B (next morning):
  pull → resume → continues team's work
```

---

## Command Line Usage

### Check Staleness
```bash
~/.claude/skills/session-resume/scripts/check_staleness.sh CLAUDE_RESUME.md
# Output: fresh | recent | old | very_stale
```

### List Archives
```bash
~/.claude/skills/session-resume/scripts/list_archives.sh --limit 5
# Output: Recent archives with timestamps
```

### Check Uncommitted Changes
```bash
~/.claude/skills/session-resume/scripts/check_uncommitted_changes.sh "$PWD"
# Exit: 0=clean, 1=changes-detected, 2=error
```

---

*Usage examples for session-resume v1.3.8*
