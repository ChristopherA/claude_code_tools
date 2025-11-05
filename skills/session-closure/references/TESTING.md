# Testing Guide - session-closure

This document provides comprehensive testing instructions for the session-closure skill.

---

## Testing Checklist

### Standalone Tests

**Manual Trigger Tests**:
- [ ] Manual trigger: "close context" → skill activates
- [ ] Manual trigger: "end session" → skill activates
- [ ] Manual trigger: "prepare to stop" → skill activates
- [ ] Non-trigger: "save file" → skill doesn't activate
- [ ] Non-trigger: "save draft" → skill doesn't activate
- [ ] CLAUDE_RESUME.md created at project root
- [ ] All sections populated with content

### Hook Integration Tests

**SessionEnd Hook**:
- [ ] SessionEnd hook invokes skill on /exit
- [ ] SessionEnd hook invokes skill on /compact
- [ ] Resume created without manual trigger
- [ ] Hook invocation completes successfully
- [ ] User sees completion message

### Archiving Tests

**Archive Behavior**:
- [ ] First close: No previous resume, no archive created
- [ ] Second close: Previous resume archived to archives/CLAUDE_RESUME/
- [ ] Archive has correct timestamp filename (YYYY-MM-DD-HHMM.md)
- [ ] Archive preserves original content exactly
- [ ] Tracked resume: Skips archiving, shows git message
- [ ] Archive directory created automatically if missing

### Mode Tests

**Operational Modes**:
- [ ] Normal context (>30k remaining): Full Mode used
- [ ] Low context (<30k remaining): Minimal Mode used, warning shown
- [ ] Critically low context: Emergency Mode, output to chat
- [ ] Resume format matches selected mode
- [ ] Mode selection message displayed to user

### Validation Tests

**Resume Validation**:
- [ ] Valid resume: Passes validation script
- [ ] Missing "Last Session": Fails validation
- [ ] Missing "Last Activity": Fails validation
- [ ] Missing "Pending" section: Fails validation
- [ ] Missing "Next Session Focus": Fails validation
- [ ] Missing footer: Fails validation
- [ ] Validation script exit code 0 on success
- [ ] Validation script exit code 1 on failure

### Pairing Tests (with session-resume)

**Complete Workflow**:
- [ ] Close → exit → start → "resume" flow works
- [ ] Archived resume can be loaded from archives/
- [ ] Version in footer matches skill version
- [ ] Resume contains all expected sections
- [ ] Pending tasks appear in resume

### Project Status Tests

**Project Status Section**:
- [ ] Project Status section included in resume
- [ ] Current State field populated with emoji + description
- [ ] Key Changes field describes session work
- [ ] Next Priority field indicates next action
- [ ] Dependencies field notes blockers (if any)
- [ ] Project Health field provides assessment

### Sync Status Tests

**Sync Status Section** (when applicable):
- [ ] Sync Status included when project has authoritative sources
- [ ] Sync Status omitted when no authoritative sources
- [ ] Source URLs included
- [ ] Last sync dates recorded
- [ ] "current" used when just synced

---

## Automated Test Suite

### Running Tests

```bash
cd tests
./test_scripts.sh
```

### Test Coverage

**Current coverage**: 6 tests, 12 assertions

1. **Test 1: First closure (no previous resume)**
   - Verifies archive script handles missing file
   - Expected: "✓ No previous resume to archive"

2. **Test 2: Second closure (archives previous)**
   - Creates resume, runs script again
   - Expected: Resume moved to archives/ with timestamp
   - Verifies: Archive file exists and is readable

3. **Test 3: Git-tracked resume (skips archive)**
   - Simulates git-tracked CLAUDE_RESUME.md
   - Expected: "✓ Resume tracked in git - skipping archive"
   - Verifies: No archive created

4. **Test 4: Valid resume passes validation**
   - Creates properly formatted resume
   - Expected: Validation script returns 0
   - Verifies: All required sections present

5. **Test 5: Invalid resume fails validation**
   - Creates resume missing required sections
   - Expected: Validation script returns 1
   - Verifies: Error message lists missing sections

6. **Test 6: Missing resume file handled**
   - Runs validation on non-existent file
   - Expected: Validation script returns 2
   - Verifies: Clear error message

### Expected Output

```
========================================
session-closure Script Test Suite
========================================

Test 1: First closure (no previous resume)
✓ Correctly reports no previous resume

Test 2: Second closure (archives previous)
✓ Archives correctly with timestamp

Test 3: Git-tracked resume (skips archive)
✓ Skips archive for git-tracked files

Test 4: Valid resume passes validation
✓ Validation passes for correct format

Test 5: Invalid resume fails validation
✓ Validation fails appropriately

Test 6: Missing resume file handled
✓ Missing file detected with correct exit code

========================================
Test Summary
========================================
Tests run:    6
Tests passed: 12
Tests failed: 0
========================================
```

---

## Manual Testing Procedures

### Test 1: Basic Closure Flow

1. Start Claude Code in a test project
2. Do some work (create files, make changes)
3. Say "close context"
4. Verify:
   - Skill activates
   - CLAUDE_RESUME.md created
   - Contains all expected sections
   - Footer has correct version
   - Completion message shown

### Test 2: Archive on Second Close

1. Complete Test 1 (have existing CLAUDE_RESUME.md)
2. Start new session
3. Do more work
4. Say "close context" again
5. Verify:
   - Old resume moved to archives/CLAUDE_RESUME/
   - Archive has timestamp filename
   - Archive content matches original
   - New CLAUDE_RESUME.md created

### Test 3: Git-Tracked Resume

1. Add CLAUDE_RESUME.md to git: `git add CLAUDE_RESUME.md`
2. Commit: `git commit -m "Track resume"`
3. Make changes, say "close context"
4. Verify:
   - No archive created
   - Message: "Resume tracked in git - skipping archive"
   - New resume overwrites existing

### Test 4: Full vs Minimal Mode

**Full Mode**:
1. Start fresh session with plenty of context
2. Say "close context" early (>30k tokens remaining)
3. Verify: Full mode resume with all sections

**Minimal Mode**:
1. Build up context to ~175k tokens
2. Say "close context"
3. Verify:
   - Minimal mode message shown
   - Resume has abbreviated format
   - Warning about limited context

### Test 5: Hook Integration

1. Configure SessionEnd hook in ~/.claude/settings.json
2. Start Claude Code
3. Do work
4. Type `/exit`
5. Verify:
   - Skill activates automatically
   - Resume created before exit
   - No manual trigger needed

---

## Troubleshooting Test Failures

### Test Fails: "Archive not created"

**Check**:
- Previous resume existed before test?
- Archives directory has write permissions?
- Script output for error messages

**Fix**:
- Ensure test starts with existing resume
- Check directory permissions: `ls -la archives/`

### Test Fails: "Validation should pass but fails"

**Check**:
- Resume has all required sections?
- Section headers match expected format?
- Footer present with version?

**Fix**:
- Compare resume to fixtures/sample_resume.md
- Check for typos in section headers

### Test Fails: "Git detection not working"

**Check**:
- Git repository initialized in test directory?
- File actually tracked: `git ls-files CLAUDE_RESUME.md`
- Git command available: `which git`

**Fix**:
- Initialize git: `git init`
- Add file: `git add CLAUDE_RESUME.md && git commit -m "test"`

---

## Performance Testing

### Context Budget Impact

**Measure skill token usage**:
1. Note context tokens before: Check context window
2. Trigger skill: "close context"
3. Note context tokens after
4. Calculate: After - Before = Skill usage

**Expected**: ~7.5k tokens for Full Mode

### Execution Time

**Measure skill execution time**:
1. Start timer when triggering
2. Stop timer at completion message
3. Record time

**Expected**: <3 seconds for typical resume

---

## Regression Testing

After any changes to the skill, verify:

1. All automated tests still pass
2. Manual trigger still works
3. Hook integration still works
4. Archive behavior unchanged
5. Validation catches invalid resumes
6. Git detection still works
7. Mode selection logic unchanged
8. Output format matches expected

---

*Testing guide for session-closure v1.3.0*
