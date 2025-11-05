# Troubleshooting Guide - session-closure

This document provides solutions for common issues with the session-closure skill.

---

## Phantom Tasks (Rare Issue)

### Symptom

Claude attempts already-completed tasks from previous sessions on resume.

**Signs**:
- Tasks from old sessions reappear
- Completed work attempted again
- TodoWrite tasks persist unexpectedly across sessions

### Root Cause

TodoWrite can sometimes interfere with context management, causing tasks to persist across sessions even after completion.

**Why this happens**:
- TodoWrite state may persist in Claude's memory
- Session boundary not always clean with `/compact`
- Tasks not explicitly cleared before closure

### Solution 1: Clear TodoWrite (Optional Step)

**When to use**: If experiencing phantom tasks issue.

**Add before creating resume**:

```markdown
### Optional Step: Clear Todo List

If experiencing phantom tasks, clear the todo list:

1. Call TodoWrite with empty array: `TodoWrite([])`
2. Confirm: "Todo list cleared for next session"
```

**Note**: This is OPTIONAL, not required. Most users won't need this.

### Solution 2: PROHIBITED TASKS Section

**When to use**: If phantom tasks persist after Solution 1.

**Add to TOP of resume** if phantom tasks continue:

```markdown
# PROHIBITED TASKS - DO NOT EXECUTE

The following have ALREADY been completed. DO NOT attempt them again:
- [Task that keeps reappearing]
- [Another phantom task]
- [Any other completed work being re-attempted]

---

[Rest of resume...]
```

**This forces explicit prohibition** at resume load time.

### Solution 3: Session Boundary

Use `/exit` instead of `/compact` to fully clear context state between sessions.

**Why this helps**:
- `/exit` completely ends session
- `/compact` tries to preserve some state
- Full exit creates cleaner boundary

**Recommended workflow**:
```
1. Say "close context" → Creates resume
2. Type /exit → Ends session cleanly
3. Restart Claude Code → Fresh context
4. Say "resume" → Loads clean state
```

### Prevention

**Best practices to avoid phantom tasks**:

1. **Mark tasks complete when done**:
   - Use TodoWrite to mark tasks completed
   - Don't leave tasks in pending state

2. **Review pending tasks before closure**:
   - Check TodoWrite list
   - Remove completed items
   - Only leave truly pending tasks

3. **Clean up "Pending Tasks" section**:
   - Don't copy old tasks into new resume
   - Only include actual remaining work
   - Archive old task lists

4. **Use clear session boundaries**:
   - Prefer `/exit` over `/compact`
   - Start fresh sessions for new work
   - Don't resume from very old resumes

---

## Sync Status Guidance

### When to Include "Sync Status" Section

✅ **Include if project has**:
- Google Docs as authoritative master
- HackMD as authoritative master
- GitHub as authoritative master (different from project repo)
- Local markdown synced from external sources

❌ **Omit if project**:
- Has no external authoritative sources
- Everything is local/git only
- No synchronization workflow needed

### How to Check

Look in project's CLAUDE.md or LOCAL_CONTEXT.md for "Authoritative Sources" section.

**Quick check**:
```bash
# Search for authoritative source mentions
grep -i "authoritative\|master\|google docs\|hackmd" CLAUDE.md LOCAL_CONTEXT.md
```

**If found** → Include "Sync Status" section
**If not found** → Omit "Sync Status" section

### Example with Authoritative Sources

```markdown
## Sync Status

**Authoritative Sources**:
- **API Specification**: https://docs.google.com/document/d/abc123 (synced 2025-11-03)
- **Architecture Decisions**: https://hackmd.io/@team/architecture (synced 2025-11-02)
- **Project Board**: https://github.com/org/repo/projects/1 (synced 2025-11-03)

**Sync Health**: ✅ All sources current
```

### Example without Authoritative Sources

```markdown
[No Sync Status section - omit entirely]
```

---

## Common Issues

### Issue: Resume Not Created

**Symptoms**:
- Say "close context"
- Skill seems to activate
- No CLAUDE_RESUME.md file appears

**Possible Causes**:
1. Insufficient permissions in directory
2. Emergency Mode triggered (critically low context)
3. File creation failed silently

**Solutions**:
1. Check directory permissions: `ls -la`
2. Check context usage - if very high, try `/exit` and restart
3. Check for error messages in skill output

### Issue: Archive Not Created

**Symptoms**:
- Second closure doesn't create archive
- Old resume disappears without backup

**Possible Causes**:
1. No previous resume existed
2. Resume is tracked in git (intentionally skipped)
3. Archive directory not writable

**Solutions**:
1. First closure never creates archive (expected)
2. Check if git-tracked: `git ls-files CLAUDE_RESUME.md`
3. Check permissions: `ls -la archives/`

### Issue: Validation Fails

**Symptoms**:
- Resume created but validation fails
- Error listing missing sections

**Possible Causes**:
1. Resume actually missing sections (bug in creation)
2. Section names don't match expected format
3. Minimal Mode used (abbreviated format)

**Solutions**:
1. Compare resume to fixtures/sample_resume.md
2. Check section headers for typos
3. Minimal Mode resumes may fail validation - acceptable

### Issue: Hook Not Triggering

**Symptoms**:
- Configured SessionEnd hook
- Type `/exit`
- Skill doesn't run

**Possible Causes**:
1. Settings JSON invalid
2. Skill not installed correctly
3. Hook configuration wrong

**Solutions**:
1. Validate JSON: `cat ~/.claude/settings.json | jq`
2. Check skill exists: `ls ~/.claude/skills/session-closure`
3. Verify hook syntax matches documentation

### Issue: Git Detection Wrong

**Symptoms**:
- Resume IS tracked in git
- Archive created anyway (should skip)

OR:

- Resume NOT tracked in git
- Archive skipped (should create)

**Possible Causes**:
1. Git not installed
2. Not in git repository
3. Git command failing

**Solutions**:
1. Install git: `brew install git` (macOS)
2. Initialize repository: `git init`
3. Test git command: `git ls-files CLAUDE_RESUME.md`

---

## Debugging

### Enable Debug Output

Add to script for debugging:

```bash
#!/bin/bash
set -x  # Enable debug output
set -e  # Exit on error

# ... rest of script
```

**Output**: Shows each command before execution.

### Test Scripts Manually

```bash
# Test archive script
cd /path/to/project
~/.claude/skills/session-closure/scripts/archive_resume.sh

# Test validation script
~/.claude/skills/session-closure/scripts/validate_resume.sh
```

**Check exit code**: `echo $?` (0 = success)

### Run Automated Tests

```bash
cd ~/.claude/skills/session-closure/tests
./test_scripts.sh
```

**Expected**: All tests passing

---

## Getting Help

### Check Documentation

1. **SKILL.md**: Task instructions
2. **CONFIGURATION.md**: Setup and hooks
3. **DEVELOPMENT.md**: Scripts and testing
4. **This file**: Troubleshooting

### Report Issues

**GitHub**: https://github.com/ChristopherA/claude_code_tools/issues

**Include**:
- Symptom description
- Error messages
- Steps to reproduce
- Environment (macOS/Linux, Claude Code version)
- Test output: `cd tests && ./test_scripts.sh`

### Debug Checklist

Before reporting issue:
- [ ] Ran automated tests
- [ ] Checked permissions
- [ ] Verified skill installed
- [ ] Tested scripts manually
- [ ] Checked settings.json valid
- [ ] Read this troubleshooting guide

---

*Troubleshooting guide for session-closure v1.3.0*
