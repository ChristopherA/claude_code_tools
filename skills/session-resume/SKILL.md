---
name: session-resume
version: 1.3.6
description: >
  Load and process previous session context from CLAUDE_RESUME.md.
  Provides summary and highlights next session focus. Uses executable
  scripts for staleness detection and archive listing. Recognizes
  Project Status (inter-project communication) and Sync Status
  (authoritative source tracking) sections. Enhanced SessionStart hook
  warns about uncommitted changes for better between-session awareness.

  ENHANCED in v1.3.6: Step 0.5 now provides contextual messaging about
  what changed (resume edits, project work, or both). Helps user understand
  the nature of uncommitted changes before committing. Professional status
  indicators and clear explanations improve workflow clarity.

  FIXED in v1.3.5: Script paths now use SKILL_BASE for absolute path
  resolution. Works in workspace root, project subdirectories, and all
  contexts. Previously failed with "no such file" in workspace roots.

  CRITICAL in v1.3.4: Step 0.5 now BLOCKS if uncommitted changes exist
  (does NOT auto-commit). User must manually commit changes using Git
  Commit Protocol before resume proceeds. This ensures clean separation
  between previous changes and new session work, prevents mixing commits,
  and maintains workflow integrity. Includes secret detection warnings.


  WHEN: User explicitly requests "resume", "load resume", "continue
  from last session", "what was I working on", "show previous session",
  or "previous context".


  WHEN NOT: Automatically on session start, mid-session context switches,
  when no CLAUDE_RESUME.md exists, or during file operations. Never
  auto-invoke - requires explicit user request.
---

# Session Resume Protocol

## Setup

Before executing any steps, establish the skill base directory for script access:

```bash
# Skill base directory - works in all contexts (project root, workspace root, subdirectories)
SKILL_BASE="${SKILL_BASE:-$HOME/.claude/skills/session-resume}"
```

This ensures scripts can be found regardless of where the skill is invoked from.

## Resume Loading Steps

### Step 0.5: Check for Uncommitted Changes (BLOCKING)

**Purpose**: Ensure clean git state before loading resume context.

**Why this matters**:
- Uncommitted changes must be committed BEFORE other work
- Prevents mixing previous changes with new session work
- Maintains clean git checkpoints for recovery
- Follows Git Commit Protocol (explicit approval required)

**Implementation**:

1. **Check if git repository**:
   ```bash
   git rev-parse --git-dir >/dev/null 2>&1
   ```
   - If not a git repo: Skip this step entirely (proceed to Step 1)
   - If git repo: Continue to check for changes

2. **Check for uncommitted changes**:
   ```bash
   # Use porcelain v2 for reliable machine-parseable output
   git status --porcelain=v2
   ```
   - If empty (no changes): Proceed to Step 1
   - If non-empty: BLOCK and require user action

3. **When uncommitted changes detected** (BLOCKING):

   a. **Display all changes with context**:
   ```bash
   # Check what types of changes exist
   # Use porcelain v2 for reliable parsing
   RESUME_CHANGED=false
   OTHER_CHANGED=false

   if git diff --quiet CLAUDE_RESUME.md 2>/dev/null && git diff --cached --quiet CLAUDE_RESUME.md 2>/dev/null; then
       RESUME_CHANGED=false
   else
       RESUME_CHANGED=true
   fi

   # Check if any other files changed (porcelain v2 format)
   CHANGES=$(git status --porcelain=v2)
   OTHER_FILES=$(echo "$CHANGES" | grep -v "CLAUDE_RESUME.md")

   if [ -n "$OTHER_FILES" ]; then
       OTHER_CHANGED=true
   fi

   # Contextual header
   echo "❌ Cannot resume: Uncommitted changes detected"
   echo ""

   if [ "$RESUME_CHANGED" = true ] && [ "$OTHER_CHANGED" = true ]; then
       echo "📝 Changes found in CLAUDE_RESUME.md AND other project files"
       echo "   (Manual edits to resume + work done while session suspended)"
   elif [ "$RESUME_CHANGED" = true ]; then
       echo "📝 Changes found in CLAUDE_RESUME.md"
       echo "   (Manual edits made between sessions)"
   else
       echo "📝 Changes found in project files"
       echo "   (Work done while session was suspended)"
   fi

   echo ""
   echo "The following files have uncommitted changes:"
   echo ""
   git status --short
   echo ""
   echo "=== Full diff ==="
   git diff HEAD

   # For untracked files, show content
   git ls-files --others --exclude-standard | while read file; do
       echo ""
       echo "=== New file: $file ==="
       cat "$file"
   done
   ```

   b. **Check for secret files** (warning only):
   ```bash
   # Use porcelain v2 for reliable parsing
   CHANGES=$(git status --porcelain=v2)
   # Extract filenames (last field in porcelain v2 output)
   FILENAMES=$(echo "$CHANGES" | awk '{print $NF}')
   SECRET_FILES=$(echo "$FILENAMES" | grep -E '\.(env|credentials|key|pem|secret)$|credentials\.json|\.aws/|\.ssh/' || true)

   if [ -n "$SECRET_FILES" ]; then
       echo ""
       echo "⚠️  WARNING: Potential secret files detected:"
       echo "$SECRET_FILES"
       echo ""
       echo "Review carefully before committing!"
   fi
   ```

   c. **Provide clear next steps**:
   ```bash
   echo ""
   echo "────────────────────────────────────────"
   echo "REQUIRED ACTION: Commit changes before resuming"
   echo "────────────────────────────────────────"
   echo ""
   echo "1. Review the changes above"
   echo "2. Commit them using Git Commit Protocol:"
   echo ""
   echo "   git add <files>           # Stage specific files"
   echo "   # Draft commit message"
   echo "   # Say: I APPROVE THIS COMMIT"
   echo "   git commit -S -s -m \"<message>\""
   echo ""
   echo "3. Then say 'resume' again to load session context"
   echo ""
   echo "Why this matters:"
   echo "- Keeps your changes separate from new session work"
   echo "- Maintains clean git checkpoints for recovery"
   echo "- Follows Git Commit Protocol (explicit approval)"
   echo ""

   exit 1  # Block execution
   ```

4. **If no uncommitted changes**: Proceed directly to Step 1 (silent success)

**Error handling**:

- **Not a git repo**: Silent skip (proceed to Step 1)
- **Git command fails**: Display error, suggest manual git status check
- **Any uncommitted changes**: BLOCK with clear instructions (exit 1)

**User experience**:

**Scenario A: No uncommitted changes** (normal case)
```
User: resume

Claude: 📋 Resuming from November 13, 2025 session:
[Normal resume presentation - Step 0.5 passed silently]
```

**Scenario B: Resume file changed** (BLOCKING)
```
User: resume

Claude: ❌ Cannot resume: Uncommitted changes detected

📝 Changes found in CLAUDE_RESUME.md
   (Manual edits made between sessions)

The following files have uncommitted changes:

M  CLAUDE_RESUME.md

=== Full diff ===
[Shows complete diff output]

────────────────────────────────────────
REQUIRED ACTION: Commit changes before resuming
────────────────────────────────────────
[Instructions...]
```

**Scenario C: Project files changed** (BLOCKING)
```
User: resume

Claude: ❌ Cannot resume: Uncommitted changes detected

📝 Changes found in project files
   (Work done while session was suspended)

The following files have uncommitted changes:

M  requirements/ISSUES_SESSION_SKILLS.md
?? new_file.md

=== Full diff ===
[Shows complete diff output]

────────────────────────────────────────
REQUIRED ACTION: Commit changes before resuming
────────────────────────────────────────
[Instructions...]
```

**Scenario D: Both resume and project files** (BLOCKING)
```
User: resume

Claude: ❌ Cannot resume: Uncommitted changes detected

📝 Changes found in CLAUDE_RESUME.md AND other project files
   (Manual edits to resume + work done while session suspended)

The following files have uncommitted changes:

M  CLAUDE_RESUME.md
M  requirements/ISSUES_SESSION_SKILLS.md

=== Full diff ===
[Shows complete diff output]

────────────────────────────────────────
REQUIRED ACTION: Commit changes before resuming
────────────────────────────────────────
[Instructions...]
```

**Scenario E: Secret files detected** (BLOCKING with warning)
```
User: resume

Claude: ❌ Cannot resume: Uncommitted changes detected

The following files have uncommitted changes:

M  .env
?? credentials.json

⚠️  WARNING: Potential secret files detected:
M  .env
?? credentials.json

Review carefully before committing!

────────────────────────────────────────
REQUIRED ACTION: Commit changes before resuming
────────────────────────────────────────

[Rest of blocking message with instructions...]
```

**Integration with SessionStart hook**:

The SessionStart hook (v1.3.2) already warns about uncommitted changes:
```
⚠️  Uncommitted changes from previous session. Review with "git status".
```

Step 0.5 complements this by:
1. User sees warning at session start
2. User says "resume"
3. Step 0.5 BLOCKS if uncommitted changes exist
4. User commits changes manually using Git Commit Protocol
5. User says "resume" again - now proceeds normally

**Testing this step**:
- [ ] No git repo: Step skipped silently (proceed to Step 1)
- [ ] Git repo, no changes: Step skipped silently (proceed to Step 1)
- [ ] Git repo, modified files: BLOCKS with clear message
- [ ] Git repo, new files: BLOCKS with clear message
- [ ] Git repo, deleted files: BLOCKS with clear message
- [ ] Git repo, mixed changes: BLOCKS, shows all changes
- [ ] Secret files present: BLOCKS with WARNING
- [ ] After committing: Step 0.5 passes, proceeds to Step 1

---

### Step 1: Check for Resume File

1. **Look for CLAUDE_RESUME.md** in current directory
   - If found: Continue to Step 2
   - If not found: Check archives/ and report

2. **If CLAUDE_RESUME.md not found**, check archives:

   ```bash
   "$SKILL_BASE/scripts/list_archives.sh" "$PWD" --format detailed
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
STALENESS=$("$SKILL_BASE/scripts/check_staleness.sh" "$PWD")
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

**SessionStart hook** (recommended - enhanced v1.3.7):
```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "date +'📅 Today is %A, %B %d, %Y' && ([ -f CLAUDE_RESUME.md ] && echo '\\n📋 Previous session available. Say \"resume\" to continue.' || true) && (git rev-parse --git-dir >/dev/null 2>&1 && [ -n \"$(git status --porcelain=v2)\" ] && echo '\\n⚠️  Uncommitted changes from previous session. Review with \"git status\".' || true)"
    }]
  }
}
```

**What this hook does** (v1.3.2 enhanced):
- Shows current date and day of week
- Notifies if CLAUDE_RESUME.md exists (resume available)
- **NEW**: Warns if uncommitted changes exist (git dirty state)
- All checks are non-blocking (graceful if files or git not available)

**Why the git warning helps**:
- User aware of dirty state at session START (before resuming)
- Addresses between-session change detection
- Non-blocking (informational only - user decides whether to commit)
- Works with any project (gracefully skips if not a git repo)

**Alternative: Basic hook** (without git warning):
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

**Between-Session Changes (Step 0.5)** - NEW in v1.3.3:
- [ ] No git repo: Step skipped silently
- [ ] Git repo, no changes: Step skipped silently
- [ ] Git repo, modified files: Changes detected and committed
- [ ] Git repo, new untracked files: Changes detected and committed
- [ ] Git repo, deleted files: Changes detected and committed
- [ ] Git repo, mixed changes (modified + new + deleted): All detected
- [ ] Secret files (.env, credentials.json, etc.): Auto-commit blocked
- [ ] Diffs displayed for all changed files
- [ ] Untracked file contents shown
- [ ] Commit message includes per-file summaries
- [ ] Clean state verified after auto-commit
- [ ] Context incorporated before resume loads

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
- [ ] Step 0.5 works seamlessly with session-closure clean state

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

## Additional Documentation

For detailed information beyond task instructions, see:

**User Documentation**:
- **references/CONFIGURATION.md** - Setup, hooks, installation methods
  - SessionStart notification hook
  - Combined workflow with session-closure
  - Multi-project coordination
  - Staleness threshold customization
- **references/EXAMPLES.md** - Real-world usage scenarios
  - Basic resume loading examples
  - Stale resume handling
  - Archive browsing examples
  - Team collaboration workflows

**Developer Documentation**:
- **references/DEVELOPMENT.md** - Scripts, architecture, contributing
  - check_staleness.sh implementation details
  - list_archives.sh documentation
  - Cross-platform date handling
  - Testing infrastructure
- **references/TESTING.md** - Test suite details and manual testing
  - 8 automated tests coverage
  - Manual testing procedures
  - Cross-platform testing (macOS + Linux)
  - Troubleshooting test failures

**Design Documentation**:
- **references/DESIGN_DECISIONS.md** - Why design choices were made
  - Why explicit triggering only (no auto-invoke)
  - Why staleness detection matters
  - Progressive disclosure architecture rationale
  - Cross-platform compatibility decisions
- **references/ROADMAP.md** - Future enhancements and version history
  - Version history (v1.1.0 → v1.3.0)
  - Planned features (archive search, branch-aware resumes)
  - Feature requests and community input
  - Non-goals and boundaries

**Resume Format Specification**:
- **references/RESUME_FORMAT_v1.2.md** - Complete format specification (in parent skill directory)

---

*Session-resume skill v1.3.7 - Porcelain v2 for all git status + Contextual uncommitted changes messaging + Fixed script paths (SKILL_BASE) + BLOCKING (Git Commit Protocol) + progressive disclosure*
