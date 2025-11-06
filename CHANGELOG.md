# Changelog

All notable changes to the session-skills plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
| 1.3.0 | ✅ Current | TBD | Production-ready, recommended |
| 1.2.1 | ✅ Supported | 2026-Q2 | Stable, but missing cross-platform support |
| 1.2.0 | ✅ Supported | 2026-Q2 | Stable, but missing v1.2.1 fixes |
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
*Last updated: November 5, 2025*
