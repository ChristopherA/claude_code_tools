# Configuration Guide - session-closure

This document provides configuration and setup instructions for the session-closure skill.

---

## Archive Structure

### Default Archive Location

**Path**: `archives/CLAUDE_RESUME/<timestamp>.md`

**Why this location**:
- One `archives/` directory at project root
- Organized by type (CLAUDE_RESUME, future: transcripts, etc.)
- Extensible pattern for other archive types
- Simple .gitignore: just `archives/`

**Timestamp format**: `YYYY-MM-DD-HHMM` (e.g., `2025-11-04-1430.md`)

**Example structure**:
```
project-root/
├── CLAUDE_RESUME.md              # Current session resume
├── archives/
│   └── CLAUDE_RESUME/            # Resume archives
│       ├── 2025-11-04-1430.md    # Session from Nov 4, 2:30 PM
│       ├── 2025-11-03-1615.md    # Session from Nov 3, 4:15 PM
│       └── 2025-11-02-0945.md    # Session from Nov 2, 9:45 AM
├── CLAUDE.md                     # Project context (if used)
└── .gitignore                    # Excludes ephemeral files
```

---

## Recommended .gitignore

Add these patterns to your project's `.gitignore`:

```gitignore
# Claude session state (personal, ephemeral)
CLAUDE_RESUME.md

# All project archives (session resumes, transcripts, etc.)
archives/
```

**Rationale**:
- `CLAUDE_RESUME.md` is personal work state, not project code
- Archives are historical snapshots, not needed in git
- Keeps repository clean and focused on code

**Exception**: Some projects track `CLAUDE_RESUME.md` in git for coordination. In this case:
```gitignore
# Track resume in git, but exclude archives
archives/
```

---

## Hook Integration

### SessionEnd Hook (Automatic Closure)

Automatically trigger session-closure when exiting Claude Code.

**Add to `~/.claude/settings.json`**:
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

**Behavior**:
- User types `/exit` or `/compact`
- session-closure runs automatically
- Resume created before session ends
- No manual "close context" needed

**User workflow**:
```
1. User: /exit
2. Hook triggers session-closure
3. Resume created
4. Session ends
```

---

### Combining with Custom Commands

Run custom command before skill:

```json
{
  "hooks": {
    "SessionEnd": [{
      "type": "command",
      "command": "echo '👋 Session ending...'"
    }, {
      "type": "skill",
      "skill": "session-closure"
    }]
  }
}
```

**Output**:
```
👋 Session ending...
[session-closure executes]
✅ Session closure complete.
...
```

---

### User-Level vs Project-Level

**User-level** (`~/.claude/settings.json`):
- Applies to all projects
- Good for consistent workflow
- Install skill at `~/.claude/skills/session-closure`

**Project-level** (`.claude/settings.json`):
- Applies only to specific project
- Good for team coordination
- Include settings in git for team

**Example project-level**:
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

Commit this file so team members get automatic closure.

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
cp -r claude_code_tools/skills/session-closure ~/.claude/skills/

# Or copy to project directory
cp -r claude_code_tools/skills/session-closure .claude/skills/
```

---

### Method 3: Symlink (Development)

For developing the skill:

```bash
# Clone repository
git clone https://github.com/ChristopherA/claude_code_tools.git

# Symlink to user directory
ln -s /path/to/claude_code_tools/skills/session-closure ~/.claude/skills/
```

Changes to skill immediately available.

---

## Configuration Options

### Archive Location (Advanced)

To customize archive location, modify `scripts/archive_resume.sh`:

```bash
# Default
ARCHIVE_DIR="archives/CLAUDE_RESUME"

# Custom
ARCHIVE_DIR="my-custom-path/resumes"
```

**Note**: This requires editing the script. Future versions may support configuration files.

---

### Resume Format Customization

Resume format is defined in `Step 3: Create CLAUDE_RESUME.md` in SKILL.md.

To customize for your workflow:
1. Copy skill to project: `.claude/skills/session-closure/`
2. Edit `SKILL.md` Step 3
3. Modify template sections

**Example customizations**:
- Add "Test Status" section for development projects
- Add "Review Cycle" section for policy projects
- Add "Design Notes" section for creative projects

See `references/RESUME_FORMAT_v1.2.md` for complete format specification.

---

## Multi-Project Coordination

### Using Project Status Section

For projects that coordinate with other projects:

**Enable Project Status** (always included):
```markdown
## Project Status

- **Current State**: 🔄 IN PROGRESS - Database migration complete
- **Key Changes**: Migrated from MySQL to PostgreSQL
- **Next Priority**: Update API endpoints for new schema
- **Dependencies**: Waiting on frontend team to update queries
- **Project Health**: Good - on track for Friday deployment
```

Other projects can read this to understand dependencies.

---

### Using Sync Status Section

For projects syncing with external authoritative sources:

**When to include**:
- Project has Google Docs as master
- Project has HackMD as master
- Local markdown synced from external

**Example**:
```markdown
## Sync Status

**Authoritative Sources**:
- **API Specification**: https://docs.google.com/document/d/abc123 (synced 2025-11-03)
- **Architecture Decisions**: https://hackmd.io/@team/architecture (synced 2025-11-02)

**Sync Health**: ✅ All sources current
```

**When to omit**:
- Everything is local/git only
- No external authoritative sources

---

## Trigger Customization

### Default Triggers

Skill activates on:
- "close context"
- "end session"
- "prepare to stop"
- "save state"
- "create resume"
- Context approaching 170k tokens (proactive)
- SessionEnd hook (if configured)

### Doesn't Activate On

- "save file" (file operation)
- "save draft" (work in progress)
- Mid-conversation pauses
- Temporary checkpoints

**Customization**: To modify triggers, edit frontmatter description in SKILL.md.

---

## Integration with session-resume

session-closure pairs with session-resume for complete continuity.

**Recommended workflow**:

1. **SessionEnd hook** → session-closure (automatic)
2. **SessionStart hook** → Notification about resume
3. User says "resume" → session-resume loads context

**SessionStart hook configuration**:
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

---

## Troubleshooting Configuration

### Hook Not Triggering

**Check**:
1. Settings file valid JSON: `cat ~/.claude/settings.json | jq`
2. Skill installed: `ls ~/.claude/skills/session-closure`
3. Hook syntax correct

**Fix**: Verify JSON format, restart Claude Code.

---

### Archives Directory Not Created

**Check**:
1. Script has execute permission: `ls -la ~/.claude/skills/session-closure/scripts/`
2. Current directory has write permission

**Fix**:
```bash
chmod +x ~/.claude/skills/session-closure/scripts/*.sh
```

---

### Git Detection Not Working

**Check**:
1. Git installed: `which git`
2. Repository initialized: `git status`
3. File tracked: `git ls-files CLAUDE_RESUME.md`

**Fix**: Install git or initialize repository.

---

*Configuration guide for session-closure v1.3.0*
