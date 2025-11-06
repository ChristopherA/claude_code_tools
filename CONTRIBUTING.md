# Contributing to Session Skills

Thank you for your interest in contributing to the session-skills plugin! This document provides guidelines for contributing to the project.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

---

## Code of Conduct

### Our Standards

- **Be respectful**: Treat all contributors with respect
- **Be collaborative**: Work together to improve the project
- **Be constructive**: Provide helpful feedback
- **Be patient**: Remember that everyone is learning

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Personal attacks
- Publishing others' private information

### Enforcement

Instances of unacceptable behavior may be reported to [ChristopherA@LifeWithAlacrity.com](mailto:ChristopherA@LifeWithAlacrity.com). All complaints will be reviewed and investigated.

---

## Getting Started

### Prerequisites

- **Git**: Version control
- **Bash**: Shell for scripts (macOS/Linux)
- **Claude Code**: For testing skills
- **GPG** (optional): For signed commits

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/claude_code_tools.git
cd claude_code_tools
```

---

## Development Setup

### Install Skills Locally

```bash
# Option 1: Symlink for development (changes immediately available)
ln -s $PWD/skills/session-closure ~/.claude/skills/session-closure
ln -s $PWD/skills/session-resume ~/.claude/skills/session-resume

# Option 2: Copy for testing
cp -r skills/session-closure ~/.claude/skills/
cp -r skills/session-resume ~/.claude/skills/
```

### Verify Installation

```bash
# Check skills are available
ls ~/.claude/skills/session-*/SKILL.md

# Run test suites
cd skills/session-closure/tests
./test_scripts.sh

cd ../../session-resume/tests
./test_scripts.sh
```

**Expected**: All tests passing (14 tests, 20 assertions)

---

## How to Contribute

### Reporting Bugs

**Before submitting**:
1. Check existing issues: https://github.com/ChristopherA/claude_code_tools/issues
2. Verify you're on latest version: `grep version ~/.claude/skills/*/SKILL.md`
3. Try to reproduce with minimal test case

**Bug report should include**:
- Version number
- Operating system (macOS/Linux)
- Steps to reproduce
- Expected behavior
- Actual behavior
- Error messages or logs
- Test output: `./tests/test_scripts.sh`

**Example**:
```markdown
**Version**: 1.3.0
**OS**: macOS 14.0
**Issue**: check_staleness.sh returns "error" for valid resume

**Steps**:
1. Create CLAUDE_RESUME.md with "**Last Session**: November 5, 2025"
2. Run `./scripts/check_staleness.sh`
3. Returns "error" instead of "fresh"

**Expected**: Returns "fresh"
**Actual**: Returns "error"

**Test output**:
```
./tests/test_scripts.sh
Test 4: Check staleness (fresh resume)
✗ Fresh resume NOT detected correctly
```
```

### Suggesting Features

**Feature requests should include**:
- Clear use case: What problem does this solve?
- User benefit: Who benefits and how?
- Implementation sketch: Rough idea of approach
- Compatibility: Impact on existing features

**Example**:
```markdown
**Feature**: Archive search by content keywords

**Use Case**: User wants to find resume mentioning specific feature

**Benefit**: Faster discovery of relevant past sessions

**Implementation**: New script `search_archives.sh` that greps all archives

**Compatibility**: No breaking changes, new optional feature
```

---

## Coding Standards

### Bash Scripts

**Style**:
```bash
#!/bin/bash
# script_name.sh - Brief description
# Part of session-SKILLNAME skill vX.Y.Z

set -e  # Exit on error

# Use descriptive variable names
RESUME_FILE="CLAUDE_RESUME.md"

# Quote all variables
if [ -f "$RESUME_FILE" ]; then
    echo "Found: $RESUME_FILE"
fi

# Add comments for complex logic
# Extract date from "Last Session: Month DD, YYYY" format
SESSION_DATE=$(grep -i "Last Session" "$RESUME_FILE" | ...)
```

**Best practices**:
- Use `set -e` for error handling
- Quote all variables: `"$VAR"` not `$VAR`
- Use descriptive variable names (UPPERCASE for constants)
- Add comments for non-obvious logic
- Keep functions small (<50 lines)
- Test on both macOS and Linux if possible

### SKILL.md Format

**Structure**:
```markdown
---
name: skill-name
version: X.Y.Z
description: >
  What the skill does. When to use it (WHEN). When NOT to use it (WHEN NOT).
---

# Skill Title

## Main Steps

### Step 1: First Task

Instructions...

### Step 2: Second Task

Instructions...

---

## Additional Documentation

For detailed information, see references/...

---

*Skill name vX.Y.Z - Brief tagline*
```

**Best practices**:
- Keep task instructions clear and concise
- Use progressive disclosure (references/ for details)
- Include script invocations with examples
- Update version in 3 places (frontmatter, scripts, footer)

### Markdown Documentation

**Style**:
- Use ATX-style headers (`#` not underlines)
- One sentence per line (easier diffs)
- Code blocks with language identifiers
- Use **bold** for emphasis, `code` for literals
- Include examples for complex concepts

---

## Testing Requirements

### Running Tests

**Before submitting PR**:
```bash
# Test session-closure
cd skills/session-closure/tests
./test_scripts.sh
# Must see: "Tests passed: 12"

# Test session-resume
cd skills/session-resume/tests
./test_scripts.sh
# Must see: "Tests passed: 8"
```

### Writing New Tests

**When to add tests**:
- New feature added
- Bug fixed (regression test)
- Edge case discovered

**Test structure**:
```bash
# Test N: Brief description
TEST_DIR=$(mktemp -d)
# Setup
echo "Test data" > "$TEST_DIR/file.md"

# Execute
RESULT=$(./script.sh "$TEST_DIR/file.md")

# Assert
if [ "$RESULT" = "expected" ]; then
    echo "✓ Test N passed"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Test N failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Cleanup
rm -rf "$TEST_DIR"
```

### Cross-Platform Testing

**If modifying scripts that use date, grep, or other commands**:
- Test on macOS (BSD tools)
- Test on Linux (GNU tools) if available
- Use `$OSTYPE` for OS detection when needed
- Document platform-specific behavior

---

## Documentation

### What to Document

**Always update**:
- SKILL.md if behavior changes
- References/ files if relevant
- CHANGELOG.md with changes
- Test documentation if tests added

**Version changes require**:
1. SKILL.md frontmatter: `version: X.Y.Z`
2. SKILL.md footer: `*Skill name vX.Y.Z ...*`
3. Script headers: `# Part of skill vX.Y.Z`
4. marketplace.json: `"version": "X.Y.Z"`
5. CHANGELOG.md: New entry

### Documentation Style

**Clear and concise**:
- Short sentences
- Active voice
- Code examples
- Real-world scenarios

**Example documentation**:
```markdown
### check_staleness.sh

**Purpose**: Calculate resume age in days.

**Usage**:
```bash
./check_staleness.sh [RESUME_FILE]
```

**Output**: `fresh`, `recent`, `stale`, `very_stale`, or `error`

**Example**:
```bash
./check_staleness.sh
# Output: fresh
```
```

---

## Commit Guidelines

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `test`: Adding or updating tests
- `refactor`: Code restructuring
- `perf`: Performance improvement
- `chore`: Maintenance tasks

**Example**:
```
fix: Handle resume files with BOM markers

check_staleness.sh was failing on resume files with UTF-8 BOM
(byte order mark). Added BOM detection and stripping.

Fixes #42
```

### Signed Commits

**Required for all commits**:
```bash
git commit -S -s -m "Your message"
```

**Flags**:
- `-S`: GPG signature (cryptographic verification)
- `-s`: Sign-off (DCO compliance)

**Setup GPG** (if needed):
```bash
# Generate key
gpg --full-generate-key

# List keys
gpg --list-secret-keys --keyid-format LONG

# Configure git
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

### What NOT to Commit

**Never commit**:
- Temporary files (*.tmp, *.swp)
- IDE files (.vscode/, .idea/)
- OS files (.DS_Store, Thumbs.db)
- Personal credentials
- Test output files
- Large binary files

**Use .gitignore** - it's already configured.

---

## Pull Request Process

### Before Submitting

**Checklist**:
- [ ] All tests passing
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Commits signed (`-S -s`)
- [ ] Branch from latest `main`
- [ ] No merge conflicts

### PR Description Template

```markdown
## What

Brief description of changes (1-2 sentences)

## Why

Motivation and context for the change

## Changes

- List of specific changes
- Each change on separate line
- Include file paths if helpful

## Testing

- [ ] All existing tests passing
- [ ] Added new tests for feature/fix (if applicable)
- [ ] Tested on macOS
- [ ] Tested on Linux (if applicable)
- [ ] Manual testing performed

## Documentation

- [ ] Updated SKILL.md (if behavior changed)
- [ ] Updated references/ (if needed)
- [ ] Updated CHANGELOG.md
- [ ] Added examples (if new feature)

## Breaking Changes

- [ ] No breaking changes
- [ ] Breaking changes described below (if any)

## Related Issues

Fixes #ISSUE_NUMBER (if applicable)
```

### Review Process

1. **Automated checks**: Tests must pass
2. **Code review**: Maintainer reviews code
3. **Discussion**: Address feedback
4. **Approval**: Maintainer approves
5. **Merge**: Squash and merge to main

**Timeline**: Expect response within 3-5 business days

### After Merge

- PR merged → appears in next release
- Credit given in CHANGELOG.md
- Closed issues linked to PR

---

## Release Process

*(For maintainers)*

### Version Numbers

**Semantic Versioning**: MAJOR.MINOR.PATCH

- **MAJOR**: Breaking changes (e.g., 2.0.0)
- **MINOR**: New features, backward compatible (e.g., 1.4.0)
- **PATCH**: Bug fixes, backward compatible (e.g., 1.3.1)

### Release Checklist

1. **Update version numbers** (5 locations):
   - [ ] session-closure/SKILL.md (frontmatter + footer)
   - [ ] session-resume/SKILL.md (frontmatter + footer)
   - [ ] All script headers
   - [ ] marketplace.json
   - [ ] CHANGELOG.md

2. **Run all tests**:
   ```bash
   cd skills/session-closure/tests && ./test_scripts.sh
   cd skills/session-resume/tests && ./test_scripts.sh
   ```

3. **Update CHANGELOG.md**:
   - Add new version section
   - List all changes
   - Credit contributors

4. **Commit and tag**:
   ```bash
   git commit -S -s -m "Release vX.Y.Z"
   git tag -a -s vX.Y.Z -m "Release vX.Y.Z: Brief description"
   git push origin main
   git push origin vX.Y.Z
   ```

5. **Create GitHub release**:
   - Go to https://github.com/ChristopherA/claude_code_tools/releases
   - Draft new release from tag
   - Copy CHANGELOG entry
   - Publish release

---

## Questions?

- **GitHub Discussions**: https://github.com/ChristopherA/claude_code_tools/discussions
- **GitHub Issues**: https://github.com/ChristopherA/claude_code_tools/issues
- **Email**: ChristopherA@LifeWithAlacrity.com

---

## Recognition

Contributors are recognized in:
- CHANGELOG.md (per release)
- GitHub contributors page
- Release notes

Thank you for contributing! 🎉

---

*Contributing guidelines for session-skills v1.3.0*
*Last updated: November 5, 2025*
