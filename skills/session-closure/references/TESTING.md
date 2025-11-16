# Testing - session-closure

## Manual Testing

**Test 1: Basic closure**
```bash
# Do some work
# Say "close context"
# Expected: Resume created, validated, committed
```

**Test 2: Uncommitted changes (Step 0.5)**
```bash
# Make changes, don't commit
# Say "close context"
# Expected: Changes detected, committed together with resume
```

**Test 3: Secret files**
```bash
# Create .env file
# Say "close context"
# Expected: Blocks, warns about secrets
```

**Test 4: Archive behavior**
```bash
# Create resume
# Say "close context" again
# Expected: Previous resume archived
```

**Test 5: Minimal mode**
```bash
# Use skill when context >170k tokens
# Expected: Creates minimal resume
```

## Verification

After closure:
- `cat CLAUDE_RESUME.md` - Resume created
- `git log -1` - Resume committed
- `git status` - Clean working directory
- `ls claude/archive/sessions/` - Previous resume archived (if existed)

---

*Testing guide for session-closure v1.3.7*
