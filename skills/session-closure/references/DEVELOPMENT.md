# Development Guide - session-closure

This document provides development information for maintainers and contributors to the session-closure skill.

---

## Available Scripts

### scripts/archive_resume.sh

**Purpose**: Archives CLAUDE_RESUME.md with timestamp before creating new resume.

**Usage**:
```bash
./scripts/archive_resume.sh
```

**Behavior**:
- If CLAUDE_RESUME.md doesn't exist: Skips (nothing to archive)
- If file is tracked in git: Skips (git history is the archive)
- Otherwise: Moves to `archives/CLAUDE_RESUME/<timestamp>.md`

**Output Messages**:
- `✓ No previous resume to archive` - First closure, no existing file
- `✓ Resume tracked in git - skipping archive` - Git tracking detected
- `📦 Archived to archives/CLAUDE_RESUME/YYYY-MM-DD-HHMM.md` - Successful archive

**Implementation Details**:
- Checks file existence with `[ -f CLAUDE_RESUME.md ]`
- Detects git tracking: `git ls-files --error-unmatch CLAUDE_RESUME.md 2>/dev/null`
- Creates archive directory automatically: `mkdir -p archives/CLAUDE_RESUME`
- Timestamp format: `date +"%Y-%m-%d-%H%M"`
- Moves file: `mv CLAUDE_RESUME.md archives/CLAUDE_RESUME/$TIMESTAMP.md`

**Exit Codes**:
- `0`: Success (archived, skipped, or no file)
- Non-zero: Unexpected error

**Testing**: See tests/test_scripts.sh, Tests 1-3

---

### scripts/validate_resume.sh

**Purpose**: Validates CLAUDE_RESUME.md structure before finalizing session closure.

**Usage**:
```bash
./scripts/validate_resume.sh [RESUME_FILE]
```

**Default**: Validates `CLAUDE_RESUME.md` if no argument provided.

**Validation Checks**:
1. File exists
2. Contains "Last Session" header
3. Contains "Last Activity" section
4. Contains "Pending" section (tasks)
5. Contains "Next Session Focus" section
6. Contains footer with "Resume created by session-closure"

**Output Messages**:
- `✅ Resume validation passed: CLAUDE_RESUME.md` - All checks passed
- `❌ Resume validation failed: Missing sections:` + list - Validation failed

**Implementation Details**:
- Uses `grep -q` for silent section detection
- Checks each section sequentially
- Accumulates missing sections for error report
- Case-insensitive matching for robustness

**Exit Codes**:
- `0`: Validation passed
- `1`: Validation failed (missing sections)
- `2`: File not found

**Testing**: See tests/test_scripts.sh, Tests 4-6

---

## Running Tests

### Automated Test Suite

**Location**: `tests/test_scripts.sh`

**Run tests**:
```bash
cd tests
./test_scripts.sh
```

**Test Coverage**: 6 tests, 12 assertions

| Test | Description | Validates |
|------|-------------|-----------|
| 1 | First closure (no previous resume) | Archive script handles missing file |
| 2 | Second closure (archives previous) | Archiving creates timestamped file |
| 3 | Git-tracked resume (skips archive) | Git detection works correctly |
| 4 | Valid resume passes validation | All required sections detected |
| 5 | Invalid resume fails validation | Missing sections caught |
| 6 | Missing file handled | Graceful error handling |

**Expected Output**:
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

### Test Fixtures

**Location**: `tests/fixtures/`

**sample_resume.md**: Example of properly formatted resume for validation testing.

**Structure**:
```
tests/
├── fixtures/
│   └── sample_resume.md  # Valid resume for testing
└── test_scripts.sh       # Test suite
```

---

## Architecture

### Why Scripts?

**Design Decision**: Use executable scripts instead of inline bash in SKILL.md.

**Rationale**:
1. **Consistency**: Same behavior every invocation (not re-interpreted by Claude)
2. **Testability**: Can be validated by automated test suite
3. **Token efficiency**: Call script vs parse pseudo-code every session
4. **Maintainability**: Update script once, not documentation
5. **Portability**: Scripts work across different Claude Code versions

**Learned from**: project-cleanup v1.2.0 (documented in CORE_PROCESSES.md)

**Trade-offs**:
- ✅ Pro: Deterministic, tested, efficient
- ⚠️ Con: May need reading for patching or environment adjustments
- ⚠️ Con: Requires bash shell

---

## Skill Workflow

### Task Flow Diagram

```
User: "close context"
    ↓
Step 0: Determine Mode
    ├─ >30k tokens → Full Mode
    ├─ <30k tokens → Minimal Mode
    └─ Critically low → Emergency Mode
    ↓
Step 1: Archive Existing Resume
    ├─ Run ./scripts/archive_resume.sh
    ├─ No file → Skip
    ├─ Git tracked → Skip
    └─ Otherwise → Move to archives/
    ↓
Step 2: Assess Session State
    ├─ Full Mode: Analyze thoroughly
    └─ Minimal Mode: Essential only
    ↓
Step 3: Create CLAUDE_RESUME.md
    ├─ Header (date, duration, status)
    ├─ Last Activity Completed
    ├─ Pending Tasks
    ├─ Key Decisions (optional)
    ├─ Insights & Learnings (optional)
    ├─ Session Summary
    ├─ Sync Status (conditional)
    ├─ Project Status (required)
    ├─ Next Session Focus
    └─ Footer
    ↓
Step 4: Verify Resume
    ├─ Run ./scripts/validate_resume.sh
    ├─ Passed → Continue
    └─ Failed → Fix and re-validate
    ↓
Step 5: Confirmation
    └─ Display completion message
```

---

## Code Structure

### Directory Layout

```
session-closure/
├── SKILL.md                      # Main skill instructions
├── scripts/
│   ├── archive_resume.sh         # Archive old resume
│   └── validate_resume.sh        # Validate new resume
├── tests/
│   ├── fixtures/
│   │   └── sample_resume.md      # Test data
│   └── test_scripts.sh           # Test suite
└── references/
    ├── CONFIGURATION.md          # Setup guide
    ├── DEVELOPMENT.md            # This file
    ├── DESIGN_DECISIONS.md       # Architecture notes
    ├── IMPLEMENTATION_DETAILS.md # Technical details
    ├── RESUME_FORMAT_v1.2.md     # Format specification
    ├── TESTING.md                # Testing guide
    └── TROUBLESHOOTING.md        # Common issues
```

---

## Development Workflow

### Making Changes

1. **Update scripts** in `scripts/`
2. **Update tests** in `tests/test_scripts.sh`
3. **Run tests**: `cd tests && ./test_scripts.sh`
4. **Update SKILL.md** if behavior changes
5. **Update references/** if documentation changes
6. **Bump version** in SKILL.md frontmatter
7. **Update changelog**

### Adding New Features

**Example**: Add support for custom archive locations

1. **Design**: Document in references/DESIGN_DECISIONS.md
2. **Implement**: Update scripts/archive_resume.sh
3. **Test**: Add test cases to test_scripts.sh
4. **Document**: Update SKILL.md if user-facing
5. **Reference**: Update references/CONFIGURATION.md for setup
6. **Version**: Bump minor version (1.3.0 → 1.4.0)

---

## Token Efficiency

### SKILL.md Size

**Current**: ~313 lines (post-Phase 2)
**Target**: <350 lines
**Ideal**: <500 lines (official recommendation)

**Achieved**: ✅ Well under target

### Progressive Disclosure

**Level 1: Metadata** (~100 words, always loaded):
- Frontmatter (name, description, version)

**Level 2: SKILL.md** (~2000 words, loaded when skill triggers):
- Task instructions only
- Brief script invocations
- Essential workflow

**Level 3: references/** (loaded on-demand):
- CONFIGURATION.md (when user asks "how to configure")
- DEVELOPMENT.md (when developer asks "how does this work")
- TESTING.md (when testing)
- etc.

**Impact**: ~40% reduction in initial token load vs v1.2.0

---

## Version History

### v1.3.0 (2025-11-XX)
- Optimized SKILL.md to <350 lines
- Implemented progressive disclosure with references/
- Removed redundant "When This Skill Activates" section
- Extracted meta-documentation to references/

### v1.2.0 (2025-11-04)
- Added Project Status section (inter-project communication)
- Added Sync Status section (authoritative source tracking)
- Documented TodoWrite clearing pattern (optional)
- Full/Minimal/Emergency modes

### v1.1.0 (2025-11-02)
- Added executable scripts (archive_resume.sh, validate_resume.sh)
- Added automated test suite (6 tests, 12 assertions)
- Git-aware archiving
- Resume validation

### v1.0.0 (initial)
- Basic session closure functionality
- Manual archiving
- Simple resume format

---

## Performance Benchmarks

### Script Execution Time

**archive_resume.sh**:
- No previous resume: <1ms
- Archive resume: <10ms
- Git detection: <5ms

**validate_resume.sh**:
- Valid resume: <5ms
- Invalid resume: <5ms

**Total skill execution**: ~2-3 seconds (including Claude analysis)

### Token Usage

**Full Mode**: ~7.5k tokens
**Minimal Mode**: ~3k tokens
**Emergency Mode**: ~1k tokens

---

## Troubleshooting Development Issues

### Tests Failing After Changes

1. Run individual tests: Comment out others in test_scripts.sh
2. Check script exit codes: `echo $?` after manual run
3. Verify fixtures unchanged: `git diff tests/fixtures/`
4. Test scripts manually: `./scripts/archive_resume.sh`

### Script Behavior Issues

1. Add debug output: `set -x` at top of script
2. Check permissions: `ls -la scripts/`
3. Verify bash available: `which bash`
4. Test in isolation: Create temp directory

### Git Detection Not Working

1. Verify git installed: `which git`
2. Check repository: `git status`
3. Verify file tracked: `git ls-files CLAUDE_RESUME.md`
4. Test command: `git ls-files --error-unmatch CLAUDE_RESUME.md`

---

## Contributing

### Code Style

**Shell scripts**:
- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Quote variables: `"$VARIABLE"`
- Use descriptive variable names: `RESUME_FILE` not `RF`
- Add comments for complex logic

**Documentation**:
- Use markdown format
- Include code examples
- Add "Why?" explanations
- Keep line length <100 chars

### Pull Request Process

1. Fork repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Make changes
4. Add/update tests
5. Run test suite: `./tests/test_scripts.sh`
6. Update documentation
7. Commit with signed-off: `git commit -S -s`
8. Push and create PR

---

*Development guide for session-closure v1.3.0*
