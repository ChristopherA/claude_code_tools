# Changelog

All notable changes to claude-code-tools will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.7.7] - 2026-01-12

### Fixed
- **Issue #15 (CRITICAL)**: hooks.json missing required `"hooks"` wrapper key
  - Plugin hooks were not executing at all
  - Git enforcement (commit compliance, workflow guidance) was completely broken
  - Added required top-level `"hooks"` wrapper per Claude Code schema

---

## [1.7.6] - 2026-01-08

### Fixed
- **Issue #8**: context-monitor README missing required `type` field in statusLine config
  - Added `"type": "command"` to JSON example
- **Issue #6**: archive_resume.sh now checks both root and `.claude/` for CLAUDE.md
  - Previously only checked root, causing confusing warning for projects using `.claude/CLAUDE.md`
- **Issue #7**: Investigated - current code already has correct contextual messaging
  - Shows "Changes found in project files" when CLAUDE_RESUME.md unchanged
  - Issue referenced message from older version, already fixed

### Changed
- **session-cleanup skill v0.5.2**: Added category (h) marketplace validation to ultrathink
- **marketplace.json**: Version 1.7.5 → 1.7.6

### Testing
- session-closure: 10 tests (18 assertions), all passing

---

## [1.7.5] - 2026-01-07

### Fixed
- **Marketplace schema compliance**: Fixed errors preventing plugin installation
  - Error: `Unrecognized key(s) in object: 'tools'` - removed context-monitor from marketplace
  - Error: `hooks.0: Invalid input: must end with ".json"` - added hooks.json wrapper

### Added
- **hooks/hooks.json**: Hook configuration file for plugin system
  - Wraps git-commit-compliance.py and git-workflow-guidance.py
  - Uses `${CLAUDE_PLUGIN_ROOT}` for portable paths
  - Enables `/plugin install git-enforcement-hooks@claude-code-tools`

### Changed
- **marketplace.json**: Version 1.7.4 → 1.7.5
  - Removed context-monitor plugin (no `tools` key in schema - manual install only)
  - Changed git-enforcement-hooks to use `"hooks": "./hooks/hooks.json"`
- **README.md**: Updated installation instructions
  - Added git-enforcement-hooks to plugin install commands
  - Added note about context-monitor requiring manual installation

### Documentation
- hooks/README.md updated with plugin installation option

---

## [1.7.4] - 2026-01-06

### Added
- **hooks/tests/test_hooks.sh**: Automated test suite for git enforcement hooks
  - 13 tests covering: syntax validation, is_git_command() detection, hook behavior
  - Tests for Issue #3 (Python 3.9 compatibility) and Issue #4 (false positives)
  - Follows skill-testing.md methodology

### Changed
- **marketplace.json**: Version 1.7.3 → 1.7.4

### Testing
- hooks: 13 tests (all passing)
  - Python syntax validation (2 tests)
  - is_git_command() true positives (1 test, 10 cases)
  - is_git_command() false positives (1 test, 7 cases)
  - Hook behavior tests (7 tests)
  - Future annotations verification (2 tests)

---

## [1.7.3] - 2026-01-06

### Fixed
- **git-commit-compliance.py**: Python 3.9 compatibility (closes #3)
  - Added `from __future__ import annotations` for PEP 563 deferred evaluation
  - Type hints like `str | None` now work on Python 3.9+
- **git-workflow-guidance.py**: False positive on gh CLI (closes #4)
  - Added `is_git_command()` function to properly detect git commands
  - Now correctly skips `gh issue create --body "git workflow"` style commands
  - Handles shell-wrapped git: `bash -c "git ..."`, `/bin/zsh -c 'git ...'`

### Added
- **git-enforcement-hooks plugin**: Added to marketplace for discoverability (closes #2)
  - git-commit-compliance.py - Enforces -S -s flags, blocks Claude attribution
  - git-workflow-guidance.py - Enforces separate git add/commit workflow

### Changed
- **hooks/README.md**: Updated to document all hooks (Python + Bash)
- **marketplace.json**: Added git-enforcement-hooks plugin, version 1.7.2 → 1.7.3

### Testing
- hooks: No tests (added in v1.7.4)

---

## [1.7.2] - 2026-01-06

### Added
- **context-monitor tool v0.1.0**: Always-visible statusline showing context usage
  - Model display: `[Opus 4.5]`
  - Color thresholds: green >40%, yellow 21-40%, red ≤20% with warning
  - Configurable overhead via `CLAUDE_CONTEXT_OVERHEAD` (default 42000)
  - Optional cost display via `CLAUDE_SHOW_COST` environment variable
  - scripts/status-line.sh with session-specific caching
  - README.md with installation and configuration guide

### Changed
- **session-resume skill v0.5.1**: Dual location support + test coverage (closes #1)
  - Support for `.claude/CLAUDE_RESUME.md` location (preferred over root)
  - Support for `.claude/archives/` archive location
  - Added Step 0.1 pre-check hook mechanism
  - list_archives.sh now searches both archive locations
  - 4 new tests (Tests 9-12) for dual location support

- **session-closure skill v0.5.1**: Dual location support + test coverage
  - Support for `.claude/CLAUDE_RESUME.md` location (preferred over root)
  - archive_resume.sh archives to matching location (.claude/ or root)
  - Added Step 0.1 pre-check hook mechanism
  - 4 new tests (Tests 7-10) for dual location support

- **session-cleanup skill v0.5.1**: Dual location support + test coverage
  - Support for `.claude/processes/local-session-cleanup.md` location
  - Added test coverage category (f) to ultrathink
  - 3 new tests (Tests 9-11) for dual location support

- **marketplace.json**: Added context-monitor plugin, version 1.7.1 → 1.7.2

### Testing
- session-resume: 12 tests (8 original + 4 new)
- session-closure: 10 tests (6 original + 4 new)
- session-cleanup: 11 tests (8 original + 3 new)
- Total: 33 automated tests, all passing

### Documentation
- README.md updated with context-monitor section and installation instructions

---

## [1.7.1] - 2025-12-31

### Fixed
- **git-worktree skill v1.0.1**: False positive in troubleshoot.sh Step 5
  - Bare repositories incorrectly flagged as "missing .git file"
  - Root cause: Bare repos ARE the git directory, they don't have .git files
  - Fix: Skip entries marked "(bare)" in worktree list during integrity check

### Changed
- **git-worktree/scripts/troubleshoot.sh**: Added bare repo detection
- **git-worktree/SKILL.md**: Version 1.0.0 → 1.0.1

### Testing
- Validated with XID-Quickstart worktree setup (6 worktrees)
- Confirmed: "No issues found" for healthy bare repo configurations

---

## [1.7.0] - 2025-12-22

### Added
- **Session-start hooks**: Hook infrastructure for session initialization
  - `hooks/session-start.sh` - PROJECT_ROOT persistence across session
  - `hooks/session-start-git-context.sh` - Git awareness at session start
    - Branch, uncommitted changes, recent commits, stashes, remote status
    - Foundation hook detection (warns if git enforcement hooks not installed)

### Changed
- **marketplace.json**: Updated description to include hooks
- **Version**: 1.6.0 → 1.7.0 (hooks addition)

### Documentation
- Hooks deploy to `~/.claude/hooks/` (different from skills which go to `~/.claude/skills/`)
- Ownership model: session-start hooks owned by session-skills, git-*.py owned by foundation

### Installation
- Skills: `cp -r skills/* ~/.claude/skills/`
- Hooks: `cp hooks/*.sh ~/.claude/hooks/ && chmod +x ~/.claude/hooks/session-start*.sh`

---

## [1.6.0] - 2025-12-20

### Added
- **session-cleanup skill v1.1.0**: Adaptive session audit before closure
  - Automated pre-closure checks: permissions, uncommitted changes, complexity detection
  - Depth calibration: light (0-1 commits), standard (2-5 commits), thorough (6+ commits)
  - Structured ultrathink with category hints for comprehensive session review
  - Project-specific local cleanup support (`claude/processes/local-session-cleanup.md`)
  - 4 executable scripts:
    - check_permissions.sh - One-time permission verification
    - check_uncommitted_changes.sh - Git state validation
    - detect_complexity.sh - Session depth calibration
    - find_local_cleanup.sh - Local cleanup file detection
  - references/README.md - User guide with installation, usage, troubleshooting
  - references/CONTRIBUTING.md - Developer guide with script documentation
  - references/LOCAL_TEMPLATE.md - Template for project-specific cleanup checklists
  - tests/test_session_cleanup.sh - 8 automated tests

### Changed
- **marketplace.json**: Added session-cleanup to session-skills plugin
- **Version**: 1.5.0 → 1.6.0 (new skill addition)

### Documentation
- README.md updated with session-cleanup triggers and features
- Skills Included section expanded with session-cleanup details

### Testing
- session-cleanup skill tested with 8 automated tests
- All scripts validated for non-git and minimal project structures
- Cross-project validation (Tableau project)
- Platform: macOS (Darwin 25.2.0)

### Deployment
- Deployed to: claude_code_tools v1.6.0
- Installation: `/plugin install session-skills@claude-code-tools`
- Manual: `cp -r skills/session-cleanup ~/.claude/skills/`

---

## [1.5.0] - 2025-12-15

### Added
- **git-worktree skill v1.0.0**: Interactive git worktree management
  - Clone repos directly into worktree form (`clone worktree from {url}`)
  - Convert existing repos to worktree structure (`convert to worktree`)
  - Create/list/remove worktrees for branches
  - Troubleshoot common issues (core.bare, stale entries, broken links)
  - WORKTREES/GITHUB/{owner}/{repo}/ workspace pattern
  - Inception commit detection (Open Integrity pattern)
  - 10 executable scripts:
    - clone-as-worktree.sh, convert-to-worktree.sh, create-worktree.sh
    - list-worktrees.sh, remove-worktree.sh, troubleshoot.sh
    - detect-repo-type.sh, extract-owner.sh, detect-inception.sh, validate-setup.sh
  - references/troubleshooting.md for advanced diagnostics

### Changed
- **Marketplace renamed**: `session-skills` → `claude-code-tools`
  - Now a multi-plugin collection
  - session-skills remains as separate plugin within collection
- **marketplace.json updated**: Added git-worktree as new plugin
- **README.md rewritten**: Now documents all skills in collection
- **Version**: 1.4.0 → 1.5.0 (new skill addition)

### Documentation
- README.md updated with git-worktree quick start and features
- Skills Included section expanded with git-worktree details
- Installation instructions updated for both plugins

### Testing
- git-worktree skill tested with 8 evaluation scenarios
- All scripts validated (10 scripts, ~2200 lines total)
- Platform: macOS (Darwin 25.1.0)

### Deployment
- Deployed to: claude_code_tools v1.5.0
- Installation: `/plugin install git-worktree@claude-code-tools`
- Manual: `cp -r skills/git-worktree ~/.claude/skills/`

---

## [1.4.0] - 2025-12-04

### Added
- **Git Hooks**: New `~/.claude/hooks/` enforcement for Git Commit Protocol
  - `git-commit-compliance.py`: Enforces -S -s flags, blocks Claude attribution, validates message quality
  - `git-workflow-guidance.py`: Blocks combined git add + git commit operations
  - `README.md`: Comprehensive hook documentation
  - `tests/test_hooks.sh`: 14 automated tests for hook validation
- **session-closure**: Reference file consolidation (README.md, CONTRIBUTING.md, PERMISSIONS.md)
- **session-resume**: Reference file consolidation (README.md, CONTRIBUTING.md)

### Fixed
- **HEREDOC bypass**: Fixed vulnerability where HEREDOC commit messages bypassed content validation
  - `git-commit-compliance.py`: Now extracts and validates HEREDOC content
  - Blocks prohibited Claude/Anthropic attribution in HEREDOC messages
- **Test scripts**: Updated interface to use PROJECT_ROOT parameter
  - `session-closure/tests/test_scripts.sh`: Fixed 2 failing tests
  - `session-resume/tests/test_scripts.sh`: Fixed 3 failing tests
  - All 34 tests now passing (20 skill tests + 14 hook tests)

### Changed
- **Git Commit Protocol**: Consolidated from skill documentation to hooks + CORE_PROCESSES.md
  - Skills now reference CORE_PROCESSES.md instead of duplicating ~200 lines
  - Hook enforcement replaces documentation-based reminders
- **Documentation**: `examples/` refactored to `guides/`
  - Renamed folder and files for clarity
  - Updated content for v1.4.0 (removed mode references, added hook info)
  - 817 → 345 lines (58% reduction)

### Removed
- **Distribution bloat**: Deleted historical completion documents
  - `PHASE_1_COMPLETE.md` (6.9KB)
  - `PHASE_2_COMPLETE.md` (18.9KB)
  - `archives/` directory (empty placeholder)

### Testing
- All skill scenarios validated (20 tests)
- Hook enforcement validated (14 tests)
- Test coverage: session-closure (12), session-resume (8), hooks (14)
- Platform: macOS (Darwin 25.1.0)

### Deployment
- Deployed to: claude_code_tools v1.4.0
- Hooks location: ~/.claude/hooks/
- Installation: Copy skills to ~/.claude/skills/, hooks to ~/.claude/hooks/

---

## [1.3.8] - 2025-11-15

### Added
- **session-closure**: New `scripts/check_uncommitted_changes.sh` for Step 0.5 blocking
- **session-resume**: New `scripts/check_uncommitted_changes.sh` for Step 0.5 blocking
- **session-resume**: CORE_PROCESSES.md reference in Step 0.5 blocking message

### Fixed
- **Issue 17 (MEDIUM)**: session-resume Step 0.5 inline script permission prompts
  - Extracted 60+ line inline bash to check_uncommitted_changes.sh
  - Single permission entry eliminates repeated approval prompts
  - Consistent with session-closure pattern (Issue 19)
- **Issue 18 (MEDIUM)**: session-resume blocking message missing protocol guidance
  - Added CORE_PROCESSES.md reference to Step 0.5 blocking output
  - Guides users to workspace Git Commit Protocol
  - Maintains correct security model (manual approval required)
- **Issue 19 (MEDIUM)**: session-closure Step 0.5 inline script permission prompts
  - Extracted inline bash to check_uncommitted_changes.sh
  - Matches session-resume Issue 17 pattern
  - Eliminates permission prompts for improved UX

### Changed
- **session-closure**: Updated version to v1.3.8
- **session-resume**: Enhanced Step 0.5 with workspace-aware commit guidance

### Cleanup
- **Deployment-tight philosophy**: Removed bloat documentation files
- **session-closure**: Deleted DESIGN_DECISIONS.md, IMPLEMENTATION_DETAILS.md
- **session-resume**: Deleted DESIGN_DECISIONS.md
- **Size reduction**: 288K → 124K (57% reduction, 164KB removed)
- **Git diff**: 7,511 deletions, 637 insertions
- Skills now execution-focused with essential documentation only

### Testing
- All scenarios validated in user-level skills
- Functional equivalence confirmed post-cleanup
- Both skills tested from project root
- Script references validated
- Platform: macOS (Darwin 25.1.0)

### Deployment
- Deployed to: claude_code_tools v1.3.8
- Installation: Copy to ~/.claude/skills/ or use marketplace

---

## [1.3.7] - 2025-11-14

### Added
- **session-closure**: New `scripts/commit_resume.sh` for automated Step 5 git commits
- **session-closure**: "prepare to close session" trigger phrase (user request)
- **session-closure**: Step 0.5 - Comprehensive uncommitted change detection and handling
- **session-resume**: Step 0.5 - BLOCKING uncommitted change detection (Git Commit Protocol)
- **session-resume**: Contextual messaging for uncommitted changes (resume/project/both)
- **session-resume**: Enhanced SessionStart hook with git dirty state warnings

### Fixed
- **Issue 12 (CRITICAL)**: SKILL_BASE path resolution in session-resume
  - Scripts now use absolute paths via SKILL_BASE environment variable
  - Works from workspace root, project subdirectories, all contexts
  - Resolves "no such file" errors when invoking from workspace roots
- **Issue 15 (CRITICAL)**: Porcelain v2 migration for all git status operations
  - All git operations now use `--porcelain=v2` for reliable machine parsing
  - Eliminates false positives and parsing errors from status output
  - Ensures consistent behavior across git versions
- **Issue 16 (MEDIUM)**: session-closure execution UX improvements
  - Extracted Step 5 auto-commit logic to commit_resume.sh script
  - Enhanced commit message guidance for better git history
  - Clear status indicators throughout closure workflow

### Changed
- **session-closure**: Step 0.5 now detects ALL uncommitted changes (not just resume)
  - Prevents silent commits of unreviewed changes
  - Reviews and explains all changes before committing
  - Critical fix for v1.3.3 flaw (LOCAL_CONTEXT.md committed without review)
- **session-closure/scripts/archive_resume.sh**: Enhanced git status messaging
  - Distinguishes clean vs dirty git state
  - Contextual recommendations for workflow
  - Clear indicators for backup status
- **session-resume**: BLOCKING behavior on uncommitted changes
  - No auto-commit - requires manual Git Commit Protocol compliance
  - Ensures clean session boundaries
  - Prevents mixing previous work with new session

### Improvements
- Professional status indicators throughout both skills (✅ ⚠️ ❌)
- Secret detection warnings for .env, credentials.json, private keys
- Better separation between session work and git checkpoints
- Comprehensive diff display for all uncommitted changes
- Cross-context compatibility (works anywhere in repository)

### Testing
- All Issues 12-16 validated through end-to-end testing
- Complete lifecycle tested: close → exit → start → resume
- SKILL_BASE tested from workspace root and project subdirectories
- Porcelain v2 auto-commit verified in git log
- Step 0.5 blocking behavior confirmed in both skills

### Documentation
- Updated version metadata in all SKILL.md files
- Enhanced Step 0.5 documentation in both skills
- Added SKILL_BASE setup instructions to session-resume
- Deployment notes in commit message

---

## [1.3.6] - 2025-11-13

### Fixed
- **session-resume**: Fixed SKILL_BASE path resolution (Issue 12)
  - Added SKILL_BASE setup in protocol header
  - Scripts now work from any directory context
  - Resolves cross-context compatibility issues

### Added
- **session-resume**: Contextual uncommitted changes messaging
  - Explains what changed: resume edits, project work, or both
  - Professional status indicators
  - Improved workflow clarity

### Changed
- **session-resume**: Updated version to v1.3.6
- **session-resume**: Enhanced Step 0.5 with better UX

---

## [1.3.5] - 2025-11-12

### Added
- **session-closure**: "prepare to close session" trigger phrase
- **session-closure**: Enhanced archive_resume.sh git status messaging

### Changed
- **session-closure**: Step 0.5 now handles ALL uncommitted changes
- **session-closure**: Improved workflow clarity with contextual messages
- **session-closure**: Updated version to v1.3.5

---

## [1.3.4] - 2025-11-12

### Added
- **session-resume**: Step 0.5 BLOCKING behavior for uncommitted changes
  - No auto-commit - requires manual Git Commit Protocol
  - Secret detection warnings
  - Complete change review before resume loads

### Fixed
- **Issue 14 (CRITICAL)**: Auto-commit removed from session-resume
  - Changed from automatic commits to BLOCKING on dirty git state
  - Enforces Git Commit Protocol (explicit user approval)
  - Maintains clean session boundaries

### Changed
- **session-resume**: Updated version to v1.3.4
- **session-resume**: Enhanced Step 0.5 documentation

---

## [1.3.1] - 2025-11-07

### Fixed
- **Issue 1 (CRITICAL)**: Working directory assumptions in session-closure
  - Scripts now accept PROJECT_ROOT parameter passed via $PWD
  - Added project root verification (checks for CLAUDE.md)
  - Scripts cd to project root before operating
  - Fixes resume/archive creation in wrong location when Claude changes working directory
- **Issue 2 (CRITICAL)**: Missing git backup step in session-closure
  - Added Step 5 (Git Backup) between validation and confirmation
  - Checks for git repository before attempting commit
  - Only commits if there are uncommitted changes
  - Prevents data loss by ensuring session state backed up in git
- **Issue 3 (MEDIUM)**: Script path issues in session-resume
  - check_staleness.sh now accepts PROJECT_ROOT parameter
  - list_archives.sh now accepts PROJECT_ROOT parameter
  - Scripts cd to project root before operating
  - Fixes resume loading from any directory

### Changed
- **session-closure/SKILL.md**: Updated to pass $PWD to scripts, added git backup step
- **session-closure/scripts/archive_resume.sh**: Now accepts PROJECT_ROOT parameter (v1.3.0 → v1.3.1)
- **session-closure/scripts/validate_resume.sh**: Now accepts PROJECT_ROOT parameter (v1.3.0 → v1.3.1)
- **session-resume/SKILL.md**: Updated to pass $PWD to scripts
- **session-resume/scripts/check_staleness.sh**: Now accepts PROJECT_ROOT parameter (v1.3.0 → v1.3.1)
- **session-resume/scripts/list_archives.sh**: Now accepts PROJECT_ROOT parameter (v1.3.0 → v1.3.1)

### Resolved (Side-effects of Issue 1 fix)
- **Issue 4 (LOW)**: No error recovery in validation - eliminated by working directory fix
- **Issue 5 (MEDIUM)**: Archive location mismatch - resolved by project root verification
- **Issue 6 (LOW)**: Missing error handling for working directory - resolved by proper error handling

### Testing
- All scenarios tested on macOS 15.0 (Darwin 25.0.0)
- ✅ From project root
- ✅ From subdirectory
- ✅ From different directory
- ✅ Archive creation in non-git directories
- See session-skills-fixes/tests/README.md for detailed test results

---

## [1.3.0] - 2025-11-05

### Added
- **Progressive Disclosure Architecture**: Extracted 4,200 lines of documentation to references/ directories
- **Cross-Platform Support**: macOS + Linux compatibility for date commands
- **BSD-2-Clause-Patent LICENSE**: Legal clarity for users and contributors
- **12 Reference Files**: Comprehensive on-demand documentation
  - session-closure: 6 files (CONFIGURATION, TESTING, DEVELOPMENT, DESIGN_DECISIONS, IMPLEMENTATION_DETAILS, TROUBLESHOOTING)
  - session-resume: 6 files (CONFIGURATION, TESTING, DEVELOPMENT, DESIGN_DECISIONS, EXAMPLES, ROADMAP)
- **Archives Directory Structure**: Created archives/CLAUDE_RESUME/.gitkeep for clarity
- **Reference Pointers**: Added "Additional Documentation" sections to both SKILL.md files

### Changed
- **Token Load Reduction**: 76% reduction (~23k → ~5.5k tokens)
- **session-closure SKILL.md**: v1.2.0 → v1.3.0 (removed 20 lines duplicates, added 39 lines pointers)
- **session-resume SKILL.md**: v1.2.1 → v1.3.0 (removed 21 lines duplicates, added 45 lines pointers)
- **All Scripts**: Updated version comments to v1.3.0
- **marketplace.json**: Updated to v1.3.0

### Fixed
- **Cross-Platform Date Command**: check_staleness.sh now supports both BSD (macOS) and GNU (Linux) date commands
- **Test Documentation**: Clarified test counts (14 tests total: 6 + 8 = 20 assertions)
- **Script Path Resolution**: check_staleness.sh works from any directory (v1.2.1 fix carried forward)

### Removed
- **Duplicate Trigger Sections**: Removed "When This Skill Activates" sections from SKILL.md bodies (frontmatter description sufficient)

### Performance
- **Token Efficiency**: 76% reduction in initial skill load
- **Script Execution**: All scripts <10ms execution time
- **Test Suite**: All 14 tests (20 assertions) passing

### Documentation
- Added PHASE_2_COMPLETE.md with comprehensive completion report
- Integrated external code review feedback (B+ → A grade)
- Updated README.md with accurate test counts

---

## [1.2.1] - 2025-11-02

### Fixed
- **Script Path Resolution**: check_staleness.sh now finds CLAUDE_RESUME.md when invoked from skills subdirectory
- Added directory traversal logic to walk up tree looking for resume file

### Changed
- Updated check_staleness.sh to v1.2.1 with enhanced path resolution

### Testing
- All 8 session-resume tests passing
- All 6 session-closure tests (12 assertions) passing

---

## [1.2.0] - 2025-10-28

### Added
- **Project Status Section**: Inter-project communication support
  - Current state, key changes, next priority, dependencies, project health
  - Recognized by both session-closure and session-resume
- **Sync Status Section**: Authoritative source tracking
  - Google Docs, HackMD, GitHub as masters
  - Last sync dates and sync health indicators
  - Conditional section (only when relevant)

### Changed
- Updated resume format to v1.2.0 with new optional sections
- Enhanced session-resume to highlight Project Status and Sync Status
- Updated session-closure to create new sections when appropriate

### Documentation
- Added RESUME_FORMAT_v1.2.md specification
- Updated both SKILL.md files with new section handling

---

## [1.1.0] - 2025-10-25

### Added
- **session-closure skill**: Automated session closure with resume creation
  - Full/Minimal/Emergency operational modes
  - Git-aware archiving (skips if tracked in git)
  - Resume validation script
  - 6 tests (12 assertions)
- **session-resume skill**: Load previous session context
  - Staleness detection (fresh/recent/stale/very_stale)
  - Archive browsing when current resume missing
  - 8 automated tests
- **Executable Scripts**:
  - archive_resume.sh (session-closure)
  - validate_resume.sh (session-closure)
  - check_staleness.sh (session-resume)
  - list_archives.sh (session-resume)
- **Automated Test Suites**: 14 tests total
- **Resume Format v1.1.0**: Structured markdown format

### Documentation
- README.md with installation and usage
- SKILL.md for both skills with comprehensive instructions
- PHASE_1_COMPLETE.md documenting MVP completion

---

## [1.0.0] - 2025-10-20 (Internal)

### Added
- Initial concept and design
- Basic resume format
- Prototype implementations

*Note: v1.0.0 was internal development only, not released*

---

## Upgrade Guide

### Upgrading from v1.2.1 to v1.3.0

**No breaking changes** - fully backward compatible.

**What you get**:
- Faster skill execution (76% token reduction)
- Cross-platform support (Linux compatibility)
- Comprehensive reference documentation
- Legal clarity (LICENSE file)

**Action required**: None - skills work the same way

**Optional**: Explore new reference documentation:
```bash
cd ~/.claude/skills/session-closure/references/
ls -la  # See available docs
```

### Upgrading from v1.1.0 to v1.2.0

**No breaking changes** - fully backward compatible.

**What you get**:
- Project Status section support
- Sync Status section support
- Enhanced inter-project coordination

**Action required**: None - new sections are optional

---

## Version Support

| Version | Status | Support Until | Notes |
|---------|--------|---------------|-------|
| 1.3.7 | ✅ Current | TBD | Production-ready, recommended - Critical fixes |
| 1.3.6 | ✅ Supported | 2026-Q2 | Stable, missing v1.3.7 UX improvements |
| 1.3.5 | ✅ Supported | 2026-Q2 | Stable, missing SKILL_BASE fixes |
| 1.3.4 | ✅ Supported | 2026-Q2 | Stable, missing archive messaging |
| 1.3.1 | ✅ Supported | 2026-Q2 | Stable, but missing porcelain v2 fixes |
| 1.3.0 | ⚠️ Maintenance | 2025-Q4 | Missing critical path fixes |
| 1.2.1 | ⚠️ Maintenance | 2025-Q4 | Missing working directory fixes |
| 1.1.0 | ⚠️ Maintenance | 2025-Q4 | Missing Project/Sync Status features |

---

## Deprecation Policy

- **Major versions** (X.0.0): Supported for 12 months after next major
- **Minor versions** (x.Y.0): Supported for 6 months after next minor
- **Patch versions** (x.y.Z): Supported until next patch

**Example**: When v2.0.0 releases, v1.x.x will be supported until v2.1.0 or 12 months, whichever is longer.

---

## Reporting Issues

Found a bug or have a feature request?

**GitHub Issues**: https://github.com/ChristopherA/claude_code_tools/issues

**Include**:
- Version number (`grep version ~/.claude/skills/session-*/SKILL.md`)
- Operating system (macOS/Linux)
- Steps to reproduce
- Expected vs actual behavior
- Test output if applicable

---

## Release Notes

Detailed release notes available:
- [v1.3.0 Release Notes](https://github.com/ChristopherA/claude_code_tools/releases/tag/v1.3.0)
- [PHASE_2_COMPLETE.md](./PHASE_2_COMPLETE.md) - Comprehensive completion report
- [PHASE_1_COMPLETE.md](./PHASE_1_COMPLETE.md) - MVP completion report

---

*Changelog maintained by [Christopher Allen](https://github.com/ChristopherA)*
*Last updated: January 7, 2026*
