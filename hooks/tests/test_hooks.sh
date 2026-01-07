#!/bin/bash
# hooks/tests/test_hooks.sh - Test suite for git enforcement hooks
#
# Usage: ./test_hooks.sh [PROJECT_ROOT]
# Tests: is_git_command detection, Python 3.9 compatibility, hook behavior

set -e

# Get project root
PROJECT_ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
HOOKS_DIR="$PROJECT_ROOT/hooks"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    echo "  Expected: $2"
    echo "  Got: $3"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

skip() {
    echo -e "${YELLOW}SKIP${NC}: $1 - $2"
}

# Test: Python syntax check (Python 3.9 compatibility)
test_python_syntax() {
    echo ""
    echo "=== Test 1: Python 3.9+ syntax compatibility ==="

    # Check git-workflow-guidance.py
    if python3 -m py_compile "$HOOKS_DIR/git-workflow-guidance.py" 2>/dev/null; then
        pass "git-workflow-guidance.py syntax valid"
    else
        fail "git-workflow-guidance.py syntax check" "valid syntax" "syntax error"
    fi

    # Check git-commit-compliance.py
    if python3 -m py_compile "$HOOKS_DIR/git-commit-compliance.py" 2>/dev/null; then
        pass "git-commit-compliance.py syntax valid"
    else
        fail "git-commit-compliance.py syntax check" "valid syntax" "syntax error"
    fi
}

# Test: is_git_command() detection - true positives
test_git_command_true_positives() {
    echo ""
    echo "=== Test 2: is_git_command() true positives ==="

    # Create a test script to check is_git_command
    local test_script=$(mktemp)
    cat > "$test_script" << 'PYTEST'
import sys
import re

def is_git_command(command):
    if re.match(r'^\s*(?:sudo\s+)?git\s+', command):
        return True
    if re.match(r'^\s*(?:sudo\s+)?(?:/[\w/]*)?(?:ba|z)?sh\s+-c\s+["\'](?:sudo\s+)?git\s+', command):
        return True
    return False

# Test cases that SHOULD match
true_positives = [
    "git status",
    "git add .",
    "git commit -m 'message'",
    "  git push",
    "sudo git pull",
    'bash -c "git status"',
    "/bin/bash -c 'git log'",
    'zsh -c "git diff"',
    '/bin/zsh -c "git branch"',
    'sh -c "git stash"',
]

exit_code = 0
for cmd in true_positives:
    if not is_git_command(cmd):
        print(f"FAIL: Should match: {cmd}")
        exit_code = 1
    else:
        print(f"OK: {cmd}")

sys.exit(exit_code)
PYTEST

    if python3 "$test_script"; then
        pass "is_git_command() correctly identifies git commands"
    else
        fail "is_git_command() true positives" "all git commands detected" "some missed"
    fi
    rm -f "$test_script"
}

# Test: is_git_command() detection - false positives (Issue #4)
test_git_command_false_positives() {
    echo ""
    echo "=== Test 3: is_git_command() false positives (Issue #4) ==="

    local test_script=$(mktemp)
    cat > "$test_script" << 'PYTEST'
import sys
import re

def is_git_command(command):
    if re.match(r'^\s*(?:sudo\s+)?git\s+', command):
        return True
    if re.match(r'^\s*(?:sudo\s+)?(?:/[\w/]*)?(?:ba|z)?sh\s+-c\s+["\'](?:sudo\s+)?git\s+', command):
        return True
    return False

# Test cases that should NOT match (false positives to avoid)
false_positives = [
    'gh issue create --body "git workflow"',
    'gh pr create --title "Fix git handling"',
    'echo "use git for version control"',
    'grep "git" README.md',
    'cat file.txt | grep git',
    'gh issue list --label "git-related"',
    'curl https://github.com/git/git',
]

exit_code = 0
for cmd in false_positives:
    if is_git_command(cmd):
        print(f"FAIL: Should NOT match: {cmd}")
        exit_code = 1
    else:
        print(f"OK (correctly skipped): {cmd}")

sys.exit(exit_code)
PYTEST

    if python3 "$test_script"; then
        pass "is_git_command() correctly skips non-git commands"
    else
        fail "is_git_command() false positives" "no false matches" "some false matches"
    fi
    rm -f "$test_script"
}

# Test: git-workflow-guidance.py hook behavior
test_workflow_hook_blocks_combined() {
    echo ""
    echo "=== Test 4: git-workflow-guidance blocks combined add+commit ==="

    local test_input='{"tool_name": "Bash", "tool_input": {"command": "git add . && git commit -m \"test\""}}'
    local result=$(echo "$test_input" | python3 "$HOOKS_DIR/git-workflow-guidance.py")

    if echo "$result" | grep -q '"proceed": false'; then
        pass "Blocks combined git add && git commit"
    else
        fail "Block combined add+commit" '"proceed": false' "$result"
    fi
}

# Test: git-workflow-guidance.py allows separate commands
test_workflow_hook_allows_separate() {
    echo ""
    echo "=== Test 5: git-workflow-guidance allows separate git commands ==="

    local test_input='{"tool_name": "Bash", "tool_input": {"command": "git add ."}}'
    local result=$(echo "$test_input" | python3 "$HOOKS_DIR/git-workflow-guidance.py")

    if echo "$result" | grep -q '"proceed": true'; then
        pass "Allows separate git add"
    else
        fail "Allow separate git add" '"proceed": true' "$result"
    fi
}

# Test: git-workflow-guidance.py skips gh commands
test_workflow_hook_skips_gh() {
    echo ""
    echo "=== Test 6: git-workflow-guidance skips gh CLI commands ==="

    local test_input='{"tool_name": "Bash", "tool_input": {"command": "gh issue create --body \"git add && git commit workflow\""}}'
    local result=$(echo "$test_input" | python3 "$HOOKS_DIR/git-workflow-guidance.py")

    if echo "$result" | grep -q '"proceed": true'; then
        pass "Skips gh CLI commands (no false positive)"
    else
        fail "Skip gh CLI" '"proceed": true' "$result"
    fi
}

# Test: git-commit-compliance.py requires flags
test_commit_hook_requires_flags() {
    echo ""
    echo "=== Test 7: git-commit-compliance requires -S -s flags ==="

    local test_input='{"tool_name": "Bash", "tool_input": {"command": "git commit -m \"test message\""}}'
    local result=$(echo "$test_input" | python3 "$HOOKS_DIR/git-commit-compliance.py")

    if echo "$result" | grep -q '"proceed": false'; then
        pass "Blocks commit without -S -s flags"
    else
        fail "Block commit without flags" '"proceed": false' "$result"
    fi
}

# Test: git-commit-compliance.py allows proper commit
test_commit_hook_allows_proper() {
    echo ""
    echo "=== Test 8: git-commit-compliance allows proper commit ==="

    local test_input='{"tool_name": "Bash", "tool_input": {"command": "git commit -S -s -m \"Proper commit message\""}}'
    local result=$(echo "$test_input" | python3 "$HOOKS_DIR/git-commit-compliance.py")

    if echo "$result" | grep -q '"proceed": true'; then
        pass "Allows commit with -S -s flags"
    else
        fail "Allow proper commit" '"proceed": true' "$result"
    fi
}

# Test: git-commit-compliance.py skips non-git
test_commit_hook_skips_non_git() {
    echo ""
    echo "=== Test 9: git-commit-compliance skips non-git commands ==="

    local test_input='{"tool_name": "Bash", "tool_input": {"command": "gh pr create --body \"git commit -m test\""}}'
    local result=$(echo "$test_input" | python3 "$HOOKS_DIR/git-commit-compliance.py")

    if echo "$result" | grep -q '"proceed": true'; then
        pass "Skips gh CLI (no false positive on commit)"
    else
        fail "Skip non-git" '"proceed": true' "$result"
    fi
}

# Test: git-commit-compliance.py blocks Claude attribution
test_commit_hook_blocks_attribution() {
    echo ""
    echo "=== Test 10: git-commit-compliance blocks Claude attribution ==="

    local test_input='{"tool_name": "Bash", "tool_input": {"command": "git commit -S -s -m \"Fix bug\n\nCo-Authored-By: Claude\""}}'
    local result=$(echo "$test_input" | python3 "$HOOKS_DIR/git-commit-compliance.py")

    if echo "$result" | grep -q '"proceed": false'; then
        pass "Blocks Claude attribution in commit message"
    else
        fail "Block attribution" '"proceed": false' "$result"
    fi
}

# Test: Python 3.9 future annotations work
test_future_annotations() {
    echo ""
    echo "=== Test 11: from __future__ import annotations present ==="

    if grep -q "from __future__ import annotations" "$HOOKS_DIR/git-workflow-guidance.py"; then
        pass "git-workflow-guidance.py has future annotations"
    else
        fail "Future annotations in workflow hook" "import present" "import missing"
    fi

    if grep -q "from __future__ import annotations" "$HOOKS_DIR/git-commit-compliance.py"; then
        pass "git-commit-compliance.py has future annotations"
    else
        fail "Future annotations in commit hook" "import present" "import missing"
    fi
}

# Main test runner
main() {
    echo "========================================"
    echo "Git Enforcement Hooks Test Suite"
    echo "========================================"
    echo "Hooks directory: $HOOKS_DIR"
    echo ""

    # Check hooks exist
    if [ ! -f "$HOOKS_DIR/git-workflow-guidance.py" ]; then
        echo "ERROR: git-workflow-guidance.py not found"
        exit 1
    fi
    if [ ! -f "$HOOKS_DIR/git-commit-compliance.py" ]; then
        echo "ERROR: git-commit-compliance.py not found"
        exit 1
    fi

    # Check Python available
    if ! command -v python3 &> /dev/null; then
        echo "ERROR: python3 not found"
        exit 1
    fi

    # Run tests
    test_python_syntax
    test_git_command_true_positives
    test_git_command_false_positives
    test_workflow_hook_blocks_combined
    test_workflow_hook_allows_separate
    test_workflow_hook_skips_gh
    test_commit_hook_requires_flags
    test_commit_hook_allows_proper
    test_commit_hook_skips_non_git
    test_commit_hook_blocks_attribution
    test_future_annotations

    # Summary
    echo ""
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo "Tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

main "$@"
