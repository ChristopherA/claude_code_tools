# Claude Code Session Skills

Session continuity skills for Claude Code - maintain context across coding sessions with intelligent resume creation and loading.

## Overview

This plugin provides two complementary skills that work together to preserve your work context across Claude Code sessions:

- **session-closure**: Creates detailed session resumes when ending a session
- **session-resume**: Loads and presents previous session context when starting a new session

## Features

✅ **Automatic Session Resumes** - Capture what you accomplished, what's pending, and what to focus on next
✅ **Project Status Tracking** - Inter-project communication and coordination
✅ **Sync Status** - Track authoritative sources (Google Docs, HackMD, GitHub)
✅ **Intelligent Archiving** - Automatic resume archiving with git-aware logic
✅ **Staleness Detection** - Warns when resuming from old sessions
✅ **Full & Minimal Modes** - Adapts to available context budget
✅ **Executable Scripts** - Consistent, tested, token-efficient operations
✅ **Comprehensive Testing** - 20 automated tests ensure reliability

## Installation

### Option 1: Plugin Installation (Recommended)

```bash
# Add this marketplace
/plugin marketplace add ChristopherA/claude_code_tools

# Install the session-skills plugin
/plugin install session-skills@session-skills
```

### Option 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/ChristopherA/claude_code_tools.git

# Copy skills to your Claude Code skills directory
cp -r claude_code_tools/skills/session-closure ~/.claude/skills/
cp -r claude_code_tools/skills/session-resume ~/.claude/skills/
```

## Quick Start

### Ending a Session

When you're ready to end your coding session:

```
User: close context
```

Claude will:
1. Archive any previous resume
2. Analyze your session
3. Create a structured CLAUDE_RESUME.md with:
   - What you accomplished
   - Pending tasks
   - Key decisions made
   - Next session focus
   - Project status
   - Sync status (if applicable)

### Starting a New Session

When you return to work:

```
User: resume
```

Claude will:
1. Load CLAUDE_RESUME.md
2. Check for staleness
3. Present summary with:
   - Last activity
   - Next focus
   - Pending tasks (with count)
   - Project status
4. Ready you to continue where you left off

## Skills Included

### session-closure v1.2.0

**Triggers**:
- "close context", "end session", "prepare to stop"
- Context approaching 170k tokens (proactive)
- SessionEnd hook (automatic on /exit)

**Key Features**:
- Full mode: Complete analysis and detailed resume
- Minimal mode: Essential state when context limited
- Emergency mode: Output to chat when critically low
- Git-aware archiving (skips if tracked in git)
- Resume validation with format checking
- Project Status section (inter-project communication)
- Sync Status section (authoritative source tracking)

**Scripts**:
- `archive_resume.sh` - Intelligent resume archiving
- `validate_resume.sh` - Format validation

### session-resume v1.2.1

**Triggers**:
- "resume", "load resume", "continue from last session"
- "what was I working on", "show previous session"

**Key Features**:
- Staleness detection with warnings
- Archive browsing and loading
- Project Status recognition
- Sync Status recognition
- Multiple resume format support (v1.1.0, v1.2.0)

**Scripts**:
- `check_staleness.sh` - Calculate resume age
- `list_archives.sh` - Discover archived sessions

## Usage Examples

### Daily Workflow

**End of day**:
```
User: We've made good progress on the authentication feature. Close context.

Claude: [Archives previous resume]
Creating session resume...

✅ Resume created: CLAUDE_RESUME.md

**Last activity**: Implemented JWT authentication with refresh tokens

**Next focus**: Add rate limiting and write integration tests

**Pending**: 3 tasks remaining
- Add rate limiting middleware
- Write integration tests for auth flow
- Update API documentation

Resume saved. See you next session!
```

**Next morning**:
```
User: resume

Claude: 📋 Resuming from November 3, 2025 session:

**Project**: auth-service
**Status**: 🔄 IN PROGRESS - JWT implementation complete, testing pending

**Last activity**: Implemented JWT authentication with refresh tokens

**Next focus**: Add rate limiting and write integration tests

**Pending tasks**: 3 tasks remaining
- Add rate limiting middleware
- Write integration tests for auth flow
- Update API documentation

Full context loaded. Ready to continue!
```

### Multi-Project Coordination

With Project Status section, coordinate across projects:

```markdown
## Project Status

- **Current State**: 🔄 TESTING - Core features complete, integration tests in progress
- **Key Changes**: Implemented OAuth2 flow, migrated from sessions to JWT
- **Next Priority**: Complete integration tests, then deploy to staging
- **Dependencies**: Waiting on database migration approval from DBA team
- **Project Health**: Good - on track for Friday release
```

Other project contexts can read this status to understand dependencies.

### Working with Authoritative Sources

When syncing with external docs:

```markdown
## Sync Status

**Authoritative Sources**:
- **API Specification**: https://docs.google.com/document/d/abc123 (synced 2025-11-03)
- **Architecture Decisions**: https://hackmd.io/@team/architecture (synced 2025-11-02)
- **Project Board**: https://github.com/org/repo/projects/1 (synced 2025-11-03)

**Sync Health**: ✅ All sources current
```

Claude will warn if sources become stale (>7 days old).

## Testing

Both skills include comprehensive test suites:

```bash
# Test session-closure
cd skills/session-closure/tests
./test_scripts.sh

# Test session-resume
cd skills/session-resume/tests
./test_scripts.sh
```

Expected: All tests passing (6 tests with 12 assertions for session-closure, 8 tests for session-resume)

## Resume Format

Resumes are created in markdown format with these sections:

**Required**:
- Header (date, duration, status)
- Last Activity Completed
- Pending Tasks
- Session Summary
- Next Session Focus

**Optional** (v1.2.0+):
- Project Status (inter-project communication)
- Sync Status (authoritative source tracking)
- Key Decisions Made
- Insights & Learnings

**Modes**:
- Full mode: All sections, detailed content
- Minimal mode: Essential sections, abbreviated content
- Emergency mode: Template output to chat

For complete format specification, see `skills/session-closure/references/RESUME_FORMAT_v1.2.md`

## Configuration

### SessionEnd Hook (Recommended)

Automatically trigger session-closure on /exit:

Add to `~/.claude/settings.json`:
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

Or combine with custom command:
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

### SessionStart Hook (Recommended)

Show reminder about resume availability:

Add to `~/.claude/settings.json`:
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

## Requirements

- Claude Code (latest version recommended)
- Bash shell (for scripts)
- Git (optional, for git-aware archiving)

## Architecture

Both skills follow best practices:

- **Executable Scripts**: Consistent, tested, token-efficient
- **Progressive Disclosure**: Core logic in SKILL.md, details in references/
- **Automated Testing**: All scripts validated by test suites
- **Format Validation**: Resume structure verified before writing
- **Error Handling**: Graceful degradation and clear error messages

## Documentation

### Core Documentation
- **[CHANGELOG.md](./CHANGELOG.md)** - Version history and release notes
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Contribution guidelines and development setup
- **[PHASE_2_COMPLETE.md](./PHASE_2_COMPLETE.md)** - v1.3.0 implementation details

### Examples
- **[examples/](./examples/)** - Real-world workflow examples
  - [Daily Workflow](./examples/daily-workflow.md) - Individual developer workflow
  - [Team Coordination](./examples/team-coordination.md) - Team collaboration workflow

### Skill-Specific Documentation

**session-closure**: See `skills/session-closure/references/` for:
- CONFIGURATION.md - Setup and hooks
- TESTING.md - Test procedures
- DEVELOPMENT.md - Script documentation
- DESIGN_DECISIONS.md - Architecture rationale
- IMPLEMENTATION_DETAILS.md - Technical details
- TROUBLESHOOTING.md - Common issues

**session-resume**: See `skills/session-resume/references/` for:
- CONFIGURATION.md - Setup and hooks
- TESTING.md - Test procedures
- DEVELOPMENT.md - Script documentation
- DESIGN_DECISIONS.md - Architecture rationale
- EXAMPLES.md - 13 usage scenarios
- ROADMAP.md - Future enhancements

## Versions

**Current**: v1.3.1 (November 7, 2025)

**Key Features**:
- **NEW**: Working directory fixes - scripts work from any directory
- **NEW**: Git backup step - automatic session state backup
- Progressive disclosure architecture (76% token reduction)
- Cross-platform support (macOS + Linux)
- 12 reference files (4,200 lines on-demand documentation)
- BSD-2-Clause-Patent LICENSE
- 14 tests (20 assertions) all passing

See [CHANGELOG.md](./CHANGELOG.md) for complete version history.

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

**Quick links**:
- Issues: https://github.com/ChristopherA/claude_code_tools/issues
- Pull Requests: https://github.com/ChristopherA/claude_code_tools/pulls
- Discussions: https://github.com/ChristopherA/claude_code_tools/discussions

## License

BSD-2-Clause-Patent License - see [LICENSE](./LICENSE) file for details

## Author

Christopher Allen (ChristopherA@LifeWithAlacrity.com)

## Acknowledgments

Built following [Anthropic's Agent Skills best practices](https://github.com/anthropics/skills) and [Claude Code documentation](https://docs.claude.com/en/docs/claude-code/skills).

---

**Need help?** Say "How do I use session-closure?" or "How do I use session-resume?" in Claude Code.
