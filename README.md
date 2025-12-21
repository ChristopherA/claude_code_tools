# Claude Code Tools

A collection of Claude Code skills for enhanced development workflows.

## Overview

This repository provides multiple skills for Claude Code:

**Session Management** (`session-skills` plugin):
- **session-closure**: Creates detailed session resumes when ending a session
- **session-resume**: Loads and presents previous session context when starting a new session
- **session-cleanup**: Adaptive session audit before closure with depth calibration

**Git Worktree Operations** (`git-worktree` plugin):
- **git-worktree**: Interactive git worktree management - clone, convert, create, list, remove, troubleshoot

## Features

### Session Skills
- Automatic session resumes with project status tracking
- Intelligent archiving with git-aware logic
- Staleness detection and warnings
- Full, minimal, and emergency modes
- Pre-closure cleanup with depth calibration (light/standard/thorough)
- Project-specific cleanup checklists

### Git Worktree Skill
- Clone repos directly into worktree form
- Convert existing repos to worktree structure
- Create/list/remove worktrees for branches
- Troubleshoot common worktree issues
- WORKTREES/GITHUB/{owner}/{repo}/ workspace pattern

### Common Features
- Executable scripts for consistency
- Progressive disclosure architecture
- Cross-platform support (macOS + Linux)
- Comprehensive test suites

## Installation

### Option 1: Plugin Installation (Recommended)

```bash
# Add this marketplace
/plugin marketplace add ChristopherA/claude_code_tools

# Install individual plugins
/plugin install session-skills@claude-code-tools
/plugin install git-worktree@claude-code-tools
```

### Option 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/ChristopherA/claude_code_tools.git

# Copy session skills
cp -r claude_code_tools/skills/session-closure ~/.claude/skills/
cp -r claude_code_tools/skills/session-resume ~/.claude/skills/
cp -r claude_code_tools/skills/session-cleanup ~/.claude/skills/

# Copy git-worktree skill
cp -r claude_code_tools/skills/git-worktree ~/.claude/skills/
```

## Quick Start

### Git Worktree Operations

```
User: clone worktree from https://github.com/owner/repo

Claude: This will create:
  ~/WORKTREES/GITHUB/owner/repo/
  ├── repo.git/   (bare repository)
  └── main/       (main branch worktree)

Proceed? [Y/n]

✅ Cloned into worktree form
cd ~/WORKTREES/GITHUB/owner/repo/main
```

Other commands:
- "convert to worktree" - Convert current repo
- "create worktree for feature/auth" - Add branch worktree
- "list worktrees" - Show all worktrees
- "troubleshoot worktrees" - Fix common issues

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

### git-worktree v1.0.0

**Triggers**:
- "clone worktree from {url}", "get worktree from {repo}"
- "convert to worktree"
- "create worktree for {branch}"
- "list worktrees", "remove worktree {name}"
- "troubleshoot worktrees", "validate worktree"

**Key Features**:
- Clone GitHub repos directly into worktree form
- Convert existing local repos to worktree structure
- Create/list/remove worktrees for branches
- Troubleshoot common issues (core.bare, stale entries, broken links)
- WORKTREES/GITHUB/{owner}/{repo}/ workspace pattern
- Inception commit detection (Open Integrity pattern)

**Scripts** (10 total):
- `clone-as-worktree.sh` - Clone into worktree form
- `convert-to-worktree.sh` - Convert existing repo
- `create-worktree.sh` - Add worktree for branch
- `list-worktrees.sh` - Show worktrees with status
- `remove-worktree.sh` - Safely remove worktree
- `troubleshoot.sh` - Diagnose and fix issues
- Plus 4 utility scripts (detect-repo-type, extract-owner, detect-inception, validate-setup)

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

### session-cleanup v1.1.0

**Triggers**:
- "session cleanup", "session review", "audit session"
- "pre-closure check", "cleanup"

**Key Features**:
- Adaptive depth calibration based on session complexity
- Automated checks: permissions, uncommitted changes, complexity
- Structured ultrathink with category hints
- Project-specific local cleanup support
- Seamless handoff to session-closure

**Scripts**:
- `check_permissions.sh` - One-time permission verification
- `check_uncommitted_changes.sh` - Git state validation
- `detect_complexity.sh` - Session depth calibration
- `find_local_cleanup.sh` - Local cleanup file detection

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

### Guides
- **[guides/](./guides/)** - Practical workflow tutorials
  - [Solo Workflow](./guides/solo-workflow.md) - Individual developer workflow
  - [Team Workflow](./guides/team-workflow.md) - Team collaboration with git

### Skill Documentation

**git-worktree**: See `skills/git-worktree/` for:
- SKILL.md - Complete skill documentation
- references/troubleshooting.md - Advanced troubleshooting guide

**session-closure**: See `skills/session-closure/references/` for:
- README.md - Installation and usage
- CONTRIBUTING.md - Development guide
- PERMISSIONS.md - Permission configuration
- RESUME_FORMAT_v1.2.md - Resume format specification

**session-resume**: See `skills/session-resume/references/` for:
- README.md - Installation and usage
- CONTRIBUTING.md - Development guide
- RESUME_FORMAT_v1.2.md - Resume format specification

**session-cleanup**: See `skills/session-cleanup/references/` for:
- README.md - Installation and usage
- CONTRIBUTING.md - Developer guide with script documentation
- LOCAL_TEMPLATE.md - Template for project-specific cleanup

## Versions

**Current**: v1.6.0 (December 20, 2025)

**What's New in v1.6.0**:
- **NEW**: session-cleanup skill - Adaptive session audit before closure
  - Depth calibration (light/standard/thorough)
  - Automated pre-closure checks
  - Structured ultrathink with category hints
  - Project-specific local cleanup support
  - 4 executable scripts, 8 automated tests

**Previous (v1.5.0)**:
- git-worktree skill - Interactive git worktree management
- Repository renamed to "claude-code-tools"

**Previous (v1.4.0)**:
- Git hooks enforcement (`~/.claude/hooks/git-commit-compliance.py`)
- Consolidated Git Commit Protocol (hooks + CORE_PROCESSES.md)
- 34 automated tests (skills + hooks)
- Working directory fixes - scripts work from any directory
- Progressive disclosure architecture (76% token reduction)
- Cross-platform support (macOS + Linux)
- BSD-2-Clause-Patent LICENSE

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

**Need help?** In Claude Code, try:
- "clone worktree from https://github.com/owner/repo"
- "convert to worktree"
- "close context" or "resume"
