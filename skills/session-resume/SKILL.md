---
name: session-resume
version: 1.5.0
description: >
  Load and process previous session context from CLAUDE_RESUME.md.
  Checks for uncommitted changes before loading (blocking). Uses
  executable scripts for archive listing and uncommitted changes
  detection. Recognizes Project Status (inter-project communication),
  Sync Status (authoritative source tracking), and Pending Outbound
  Handoffs (cross-project tracking) sections. Provides summary and
  highlights next session focus.

  WHEN: User explicitly requests "resume", "load resume", "continue
  from last session", "what was I working on", "show previous session",
  or "previous context".

  WHEN NOT: Automatically on session start, mid-session context switches,
  when no CLAUDE_RESUME.md exists, or during file operations. Never
  auto-invoke - requires explicit user request.
---

# Session Resume Protocol

## Contents

1. [Resume Loading Steps](#resume-loading-steps)
   - [Step 0: Check Permissions](#step-0-check-permissions-one-time-setup)
   - [Step 0.5: Check for Uncommitted Changes](#step-05-check-for-uncommitted-changes-blocking)
   - [Step 1: Check for Resume File](#step-1-check-for-resume-file)
   - [Step 2: Load and Analyze Resume](#step-2-load-and-analyze-resume)
   - [Step 3: Present Resume Summary](#step-3-present-resume-summary)
   - [Step 4: Optional Actions](#step-4-optional-actions)
2. [Git Commit Protocol](#git-commit-protocol)
3. [Additional Documentation](#additional-documentation)

---

## Resume Loading Steps

### Step 0: Check Permissions (ONE-TIME SETUP)

**Purpose**: Verify session-skills permissions are configured to prevent repeated permission prompts.

**Why this matters**:
- Claude Code's interactive permission approval doesn't persist across sessions
- Without pre-approved permissions, users get repeated prompts for every skill script
- One-time setup enables smooth session-resume and session-closure operation

**Implementation**:

Run the permission check script:

```bash
"${SKILL_BASE:-$HOME/.claude/skills/session-resume}/scripts/check_permissions.sh" "${PROJECT_ROOT:-$PWD}"
```

**Script behavior**:
- **All permissions present**: Exits silently (code 0) → proceed to Step 0.5
- **Permissions missing/outdated**: Exits with details (code 1) → offer configuration
- **No settings file**: Exits with MISSING_FILE marker → offer to create

**When configuration needed**:

The script outputs structured information:
1. **MISSING_REQUIRED**: Critical permissions needed for skills to function
2. **MISSING_RECOMMENDED**: Optional permissions for better UX (git, rsync, etc.)
3. **FOUND_OLD**: Deprecated patterns that should be removed (e.g., `session-*` wildcards)

**Present configuration offer to user**:

```markdown
🔧 Session skills need one-time permission setup

[If missing file:]
No .claude/settings.local.json found. I'll create one with required permissions.

[If missing patterns:]
Missing required permissions ([count] patterns):
- Skill(session-closure)
- Skill(session-resume)
- [List other missing REQUIRED patterns]

[If old patterns found:]
Found deprecated patterns ([count] to remove):
- Bash(~/.claude/skills/session-closure/scripts/*)
- [List other FOUND_OLD patterns]

I can configure these automatically using this inline script:
[Show inline bash script that will be executed]

May I update .claude/settings.local.json to add these permissions?
```

**After user approval, execute inline configuration script**:

```bash
#!/bin/bash
# Inline permission configuration script
# Adds/updates .claude/settings.local.json with session-skills permissions

PROJECT_DIR="${PROJECT_ROOT:-$PWD}"
SETTINGS_FILE="$PROJECT_DIR/.claude/settings.local.json"

# Create .claude directory if needed
mkdir -p "$PROJECT_DIR/.claude"

# Required permission patterns
REQUIRED_PATTERNS='[
  "Skill(session-closure)",
  "Skill(session-resume)",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-closure}/scripts/check_permissions.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-resume}/scripts/check_permissions.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-closure}/scripts/check_uncommitted_changes.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-closure}/scripts/archive_resume.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-closure}/scripts/validate_resume.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-closure}/scripts/commit_resume.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-resume}/scripts/check_uncommitted_changes.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-resume}/scripts/list_archives.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Bash(\"${SKILL_BASE:-$HOME/.claude/skills/session-resume}/scripts/check_staleness.sh\" \"${PROJECT_ROOT:-$PWD}\")",
  "Read(~/.claude/skills/session-closure/**)",
  "Read(~/.claude/skills/session-resume/**)"
]'

# Old patterns to remove
OLD_PATTERNS=(
  'Bash(~/.claude/skills/session-closure/scripts/*)'
  'Bash(~/.claude/skills/session-resume/scripts/*)'
)

if [ ! -f "$SETTINGS_FILE" ]; then
  # Create new settings file
  cat > "$SETTINGS_FILE" <<EOF
{
  "permissions": {
    "allow": $REQUIRED_PATTERNS,
    "deny": [],
    "ask": []
  }
}
EOF
  echo "✅ Created $SETTINGS_FILE with session-skills permissions"
else
  # Merge with existing file using jq
  if command -v jq >/dev/null 2>&1; then
    # Parse required patterns as JSON array
    REQUIRED_JSON=$(echo "$REQUIRED_PATTERNS" | jq -c '.')

    # Read existing permissions, add new ones, remove old ones, deduplicate
    jq --argjson new "$REQUIRED_JSON" \
       '.permissions.allow = ([.permissions.allow[], $new[]] | unique) |
        .permissions.allow -= ["Bash(~/.claude/skills/session-closure/scripts/*)", "Bash(~/.claude/skills/session-resume/scripts/*)"]' \
       "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

    echo "✅ Updated $SETTINGS_FILE with session-skills permissions"
  else
    echo "⚠️  jq not found - manual merge required"
    echo "Add these patterns to permissions.allow array:"
    echo "$REQUIRED_PATTERNS"
  fi
fi
```

**After configuration**:
- Proceed to Step 0.5 (uncommitted changes check)
- Future sessions will skip this step (permissions already configured)

**Error handling**:
- Script not found: Display error, proceed with warning (user will get permission prompts)
- Script fails: Display error, proceed with warning
- User declines: Proceed anyway (user will approve permissions interactively)

---

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
"${SKILL_BASE:-$HOME/.claude/skills/session-resume}/scripts/check_uncommitted_changes.sh" "${PROJECT_ROOT:-$PWD}"
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
   "${SKILL_BASE:-$HOME/.claude/skills/session-resume}/scripts/list_archives.sh" "${PROJECT_ROOT:-$PWD}" --format detailed
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

### Step 2: Load and Analyze Resume

1. **Read CLAUDE_RESUME.md** completely

2. **Extract key sections**:
   - Last Activity Completed
   - Pending Tasks (with count)
   - **Project Status** (if present - v1.2.0+)
   - **Sync Status** (if present - v1.2.0+)
   - **Pending Outbound Handoffs** (if present - v1.3.0+)
   - Next Session Focus
   - Key Decisions (if present)
   - Insights & Learnings (if present)

3. **Check Sync Status** (if present):
   - If sync dates are >7 days old: Warn user
   - If "current": Note that sources are up-to-date
   - If missing: No sync concerns

4. **Check Pending Outbound Handoffs** (if present):
   - Note any handoffs awaiting response
   - Flag handoffs sent >7 days ago as possibly stale

### Step 3: Present Resume Summary

Present the resume to the user:

```markdown
📋 Resuming from [Date] session:

[If Project Status present:]
**Project**: [Project name from resume title]
**Status**: [State emoji + description from Project Status]

**Last activity**: [One-line summary from resume]

[If Sync Status present and has stale dates:]
⚠️  Authoritative sources may need syncing:
- [Source]: Last synced [date] ([N] days ago)

[If Pending Outbound Handoffs present:]
📤 **Pending outbound handoffs**:
- [Destination]: [Summary] (sent [date], [N] days ago)
[If any >7 days: ⚠️ May need follow-up]

**Next focus**: [From "Next Session Focus" section]

**Pending tasks**: [Count] tasks remaining
[List top 3-5 tasks]

[If Key Decisions present: Highlight 1-2 key decisions]

Full context loaded. Ready to continue.
```

### Step 4: Optional Actions

After presenting resume, offer:

1. **Archive option** (if desired):
   ```markdown
   Would you like to archive this resume to keep project clean?
   (Moves to archives/CLAUDE_RESUME/ with timestamp)
   ```

2. **Ready to work**:
   ```markdown
   Ready to continue where you left off!
   ```


## Git Commit Protocol

See **CORE_PROCESSES.md § Git Commit Protocol** for complete requirements.

**Quick reference**:
- Required: `git commit -S -s -m "message"`
- Never: Claude attribution (hook enforced)
- Always: Request user approval before committing

**Hook enforcement** (`~/.claude/hooks/`):

| Hook | Enforces |
|------|----------|
| git-commit-compliance.py | -S -s flags, message quality (≥10 chars), no attribution |
| git-workflow-guidance.py | Separate git add from git commit |

**Workflow when Step 0.5 blocks**:
1. `git status` - See what's changed
2. `git diff` - Understand changes
3. `git add <files>` - Stage specific changes
4. `git diff --staged` - Review staged changes
5. `git commit -S -s -m "..."` - Commit with descriptive message

---

## Additional Documentation

- **references/README.md** - Installation, usage examples, and workflow integration
- **references/RESUME_FORMAT_v1.3.md** - Resume format specification (required reading)
- **references/CONTRIBUTING.md** - Development, testing, and contribution guide

---

*Session-resume skill v1.5.0 - Added Pending Outbound Handoffs recognition (December 2025)*
