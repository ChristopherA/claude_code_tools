# Enhance Error Recovery Documentation in SKILL.md

**Priority**: P2 - Minor Improvement
**Labels**: documentation, enhancement, user-experience

## Description

Enhance the error handling documentation in both SKILL.md files to make error recovery procedures more explicit and actionable.

## Current State

Both skills have good error handling in scripts, but SKILL.md doesn't explicitly document what happens when errors occur or how Claude should respond to them.

## Proposed Changes

### For session-closure/SKILL.md

Add error recovery guidance to Step 1 (Archive) and Step 4 (Validate):

**After Step 1 archive script invocation** (line ~56), add:

```markdown
**If archiving fails**:
- Check error message from script
- Verify write permissions on `archives/` directory
- Ensure adequate disk space
- Continue with closure (archiving is optional, non-blocking)
```

**After Step 4 validation script invocation** (line ~227), add:

```markdown
**If validation fails**:
1. Review which sections are missing (script lists them)
2. Add missing sections to CLAUDE_RESUME.md
3. Re-run validation: `./scripts/validate_resume.sh`
4. Do not proceed to Step 5 until validation passes

**If script cannot execute**:
- Check permissions: `chmod +x scripts/validate_resume.sh`
- See Troubleshooting Quick-Start section
```

### For session-resume/SKILL.md

Add error recovery to Step 1 (Check for Resume):

**After Step 1 archive check** (line ~48), add:

```markdown
**If list_archives.sh fails**:
- Check permissions: `chmod +x scripts/list_archives.sh`
- Verify `archives/CLAUDE_RESUME/` directory exists
- Report: "Cannot check archives, assuming fresh start"
- Continue without archive context
```

Add error recovery to Step 2 (Staleness):

**After Step 2 staleness check** (line ~65), add:

```markdown
**If staleness check returns "error"**:
- Resume file may be missing or corrupted
- Date format may be unrecognized
- Notify user: "Cannot determine resume age, proceeding with caution"
- Continue with loading but warn about unknown freshness
```

## Acceptance Criteria

- [ ] Error recovery added to session-closure/SKILL.md Step 1 (archiving)
- [ ] Error recovery added to session-closure/SKILL.md Step 4 (validation)
- [ ] Error recovery added to session-resume/SKILL.md Step 1 (archive listing)
- [ ] Error recovery added to session-resume/SKILL.md Step 2 (staleness)
- [ ] Each recovery procedure is actionable (specific steps)
- [ ] Recovery procedures maintain graceful degradation
- [ ] Non-critical errors allow continuation
- [ ] Critical errors block progression with clear fix instructions

## Rationale

Current error handling exists in scripts but SKILL.md doesn't tell Claude:
- What to do when scripts fail
- Which errors are critical vs. non-critical
- How to gracefully degrade functionality
- When to continue vs. when to stop

Explicit error recovery documentation:
- Reduces user confusion
- Improves resilience
- Provides clear troubleshooting path
- Follows best practice of handling failures gracefully

## Estimated Effort

15 minutes (review both skills and add recovery blocks)

## References

- Best practice review: Repository best practices analysis (November 2025)
- Existing error handling: Script exit codes and error messages
- Graceful degradation: SKILL.md operational modes (Full/Minimal/Emergency)
