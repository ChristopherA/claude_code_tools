# CLAUDE_RESUME.md Format v1.2.0

**Version**: 1.2.0
**Created by**: session-closure skill
**Loaded by**: session-resume skill
**Purpose**: Session continuity and inter-project communication

---

## Overview

CLAUDE_RESUME.md provides session continuity between Claude sessions and enables inter-project communication across a multi-project workspace.

**Key Features (v1.2.0)**:
- Session state preservation
- Inter-project status communication ("Project Status")
- Authoritative source tracking ("Sync Status")
- Backward compatible with v1.0.0 and v1.1.0

---

## Complete Format

```markdown
# Claude Resume - [Project Name]

**Last Session**: [Date]
**Session Duration**: [Approximate time]
**Overall Status**: [One-line summary]

---

## Last Activity Completed

[What was just finished - enough detail to understand context]

---

## Pending Tasks

- [ ] [Next immediate task]
- [ ] [Subsequent tasks]
- [ ] [Known blockers or dependencies]

---

## Key Decisions Made

[Important decisions made this session - focus on WHY not just WHAT]

---

## Insights & Learnings

[Discoveries, patterns found, approaches that worked/didn't work]

---

## Session Summary

[2-3 sentences on what was accomplished and why decisions were made]

---

## Sync Status
*Include if project has authoritative sources (Google Docs, HackMD, GitHub)*
*Omit this section if project has no external masters*

- Google Docs: [last sync date or "current"]
- HackMD: [last sync date or "current"]
- GitHub: [last sync date or "current"]
- Distribution: [ready/needs update]

---

## Project Status
*Required for all projects - enables inter-project communication*

- **Current State**: [STATE] - Brief description
- **Key Changes**: What changed this session
- **Next Priority**: Immediate action needed
- **Dependencies**: Any blockers or waiting on external projects
- **Project Health**: Overall assessment

**State Options**:
- 🟢 ACTIVE - Currently being worked on
- 🔴 BLOCKED - Waiting on external dependency
- 🟡 WAITING - Paused for specific reason
- ✅ COMPLETE - Finished, ready to archive
- 🔄 REVIEW - Under review/testing

---

## Next Session Focus

[What the next session should tackle first based on current progress]

---

*Resume created by session-closure v1.2.0: [Timestamp]*
*Next session: Say "resume" to load this context*
```

---

## Section Guide

### Always Required

#### Header
```markdown
# Claude Resume - [Project Name]

**Last Session**: November 2, 2025
**Session Duration**: ~3 hours
**Overall Status**: Refactoring session skills to v1.2.0
```

- Project name matches directory or CLAUDE.md title
- Last Session includes full date (for staleness detection)
- Duration approximate
- Overall Status is one-line snapshot

#### Last Activity Completed
```markdown
## Last Activity Completed

Successfully refactored session-closure and session-resume to v1.2.0,
adding Project Status and Sync Status sections to resume format.
```

- Past tense (what was just completed)
- Enough detail to understand context
- Not a list - narrative description

#### Pending Tasks
```markdown
## Pending Tasks

- [ ] Test v1.2.0 format in real project
- [ ] Update CORE_PROCESSES.md to reference skills
- [ ] Deploy to ~/.claude/skills/
```

- Checkbox format for easy tracking
- Ordered by priority (most urgent first)
- Include blockers if relevant

#### Project Status
```markdown
## Project Status

- **Current State**: 🟢 ACTIVE - Implementing v1.2.0 format
- **Key Changes**: Added Project Status and Sync Status sections
- **Next Priority**: Test new format with real project
- **Dependencies**: None
- **Project Health**: On track, making good progress
```

**Required for all projects** - enables inter-project communication

**Use cases**:
- Root context reads child project statuses
- ProjectA checks ProjectB's status (dependencies)
- Cross-project workspace awareness

**State selection guide**:
- 🟢 ACTIVE: Currently working on it
- 🔴 BLOCKED: Can't proceed (waiting on external dependency)
- 🟡 WAITING: Paused for specific reason (schedule, decision, etc.)
- ✅ COMPLETE: Done, ready to archive
- 🔄 REVIEW: Under review/testing phase

#### Next Session Focus
```markdown
## Next Session Focus

Test v1.2.0 format by using it to close this session, then resume
in next session to validate recognition of new sections.
```

- What to do first next time
- Actionable and specific
- Sets clear starting point

#### Footer
```markdown
---
*Resume created by session-closure v1.2.0: 2025-11-02 16:30*
*Next session: Say "resume" to load this context*
```

- Version number for compatibility tracking
- Timestamp for reference
- Instructions for loading

---

### Optional Sections

#### Key Decisions Made
```markdown
## Key Decisions Made

Decided to make "Project Status" required for all projects (not just
for root) to enable peer-to-peer project coordination, not just
upward reporting.
```

**Include when**:
- Significant decisions were made
- Rationale needs to be documented
- Future you needs to understand WHY

**Omit when**:
- No major decisions this session
- Routine work only

#### Insights & Learnings
```markdown
## Insights & Learnings

TodoWrite clearing may not be needed anymore - the phantom task issue
was when TodoWrite interfered with context management, but that may
be resolved. Documented as optional troubleshooting pattern instead
of required step.
```

**Include when**:
- Discovered something important
- Found patterns or approaches
- Learned what works/doesn't work

**Omit when**:
- No new insights
- Routine execution

#### Session Summary
```markdown
## Session Summary

Refactored session skills from v1.1.0 to v1.2.0 based on ULTRATHINK
analysis comparing CORE_PROCESSES.md requirements. Added Project Status
for inter-project communication and Sync Status for authoritative
source tracking.
```

**Length**: 2-3 sentences (concise)
**Focus**: What and why (not exhaustive detail)

Can be expanded to 1-2 paragraphs for complex sessions, but prefer brevity.

---

### Conditional Sections

#### Sync Status
```markdown
## Sync Status

- Google Docs: 2025-10-28 (4 days ago - check for updates)
- HackMD: current (synced today)
- GitHub: current (pushed this morning)
- Distribution: ready (v0.93 exported, curly quotes applied)
```

**Include ONLY if project has**:
- Google Docs as authoritative master
- HackMD as authoritative master
- GitHub as authoritative master
- Local markdown synced from external sources

**Omit if project**:
- Has no external authoritative sources
- Everything is local/git only
- No synchronization workflow

**How to determine**: Check project's CLAUDE.md or LOCAL_CONTEXT.md for "Authoritative Sources" section.

**Quick check**:
```bash
grep -i "authoritative\|master\|google docs\|hackmd" CLAUDE.md LOCAL_CONTEXT.md
```

---

## Minimal Mode Format

When context is limited (<30k tokens remaining), use minimal format:

```markdown
# Claude Resume - [Project Name] (Essential)

**Last Session**: [Date]
**Status**: [One-line summary]

---

## Last Activity
[One paragraph maximum]

## Pending
- [Critical task 1]
- [Critical task 2]

## Project Status
- **Current State**: [STATE]
- **Next Priority**: [Immediate need]

## Next
[One paragraph - what to do next]

---
*Essential resume - limited context prevented full analysis*
*Created by session-closure v1.2.0: [Timestamp]*
*Next session: Say "resume" to load this context*
```

**Differences from Full Mode**:
- Shorter section names ("Pending" vs "Pending Tasks")
- No Key Decisions or Insights sections
- Simplified Project Status (just State + Priority)
- One paragraph limits
- Footer notes "Essential resume"

---

## Examples by Project Type

### Example 1: Development Project (No External Masters)

```markdown
# Claude Resume - BaseTheme

**Last Session**: November 2, 2025
**Session Duration**: ~2 hours
**Overall Status**: Implementing responsive design system

---

## Last Activity Completed

Completed mobile breakpoint styles for navigation component. All tests
passing, ready for tablet breakpoint work.

---

## Pending Tasks

- [ ] Implement tablet breakpoints (768-1024px)
- [ ] Add desktop breakpoints (>1024px)
- [ ] Update Storybook documentation
- [ ] Run accessibility audit

---

## Key Decisions Made

Decided to use CSS Grid for layout instead of Flexbox for better
browser compatibility with older mobile devices.

---

## Session Summary

Implemented mobile-first responsive design for navigation. Grid-based
approach provides better fallback support.

---

## Project Status

- **Current State**: 🟢 ACTIVE - Building responsive design system
- **Key Changes**: Completed mobile breakpoints this session
- **Next Priority**: Implement tablet breakpoints
- **Dependencies**: None
- **Project Health**: On track, good progress

---

## Next Session Focus

Start tablet breakpoint implementation, focusing on navigation and
header components first.

---

*Resume created by session-closure v1.2.0: 2025-11-02 14:30*
*Next session: Say "resume" to load this context*
```

**Note**: No "Sync Status" section - this is a local/git-only project.

---

### Example 2: Policy Project (With External Masters)

```markdown
# Claude Resume - TAoA

**Last Session**: November 2, 2025
**Session Duration**: ~3 hours
**Overall Status**: Preparing v0.94 for Shannon review

---

## Last Activity Completed

Incorporated feedback from v0.93 review cycle. Added privacy rights
section and updated consent framework based on Shannon's comments.

---

## Pending Tasks

- [ ] Submit v0.94 to Shannon for review (Monday)
- [ ] Wait for feedback (expected Tuesday-Wednesday)
- [ ] Incorporate feedback into v0.95
- [ ] Prepare distribution files

---

## Key Decisions Made

Added explicit consent revocation mechanism per Shannon's suggestion.
This strengthens user agency in the framework.

---

## Session Summary

Completed v0.94 incorporating all feedback from v0.93. Ready for
submission on Monday for Shannon's Tuesday-Wednesday review window.

---

## Sync Status

- Google Docs: current (synced this afternoon)
- HackMD: 2025-10-30 (2 days ago - slides not updated yet)
- GitHub: current (pushed v0.94 today)
- Distribution: needs update (will generate after Shannon feedback)

---

## Project Status

- **Current State**: 🟡 WAITING - Ready to submit for Shannon review
- **Key Changes**: Incorporated v0.93 feedback, added privacy section
- **Next Priority**: Submit Monday, check for feedback Tuesday
- **Dependencies**: Shannon availability (Tuesday-Wednesday window)
- **Project Health**: On track, comfortable timeline

---

## Next Session Focus

Submit v0.94 to Shannon on Monday morning. Tuesday: check for feedback
and begin incorporation if available.

---

*Resume created by session-closure v1.2.0: 2025-11-02 16:00*
*Next session: Say "resume" to load this context*
```

**Note**: Includes "Sync Status" - this project has Google Docs, HackMD, and GitHub as authoritative sources.

---

### Example 3: Meta Project (context-refactor)

```markdown
# Claude Resume - context-refactor

**Last Session**: November 2, 2025
**Session Duration**: ~6 hours
**Overall Status**: Completed v1.2.0 skills refactor

---

## Last Activity Completed

Successfully updated session-closure and session-resume from v1.1.0
to v1.2.0, adding Project Status (inter-project communication) and
Sync Status (authoritative source tracking) sections based on
ULTRATHINK analysis.

---

## Pending Tasks

- [ ] Test v1.2.0 format in real project (dogfooding)
- [ ] Update CORE_PROCESSES.md to reference skills
- [ ] Deploy to ~/.claude/skills/ for user-wide use
- [ ] Document migration path for 21 projects

---

## Key Decisions Made

Based on user clarification: TodoWrite clearing is optional
(troubleshooting pattern, not required). "Project Status" section
renamed from "Status for Claude Root" to reflect inter-project
communication purpose, not just upward reporting.

---

## Insights & Learnings

ULTRATHINK analysis revealed critical gaps: session-closure was
missing TodoWrite clearing (now optional), and format was incompatible
with CORE_PROCESSES requirements (Status for Root, Sync Status).
v1.2.0 resolves these gaps while maintaining backward compatibility.

---

## Session Summary

Completed comprehensive refactor applying project-cleanup v1.2.0
lessons to session skills. Skills now have executable scripts,
automated tests (20/20 passing), and format compatible with
CORE_PROCESSES requirements.

---

## Project Status

- **Current State**: 🔄 REVIEW - v1.2.0 complete, needs real-world testing
- **Key Changes**: Added Project Status and Sync Status to resume format
- **Next Priority**: Dogfood v1.2.0, test inter-project communication
- **Dependencies**: None
- **Project Health**: Excellent - all planned work complete

---

## Next Session Focus

Use this v1.2.0 format to close this session, then test loading
in next session to validate Project Status and Sync Status recognition.

---

*Resume created by session-closure v1.2.0: 2025-11-02 18:00*
*Next session: Say "resume" to load this context*
```

**Note**: No "Sync Status" - this is a local project with no external masters.

---

## Version Compatibility

### v1.0.0 → v1.1.0 (No Breaking Changes)

**Added**:
- Archive management (archives/)
- Git tracking detection
- Staleness detection
- Validation scripts
- Executable archive/validate scripts

**Format**: Unchanged
**Compatibility**: Full (v1.1.0 can read v1.0.0, vice versa)

### v1.1.0 → v1.2.0 (Additive Changes Only)

**Added**:
- "Project Status" section (required)
- "Sync Status" section (conditional)
- Troubleshooting guidance (phantom tasks, sync status)

**Format**: Enhanced (added sections, separator lines)
**Compatibility**: Full backward compatible
- v1.2.0 can read v1.0.0 and v1.1.0 (ignores missing sections)
- v1.1.0 can read v1.2.0 (ignores new sections)
- v1.0.0 can read v1.2.0 (ignores new sections)

### CORE_PROCESSES.md Format Compatibility

**CORE_PROCESSES format** (historical):
```markdown
## Status for Claude Root
- Current State: [STATE]
- Key Changes: [...]
- Next Priority: [...]
- Dependencies: [...]
- Project Health: [...]
```

**v1.2.0 format**:
```markdown
## Project Status
- **Current State**: [STATE]
- **Key Changes**: [...]
- **Next Priority**: [...]
- **Dependencies**: [...]
- **Project Health**: [...]
```

**Key difference**: Section name ("Status for Claude Root" → "Project Status")
**Content**: Identical fields
**Purpose**: Broadened from "upward reporting" to "inter-project communication"

**Migration**: Root context should recognize both formats.

---

## Migration Guide

### From CORE_PROCESSES Manual Format

**Old format** (manual creation per CORE_PROCESSES.md):
- Section: "Status for Claude Root"
- Resume deleted (not archived)
- TodoWrite manually cleared
- No validation

**New format** (session-closure v1.2.0):
- Section: "Project Status" (same content, broader purpose)
- Resume archived automatically
- TodoWrite optional (troubleshooting only)
- Automatic validation

**Migration steps**:
1. Start using session-closure skill (say "close context")
2. Old resumes still readable
3. New resumes use v1.2.0 format automatically
4. No forced migration needed (gradual adoption)

### From v1.0.0 or v1.1.0

**No migration needed** - v1.2.0 is fully backward compatible.

**To adopt new features**:
1. Use session-closure v1.2.0 to create resume
2. New resumes include "Project Status" automatically
3. Add "Sync Status" if project has authoritative sources

**Old resumes**: Still load fine, just missing new sections.

---

## Validation

Use `validate_resume.sh` script to check format:

```bash
./.claude/skills/session-closure/scripts/validate_resume.sh CLAUDE_RESUME.md
```

**Checks**:
- ✅ File exists
- ✅ Contains "Last Session"
- ✅ Contains "Last Activity"
- ✅ Contains "Pending"
- ✅ Contains "Project Status" (v1.2.0+)
- ✅ Contains "Next Session Focus"
- ✅ Contains footer with "Resume created by session-closure"

**Optional sections** (not validated):
- Key Decisions
- Insights & Learnings
- Sync Status

---

## Best Practices

### DO

✅ **Keep Project Status current**: Update state emoji and description accurately
✅ **Use checkboxes for pending tasks**: Easy to track progress
✅ **Be specific in Next Session Focus**: Clear starting point for next time
✅ **Include Sync Status if you have external masters**: Prevents working on stale data
✅ **Update dependencies**: Note blockers clearly in Project Status
✅ **Use appropriate state emoji**: Signals at-a-glance status

### DON'T

❌ **Don't make every session ACTIVE**: Use WAITING/BLOCKED/REVIEW appropriately
❌ **Don't skip Project Status**: Required for inter-project communication
❌ **Don't include Sync Status if no external sources**: Clutters resume unnecessarily
❌ **Don't write essays**: Keep summaries concise (2-3 sentences)
❌ **Don't forget to close context**: Resume only created if you explicitly close

---

## Troubleshooting

### Phantom Tasks

**Symptom**: Tasks from previous sessions reappear

**Solution**: See session-closure SKILL.md Troubleshooting section
- Optional: Clear TodoWrite before creating resume
- Add "PROHIBITED TASKS" section if issue persists

### Stale Sync Status

**Symptom**: Working on stale local copies

**Solution**: Check Sync Status on resume load
- session-resume warns if >7 days old
- Sync before starting work

### Missing Project Status

**Symptom**: Root context can't read project status

**Solution**: Use session-closure v1.2.0 to create resume
- "Project Status" section is required in v1.2.0
- Validation script checks for presence

---

## Future Enhancements

**Possible v1.3.0 features**:
- Project-specific templates (dev/policy/creative)
- Automatic sync status checking
- Dependencies graph (which projects depend on which)
- Archive statistics (session frequency, patterns)

**Keep it simple for now** - v1.2.0 provides solid foundation.

---

*CLAUDE_RESUME.md Format v1.2.0*
*Created by: session-closure v1.2.0*
*Loaded by: session-resume v1.2.0*
*Last updated: November 2, 2025*
