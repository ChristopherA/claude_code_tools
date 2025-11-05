# Roadmap - session-resume

This document outlines potential future enhancements and features for the session-resume skill.

---

## Version History

### v1.3.0 (Current) - Progressive Disclosure

**Released**: November 2025

**Key features**:
- ✅ Progressive disclosure architecture (references/ directory)
- ✅ Cross-platform date command support (macOS + Linux)
- ✅ Removed duplicate trigger section
- ✅ Added comprehensive reference documentation
- ✅ 6 reference files organized by audience

**Impact**: 77% reduction in initial token load, production-ready cross-platform support.

---

### v1.2.1 - Path Resolution Fix

**Released**: November 2025

**Key features**:
- ✅ Fixed check_staleness.sh path resolution
- ✅ Script works from any directory
- ✅ Directory traversal to find resume

**Impact**: Reliability improvement when invoked from skill subdirectory.

---

### v1.2.0 - Project Coordination

**Released**: October 2025

**Key features**:
- ✅ Project Status section recognition
- ✅ Sync Status section recognition
- ✅ Inter-project communication support
- ✅ Authoritative source tracking

**Impact**: Enables multi-project workflows and external source coordination.

---

### v1.1.0 - Initial Release

**Released**: October 2025

**Key features**:
- ✅ Basic resume loading
- ✅ Staleness detection (4 levels)
- ✅ Archive browsing
- ✅ Executable scripts (check_staleness.sh, list_archives.sh)
- ✅ Automated test suite (8 tests)

**Impact**: Core functionality established.

---

## Planned Enhancements

### v1.4.0 - Enhanced Archive Management

**Status**: Planned (Q1 2026)

**Proposed features**:

**1. Archive Search**
- Search archives by content keywords
- Find resumes mentioning specific files or features
- Timeline view of project evolution

**Implementation**:
```bash
./scripts/search_archives.sh "authentication module"
# Output: Archives containing "authentication module"
# - 2025-11-04-1430.md (3 matches)
# - 2025-10-28-0915.md (1 match)
```

**2. Archive Comparison**
- Diff two resume files
- Show what changed between sessions
- Highlight evolution of pending tasks

**Implementation**:
```bash
./scripts/compare_archives.sh 2025-11-04-1430.md 2025-11-03-1615.md
# Output: Differences between sessions
```

**3. Archive Pruning**
- Automatically archive old resumes
- Keep N most recent + monthly snapshots
- Configurable retention policy

**Configuration**:
```json
{
  "archive_retention": {
    "keep_recent": 10,
    "keep_monthly": 12,
    "keep_yearly": 5
  }
}
```

**Estimated effort**: 3-4 weeks
**Priority**: Medium

---

### v1.5.0 - Intelligent Context Selection

**Status**: Proposed (Q2 2026)

**Proposed features**:

**1. Branch-Aware Resumes**
- Detect git branch
- Load resume specific to branch
- Separate context per branch

**Implementation**:
```bash
# On feature/api-v2 branch
CLAUDE_RESUME_feature-api-v2.md  # Branch-specific resume

# Falls back to CLAUDE_RESUME.md if branch-specific not found
```

**2. Context Relevance Scoring**
- Analyze resume content
- Score relevance to current work
- Warn if context mismatch

**Example**:
```
⚠️ Resume mentions files that no longer exist:
- src/old_auth.js (deleted 5 days ago)
- config/legacy.json (renamed to config/app.json)

Context relevance score: 60% - Use with caution
```

**3. Smart Archive Suggestions**
- Suggest relevant archives based on current work
- "You're working on auth - I found a resume from last month about auth"
- ML-based content similarity

**Estimated effort**: 6-8 weeks
**Priority**: Low (innovative but complex)

---

### v1.6.0 - Team Collaboration Features

**Status**: Proposed (Q3 2026)

**Proposed features**:

**1. Multi-User Resume Merging**
- Combine resumes from multiple team members
- Aggregate pending tasks
- Show who worked on what

**Example**:
```markdown
## Team Session Summary

**Alice** (Nov 4): Completed authentication module
**Bob** (Nov 4): Fixed database migration bugs
**Carol** (Nov 4): Updated API documentation

## Combined Pending Tasks
- [ ] Deploy auth module (Alice)
- [ ] Run full integration tests (Bob)
- [ ] Publish API docs (Carol)
```

**2. Handoff Mode**
- Explicit resume creation for next developer
- "Handoff to Bob: Here's where I left off..."
- Tagged sections for handoff

**3. Team Timeline**
- Visualize team's session history
- Who worked when
- Project velocity tracking

**Estimated effort**: 8-10 weeks
**Priority**: Medium (valuable for teams)

---

### v1.7.0 - Configuration System

**Status**: Proposed (Q4 2026)

**Proposed features**:

**1. Config File Support**
- `.session-resume.json` in project root
- Customize staleness thresholds
- Archive location
- Format preferences

**Example**:
```json
{
  "staleness_thresholds": {
    "fresh": 2,
    "recent": 14,
    "stale": 60
  },
  "archive": {
    "location": "custom/archive/path",
    "retention_days": 90
  },
  "formatting": {
    "date_format": "YYYY-MM-DD",
    "archive_format": "detailed"
  }
}
```

**2. Per-Project Customization**
- Different settings per project
- Team-shared configuration
- Override user defaults

**3. Hook Customization**
- Custom scripts on resume load
- Pre/post-load hooks
- Integration with other tools

**Estimated effort**: 4-5 weeks
**Priority**: Medium (flexibility for power users)

---

## Feature Requests

**Community-requested features** (open for discussion):

### 1. Export Resume to Different Formats

**Request**: Export CLAUDE_RESUME.md to PDF, HTML, or JSON.

**Use case**: Share with team, include in documentation, archive externally.

**Status**: Under consideration

---

### 2. Resume Templates

**Request**: Customizable resume templates for different project types.

**Example**: Web app template, data science template, documentation template.

**Status**: Under consideration

---

### 3. Integration with Project Management Tools

**Request**: Sync pending tasks with Jira, GitHub Issues, or Trello.

**Use case**: Two-way sync between resume and project tracker.

**Status**: Low priority (complexity vs benefit)

---

### 4. Voice Summary

**Request**: Audio summary of resume (text-to-speech).

**Use case**: Listen to recap while commuting.

**Status**: Out of scope (external tool more appropriate)

---

### 5. Diff with Current Project State

**Request**: Compare resume with actual project state (files, git commits).

**Use case**: Identify what changed since last session.

**Example**:
```
Since last session (Nov 4):
- 12 commits pushed
- 3 new files created
- 5 files modified
- 1 file deleted

Changed files relevant to your work:
- src/auth.js (mentioned in resume)
- tests/auth.test.js (mentioned in pending tasks)
```

**Status**: Interesting - needs investigation

---

## Non-Goals

**Features we've explicitly decided NOT to pursue**:

### ❌ Automatic Resume Loading

**Why not**: Violates explicit-only triggering principle. User control is paramount.

---

### ❌ Resume Editing via Skill

**Why not**: CLAUDE_RESUME.md is generated by session-closure. Manual editing should use file tools, not skill commands.

---

### ❌ Cloud Sync

**Why not**: Out of scope. Users can use git, Dropbox, or other tools for sync.

---

### ❌ Real-Time Collaboration

**Why not**: Claude Code is single-user. Team features should be async (git-based).

---

### ❌ AI-Generated Summaries

**Why not**: session-closure already creates summaries. No need for redundant AI processing.

---

## Contributing Ideas

Have a feature idea? We'd love to hear it!

**How to propose**:
1. Check if already listed above
2. Open issue on GitHub: https://github.com/ChristopherA/claude_code_tools/issues
3. Tag with `enhancement` and `session-resume`
4. Describe use case and benefit

**What makes a good proposal**:
- ✅ Solves real problem
- ✅ Fits existing architecture
- ✅ Benefits multiple users
- ✅ Doesn't break existing workflows
- ✅ Reasonable implementation effort

---

## Version Timeline

**Rough timeline** (subject to change):

- **Q4 2025**: v1.3.0 release (current)
- **Q1 2026**: v1.4.0 (archive management)
- **Q2 2026**: v1.5.0 (intelligent context selection)
- **Q3 2026**: v1.6.0 (team collaboration)
- **Q4 2026**: v1.7.0 (configuration system)

**Note**: Timeline depends on community feedback, priorities, and available development time.

---

## Maintenance Priorities

**Ongoing** (all versions):
- Bug fixes (highest priority)
- Security updates
- Cross-platform compatibility
- Performance optimization
- Documentation updates
- Test coverage

**Quality over features**: We prioritize stability and reliability over new features.

---

*Roadmap for session-resume skill - Last updated November 2025*
