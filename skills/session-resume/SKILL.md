---
name: session-resume
version: 1.3.8
description: >
  Load and process previous session context from CLAUDE_RESUME.md.
  Checks for uncommitted changes before loading (blocking). Uses
  executable scripts for staleness detection, archive listing, and
  uncommitted changes detection. Recognizes Project Status (inter-project
  communication) and Sync Status (authoritative source tracking) sections.
  Provides summary and highlights next session focus.

  WHEN: User explicitly requests "resume", "load resume", "continue
  from last session", "what was I working on", "show previous session",
  or "previous context".

  WHEN NOT: Automatically on session start, mid-session context switches,
  when no CLAUDE_RESUME.md exists, or during file operations. Never
  auto-invoke - requires explicit user request.
---

# Session Resume Protocol

## Contents

1. [Setup](#setup)
2. [Resume Loading Steps](#resume-loading-steps)
   - [Step 0.5: Check for Uncommitted Changes](#step-05-check-for-uncommitted-changes-blocking)
   - [Step 1: Check for Resume File](#step-1-check-for-resume-file)
   - [Step 2: Check Resume Age](#step-2-check-resume-age-staleness-detection)
   - [Step 3: Load and Analyze Resume](#step-3-load-and-analyze-resume)
   - [Step 4: Present Resume Summary](#step-4-present-resume-summary)
   - [Step 5: Optional Actions](#step-5-optional-actions)
3. [Git Commit Protocol](#git-commit-protocol)
4. [Additional Documentation](#additional-documentation)

---

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

Run the uncommitted changes detection script:

```bash
"$SKILL_BASE/scripts/check_uncommitted_changes.sh" "$PWD"
```

**Script behavior**:
- **Not a git repo**: Exits silently (code 0) → proceed to Step 1
- **No uncommitted changes**: Exits silently (code 0) → proceed to Step 1
- **Uncommitted changes detected**: BLOCKS with detailed output (exit code 1)

**When changes detected** (BLOCKING):

The script displays:
1. **Contextual header**: What changed (resume only, project files only, or both)
2. **File list**: `git status --short` output
3. **Full diffs**: All modifications shown with `git diff HEAD`
4. **Untracked file contents**: Transparency about new files
5. **Secret file warning**: If .env, credentials, keys detected
6. **Clear instructions**: Steps to commit manually with CORE_PROCESSES.md reference

**Required action when blocked**:

When uncommitted changes are detected, you MUST commit them before proceeding. Follow the **Git Commit Protocol** (see below).

**Process**:
1. Review the changes displayed by the script
2. Stage files: `git add <files>`
3. Commit using required protocol (see Git Commit Protocol section below)
4. User says "resume" again → Step 0.5 passes (clean state)

**Why blocking is necessary**:
- Prevents mixing previous work with new session changes
- Maintains clean git checkpoints for recovery
- Ensures explicit approval for all commits (protocol requirement)

**Error handling**:
- Script not found: Display error, proceed with warning
- Script fails: Display error, suggest manual `git status`
- Git command fails: Script handles gracefully

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


## Git Commit Protocol

**When Step 0.5 blocks due to uncommitted changes, use this protocol to commit them.**

### Required Commit Flags

**ALWAYS use these flags**:
```bash
git commit -S -s -m "message"
```

**Flags explained**:
- `-S`: GPG/SSH sign the commit (verifies integrity, required for Git Inception)
- `-s`: Add Signed-off-by line (DCO - establishes accountability)

### Commit Message Format

**Title line** (required):
- **Maximum 50 characters**
- Present tense imperative: "Add", "Fix", "Update" (NOT "Added", "Fixed", "Updated")
- No period at end
- Examples: "Add session resume validation", "Fix uncommitted changes check"

**Body** (optional but recommended):
- Separate from title with blank line
- Bullet points for multi-file changes
- Explain what and why, not how
- Examples:
  ```
  Add uncommitted changes detection to session-resume

  - Extract Step 0.5 to check_uncommitted_changes.sh
  - Block resume when git state is dirty
  - Display full diffs and untracked file contents
  - Provide clear commit instructions
  ```

### Attribution Policy

**NEVER include Claude Code attribution**:

❌ **DO NOT add**:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Why**: User reviews and approves all changes. GPG signature and Signed-off-by establish actual accountability.

### Commit Approval Process

**CRITICAL**: All commits require explicit user approval.

**When blocked by uncommitted changes**:
1. **Review changes**: Script displays full diffs
2. **Display preview**: Show files being staged and proposed message
3. **Request approval**: User must explicitly approve
4. **Execute commit**: Only after approval received

**Never**:
- Commit without showing user what will be committed
- Skip the -S -s flags
- Include Claude Code attribution
- Bypass approval process

### Example Workflow

**When Step 0.5 blocks**:
```markdown
I see uncommitted changes that need to be committed before resuming:

Files to commit:
- CLAUDE_RESUME.md (modified)
- claude/processes/new-feature.md (new file)

Proposed commit message:
"Add new feature documentation

- Document feature X in processes
- Update resume with session progress"

This will be committed with: git commit -S -s

May I proceed with this commit?
```

**After user approval**:
```bash
git add CLAUDE_RESUME.md claude/processes/new-feature.md
git commit -S -s -m "Add new feature documentation

- Document feature X in processes
- Update resume with session progress"
```

### Reference

This is an abbreviated protocol for session-resume blocking scenarios. For complete details, see:
- **CORE_PROCESSES.md § Git Commit Protocol** (workspace-level)
- **LOCAL_CONTEXT.md** (project-specific variations)

---

## Additional Documentation

- **references/CONFIGURATION.md** - Setup and installation
- **references/EXAMPLES.md** - Usage examples
- **references/RESUME_FORMAT_v1.2.md** - Resume format specification

---

*Session-resume skill v1.3.8 - Extracted Step 0.5 to check_uncommitted_changes.sh (Issue 17: eliminates permission prompts) + CORE_PROCESSES.md reference in blocking message (Issue 18: workspace-aware commit guidance) + Automated resume workflow*
