# Configuration Guide - session-resume

This document provides configuration and setup instructions for the session-resume skill.

---

## Installation Methods

### Method 1: Plugin Installation (Recommended)

```bash
# Add marketplace
/plugin marketplace add ChristopherA/claude_code_tools

# Install plugin
/plugin install session-skills@session-skills
```

Skills install to `~/.claude/skills/` automatically.

---

### Method 2: Manual Installation

```bash
# Clone repository
git clone https://github.com/ChristopherA/claude_code_tools.git

# Copy skill to user directory
cp -r claude_code_tools/skills/session-resume ~/.claude/skills/

# Or copy to project directory
cp -r claude_code_tools/skills/session-resume .claude/skills/
```

---

### Method 3: Symlink (Development)

For developing the skill:

```bash
# Clone repository
git clone https://github.com/ChristopherA/claude_code_tools.git

# Symlink to user directory
ln -s /path/to/claude_code_tools/skills/session-resume ~/.claude/skills/
```

Changes to skill immediately available.

---

## Hook Integration

### SessionStart Notification (Optional)

Automatically notify user about available resume when starting a session.

**Add to `~/.claude/settings.json`**:
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

**Behavior**:
- Shows current date on session start
- If CLAUDE_RESUME.md exists, shows notification
- User can type "resume" to load context
- Non-intrusive (doesn't auto-invoke skill)

**User workflow**:
```
Session starts
📅 Today is Wednesday, November 05, 2025

📋 Previous session available. Say "resume" to continue.

User: resume
[session-resume executes]
```

---

### Combined with session-closure

**Complete hooks configuration**:
```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "date +'📅 Today is %A, %B %d, %Y' && ([ -f CLAUDE_RESUME.md ] && echo '\\n📋 Previous session available. Say \"resume\" to continue.' || true)"
    }],
    "SessionEnd": [{
      "type": "skill",
      "skill": "session-closure"
    }]
  }
}
```

**Workflow**:
1. Session ends → session-closure creates resume
2. Session starts → Notification shown
3. User says "resume" → session-resume loads context
4. Complete continuity ✅

---

## Trigger Customization

### Default Triggers

Skill activates on explicit user requests only:
- "resume"
- "load resume"
- "continue from last session"
- "what was I working on"
- "show previous session"
- "previous context"
- "load context"

### Never Auto-Invokes

**Critical**: This skill NEVER triggers automatically. It requires explicit user request.

**Why**:
- User controls when to load previous context
- Avoids unwanted context loading
- Clear intentional action
- No surprises

**Doesn't Activate On**:
- Session start (even with hook)
- File existence checks
- "load file" or "read document" (file operations)
- General project questions
- Mid-session context switches

---

## Resume File Location

### Default Location

**Path**: `CLAUDE_RESUME.md` (project root)

**Detection**:
- Skill looks in current working directory
- If not found, shows friendly message
- No error if missing (normal for first session)

### Archive Location

**Path**: `archives/CLAUDE_RESUME/<timestamp>.md`

**Archive browsing**:
- Use `list_archives.sh` to see available archives
- Skill shows recent archives if current resume missing
- User can load specific archive by date

---

## Script Configuration

### check_staleness.sh

**Purpose**: Calculate resume age and categorize staleness.

**Staleness Levels**:
- **fresh**: < 1 day old (green indicator)
- **recent**: 1-6 days old (yellow indicator)
- **stale**: 7-29 days old (orange indicator)
- **very_stale**: 30+ days old (red indicator)

**Customization**: Edit thresholds in script if needed:
```bash
# Default thresholds (in days)
FRESH_THRESHOLD=1
RECENT_THRESHOLD=7
STALE_THRESHOLD=30
```

**Cross-platform**: Supports both macOS (BSD) and Linux (GNU) date commands.

---

### list_archives.sh

**Purpose**: List archived resumes sorted by date (newest first).

**Options**:
- `--limit N`: Show only N most recent archives (default: all)
- `--format short`: Show only filenames
- `--format detailed`: Show dates and sizes (default)

**Usage**:
```bash
# List all archives
./scripts/list_archives.sh

# List 5 most recent
./scripts/list_archives.sh --limit 5

# Show only filenames
./scripts/list_archives.sh --format short
```

---

## Multi-Project Coordination

### Project Status Section

For projects that coordinate with other projects:

**When resume includes Project Status**:
```markdown
## Project Status

- **Current State**: 🔄 IN PROGRESS - Database migration complete
- **Key Changes**: Migrated from MySQL to PostgreSQL
- **Next Priority**: Update API endpoints for new schema
- **Dependencies**: Waiting on frontend team to update queries
- **Project Health**: Good - on track for Friday deployment
```

**session-resume behavior**:
- Highlights Project Status section
- Shows dependencies clearly
- Enables inter-project awareness

---

### Sync Status Section

For projects syncing with external authoritative sources:

**When resume includes Sync Status**:
```markdown
## Sync Status

**Authoritative Sources**:
- **API Specification**: https://docs.google.com/document/d/abc123 (synced 2025-11-03)
- **Architecture Decisions**: https://hackmd.io/@team/architecture (synced 2025-11-02)

**Sync Health**: ✅ All sources current
```

**session-resume behavior**:
- Highlights Sync Status section
- Shows when last synced
- Alerts if sources might be stale

---

## User-Level vs Project-Level

### User-Level Configuration

**Location**: `~/.claude/settings.json`

**Use when**:
- You want same behavior across all projects
- Personal workflow preferences
- Always want resume notifications

**Example**:
```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "[ -f CLAUDE_RESUME.md ] && echo '📋 Resume available: say \"resume\"' || true"
    }]
  }
}
```

---

### Project-Level Configuration

**Location**: `.claude/settings.json` (in project directory)

**Use when**:
- Team coordination required
- Project-specific workflow
- Different behavior per project

**Example**:
```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "echo '👥 Team Project: Check CLAUDE_RESUME.md for coordination' && [ -f CLAUDE_RESUME.md ] && echo '📋 Resume available: say \"resume\"' || true"
    }]
  }
}
```

**Commit this file** so team members get same notifications.

---

## Resume Format Support

### Supported Versions

**session-resume recognizes**:
- v1.2.0 format (current)
- v1.1.0 format (legacy, still supported)
- Future versions (forward-compatible)

**Key sections detected**:
- Last Session (date extraction)
- Pending Tasks
- Next Session Focus
- Project Status (optional)
- Sync Status (optional)

---

## Troubleshooting Configuration

### Hook Not Showing Notification

**Check**:
1. Settings file valid JSON: `cat ~/.claude/settings.json | jq`
2. Hook syntax correct
3. CLAUDE_RESUME.md exists: `ls -la CLAUDE_RESUME.md`

**Fix**: Verify JSON format, restart Claude Code.

---

### Skill Not Triggering on "resume"

**Check**:
1. Skill installed: `ls ~/.claude/skills/session-resume`
2. SKILL.md exists: `ls ~/.claude/skills/session-resume/SKILL.md`
3. Using exact trigger phrase: "resume" (not "Resume" or "RESUME")

**Fix**: Reinstall skill if missing.

---

### Scripts Not Found

**Check**:
1. Scripts exist: `ls ~/.claude/skills/session-resume/scripts/`
2. Scripts executable: `ls -la ~/.claude/skills/session-resume/scripts/*.sh`

**Fix**:
```bash
chmod +x ~/.claude/skills/session-resume/scripts/*.sh
```

---

### Cross-Platform Date Issues

**v1.3.0 fix**: check_staleness.sh now supports both macOS and Linux.

**If issues persist**:
1. Check OS detection: `echo $OSTYPE`
2. Test date command: `date +%s`
3. Run script manually: `./scripts/check_staleness.sh`

**macOS**: Uses BSD date (`date -j -f`)
**Linux**: Uses GNU date (`date -d`)

---

## Advanced Configuration

### Custom Archive Location

To use custom archive path, modify `list_archives.sh`:

```bash
# Default
ARCHIVE_DIR="archives/CLAUDE_RESUME"

# Custom
ARCHIVE_DIR="my-custom-path/resumes"
```

**Note**: Requires editing script. Future versions may support config files.

---

### Custom Staleness Thresholds

Edit `check_staleness.sh` to adjust staleness categories:

```bash
# Current thresholds
AGE_DAYS=$(( (TODAY - SESSION_EPOCH) / 86400 ))

if [ "$AGE_DAYS" -lt 1 ]; then
    echo "fresh"
elif [ "$AGE_DAYS" -lt 7 ]; then
    echo "recent"
elif [ "$AGE_DAYS" -lt 30 ]; then
    echo "stale"
else
    echo "very_stale"
fi
```

**Example customization** (more aggressive staleness):
```bash
if [ "$AGE_DAYS" -lt 1 ]; then
    echo "fresh"
elif [ "$AGE_DAYS" -lt 3 ]; then      # Changed: 7 → 3
    echo "recent"
elif [ "$AGE_DAYS" -lt 14 ]; then     # Changed: 30 → 14
    echo "stale"
else
    echo "very_stale"
fi
```

---

*Configuration guide for session-resume v1.3.0*
