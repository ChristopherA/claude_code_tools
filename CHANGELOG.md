# Changelog

All notable changes to the session-skills plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
*Last updated: November 14, 2025*
