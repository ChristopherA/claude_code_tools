---
name: session-closure
version: 1.3.5
description: >
  Execute session closure protocol with resume creation. Supports
  full and minimal modes based on available context. Automatically
  archives previous resumes unless tracked in git. Uses executable
  scripts for consistent archiving and validation. Creates resumes
  with Project Status (inter-project communication) and Sync Status
  (authoritative source tracking). Includes secrets detection to
  prevent accidental commits of .env, credentials, and private keys.
  Checks for ALL uncommitted changes before closure, reviews and
  commits them with proper summaries before creating new resume.

  ENHANCED in v1.3.5: Archive script now provides clear messaging about
  git tracking status. Distinguishes between clean state (no uncommitted
  changes - safe to proceed) and dirty state (uncommitted changes exist -
  recommends committing resume separately). Improves workflow clarity and
  prevents confusion about backup status.


  WHEN: User says "close context", "end session", "prepare to stop",
  "prepare to close session", "save state", "create resume", OR when
  I detect context usage approaching 170k tokens (proactive preservation),
  OR when SessionEnd hook invokes (automatic on /exit or /compact).


  WHEN NOT: Mid-session saves, "save draft" requests, temporary
  checkpoints, brief pauses, or "save file" commands. Don't trigger
  on file operations.
---

# Session Closure Protocol

## Closure Steps

### Step 0: Determine Operational Mode

Check available context budget:

**Full Mode** (>30k tokens remaining):
- Complete session analysis
- All resume sections fully populated
- Detailed insights and learnings
- Archive with full provenance

**Minimal Mode** (<30k tokens remaining):
- Essential state only
- Abbreviated sections
- Critical information only
- Archive with basic provenance
- Notify: "⚠️ Limited context - creating essential resume"

**Emergency Mode** (critically low):
- Output resume template to chat
- User manually saves from conversation
- Notify: "❌ Insufficient context for file creation - please save from chat"

*Select appropriate mode based on remaining context. Default to Full Mode.*

### Step 0.5: Handle ALL Uncommitted Changes

Before archiving or creating new resume, check for ANY uncommitted changes in the repository.

**Why this matters**: User may have manually edited files between sessions (added notes, updated tasks, modified documentation, etc.). These changes contain important context that should be incorporated into the session and preserved in git history. Changes to ANY file should be reviewed and committed before creating the new resume.

**Critical flaw in v1.3.3**: Only checked CLAUDE_RESUME.md, but Step 5 committed everything with `git add .`. This caused silent commits of unreviewed changes (e.g., LOCAL_CONTEXT.md modifications were committed without summary or review).

**Detection and handling**:

```bash
if git rev-parse --git-dir >/dev/null 2>&1; then
  # Check for ANY uncommitted changes, not just resume
  # Use porcelain v2 for reliable machine-parseable output
  CHANGES=$(git status --porcelain=v2)

  if [ -n "$CHANGES" ]; then
    echo "⚠️  Uncommitted changes detected"
    echo ""
    echo "📝 Files changed:"
    git status --short
    echo ""
    echo "📝 All changes:"
    git diff
    echo ""
    exit 10  # Special exit code: uncommitted changes found, needs handling
  else
    echo "✓ No uncommitted changes"
  fi
else
  echo "✓ Not a git repository (cannot detect changes)"
fi
```

**When uncommitted changes are detected (exit code 10)**:

Claude should automatically:

1. **Display the diffs** - Already shown by the script above (ALL files, not just resume)
2. **Check for potential secrets** - Before committing anything:
   ```bash
   # Check for potential secrets before adding
   # Use porcelain v2 for reliable parsing
   echo "Checking for potential secrets..."
   CHANGES=$(git status --porcelain=v2)

   # Extract filenames from porcelain v2 output (last field)
   # Format: "1 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <path>"
   FILENAMES=$(echo "$CHANGES" | awk '{print $NF}')

   if echo "$FILENAMES" | grep -E '\.env|credentials|secrets|\.key|\.pem|id_rsa|\.p12|password' >/dev/null 2>&1; then
     echo "❌ ERROR: Potential secret files detected:"
     echo "$FILENAMES" | grep -E '\.env|credentials|secrets|\.key|\.pem|id_rsa|\.p12|password'
     echo ""
     echo "Session closure will NOT auto-commit for safety."
     echo "Please review these files and commit manually."
     exit 1
   else
     echo "✓ No secrets detected"
   fi
   ```
   - If secrets detected: ABORT closure, inform user to review and commit manually
   - If no secrets: Continue with auto-commit
3. **Read and incorporate ALL changes** - Review what was manually added/changed in every file
4. **Categorize changes**:
   - Manual edits to CLAUDE_RESUME.md (tasks added, status updated)
   - Manual edits to other project files (LOCAL_CONTEXT.md, documentation, etc.)
   - Files modified during previous session (if any)
5. **Commit ALL changes** - Preserve them in git history with comprehensive summary:
   - Read ALL diffs to understand what changed
   - Write a commit message that summarizes changes to EACH file
   - Use format: `git add . && git commit -S -s -m "Pre-closure changes: $(date +%Y-%m-%d-%H%M)\n\n[Human-readable summary of ALL changes by file]"`
   - Do NOT include raw diff output in commit message
   - Be specific about what changed in each file
6. **Continue with closure** - Proceed to create new resume incorporating this knowledge

**Example commit message** (if LOCAL_CONTEXT.md and CLAUDE_RESUME.md both changed):
```
Pre-closure changes: 2025-11-08-2130

CLAUDE_RESUME.md:
- Marked 2 testing tasks as completed

LOCAL_CONTEXT.md:
- Added explicit prohibition of auto-commits without user approval
- Clarified no Claude Code attribution footers in commits
- Added examples of what NOT to include in commit messages
```

**Workflow**:
- Uncommitted changes detected → ALL diffs displayed automatically
- Claude reads all diffs, understands full context
- All changes committed together with comprehensive summary
- New resume created with full knowledge from all changes
- No data loss, no silent commits, no user intervention needed

**Rationale**:
- ALL uncommitted changes should be reviewed before ANY commits
- Changes to any file represent important context for the session
- Committing separately from new resume preserves clear history
- Comprehensive summary ensures accurate git log
- Auto-handling is safe: we're only committing user's own changes
- Prevents the v1.3.3 flaw where files were silently committed

**Non-git projects**:
- Cannot detect uncommitted changes
- User responsible for backup strategy
- Proceeds with warning

### Step 1: Archive Existing Resume (If Needed)

Before creating new resume, run the archive script:

```bash
./scripts/archive_resume.sh "$PWD"
```

**Script behavior**:
- Receives project root directory via $PWD parameter
- Changes to project root to ensure correct file locations
- If CLAUDE_RESUME.md doesn't exist: Skips (nothing to archive)
- If file is tracked in git: Skips (git history is the archive)
- Otherwise: Moves to `archives/CLAUDE_RESUME/<timestamp>.md`

**Script output**:
- "✓ No previous resume to archive" (first closure)
- "✅ CLAUDE_RESUME.md tracked in git with no uncommitted changes" (git-tracked, clean)
- "⚠️  CLAUDE_RESUME.md has uncommitted changes" (git-tracked, dirty - recommends commit)
- "📦 Archived to archives/CLAUDE_RESUME/YYYY-MM-DD-HHMM.md" (non-git, archived)

**Why use a script**:
- Consistent behavior (not re-interpreted each time)
- Testable (validated by test suite)
- Handles edge cases (git detection, missing files)
- Lower token cost (call script vs parse logic)

### Step 2: Assess Session State

Analyze the session based on operational mode:

**Full Mode Questions**:
- What work was completed (development/planning/analysis)?
- What decisions were made and why?
- What tasks remain pending?
- Were there any blockers or open questions?
- What insights were gained?
- What context is critical to preserve?

**Minimal Mode Questions**:
- What was done? (brief)
- What's next? (essential only)
- Any blockers? (critical only)

### Step 3: Create CLAUDE_RESUME.md

**Location**: Current project root (same directory as CLAUDE.md)

**Format** (Full Mode):
```markdown
# Claude Resume - [Project Name]

**Last Session**: [Date]
**Session Duration**: [Approximate time]
**Overall Status**: [One-line summary]

---

## Last Activity Completed

[What was just finished - enough detail to understand context]

---

## Pending Tasks

- [ ] [Next immediate task]
- [ ] [Subsequent tasks]
- [ ] [Known blockers or dependencies]

---

## Key Decisions Made

[Important decisions made this session - focus on WHY not just WHAT]

---

## Insights & Learnings

[Discoveries, patterns found, approaches that worked/didn't work]

---

## Session Summary

[2-3 sentences on what was accomplished and why decisions were made]

---

## Sync Status
*Include if project has authoritative sources (Google Docs, HackMD, GitHub)*
*Omit this section if project has no external masters*

- Google Docs: [last sync date or "current"]
- HackMD: [last sync date or "current"]
- GitHub: [last sync date or "current"]
- Distribution: [ready/needs update]

---

## Project Status
*Required for all projects - enables inter-project communication*

- **Current State**: [STATE] - Brief description
- **Key Changes**: What changed this session
- **Next Priority**: Immediate action needed
- **Dependencies**: Any blockers or waiting on external projects
- **Project Health**: Overall assessment

**State Options**:
- 🟢 ACTIVE - Currently being worked on
- 🔴 BLOCKED - Waiting on external dependency
- 🟡 WAITING - Paused for specific reason
- ✅ COMPLETE - Finished, ready to archive
- 🔄 REVIEW - Under review/testing

---

## Next Session Focus

[What the next session should tackle first based on current progress]

---

*Resume created by session-closure v1.3.4: [Timestamp]*
*Next session: Say "resume" to load this context*
```

**Format** (Minimal Mode):
```markdown
# Claude Resume - [Project Name] (Essential)

**Last Session**: [Date]
**Status**: [One-line summary]

---

## Last Activity
[One paragraph maximum]

## Pending
- [Critical task 1]
- [Critical task 2]

## Project Status
- **Current State**: [STATE]
- **Next Priority**: [Immediate need]

## Next
[One paragraph - what to do next]

---
*Essential resume - limited context prevented full analysis*
*Created by session-closure v1.3.4: [Timestamp]*
*Next session: Say "resume" to load this context*
```

### Step 4: Verify Resume Creation

After creating CLAUDE_RESUME.md, validate it:

```bash
./scripts/validate_resume.sh "$PWD"
```

**Script checks**:
- Receives project root directory via $PWD parameter
- Changes to project root to find CLAUDE_RESUME.md
- File exists
- Contains "Last Session" header
- Contains "Last Activity" section
- Contains "Pending" section (tasks)
- Contains "Next Session Focus" section
- Contains footer with "Resume created by session-closure"

**Script output**:
- "✅ Resume validation passed: CLAUDE_RESUME.md" (success)
- "❌ Resume validation failed" + list of missing sections (failure)

**If validation fails**:
- Review which sections are missing
- Add missing sections
- Re-run validation

**Why validate**:
- Ensures resume is complete and loadable
- Catches missing sections before session ends
- Tested behavior (validated by test suite)

### Step 5: Commit New Resume

After validation, if project is a git repository, commit the new resume using the commit script.

**Important**: Step 0.5 should have already committed all pre-existing uncommitted changes. This step should ONLY see the new CLAUDE_RESUME.md. If other files have changes, something unexpected happened during closure execution.

**Use the commit script**:

```bash
SKILL_BASE="${SKILL_BASE:-$HOME/.claude/skills/session-closure}"
"$SKILL_BASE/scripts/commit_resume.sh" "$PWD"
```

**What the script does**:
- Checks if in a git repository (skips if not)
- Uses `git status --porcelain=v2` for reliable change detection
- Verifies ONLY CLAUDE_RESUME.md has uncommitted changes
- Commits with standardized message and flags (-S -s)
- Blocks if unexpected files changed (safety check)

**Script output examples**:
- `✅ Session resume committed` - Resume committed successfully
- `✓ No uncommitted changes (resume may already be committed)` - Already clean
- `✓ Not a git repository (skipping commit)` - Not a git repo
- `❌ ERROR: Unexpected changes detected during closure` - Unexpected files modified

**Commit message enhancement**:

The script uses a minimal template commit message:
```
Session closure: YYYY-MM-DD-HHMM

Resume created with session state.
```

**IMPORTANT**: Claude should enhance this message based on workspace context:

1. **Check for workspace commit protocols**:
   - If `CORE_PROCESSES.md` exists and contains Git Commit Protocol, follow it
   - Look for commit message requirements in project documentation
   - Adapt to established commit message patterns in git history

2. **Summarize session content**:
   - Review the "Last Activity Completed" section in CLAUDE_RESUME.md
   - Include key accomplishments (bugs fixed, features added, issues documented)
   - Reference important commits made during the session
   - Note severity/status of work (e.g., "CRITICAL issue fixed", "Documentation complete")

3. **Session significance**:
   - Milestones reached (e.g., "v1.3.7 deployed")
   - Testing results (e.g., "End-to-end validation passed")
   - Important decisions made
   - Blockers resolved or discovered

**Example enhanced commit message**:
```
Session closure: 2025-11-13-2345

Resume documenting Issue 16 discovery and documentation:
- Reviewed session-closure execution problems from Issue 15 test
- Documented three UX issues: bash parse error, commit message conflict, footer validation
- Created comprehensive Issue 16 with solution options
- Recommended: commit_resume.sh script + commit message guidance
- Severity: MEDIUM (works with workarounds, UX improvement needed)
- Commit: 518ae2a

Signed-off-by: @ChristopherA <ChristopherA@LifeWithAlacrity.com>
```

**Why enhance the commit message**:
- Workspace-specific protocols may require detailed commit messages
- Git history becomes more valuable for future reference
- Commit messages explain WHAT was accomplished, not just "resume created"
- Aligns with professional commit message practices
- User can still review and approve via Git Commit Protocol (if configured)

**Why this step**:
- Commits ONLY the new resume created during closure
- Verifies no unexpected file modifications occurred during closure
- Separates user changes (Step 0.5) from session closure (Step 5)
- Provides clear commit boundaries for clean git history
- Detects if closure process unexpectedly modified files

**Script implementation**:
- Uses `scripts/commit_resume.sh` (follows pattern from `archive_resume.sh`)
- Tested and consistent behavior
- Handles complex bash logic reliably
- Machine-parseable git status (porcelain v2)

**Script flags**:
- `-S`: GPG sign (required by Open Integrity for signed commits)
- `-s`: Add Signed-off-by line

**Error handling**:
- If unexpected changes detected: Script exits 1, shows what changed during closure
- If commit fails (e.g., GPG misconfigured): Error visible, user fixes git config
- If no changes: Script exits 0, skips silently
- If not git repo: Script exits 0, skips silently

**User responsibilities**:
- Configure GPG signing if using -S flag (required by Open Integrity)
- Review .gitignore to exclude unwanted files

**Secret detection**: Now handled in Step 0.5 during pre-closure commit. If secrets are detected in uncommitted changes, they're flagged before ANY commits happen, preventing accidental exposure.

### Step 6: Confirmation

After validation passes, report completion:

**Full Mode**:
```markdown
✅ Session closure complete.

📄 CLAUDE_RESUME.md created and validated
[Archive output from script if applicable]
[Mode used: Full Mode / Minimal Mode]

Summary: [One sentence about session outcome]

💡 Next session: Say "resume" to continue from here.

---
*Resume created by session-closure v1.3.4: [Timestamp]*
```

**Minimal Mode**:
```markdown
⚠️  Session closure complete (Minimal Mode - limited context).

📄 Essential resume created and validated
[Archive output from script if applicable]

Summary: [One sentence]

💡 Next session: Say "resume" to continue. You may want to expand
the resume with additional details.
```

---

## Related Skills

This skill is paired with **session-resume** which loads the resume
created here. Together they provide complete session continuity.

**Workflow**:
1. End session → session-closure creates CLAUDE_RESUME.md (this skill)
2. Start session → Notification about resume (SessionStart hook)
3. Say "resume" → session-resume loads context

---

## Archive Structure

**Default archive location**: `archives/CLAUDE_RESUME/<timestamp>.md`

**Why this location**:
- One `archives/` directory at project root
- Organized by type (CLAUDE_RESUME, future: transcripts, etc.)
- Extensible pattern for other archive types
- Simple .gitignore: just `archives/`

**Recommended .gitignore**:
```gitignore
# Claude session state (personal, ephemeral)
CLAUDE_RESUME.md

# All project archives
archives/
```

---

## Hook Integration

This skill is typically paired with a SessionEnd hook for automatic execution:

**In ~/.claude/settings.json**:
```json
{
  "hooks": {
    "SessionEnd": [{
      "type": "skill",
      "skill": "session-closure"
    }]
  }
}
```

**With hook**: User types `/exit` → session-closure runs automatically
**Without hook**: User says "close context" → session-closure runs manually

**Pattern**: Hook guarantees execution, skill does the work.

---

## Context Limit Handling

**Proactive trigger at ~170k tokens**:
- Leaves 30k buffer for closure execution
- Claude will suggest: "Context getting full, shall I close now?"
- User can accept or decline

**Buffer calculation**:
```
Total: 200k tokens
- session-closure: ~7.5k
- Resume creation: ~5k
- File operations: ~2k
- Safety margin: ~15.5k
= 30k buffer needed
→ Trigger at 170k
```

**If context is tight**: Minimal Mode ensures closure still succeeds

---

## Git Tracking Behavior

**Three cases handled**:

1. **Non-git project**: Always archive to `archives/CLAUDE_RESUME/`
2. **Git project, resume not tracked**: Archive to `archives/CLAUDE_RESUME/`
3. **Git project, resume tracked**: Skip archiving (git history is archive)

**Detection**: `git ls-files --error-unmatch CLAUDE_RESUME.md`

**Rationale**: If tracked in git, each commit preserves history.
No separate archive needed.

---

## Testing Checklist

**Standalone Tests**:
- [ ] Manual trigger: "close context" → skill activates
- [ ] Non-trigger: "save file" → skill doesn't activate
- [ ] CLAUDE_RESUME.md created at project root
- [ ] All sections populated with content

**Hook Integration Tests**:
- [ ] SessionEnd hook invokes skill on /exit
- [ ] Resume created without manual trigger
- [ ] Hook invocation completes successfully

**Archiving Tests**:
- [ ] First close: No previous resume, no archive created
- [ ] Second close: Previous resume archived to archives/CLAUDE_RESUME/
- [ ] Archive has correct timestamp filename
- [ ] Archive preserves original content exactly
- [ ] Tracked resume: Skips archiving, shows git message

**Mode Tests**:
- [ ] Normal context: Full Mode used
- [ ] Low context: Minimal Mode used, warning shown
- [ ] Resume format matches mode

**Pairing Tests** (with session-resume):
- [ ] Close → exit → start → "resume" flow works
- [ ] Archived resume can be loaded from archives/
- [ ] Version in footer matches skill version

---

## Usage Notes

**Current status**: Local prototype for context-refactor project

**Future**: Will be promoted to ~/.claude/skills/ for user-level use
after validation across different project types.

**Customization**: Resume format can be adapted for:
- Development projects (include test status, build state)
- Planning projects (emphasize decisions and insights)
- Policy projects (note review cycles, stakeholder status)
- Creative projects (capture inspiration, stylistic choices)

---

## Troubleshooting

### Phantom Tasks (Rare Issue)

**Symptom**: Claude attempts already-completed tasks from previous sessions on resume

**When this happens**:
- Tasks from old sessions reappear
- Completed work attempted again
- TodoWrite tasks persist unexpectedly

**Root cause**: TodoWrite can sometimes interfere with context management, causing tasks to persist across sessions.

**Solution 1: Clear TodoWrite (Optional Step)**

Add before creating resume:

```markdown
### Optional Step: Clear Todo List

If experiencing phantom tasks, clear the todo list:

1. Call TodoWrite with empty array: `TodoWrite([])`
2. Confirm: "Todo list cleared for next session"
```

**Solution 2: PROHIBITED TASKS Section**

Add to TOP of resume if phantom tasks persist:

```markdown
# PROHIBITED TASKS - DO NOT EXECUTE

The following have ALREADY been completed. DO NOT attempt them again:
- [Task that keeps reappearing]
- [Another phantom task]
```

**Solution 3: Session Boundary**

Use `/exit` instead of `/compact` to fully clear context state between sessions.

**Prevention**:
- Mark tasks complete when done (TodoWrite)
- Review pending tasks before closure
- Remove completed tasks from "Pending Tasks" section

### Sync Status Guidance

**When to include "Sync Status" section**:

✅ **Include if project has**:
- Google Docs as authoritative master
- HackMD as authoritative master
- GitHub as authoritative master
- Local markdown synced from external sources

❌ **Omit if project**:
- Has no external authoritative sources
- Everything is local/git only
- No synchronization workflow needed

**How to check**: Look in project's CLAUDE.md or LOCAL_CONTEXT.md for "Authoritative Sources" section.

**Example check**:
```bash
# Quick check for authoritative sources
grep -i "authoritative\|master\|google docs\|hackmd" CLAUDE.md LOCAL_CONTEXT.md
```

If found → Include "Sync Status" section
If not found → Omit "Sync Status" section

---

### Available Scripts

**scripts/archive_resume.sh**:
- Archives CLAUDE_RESUME.md with timestamp
- Detects git tracking (skips if tracked)
- Creates archive directory automatically
- Exit code 0 on success

**scripts/validate_resume.sh**:
- Validates resume structure
- Checks for required sections
- Exit code 0 (valid), 1 (invalid), 2 (missing file)

### Running Tests

```bash
cd tests
./test_scripts.sh
```

**Test coverage** (6 tests, 12 assertions):
1. First closure (no previous resume)
2. Second closure (archives previous)
3. Git-tracked resume (skips archive)
4. Valid resume passes validation
5. Invalid resume fails validation
6. Missing file handled gracefully

**Expected output**: All tests passing

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
  - Archive structure and .gitignore recommendations
  - SessionEnd hook integration
  - Multi-project coordination with Project Status section
- **references/TROUBLESHOOTING.md** - Common issues and solutions
  - Phantom tasks issue (rare but documented)
  - Sync Status guidance
  - Debugging procedures

**Developer Documentation**:
- **references/DEVELOPMENT.md** - Scripts, architecture, contributing
  - Script documentation (archive_resume.sh, validate_resume.sh)
  - Testing procedures and automated test suite
  - Performance benchmarks
- **references/TESTING.md** - Test suite details and manual testing
  - Comprehensive testing checklists
  - Test scenarios and expected behavior
  - Troubleshooting test failures

**Design Documentation**:
- **references/DESIGN_DECISIONS.md** - Why design choices were made
  - Why use scripts vs inline code
  - Progressive disclosure architecture rationale
  - Git-aware archiving decisions
- **references/IMPLEMENTATION_DETAILS.md** - Technical implementation
  - Context limit handling (170k token trigger)
  - Git tracking behavior (3 cases)
  - Operational mode logic (Full/Minimal/Emergency)

**Resume Format Specification**:
- **references/RESUME_FORMAT_v1.2.md** - Complete format specification (in parent skill directory)

---

*Session-closure skill v1.3.7 - Extracted Step 5 to commit_resume.sh script + Commit message enhancement guidance + Issue 16 UX improvements*
