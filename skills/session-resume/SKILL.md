---
name: session-resume
version: 1.2.1
description: >
  Load and process previous session context from CLAUDE_RESUME.md.
  Provides summary and highlights next session focus. Uses executable
  scripts for staleness detection and archive listing. Recognizes
  Project Status (inter-project communication) and Sync Status
  (authoritative source tracking) sections.

  WHEN: User explicitly requests "resume", "load resume", "continue
  from last session", "what was I working on", "show previous session",
  or "previous context".

  WHEN NOT: Automatically on session start, mid-session context switches,
  when no CLAUDE_RESUME.md exists, or during file operations. Never
  auto-invoke - requires explicit user request.
---

# Session Resume Protocol

## When This Skill Activates

**TRIGGER PHRASES** (Explicit only):
- "resume"
- "load resume"
- "continue from last session"
- "what was I working on"
- "show previous session"
- "previous context"
- "load context"

**NEVER AUTO-INVOKE**:
- ❌ Does NOT trigger automatically on session start
- ❌ Does NOT trigger on file existence
- ❌ Requires explicit user request

**DO NOT TRIGGER ON**:
- File operations ("load file", "read document")
- Mid-session context switches
- General questions about the project

---

## Resume Loading Steps

### Step 1: Check for Resume File

1. **Look for CLAUDE_RESUME.md** in current directory
   - If found: Continue to Step 2
   - If not found: Check archives/ and report

2. **If CLAUDE_RESUME.md not found**, check archives:

   ```bash
   ./scripts/list_archives.sh --format detailed
   ```

   **Script output**:
   - "No archives found" (no previous sessions)
   - "Found N archived session(s):" + list (archives available)

   Present to user:
   ```markdown
   📋 No current session resume found.

   [Script output - archive list or "No previous sessions"]

   Would you like to:
   1. Start fresh (no resume needed)
   2. Load a specific archive (if any exist)
   ```

### Step 2: Check Resume Age (Staleness Detection)

Use the staleness check script:

```bash
STALENESS=$(./scripts/check_staleness.sh)
```

**Script output** (one of):
- `fresh` - <1 day old, no warning needed
- `recent` - 1-6 days old, note age
- `stale` - 7-29 days old, show warning
- `very_stale` - 30+ days old, strong warning
- `error` - Cannot determine (missing date or file)

**Present warnings**:

**If stale**:
```markdown
⚠️  Resume is from [Date] ([N] days old)

This may be stale. Do you want to:
1. Continue with this context
2. Review it first then decide
3. Check archives for a more recent session
```

**If very_stale**:
```markdown
⚠️  Resume is from [Date] ([N] days old - VERY STALE)

This context is likely outdated. Consider:
1. Starting fresh
2. Reviewing archives for more recent session
3. Continuing anyway (not recommended)
```

### Step 3: Load and Analyze Resume

1. **Read CLAUDE_RESUME.md** completely

2. **Extract key sections**:
   - Last Activity Completed
   - Pending Tasks (with count)
   - **Project Status** (if present - v1.2.0+)
   - **Sync Status** (if present - v1.2.0+)
   - Next Session Focus
   - Key Decisions (if present)
   - Insights & Learnings (if present)

3. **Check resume mode** (from footer):
   - Full mode: Complete context available
   - Minimal mode: Essential only, may need expansion
   - Note in presentation if minimal

4. **Check Sync Status** (if present):
   - If sync dates are >7 days old: Warn user
   - If "current": Note that sources are up-to-date
   - If missing: No sync concerns

### Step 4: Present Resume Summary

**Standard presentation**:
```markdown
📋 Resuming from [Date] session:

[If Project Status present:]
**Project**: [Project name from resume title]
**Status**: [State emoji + description from Project Status]

**Last activity**: [One-line summary from resume]

[If Sync Status present and has stale dates:]
⚠️  Authoritative sources may need syncing:
- [Source]: Last synced [date] ([N] days ago)

**Next focus**: [From "Next Session Focus" section]

**Pending tasks**: [Count] tasks remaining
[List top 3-5 tasks]

[If Key Decisions present: Highlight 1-2 key decisions]

Full context loaded. Ready to continue.
```

**Minimal resume presentation**:
```markdown
📋 Resuming from [Date] session (Essential resume):

**Last activity**: [Summary]

**Next focus**: [Next steps]

**Pending**: [Count] tasks

⚠️  This was an essential resume (limited context during creation).
You may want to expand it with additional details before continuing.

Ready to continue or expand context?
```

### Step 5: Optional Actions

After presenting resume, offer:

1. **Archive option** (if desired):
   ```markdown
   Would you like to archive this resume to keep project clean?
   (Moves to archives/CLAUDE_RESUME/ with timestamp)
   ```

2. **Expand minimal resume** (if applicable):
   ```markdown
   This resume was created in minimal mode. Would you like me to
   help expand it with additional context before we continue?
   ```

3. **Ready to work**:
   ```markdown
   Ready to continue where you left off!
   ```

---

## Archive Support

### Listing Archives

When user asks about previous sessions or archives:

```markdown
Checking archives/CLAUDE_RESUME/...

Found [N] archived sessions:

Last 7 days:
- 2025-10-24-1630 (3 hours ago)
- 2025-10-24-1430 (5 hours ago)
- 2025-10-23-1400 (yesterday)

Older:
- 2025-10-20-1000 (4 days ago)
- 2025-10-15-1430 (9 days ago)
[... show up to 10 most recent]

Say "load [date-time]" to review a specific session.
```

### Loading Specific Archive

When user specifies a date/time:

1. **Parse request**:
   - "load resume from yesterday"
   - "load archive from this morning"
   - "load 2025-10-23-1400"

2. **Find closest match** in archives/CLAUDE_RESUME/

3. **Load and present** with archive context:
   ```markdown
   📦 Loading archive from October 23, 2025 14:00

   [Present resume content as in Step 4]

   Note: This is an archived session, not current state.
   Current resume: [date of CLAUDE_RESUME.md if different]
   ```

### Searching Archives

When user asks to search:

```markdown
User: "When did I work on the archiving strategy?"

Claude: Searching archives/CLAUDE_RESUME/...

Found mentions in:
- 2025-10-24-1630: "Designed archiving strategy"
- 2025-10-24-1430: "Discussed archive locations"

Which would you like to review?
```

---

## Error Handling

### No Resume Found

```markdown
📋 No session resume found.

No CLAUDE_RESUME.md in current directory.
No archives in archives/CLAUDE_RESUME/.

This appears to be a fresh start!

To create a resume at end of this session, say "close context"
or just type /exit (if SessionEnd hook is configured).
```

### Corrupted or Incomplete Resume

```markdown
⚠️  Resume file found but appears incomplete or corrupted.

[Show what was readable]

Would you like to:
1. Continue with partial context
2. Check archives for backup
3. Start fresh
```

### Permission Issues

```markdown
❌ Error: Cannot read CLAUDE_RESUME.md (check permissions)

You may need to check file permissions or location.

File expected at: [full path]
```

---

## Related Skills

This skill loads resumes created by **session-closure**. Together
they provide complete session continuity.

**Workflow**:
1. End session → session-closure creates CLAUDE_RESUME.md
2. Start session → Notification about resume (SessionStart hook)
3. Say "resume" → This skill loads context

**SessionStart hook** (recommended):
```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "date +'📅 Today is %A, %B %d, %Y' && ([ -f CLAUDE_RESUME.md ] && echo '\\n📋 Previous session available. Say \"resume\" to continue.' || true)"
    }]
  }
}
```

---

## Resume Format Understanding

**Expected resume structure**:
- Header with date, duration, status
- Last Activity Completed
- Pending Tasks
- Key Decisions Made (optional)
- Insights & Learnings (optional)
- Session Summary
- Next Session Focus
- Footer with version and instructions

**Handles both**:
- Full mode resumes (complete)
- Minimal mode resumes (essential only)

**Adapts presentation** based on available content.

---

## Usage Examples

### Example 1: Standard Resume

```
User: resume

Claude: 📋 Resuming from October 24, 2025 session:

**Last activity**: Designed and implemented session-closure
and session-resume skills with archiving support

**Next focus**: Test complete lifecycle (close → exit → start
→ resume) and update hook configuration

**Pending tasks**: 3 tasks remaining
- Test archiving behavior
- Update ~/.claude/settings.json with hooks
- Document final implementation

Full context loaded. Ready to continue testing!
```

### Example 2: Stale Resume

```
User: resume

Claude: 📋 Resume found from October 10, 2025

⚠️  This resume is 14 days old - context may be stale.

**Last activity**: Working on archive strategy design

Would you like to:
1. Continue with this context anyway
2. Review the resume first
3. Check if there's a more recent archive

User: 1

Claude: [Proceeds with standard presentation]
```

### Example 3: Archive Loading

```
User: What was I working on last week?

Claude: Checking archives/CLAUDE_RESUME/...

Found sessions from last week:
- 2025-10-17-1630: Session continuity testing
- 2025-10-16-1400: Hook configuration
- 2025-10-15-0900: Skill implementation

Which would you like to review?

User: load 2025-10-17-1630

Claude: 📦 Loading archive from October 17, 2025 16:30

**Last activity**: Tested session-closure with archiving,
validated archives/CLAUDE_RESUME/ structure works correctly

[Rest of archived resume content...]
```

### Example 4: No Resume

```
User: resume

Claude: 📋 No session resume found.

This appears to be a fresh start! No previous session
context is available.

When you're ready to end this session, say "close context"
or type /exit to create a resume for next time.
```

---

## Testing Checklist

**Basic Loading**:
- [ ] "resume" triggers skill
- [ ] "what was I working on" triggers skill
- [ ] Loads CLAUDE_RESUME.md from current directory
- [ ] Presents summary correctly
- [ ] Shows "Next Session Focus" clearly

**Staleness Detection**:
- [ ] Fresh resume (<24h): No warning
- [ ] Recent resume (1-7 days): Notes age
- [ ] Stale resume (>7 days): Shows warning
- [ ] Very stale (>30 days): Strong warning

**Error Handling**:
- [ ] No resume: Graceful message
- [ ] No resume, has archives: Lists archives
- [ ] Corrupted resume: Handles gracefully
- [ ] Permission error: Clear message

**Archive Support**:
- [ ] Lists archives when requested
- [ ] Loads specific archive by date/time
- [ ] Searches archives by content
- [ ] Distinguishes current vs archived resume

**Mode Handling**:
- [ ] Full mode resume: Complete presentation
- [ ] Minimal mode resume: Shows warning, offers expansion
- [ ] Version in footer recognized

**Integration**:
- [ ] Works with SessionStart hook notification
- [ ] Pairs correctly with session-closure
- [ ] Complete lifecycle works: close → exit → start → resume

---

## Future Enhancements

**Could add**:
- Archive cleanup: Delete archives older than N days
- Archive statistics: Show session frequency, patterns
- Archive export: Bundle archives for backup
- Archive comparison: Show differences between sessions
- Multi-project view: See resumes across related projects

**Keep it simple for now** - these can be added if users request them.

---

## Design Principles

**User control**: Never auto-invoke, always explicit
**Graceful degradation**: Handle missing/incomplete resumes
**Helpful defaults**: Standard presentation works for most cases
**Extensible**: Archive support for power users
**Informative**: Clear about what's being loaded and why

---

## Scripts & Testing

### Available Scripts

**scripts/list_archives.sh**:
- Lists archived resumes from archives/CLAUDE_RESUME/
- Sorted newest first
- Options: `--limit N`, `--format short|detailed`
- Exit code 0 on success

**scripts/check_staleness.sh**:
- Checks resume age and returns staleness level
- Output: `fresh|recent|stale|very_stale|error`
- Handles date parsing (multiple formats)
- Exit code 0 (success), 1 (error)

### Running Tests

```bash
cd tests
./test_scripts.sh
```

**Test coverage** (8 tests):
1. List archives (none exist)
2. List archives (multiple exist)
3. List archives (with limit parameter)
4. Check staleness (fresh resume)
5. Check staleness (stale resume)
6. Check staleness (missing file)
7. List archives (detailed format)
8. List archives (empty directory)

**Expected output**: All 8 tests passing

### Why Scripts?

Learned from **project-cleanup v1.2.0**:
- **Consistency**: Same behavior every invocation
- **Testability**: Validated by automated test suite
- **Token efficiency**: Call script vs parse pseudo-code
- **Maintainability**: Update script once, not documentation

---

*Session-resume skill v1.2.1 - Fixed script path resolution for skills directory*
