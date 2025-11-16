---
name: session-closure
version: 1.3.8
description: >
  Execute session closure protocol with resume creation. Supports
  full and minimal modes based on available context. Automatically
  archives previous resumes unless tracked in git. Uses executable
  scripts for consistent archiving, validation, and commits. Creates
  resumes with Project Status (inter-project communication) and Sync
  Status (authoritative source tracking). Checks for ALL uncommitted
  changes before closure and commits them before creating new resume.

  WHEN: User says "close context", "end session", "prepare to stop",
  "prepare to close session", "save state", "create resume", OR when
  I detect context usage approaching 170k tokens (proactive preservation),
  OR when SessionEnd hook invokes (automatic on /exit or /compact).

  WHEN NOT: Mid-session saves, "save draft" requests, temporary
  checkpoints, brief pauses, or "save file" commands. Don't trigger
  on file operations.
---

# Session Closure Protocol

## Contents

1. [Closure Steps](#closure-steps)
   - [Step 0: Determine Operational Mode](#step-0-determine-operational-mode)
   - [Step 0.5: Handle ALL Uncommitted Changes](#step-05-handle-all-uncommitted-changes)
   - [Step 1: Archive Existing Resume](#step-1-archive-existing-resume)
   - [Step 2: Assess Session State](#step-2-assess-session-state)
   - [Step 3: Create CLAUDE_RESUME.md](#step-3-create-claude_resumemd)
   - [Step 4: Verify Resume Creation](#step-4-verify-resume-creation)
   - [Step 5: Commit New Resume](#step-5-commit-new-resume)
   - [Step 6: Confirmation](#step-6-confirmation)
2. [Additional Documentation](#additional-documentation)

---

## Closure Steps

### Step 0: Determine Operational Mode

Check available context budget:

**Full Mode** (>30k tokens remaining):
- Complete session analysis with all resume sections
- Detailed insights and learnings
- Archive with full provenance

**Minimal Mode** (<30k tokens remaining):
- Essential state only, abbreviated sections
- Archive with basic provenance
- Notify: "⚠️ Limited context - creating essential resume"

**Emergency Mode** (critically low):
- Output resume template to chat for manual save
- Notify: "❌ Insufficient context for file creation - please save from chat"

*Select appropriate mode based on remaining context. Default to Full Mode.*

### Step 0.5: Handle ALL Uncommitted Changes

Before archiving or creating new resume, check for ANY uncommitted changes in the repository.

**Why**: User may have manually edited files between sessions. These changes contain important context that should be reviewed and preserved in git history.

**Implementation**:

Run the uncommitted changes detection script:

```bash
SKILL_BASE="${SKILL_BASE:-$HOME/.claude/skills/session-closure}"
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

When uncommitted changes are detected, you MUST commit them before proceeding:

1. **Review changes**: Script displays full diffs
2. **Check for secrets**: Script warns if .env, credentials, keys found
3. **Commit manually**:
   ```bash
   git add <files>
   git commit -S -s -m "Pre-closure changes: $(date +%Y-%m-%d-%H%M)

   CLAUDE_RESUME.md: [what changed]
   LOCAL_CONTEXT.md: [what changed]
   [other files]: [what changed]"
   ```
4. **User says "close context" again** → Step 0.5 passes (clean state)
5. **Continue closure** → Proceed to Step 1

**Why blocking is necessary**:
- Separates user changes from session closure work
- Maintains clean git checkpoints for recovery
- Ensures explicit approval for all commits (protocol requirement)
- Prevents silent commits of potentially sensitive changes

**Error handling**:
- Script not found: Display error, proceed with warning
- Script fails: Display error, suggest manual `git status`
- Git command fails: Script handles gracefully

### Step 1: Archive Existing Resume

Run archive script before creating new resume:

```bash
SKILL_BASE="${SKILL_BASE:-$HOME/.claude/skills/session-closure}"
"$SKILL_BASE/scripts/archive_resume.sh" "$PWD"
```

**Script behavior**:
- If CLAUDE_RESUME.md doesn't exist: Skip
- If tracked in git: Skip (git history is archive)
- Otherwise: Move to `archives/CLAUDE_RESUME/<timestamp>.md`

**Output messages**:
- "✓ No previous resume to archive"
- "✅ CLAUDE_RESUME.md tracked in git with no uncommitted changes"
- "⚠️  CLAUDE_RESUME.md has uncommitted changes" (recommends commit)
- "📦 Archived to archives/CLAUDE_RESUME/YYYY-MM-DD-HHMM.md"

### Step 2: Assess Session State

Analyze session based on operational mode:

**Full Mode**: What completed? What decisions made and why? Tasks pending? Blockers? Insights? Critical context?

**Minimal Mode**: What done? What next? Blockers?

### Step 3: Create CLAUDE_RESUME.md

**Location**: Current project root (same directory as CLAUDE.md)

**Format**: See `references/RESUME_FORMAT_v1.2.md` for complete specification.

**Full Mode sections**:
- Header (project name, date, duration, status)
- Last Activity Completed
- Pending Tasks
- Key Decisions Made (optional)
- Insights & Learnings (optional)
- Session Summary
- Sync Status (if external authoritative sources exist)
- Project Status (required)
- Next Session Focus
- Footer (version, timestamp, instructions)

**Minimal Mode sections**:
- Header (abbreviated)
- Last Activity (1 paragraph max)
- Pending (critical tasks only)
- Project Status (state + priority only)
- Next (1 paragraph)
- Footer (notes "Essential resume")

### Step 4: Verify Resume Creation

Validate resume after creation:

```bash
"$SKILL_BASE/scripts/validate_resume.sh" "$PWD"
```

**Checks**: File exists, required sections present, footer format correct.

**Output**:
- "✅ Resume validation passed" (success)
- "❌ Resume validation failed: [missing sections]" (failure)

**If validation fails**: Add missing sections, re-run validation.

### Step 5: Commit New Resume

If project is git repository, commit the new resume.

**Important**: Step 0.5 committed pre-existing changes. This step should ONLY see CLAUDE_RESUME.md.

```bash
"$SKILL_BASE/scripts/commit_resume.sh" "$PWD"
```

**What script does**:
- Verifies ONLY CLAUDE_RESUME.md has uncommitted changes
- Commits with standardized message and flags (-S -s)
- Blocks if unexpected files changed (safety check)

**Output**:
- `✅ Session resume committed` - Success
- `✓ No uncommitted changes` - Already clean
- `✓ Not a git repository` - Skipped
- `❌ ERROR: Unexpected changes detected` - Unexpected files modified

**Commit message enhancement**:

Claude should enhance the minimal template based on:
1. **Workspace commit protocols** (check CORE_PROCESSES.md)
2. **Session content** (Last Activity, accomplishments, issues)
3. **Session significance** (milestones, testing, decisions, blockers)

Example enhanced commit:
```
Session closure: 2025-11-13-2345

Resume documenting Issue 16 discovery:
- Reviewed session-closure execution problems
- Documented UX issues and solution options
- Severity: MEDIUM (works with workarounds)
- Commit: 518ae2a

Signed-off-by: @ChristopherA <ChristopherA@LifeWithAlacrity.com>
```

**Why enhance**: Workspace protocols may require detailed messages, git history becomes more valuable, aligns with professional practices.

### Step 6: Confirmation

Report completion after validation:

**Full Mode**:
```markdown
✅ Session closure complete.

📄 CLAUDE_RESUME.md created and validated
[Archive output if applicable]
[Mode: Full Mode / Minimal Mode]

Summary: [One sentence about session outcome]

💡 Next session: Say "resume" to continue from here.

---
*Resume created by session-closure v1.3.7: [Timestamp]*
```

**Minimal Mode**:
```markdown
⚠️  Session closure complete (Minimal Mode - limited context).

📄 Essential resume created and validated
[Archive output if applicable]

Summary: [One sentence]

💡 Next session: Say "resume" to continue. Consider expanding resume with details.
```

---

## Additional Documentation

- **references/CONFIGURATION.md** - Setup and installation
- **references/TROUBLESHOOTING.md** - Common issues
- **references/RESUME_FORMAT_v1.2.md** - Complete resume format specification

---

*Session-closure skill v1.3.8 - Extracted Step 0.5 inline script to check_uncommitted_changes.sh (Issue 19: eliminates permission prompts)*
