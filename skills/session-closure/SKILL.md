---
name: session-closure
version: 1.3.0
description: >
  Execute session closure protocol with resume creation. Supports
  full and minimal modes based on available context. Automatically
  archives previous resumes unless tracked in git. Uses executable
  scripts for consistent archiving and validation. Creates resumes
  with Project Status (inter-project communication) and Sync Status
  (authoritative source tracking).

  WHEN: User says "close context", "end session", "prepare to stop",
  "save state", "create resume", OR when I detect context usage
  approaching 170k tokens (proactive preservation), OR when SessionEnd
  hook invokes (automatic on /exit or /compact).

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

### Step 1: Archive Existing Resume (If Needed)

Before creating new resume, run the archive script:

```bash
./scripts/archive_resume.sh
```

**Script behavior**:
- If CLAUDE_RESUME.md doesn't exist: Skips (nothing to archive)
- If file is tracked in git: Skips (git history is the archive)
- Otherwise: Moves to `archives/CLAUDE_RESUME/<timestamp>.md`

**Script output**:
- "✓ No previous resume to archive" (first closure)
- "✓ Resume tracked in git - skipping archive" (git-tracked)
- "📦 Archived to archives/CLAUDE_RESUME/YYYY-MM-DD-HHMM.md" (archived)

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

*Resume created by session-closure v1.2.0: [Timestamp]*
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
*Created by session-closure v1.2.0: [Timestamp]*
*Next session: Say "resume" to load this context*
```

### Step 4: Verify Resume Creation

After creating CLAUDE_RESUME.md, validate it:

```bash
./scripts/validate_resume.sh
```

**Script checks**:
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

### Step 5: Confirmation

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
*Resume created by session-closure v1.1.0: [Timestamp]*
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

*Session-closure skill v1.3.0 - Progressive disclosure + cross-platform support*
