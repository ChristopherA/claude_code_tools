# Testing - session-resume

## Automated Tests

Run test suite:
```bash
cd tests
./test_scripts.sh
```

**Coverage** (8 tests):
1. List archives (none exist)
2. List archives (multiple exist)  
3. List archives (with limit)
4. Check staleness (fresh)
5. Check staleness (stale)
6. Check staleness (missing file)
7. List archives (detailed format)
8. List archives (empty directory)

**Expected**: All 8 tests passing

## Manual Testing

**Test 1: Basic resume loading**
```bash
# Create a resume (use session-closure)
# Exit and restart Claude
# Say "resume"
# Expected: Resume loads, shows summary
```

**Test 2: Staleness detection**
```bash
# Edit CLAUDE_RESUME.md, change date to 10 days ago
# Say "resume"
# Expected: Warning about stale resume
```

**Test 3: Uncommitted changes (Step 0.5)**
```bash
# Make changes to a file (don't commit)
# Say "resume"
# Expected: Blocks with change summary
# Commit changes
# Say "resume" again
# Expected: Resume loads normally
```

**Test 4: No resume**
```bash
# Delete CLAUDE_RESUME.md
# Say "resume"
# Expected: "No resume found" message
```

## Cross-Platform Testing

**macOS**: Primary development platform
**Linux**: Verify date command compatibility

---

*Testing guide for session-resume v1.3.8*
