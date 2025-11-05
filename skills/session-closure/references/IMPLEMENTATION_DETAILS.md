# Implementation Details - session-closure

This document provides technical implementation details for the session-closure skill.

---

## Context Limit Handling

### Proactive Trigger at ~170k Tokens

**Buffer Calculation**:
```
Total context: 200k tokens
- session-closure execution: ~7.5k
- Resume creation: ~5k
- File operations: ~2k
- Safety margin: ~15.5k
= 30k buffer needed
→ Trigger at 170k tokens
```

**Behavior**:
- Claude monitors context usage during session
- At ~170k tokens, suggests: "Context getting full, shall I close now?"
- User can accept or decline
- If declined, user can manually trigger later

**Why 170k**:
- Leaves enough buffer for complete closure execution
- Prevents emergency mode (critically low context)
- Ensures Full Mode resume creation possible

**Mode selection logic**:
```
if context_remaining > 30k:
    mode = "Full"
elif context_remaining > 10k:
    mode = "Minimal"
else:
    mode = "Emergency"
```

---

## Git Tracking Behavior

### Three Cases Handled

**Case 1: Non-git project**
- Detection: `.git` directory doesn't exist
- Behavior: Always archive to `archives/CLAUDE_RESUME/`
- Rationale: No git history, archive provides backup

**Case 2: Git project, resume not tracked**
- Detection: `git ls-files --error-unmatch CLAUDE_RESUME.md` fails (exit code 1)
- Behavior: Archive to `archives/CLAUDE_RESUME/`
- Rationale: File not in git history, archive provides backup

**Case 3: Git project, resume tracked**
- Detection: `git ls-files --error-unmatch CLAUDE_RESUME.md` succeeds (exit code 0)
- Behavior: Skip archiving, show message "Resume tracked in git - skipping archive"
- Rationale: Git history preserves all versions, no separate archive needed

### Detection Implementation

**Script**: `scripts/archive_resume.sh`

**Logic**:
```bash
# Check if file is tracked in git
if git ls-files --error-unmatch CLAUDE_RESUME.md >/dev/null 2>&1; then
    # File is tracked
    echo "✓ Resume tracked in git - skipping archive"
    exit 0
else
    # File not tracked (or not in git repo)
    # Proceed with archiving
    TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
    mkdir -p archives/CLAUDE_RESUME
    mv CLAUDE_RESUME.md "archives/CLAUDE_RESUME/$TIMESTAMP.md"
    echo "📦 Archived to archives/CLAUDE_RESUME/$TIMESTAMP.md"
    exit 0
fi
```

**Why this approach**:
- `git ls-files` only lists tracked files
- `--error-unmatch` returns non-zero if file not tracked
- Redirecting stderr (`2>&1`) suppresses error messages
- Works even if not in git repository (command fails gracefully)

---

## Operational Mode Logic

### Mode Determination (Step 0)

**Full Mode** (>30k tokens remaining):
- Complete session analysis
- All resume sections fully populated
- Detailed insights and learnings
- Archive with full provenance
- **Token usage**: ~7.5k

**Minimal Mode** (<30k tokens remaining):
- Essential state only
- Abbreviated sections
- Critical information only
- Archive with basic provenance
- Notification: "⚠️ Limited context - creating essential resume"
- **Token usage**: ~3k

**Emergency Mode** (critically low):
- Output resume template to chat
- User manually saves from conversation
- Notification: "❌ Insufficient context for file creation - please save from chat"
- **Token usage**: ~1k

### Context Budget Monitoring

**How Claude checks**:
- Internal token counter available to Claude
- Checked at skill invocation
- Determines which mode to use

**Selection logic**:
```python
context_remaining = 200000 - context_used

if context_remaining > 30000:
    mode = "Full"
    message = None  # No warning needed
elif context_remaining > 10000:
    mode = "Minimal"
    message = "⚠️ Limited context - creating essential resume"
else:
    mode = "Emergency"
    message = "❌ Insufficient context for file creation - please save from chat"
```

---

## Resume Creation Process

### Section Population Strategy

**Full Mode**:
1. Analyze entire conversation history
2. Extract key decisions (look for decision points)
3. Identify insights (patterns, learnings)
4. Summarize work completed
5. List pending tasks (from conversation + TodoWrite)
6. Determine next priority
7. Assess project health

**Minimal Mode**:
1. Brief summary (1-2 sentences)
2. Critical pending tasks only (top 3)
3. Essential next step
4. Minimal project status

**Emergency Mode**:
1. Template with placeholders
2. User fills in from memory
3. Better than nothing

---

## Validation Logic

### Resume Structure Validation

**Script**: `scripts/validate_resume.sh`

**Required sections** (checked in order):
1. "Last Session" - Header with date
2. "Last Activity" - What was completed
3. "Pending" - Tasks remaining
4. "Next Session Focus" - What to do next
5. Footer with "Resume created by session-closure"

**Validation process**:
```bash
#!/bin/bash
RESUME="${1:-CLAUDE_RESUME.md}"
MISSING_SECTIONS=""

# Check file exists
if [ ! -f "$RESUME" ]; then
    echo "❌ Resume file not found: $RESUME"
    exit 2
fi

# Check each section
if ! grep -qi "Last Session" "$RESUME"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- Last Session header"
fi

if ! grep -qi "Last Activity" "$RESUME"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- Last Activity section"
fi

if ! grep -qi "Pending" "$RESUME"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- Pending section"
fi

if ! grep -qi "Next Session Focus" "$RESUME"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- Next Session Focus section"
fi

if ! grep -q "Resume created by session-closure" "$RESUME"; then
    MISSING_SECTIONS="$MISSING_SECTIONS\n- Footer with version"
fi

# Report results
if [ -z "$MISSING_SECTIONS" ]; then
    echo "✅ Resume validation passed: $RESUME"
    exit 0
else
    echo "❌ Resume validation failed: Missing sections:"
    echo -e "$MISSING_SECTIONS"
    exit 1
fi
```

**Why case-insensitive** (`-qi`):
- Handles variations in section names
- "Last Activity" vs "last activity" both match
- More robust to minor formatting differences

---

## Archive Timestamp Format

### Timestamp Generation

**Format**: `YYYY-MM-DD-HHMM`
**Example**: `2025-11-04-1430` (November 4, 2025 at 2:30 PM)

**Generation**:
```bash
TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
```

**Why this format**:
- Sortable (alphabetically = chronologically)
- Human-readable
- Filesystem-safe (no special characters)
- Unique per minute (sufficient granularity)
- ISO 8601 compatible (mostly)

**Collision handling**:
- If two closures within same minute: Second overwrites first
- Rare in practice (sessions typically >1 minute)
- Could enhance with seconds if needed: `%Y-%m-%d-%H%M%S`

---

## File Operations

### Archive Move Operation

**Implementation**:
```bash
mkdir -p archives/CLAUDE_RESUME
mv CLAUDE_RESUME.md "archives/CLAUDE_RESUME/$TIMESTAMP.md"
```

**Why `mv` instead of `cp`**:
- Atomic operation (less risk of corruption)
- Faster (no copy, just metadata update)
- Removes source file (clean state for new resume)

**Directory creation** (`mkdir -p`):
- Creates parent directories if needed
- `-p`: No error if directory exists
- Ensures archive directory available

---

## Sync Status Detection

### When to Include Sync Status Section

**Detection logic**:
```bash
# Check for authoritative sources in CLAUDE.md or LOCAL_CONTEXT.md
if grep -i "authoritative\|master\|google docs\|hackmd" CLAUDE.md LOCAL_CONTEXT.md 2>/dev/null; then
    include_sync_status=true
else
    include_sync_status=false
fi
```

**Sources to check**:
- Google Docs URLs
- HackMD URLs
- GitHub URLs (as authoritative master)
- Any "Authoritative Sources" section

**Include if**:
- Project has external authoritative sources
- Local markdown synced from external

**Omit if**:
- Everything is local/git only
- No synchronization workflow

---

## Performance Optimizations

### Script Execution

**archive_resume.sh**:
- File existence check: O(1)
- Git tracking check: O(1) - single git command
- Move operation: O(1) - metadata update only
- Total: <10ms

**validate_resume.sh**:
- File read: O(n) where n = file size
- Section checks: 5 × O(n) grep operations
- Total: <5ms for typical resume (~2KB)

### Token Efficiency

**v1.2.0 approach** (inline documentation):
- All meta-content loaded every invocation
- ~8000 words × 2 skills = ~16k words
- ~24k tokens

**v1.3.0 approach** (progressive disclosure):
- Only task instructions loaded
- ~2000 words × 2 skills = ~4k words
- ~6k tokens
- **75% reduction** in initial load

**On-demand loading**:
- Claude loads references/ only when needed
- "How to configure?" → loads CONFIGURATION.md
- "How to test?" → loads TESTING.md

---

## Error Handling

### Script Failures

**archive_resume.sh**:
- Uses `set -e`: Exits on any error
- Handles missing file gracefully
- Handles non-git directory gracefully
- All outputs go to stdout (not stderr)

**validate_resume.sh**:
- Explicit exit codes:
  - 0: Validation passed
  - 1: Validation failed
  - 2: File not found
- Clear error messages
- Lists all missing sections

### Skill Execution Failures

**Mode degradation**:
- Full Mode fails → Try Minimal Mode
- Minimal Mode fails → Try Emergency Mode
- Emergency Mode → Always works (just template output)

**Validation failure handling**:
- Validation fails → Show which sections missing
- User can fix manually
- Re-run validation
- Don't proceed until valid

---

*Implementation details for session-closure v1.3.0*
