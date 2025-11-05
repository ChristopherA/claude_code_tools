#!/bin/bash
# test_scripts.sh - Test suite for session-resume scripts
# Part of session-resume skill v1.1.0
#
# Usage: ./test_scripts.sh
#
# Tests:
# 1. list_archives.sh - No archives
# 2. list_archives.sh - Multiple archives
# 3. list_archives.sh - Limit parameter
# 4. check_staleness.sh - Fresh resume (<1 day)
# 5. check_staleness.sh - Recent resume (1-6 days)
# 6. check_staleness.sh - Stale resume (7-29 days)
# 7. check_staleness.sh - Very stale resume (30+ days)
# 8. check_staleness.sh - Missing file

set -e

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURE_DIR="$TEST_DIR/fixtures"
TEMP_DIR="$TEST_DIR/tmp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Utility functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

setup_test_env() {
    # Create temp directory for testing
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
}

cleanup_test_env() {
    cd "$TEST_DIR"
    rm -rf "$TEMP_DIR"
}

# Test 1: list_archives with no archives
test_list_no_archives() {
    echo ""
    echo "Test 1: List archives (none exist)"
    TESTS_RUN=$((TESTS_RUN + 1))

    setup_test_env

    # Execute: list archives when none exist
    OUTPUT=$("$SCRIPT_DIR/list_archives.sh" 2>&1)

    # Verify: Reports no archives
    if [[ "$OUTPUT" == "No archives found" ]]; then
        pass "Correctly reports no archives"
    else
        fail "Expected 'No archives found', got: $OUTPUT"
    fi

    cleanup_test_env
}

# Test 2: list_archives with multiple archives
test_list_multiple_archives() {
    echo ""
    echo "Test 2: List archives (multiple exist)"
    TESTS_RUN=$((TESTS_RUN + 1))

    setup_test_env

    # Setup: Create archive directory with 3 files
    mkdir -p archives/CLAUDE_RESUME
    echo "Archive 1" > archives/CLAUDE_RESUME/2025-10-27-1400.md
    sleep 0.1
    echo "Archive 2" > archives/CLAUDE_RESUME/2025-10-28-1000.md
    sleep 0.1
    echo "Archive 3" > archives/CLAUDE_RESUME/2025-10-29-1600.md

    # Execute: list archives
    OUTPUT=$("$SCRIPT_DIR/list_archives.sh" 2>&1)

    # Verify: Lists archives (newest first)
    if [[ "$OUTPUT" == *"2025-10-29-1600"* ]] && [[ "$OUTPUT" == *"2025-10-28-1000"* ]]; then
        pass "Lists archives correctly"
    else
        fail "Expected archive timestamps in output, got: $OUTPUT"
    fi

    cleanup_test_env
}

# Test 3: list_archives with limit parameter
test_list_with_limit() {
    echo ""
    echo "Test 3: List archives (with limit)"
    TESTS_RUN=$((TESTS_RUN + 1))

    setup_test_env

    # Setup: Create 5 archives
    mkdir -p archives/CLAUDE_RESUME
    for i in {1..5}; do
        echo "Archive $i" > "archives/CLAUDE_RESUME/2025-10-2$i-1000.md"
        sleep 0.05
    done

    # Execute: list with limit of 2
    OUTPUT=$("$SCRIPT_DIR/list_archives.sh" --limit 2 2>&1)
    LINE_COUNT=$(echo "$OUTPUT" | wc -l | tr -d ' ')

    # Verify: Only 2 archives listed
    if [ "$LINE_COUNT" -eq 2 ]; then
        pass "Limit parameter works correctly"
    else
        fail "Expected 2 lines, got: $LINE_COUNT"
    fi

    cleanup_test_env
}

# Test 4: check_staleness - Fresh resume
test_staleness_fresh() {
    echo ""
    echo "Test 4: Check staleness (fresh resume)"
    TESTS_RUN=$((TESTS_RUN + 1))

    setup_test_env

    # Setup: Use fresh resume fixture
    cp "$FIXTURE_DIR/fresh_resume.md" CLAUDE_RESUME.md

    # Execute: check staleness
    OUTPUT=$("$SCRIPT_DIR/check_staleness.sh" CLAUDE_RESUME.md 2>&1)

    # Verify: Reports fresh (or recent if run on different day)
    if [[ "$OUTPUT" == "fresh" ]] || [[ "$OUTPUT" == "recent" ]]; then
        pass "Fresh resume detected correctly"
    else
        fail "Expected 'fresh' or 'recent', got: $OUTPUT"
    fi

    cleanup_test_env
}

# Test 5: check_staleness - Stale resume
test_staleness_stale() {
    echo ""
    echo "Test 5: Check staleness (stale resume)"
    TESTS_RUN=$((TESTS_RUN + 1))

    setup_test_env

    # Setup: Use stale resume fixture (October 15, 2025)
    cp "$FIXTURE_DIR/stale_resume.md" CLAUDE_RESUME.md

    # Execute: check staleness
    OUTPUT=$("$SCRIPT_DIR/check_staleness.sh" CLAUDE_RESUME.md 2>&1)

    # Verify: Reports stale or very_stale (depending on current date)
    if [[ "$OUTPUT" == "stale" ]] || [[ "$OUTPUT" == "very_stale" ]]; then
        pass "Stale resume detected correctly"
    else
        fail "Expected 'stale' or 'very_stale', got: $OUTPUT"
    fi

    cleanup_test_env
}

# Test 6: check_staleness - Missing file
test_staleness_missing() {
    echo ""
    echo "Test 6: Check staleness (missing file)"
    TESTS_RUN=$((TESTS_RUN + 1))

    setup_test_env

    # Execute: check staleness on non-existent file (allow error exit code)
    set +e  # Temporarily disable exit on error
    OUTPUT=$("$SCRIPT_DIR/check_staleness.sh" nonexistent.md 2>&1)
    set -e  # Re-enable exit on error

    # Verify: Reports error
    if [[ "$OUTPUT" == "error" ]]; then
        pass "Missing file handled correctly"
    else
        fail "Expected 'error', got: $OUTPUT"
    fi

    cleanup_test_env
}

# Test 7: list_archives - Detailed format
test_list_detailed_format() {
    echo ""
    echo "Test 7: List archives (detailed format)"
    TESTS_RUN=$((TESTS_RUN + 1))

    setup_test_env

    # Setup: Create archives
    mkdir -p archives/CLAUDE_RESUME
    echo "Archive 1" > archives/CLAUDE_RESUME/2025-10-27-1400.md

    # Execute: list with detailed format
    OUTPUT=$("$SCRIPT_DIR/list_archives.sh" --format detailed 2>&1)

    # Verify: Shows count and details
    if [[ "$OUTPUT" == *"Found"* ]] && [[ "$OUTPUT" == *"archived session"* ]]; then
        pass "Detailed format works correctly"
    else
        fail "Expected detailed format output, got: $OUTPUT"
    fi

    cleanup_test_env
}

# Test 8: list_archives - Empty directory (created but no files)
test_list_empty_directory() {
    echo ""
    echo "Test 8: List archives (empty directory)"
    TESTS_RUN=$((TESTS_RUN + 1))

    setup_test_env

    # Setup: Create empty archive directory
    mkdir -p archives/CLAUDE_RESUME

    # Execute: list archives
    OUTPUT=$("$SCRIPT_DIR/list_archives.sh" 2>&1)

    # Verify: Reports no archives
    if [[ "$OUTPUT" == "No archives found" ]]; then
        pass "Empty directory handled correctly"
    else
        fail "Expected 'No archives found', got: $OUTPUT"
    fi

    cleanup_test_env
}

# Run all tests
echo "========================================"
echo "session-resume Script Test Suite"
echo "========================================"

test_list_no_archives
test_list_multiple_archives
test_list_with_limit
test_staleness_fresh
test_staleness_stale
test_staleness_missing
test_list_detailed_format
test_list_empty_directory

# Summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
else
    echo "Tests failed: $TESTS_FAILED"
fi
echo "========================================"

# Exit with failure if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
