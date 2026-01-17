#!/bin/bash
#
# Definition of Done (DoD) Checker
# Verifies all DoD criteria are met before task completion
#
# Usage: ./scripts/check-dod.sh [commit-message]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║            DEFINITION OF DONE CHECKER                         ║${NC}"
echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

# Helper function
check() {
    local name="$1"
    local status="$2"
    local message="$3"

    if [[ "$status" == "pass" ]]; then
        echo -e "   ${GREEN}✅${NC} $name"
        PASSED=$((PASSED + 1))
    elif [[ "$status" == "warn" ]]; then
        echo -e "   ${YELLOW}⚠️${NC}  $name - $message"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "   ${RED}❌${NC} $name - $message"
        FAILED=$((FAILED + 1))
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CODE CHANGES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BOLD}CODE CHANGES${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Code compiles
BUILD_OUTPUT=$(xcodebuild build -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -quiet 2>&1) || true
if echo "$BUILD_OUTPUT" | grep -q "BUILD SUCCEEDED"; then
    check "Code compiles" "pass"
else
    check "Code compiles" "fail" "Build failed"
fi

# 2. Tests pass
TEST_OUTPUT=$(xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' -quiet 2>&1) || true
FAILURE_COUNT=$(echo "$TEST_OUTPUT" | grep -oE "[0-9]+ failure" | head -1 | grep -oE "[0-9]+" || echo "0")
if [[ "$FAILURE_COUNT" == "0" ]]; then
    check "Tests pass" "pass"
else
    check "Tests pass" "fail" "$FAILURE_COUNT test(s) failed"
fi

# 3. No new warnings
WARNING_COUNT=$(echo "$BUILD_OUTPUT" | grep -c "warning:" 2>/dev/null || echo "0")
if [[ "$WARNING_COUNT" == "0" ]]; then
    check "No warnings" "pass"
else
    check "No warnings" "warn" "$WARNING_COUNT warning(s)"
fi

# 4. Version consistency
if ./scripts/version-check.sh > /dev/null 2>&1; then
    check "Versions aligned" "pass"
else
    check "Versions aligned" "warn" "Run ./scripts/update-version.sh"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GIT & GITHUB
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BOLD}GIT & GITHUB${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 5. Check for uncommitted changes
UNCOMMITTED=$(git status --porcelain | wc -l | tr -d ' ')
if [[ "$UNCOMMITTED" == "0" ]]; then
    check "Changes committed" "pass"
else
    check "Changes committed" "warn" "$UNCOMMITTED uncommitted file(s)"
fi

# 6. Check commit message format (if provided)
if [[ -n "$1" ]]; then
    COMMIT_MSG="$1"
    # Check conventional commit format: type(scope): description
    if echo "$COMMIT_MSG" | grep -qE "^(feat|fix|docs|test|refactor|chore|style|perf|ci|build|revert)(\(.+\))?: .+"; then
        check "Conventional commit" "pass"
    else
        check "Conventional commit" "fail" "Use format: type(scope): description"
    fi
else
    check "Conventional commit" "warn" "Provide commit message to check"
fi

# 7. Check if pushed
AHEAD=$(git status | grep -c "ahead" || echo "0")
if [[ "$AHEAD" == "0" ]] && [[ "$UNCOMMITTED" == "0" ]]; then
    check "Pushed to remote" "pass"
else
    check "Pushed to remote" "warn" "Changes not pushed"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DOCUMENTATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BOLD}DOCUMENTATION${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 8. Check CHANGELOG has current version
VERSION=$(cat VERSION.txt | tr -d '[:space:]')
if grep -q "## \[$VERSION\]" CHANGELOG.md 2>/dev/null; then
    check "CHANGELOG updated" "pass"
else
    check "CHANGELOG updated" "warn" "No entry for v$VERSION"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SUMMARY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BOLD}SUMMARY${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "   ${GREEN}Passed:${NC}   $PASSED"
echo -e "   ${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "   ${RED}Failed:${NC}   $FAILED"
echo ""

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}${BOLD}❌ DEFINITION OF DONE: NOT MET${NC}"
    echo -e "${RED}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Fix failed items before marking task complete."
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}${BOLD}⚠️  DEFINITION OF DONE: MET (with warnings)${NC}"
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Consider addressing warnings before completing."
    exit 0
else
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}✅ DEFINITION OF DONE: FULLY MET${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    exit 0
fi
