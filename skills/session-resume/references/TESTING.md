# Testing Guide - session-resume

This document provides testing procedures and test suite documentation for the session-resume skill.

---

## Automated Test Suite

### Running Tests

```bash
cd ~/.claude/skills/session-resume/tests
./test_scripts.sh
```

**Expected output**: All 8 tests passing

### Test Coverage

**8 automated tests** covering:
1. List archives (none exist)
2. List archives (multiple exist)
3. List archives (with limit parameter)
4. Check staleness (fresh resume < 1 day)
5. Check staleness (stale resume 7+ days)
6. Check staleness (missing file)
7. List archives (detailed format)
8. List archives (empty directory)

### Test Environment

**Isolated test workspace**:
- Tests run in temporary directories
- No impact on actual project files
- Automatic cleanup after tests
- Fixtures provided for reproducible tests

---

## Manual Testing Procedures

### Test 1: Basic Resume Loading

**Setup**:
1. Have CLAUDE_RESUME.md in project root
2. Resume should have valid format

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Skill activates
- ✅ Resume loaded and summarized
- ✅ Next session focus highlighted
- ✅ Pending tasks shown

**Verify**:
- [ ] Resume date displayed
- [ ] Summary coherent
- [ ] Next steps clear
- [ ] No errors

---

### Test 2: Fresh Resume (< 1 day)

**Setup**:
1. Create CLAUDE_RESUME.md with today's date
2. Format: `**Last Session**: November 5, 2025`

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Shows "✓ Resume is fresh (< 1 day old)"
- ✅ Green indicator
- ✅ Loads without staleness warning

**Verify**:
- [ ] Staleness check passed
- [ ] No warnings shown
- [ ] Context loaded smoothly

---

### Test 3: Recent Resume (1-6 days)

**Setup**:
1. Create CLAUDE_RESUME.md with date 3 days ago
2. Format: `**Last Session**: November 2, 2025`

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Shows "⚠️ Resume is recent (3 days old)"
- ✅ Yellow indicator
- ✅ Minor staleness note

**Verify**:
- [ ] Age calculated correctly
- [ ] Warning appropriate
- [ ] Context still usable

---

### Test 4: Stale Resume (7-29 days)

**Setup**:
1. Create CLAUDE_RESUME.md with date 14 days ago
2. Format: `**Last Session**: October 22, 2025`

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Shows "⚠️ Resume is stale (14 days old)"
- ✅ Orange indicator
- ✅ Suggests reviewing for accuracy

**Verify**:
- [ ] Staleness warning shown
- [ ] User prompted to review
- [ ] Context loaded with caution

---

### Test 5: Very Stale Resume (30+ days)

**Setup**:
1. Create CLAUDE_RESUME.md with date 45 days ago
2. Format: `**Last Session**: September 21, 2025`

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Shows "❌ Resume is very stale (45 days old)"
- ✅ Red indicator
- ✅ Strong warning about accuracy
- ✅ Suggests checking project state

**Verify**:
- [ ] Strong warning shown
- [ ] User aware of risk
- [ ] Recommends verification

---

### Test 6: Missing Resume

**Setup**:
1. No CLAUDE_RESUME.md in directory
2. Clean project state

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Shows "No CLAUDE_RESUME.md found"
- ✅ Friendly message (not error)
- ✅ Suggests checking archives
- ✅ Shows how to create new session

**Verify**:
- [ ] No error thrown
- [ ] Helpful guidance
- [ ] User knows next steps

---

### Test 7: Archive Browsing

**Setup**:
1. No current CLAUDE_RESUME.md
2. Several archives exist in `archives/CLAUDE_RESUME/`

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Shows "No current resume, but archives found"
- ✅ Lists recent archives (newest first)
- ✅ Shows dates clearly
- ✅ Suggests which to load

**Verify**:
- [ ] Archives listed correctly
- [ ] Sorted by date (newest first)
- [ ] User can identify desired archive
- [ ] Clear instructions

---

### Test 8: Project Status Recognition

**Setup**:
1. CLAUDE_RESUME.md with Project Status section:
```markdown
## Project Status

- **Current State**: 🔄 IN PROGRESS - Feature development
- **Key Changes**: Added authentication module
- **Next Priority**: Write tests
- **Dependencies**: None
- **Project Health**: Good
```

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Project Status section highlighted
- ✅ Current state shown prominently
- ✅ Dependencies noted (if any)
- ✅ Health assessment clear

**Verify**:
- [ ] Section recognized
- [ ] Key info extracted
- [ ] Dependencies highlighted
- [ ] Health status visible

---

### Test 9: Sync Status Recognition

**Setup**:
1. CLAUDE_RESUME.md with Sync Status section:
```markdown
## Sync Status

**Authoritative Sources**:
- **API Spec**: https://docs.google.com/... (synced 2025-11-03)

**Sync Health**: ✅ Current
```

**Procedure**:
```
User: resume
```

**Expected behavior**:
- ✅ Sync Status section highlighted
- ✅ Authoritative sources listed
- ✅ Last sync dates shown
- ✅ Sync health indicated

**Verify**:
- [ ] Section recognized
- [ ] Sources listed
- [ ] Dates shown
- [ ] Health clear

---

### Test 10: Cross-Platform (macOS)

**Setup**:
1. Run on macOS
2. CLAUDE_RESUME.md with date

**Procedure**:
```bash
./scripts/check_staleness.sh
```

**Expected behavior**:
- ✅ Uses BSD date command
- ✅ Calculates age correctly
- ✅ Returns staleness level

**Verify**:
```bash
echo $?  # Should be 0 (success)
```

---

### Test 11: Cross-Platform (Linux)

**Setup**:
1. Run on Linux
2. CLAUDE_RESUME.md with date

**Procedure**:
```bash
./scripts/check_staleness.sh
```

**Expected behavior**:
- ✅ Uses GNU date command
- ✅ Calculates age correctly
- ✅ Returns staleness level

**Verify**:
```bash
echo $?  # Should be 0 (success)
```

---

## Troubleshooting Test Failures

### Test Hangs or Times Out

**Possible causes**:
- Date command incompatible with OS
- Script permission issues
- Infinite loop in date parsing

**Fix**:
1. Check OS type: `echo $OSTYPE`
2. Test date command manually: `date +%s`
3. Check script permissions: `ls -la scripts/*.sh`
4. Run with debug: `bash -x scripts/check_staleness.sh`

---

### Test Fails: "error" Output

**Possible causes**:
- Invalid resume format
- Date parsing failed
- Missing file

**Fix**:
1. Check resume format matches expected
2. Verify date line: `grep "Last Session" CLAUDE_RESUME.md`
3. Check date format: "Month DD, YYYY" (e.g., "November 5, 2025")

---

### Test Fails: Wrong Staleness Level

**Possible causes**:
- System date incorrect
- Resume date malformed
- Threshold logic error

**Fix**:
1. Check system date: `date`
2. Check resume date format
3. Calculate age manually to verify

---

## Regression Testing

**Before each release**:
- [ ] Run automated test suite
- [ ] All 8 tests passing
- [ ] Test on macOS
- [ ] Test on Linux (if available)
- [ ] Manual smoke tests (Tests 1-6)
- [ ] Verify no script errors

---

## Performance Testing

### Script Execution Time

**check_staleness.sh**:
- Expected: < 10ms
- Measured: ~5ms average

**list_archives.sh**:
- Expected: < 20ms
- Measured: ~10ms average (10 archives)

**Benchmark**:
```bash
time ./scripts/check_staleness.sh
```

---

## Test Fixtures

**Location**: `tests/fixtures/`

**Available fixtures**:
- `sample_resume.md` - Valid resume with all sections
- `old_resume_stale.md` - Resume 14 days old
- `old_resume_very_stale.md` - Resume 45 days old
- `minimal_resume.md` - Bare minimum format

**Usage**:
```bash
# Test with specific fixture
./scripts/check_staleness.sh tests/fixtures/old_resume_stale.md
```

---

## CI/CD Integration

**Recommended**: Run test suite in CI pipeline

**Example GitHub Actions**:
```yaml
name: Test Session Skills

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run session-resume tests
        run: |
          cd skills/session-resume/tests
          ./test_scripts.sh
```

---

*Testing guide for session-resume v1.3.0*
