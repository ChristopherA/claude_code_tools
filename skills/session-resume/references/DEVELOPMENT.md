# Development Guide - session-resume

This document provides technical implementation details, script documentation, and contributing guidelines for the session-resume skill.

---

## Architecture Overview

### Skill Components

```
session-resume/
├── SKILL.md                    # Task instructions for Claude
├── scripts/
│   ├── check_staleness.sh      # Calculate resume age
│   └── list_archives.sh        # List archived resumes
├── tests/
│   ├── test_scripts.sh         # Automated test suite
│   └── fixtures/               # Test data
└── references/                 # Documentation (this directory)
    ├── CONFIGURATION.md
    ├── TESTING.md
    ├── DEVELOPMENT.md (this file)
    ├── DESIGN_DECISIONS.md
    ├── EXAMPLES.md
    └── ROADMAP.md
```

### Execution Flow

```
User says "resume"
    ↓
Claude Code activates session-resume skill
    ↓
SKILL.md loaded (task instructions)
    ↓
Step 1: Check for CLAUDE_RESUME.md
    ↓
Step 2: Run check_staleness.sh → age in days
    ↓
Step 3: Load resume content
    ↓
Step 4: Summarize and highlight next steps
    ↓
Optional: Show archives if resume missing
```

---

## Script Documentation

### check_staleness.sh

**Purpose**: Calculate age of resume and categorize staleness level.

**Location**: `scripts/check_staleness.sh`

**Usage**:
```bash
./check_staleness.sh [RESUME_FILE]

# Examples
./check_staleness.sh                          # Uses CLAUDE_RESUME.md
./check_staleness.sh path/to/custom_resume.md # Custom file
```

**Output** (stdout):
- `fresh` - Resume < 1 day old
- `recent` - Resume 1-6 days old
- `stale` - Resume 7-29 days old
- `very_stale` - Resume 30+ days old
- `error` - File not found or date parsing failed

**Exit codes**:
- `0` - Success (staleness determined)
- `1` - Error (file not found or parsing failed)

**Implementation details**:
```bash
# Extract date from resume
SESSION_DATE=$(grep -i "Last Session" RESUME | ...)

# Calculate epoch seconds (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD date)
    SESSION_EPOCH=$(date -j -f "%B %d, %Y" "$SESSION_DATE" +%s)
else
    # Linux (GNU date)
    SESSION_EPOCH=$(date -d "$SESSION_DATE" +%s)
fi

# Calculate age in days
AGE_DAYS=$(( (TODAY - SESSION_EPOCH) / 86400 ))

# Determine staleness level
if [ "$AGE_DAYS" -lt 1 ]; then
    echo "fresh"
elif [ "$AGE_DAYS" -lt 7 ]; then
    echo "recent"
# ... etc
```

**Cross-platform support** (v1.3.0):
- Detects OS type via `$OSTYPE`
- Uses BSD date on macOS (`-j -f` flags)
- Uses GNU date on Linux (`-d` flag)
- Tested on both platforms

**Path resolution** (v1.2.1):
- Searches up directory tree for resume
- Works when invoked from skill subdirectory
- Handles both absolute and relative paths

**Date format support**:
- Primary: "Month DD, YYYY" (e.g., "November 5, 2025")
- Alternate: "Month DD YYYY" (no comma)
- Case-insensitive matching

**Error handling**:
- Missing file → returns "error" + exit 1
- Invalid date → returns "error" + exit 1
- Parsing failure → returns "error" + exit 1

**Performance**:
- Execution time: ~5ms average
- Single file read + grep + date calculation
- No external dependencies beyond bash + date

---

### list_archives.sh

**Purpose**: List archived resumes sorted by date (newest first).

**Location**: `scripts/list_archives.sh`

**Usage**:
```bash
./list_archives.sh [OPTIONS]

# Examples
./list_archives.sh                          # All archives, detailed
./list_archives.sh --limit 5                # 5 most recent
./list_archives.sh --format short           # Filenames only
./list_archives.sh --limit 3 --format short # Combined
```

**Options**:
- `--limit N` - Show only N most recent archives
- `--format short` - Show filenames only
- `--format detailed` - Show dates and sizes (default)

**Output formats**:

**Detailed** (default):
```
2025-11-05-1430.md  (November 5, 2025 at 2:30 PM, 3.2 KB)
2025-11-04-1615.md  (November 4, 2025 at 4:15 PM, 2.8 KB)
2025-11-03-0945.md  (November 3, 2025 at 9:45 AM, 3.1 KB)
```

**Short**:
```
2025-11-05-1430.md
2025-11-04-1615.md
2025-11-03-0945.md
```

**Exit codes**:
- `0` - Success (archives listed or none found)
- `1` - Error (directory not accessible)

**Implementation details**:
```bash
ARCHIVE_DIR="archives/CLAUDE_RESUME"

# Check if directory exists
if [ ! -d "$ARCHIVE_DIR" ]; then
    echo "No archives found"
    exit 0
fi

# List files sorted by modification time (newest first)
ls -t "$ARCHIVE_DIR"/*.md 2>/dev/null

# Apply limit if specified
if [ -n "$LIMIT" ]; then
    head -n "$LIMIT"
fi
```

**Performance**:
- Execution time: ~10ms (for 10 archives)
- Uses `ls -t` for efficient time-based sorting
- No file content reading (metadata only)

---

## Resume Format Parsing

### Date Extraction

**Expected format** in CLAUDE_RESUME.md:
```markdown
**Last Session**: November 5, 2025 (Tuesday)
```

**Parsing logic**:
```bash
# Extract line with "Last Session"
SESSION_DATE_LINE=$(grep -i "Last Session" "$RESUME" | head -1)

# Extract date portion (handles both formats)
SESSION_DATE=$(echo "$SESSION_DATE_LINE" |
               sed 's/.*Last Session[*:]*: *//' |
               sed 's/ (.*//' |
               cut -d' ' -f1-3)
```

**Result**: "November 5, 2025"

**Robustness**:
- Case-insensitive matching (`-i`)
- Handles variations: "Last Session:", "**Last Session**:", "Last Session -"
- Strips day of week: "(Tuesday)" removed
- Takes first 3 words: "Month Day, Year"

---

### Section Recognition

**Key sections** identified by session-resume:

1. **Last Activity** / **Last Activity Completed**
2. **Pending Tasks**
3. **Next Session Focus**
4. **Project Status** (optional)
5. **Sync Status** (optional)

**Recognition method**:
- Uses `grep -qi` (case-insensitive, quiet)
- Looks for section headers
- No strict format required
- Flexible to minor variations

---

## Testing Infrastructure

### Test Suite Structure

**Location**: `tests/test_scripts.sh`

**Test count**: 8 tests

**Test categories**:
1. **Archive listing** (4 tests)
   - No archives
   - Multiple archives
   - With limit
   - Empty directory

2. **Staleness detection** (3 tests)
   - Fresh resume
   - Stale resume
   - Missing file

3. **Format options** (1 test)
   - Detailed format

**Test execution**:
```bash
cd tests/
./test_scripts.sh

# With debug output
bash -x ./test_scripts.sh
```

**Expected output**:
```
========================================
session-resume Script Test Suite
========================================

Test 1: List archives (none exist)
✓ Correctly reports no archives

Test 2: List archives (multiple exist)
✓ Lists archives correctly

...

========================================
Test Summary
========================================
Tests run:    8
Tests passed: 8
Tests failed: 0
========================================
```

---

### Test Fixtures

**Location**: `tests/fixtures/`

**Available**:
- `sample_resume.md` - Valid resume (all sections)
- `old_resume_stale.md` - 14 days old
- `old_resume_very_stale.md` - 45 days old
- `minimal_resume.md` - Bare minimum format

**Purpose**:
- Reproducible testing
- Known-good formats
- Edge case testing
- Regression detection

**Usage in tests**:
```bash
# Create test environment
TEMP_DIR=$(mktemp -d)
cp fixtures/sample_resume.md "$TEMP_DIR/CLAUDE_RESUME.md"

# Test
./scripts/check_staleness.sh "$TEMP_DIR/CLAUDE_RESUME.md"

# Cleanup
rm -rf "$TEMP_DIR"
```

---

## Contributing Guidelines

### Before Making Changes

1. **Read DESIGN_DECISIONS.md** - Understand why things are the way they are
2. **Run tests** - Ensure current baseline: `./tests/test_scripts.sh`
3. **Create branch** - Don't work on main: `git checkout -b feature/my-change`

---

### Making Changes

**Code style**:
- Bash scripts: Follow existing patterns
- Use `set -e` for error handling
- Quote all variables: `"$VAR"` not `$VAR`
- Add comments for complex logic
- Keep functions small (<50 lines)

**Documentation**:
- Update SKILL.md if behavior changes
- Update relevant references/ docs
- Add examples for new features
- Update version numbers

**Testing**:
- Add test for new functionality
- Update existing tests if behavior changes
- Ensure all tests pass before committing
- Test on both macOS and Linux if possible

---

### Submitting Changes

**Commit guidelines**:
```bash
# Good commit messages
git commit -S -s -m "Add support for ISO date format in check_staleness.sh"
git commit -S -s -m "Fix: Handle resume files with BOM markers"

# Use -S for GPG signature, -s for sign-off
```

**Pull request**:
1. Fork repository
2. Create feature branch
3. Make changes + tests
4. Run test suite
5. Submit PR with description
6. Link to related issues

**PR description template**:
```markdown
## What

Brief description of changes

## Why

Motivation and context

## Testing

- [ ] All tests passing
- [ ] Tested on macOS
- [ ] Tested on Linux (if applicable)
- [ ] Added new tests (if applicable)

## Documentation

- [ ] Updated SKILL.md (if behavior changed)
- [ ] Updated references/ (if needed)
- [ ] Added examples (if new feature)
```

---

## Development Workflow

### Local Development

**Setup**:
```bash
# Clone repository
git clone https://github.com/ChristopherA/claude_code_tools.git
cd claude_code_tools/skills/session-resume

# Symlink to Claude skills directory
ln -s $PWD ~/.claude/skills/session-resume

# Now changes are immediately available
```

**Test changes**:
```bash
# Run test suite
cd tests/
./test_scripts.sh

# Test specific script
./scripts/check_staleness.sh

# Debug mode
bash -x ./scripts/check_staleness.sh
```

---

### Version Numbering

**Semantic versioning**: MAJOR.MINOR.PATCH

**Examples**:
- `1.3.0` - Current version (Phase 2: progressive disclosure)
- `1.2.1` - Previous (cross-platform fix)
- `1.2.0` - Previous (added Project Status)
- `1.1.0` - Previous (initial release)

**When to increment**:
- **MAJOR**: Breaking changes (resume format changes)
- **MINOR**: New features (new sections, new scripts)
- **PATCH**: Bug fixes (date parsing, error handling)

**Update locations**:
1. SKILL.md frontmatter: `version: 1.3.0`
2. SKILL.md footer: `*Session-resume skill v1.3.0 ...*`
3. Script headers: `# Part of session-resume skill v1.3.0`
4. marketplace.json: `"version": "1.3.0"`

---

## Debugging

### Enable Debug Output

**Script debug mode**:
```bash
bash -x ./scripts/check_staleness.sh
```

**Output shows**:
- Each command before execution
- Variable expansions
- Conditional evaluations
- Exit codes

**Example output**:
```bash
+ RESUME=CLAUDE_RESUME.md
+ '[' '!' -f CLAUDE_RESUME.md ']'
+ grep -i 'Last Session' CLAUDE_RESUME.md
+ head -1
+ SESSION_DATE_LINE='**Last Session**: November 5, 2025 (Tuesday)'
```

---

### Common Issues

**Issue**: Date parsing fails

**Debug**:
```bash
# Extract date line
grep -i "Last Session" CLAUDE_RESUME.md

# Check date format
echo "$SESSION_DATE"  # Should be "Month DD, YYYY"

# Test date command
date -d "November 5, 2025" +%s  # Linux
date -j -f "%B %d, %Y" "November 5, 2025" +%s  # macOS
```

---

**Issue**: Script not found

**Debug**:
```bash
# Check script location
ls -la ~/.claude/skills/session-resume/scripts/

# Check permissions
ls -la ~/.claude/skills/session-resume/scripts/check_staleness.sh

# Fix permissions
chmod +x ~/.claude/skills/session-resume/scripts/*.sh
```

---

## Performance Considerations

### Script Efficiency

**check_staleness.sh**:
- Single grep operation
- One date calculation
- No loops
- Time: ~5ms

**Optimization opportunities**:
- Cache date calculations (not implemented - complexity vs benefit)
- Use compiled tool instead of bash (not needed - fast enough)

**list_archives.sh**:
- Uses `ls -t` (efficient time-based sort)
- No file content reading
- Time: ~10ms for 10 files

**Optimization opportunities**:
- None needed - already efficient

---

## Security Considerations

### Input Validation

**File paths**:
- Always quote: `"$RESUME"`
- No `eval` used
- No user-controlled command execution

**Date parsing**:
- Uses strict format matching
- No shell expansion in date strings
- Fails safely on invalid input

### Script Permissions

**Required**: Execute permission (`+x`)

**Recommended**: Don't make world-writable
```bash
chmod 755 scripts/*.sh  # Good
chmod 777 scripts/*.sh  # Bad
```

---

*Development guide for session-resume v1.3.0*
