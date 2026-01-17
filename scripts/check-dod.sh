#!/bin/bash
#
# Definition of Done (DoD) Checker
# Verifies all DoD criteria are met before task completion
#
# Usage:
#   ./scripts/check-dod.sh [commit-message]           # Code task
#   ./scripts/check-dod.sh --research [provider-name] # Research/Integration study
#   ./scripts/check-dod.sh -r [provider-name]         # Short form
#
# Examples:
#   ./scripts/check-dod.sh "feat(ui): add dark mode"
#   ./scripts/check-dod.sh --research s3
#   ./scripts/check-dod.sh -r proton-drive
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

# Check for research mode
RESEARCH_MODE=false
PROVIDER_NAME=""

if [[ "$1" == "--research" ]] || [[ "$1" == "-r" ]]; then
    RESEARCH_MODE=true
    PROVIDER_NAME="$2"
fi

echo ""
echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
if [[ "$RESEARCH_MODE" == true ]]; then
    echo -e "${BOLD}${BLUE}║         DEFINITION OF DONE - RESEARCH TASK                   ║${NC}"
else
    echo -e "${BOLD}${BLUE}║            DEFINITION OF DONE CHECKER                         ║${NC}"
fi
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
# RESEARCH MODE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ "$RESEARCH_MODE" == true ]]; then

    echo -e "${BOLD}DOCUMENTATION${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Try to find guide file
    if [[ -n "$PROVIDER_NAME" ]]; then
        # Convert provider name to uppercase for filename matching
        PROVIDER_UPPER=$(echo "$PROVIDER_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        PROVIDER_LOWER=$(echo "$PROVIDER_NAME" | tr '[:upper:]' '[:lower:]')

        # Look for guide file with various naming patterns
        GUIDE_FILE=""
        for pattern in \
            "docs/providers/${PROVIDER_UPPER}_GUIDE.md" \
            "docs/providers/${PROVIDER_LOWER}_GUIDE.md" \
            "docs/providers/${PROVIDER_NAME}_GUIDE.md" \
            "docs/providers/${PROVIDER_NAME}.md"; do
            if [[ -f "$pattern" ]]; then
                GUIDE_FILE="$pattern"
                break
            fi
        done

        if [[ -n "$GUIDE_FILE" ]]; then
            check "Guide file exists" "pass"
            echo "         Found: $GUIDE_FILE"

            # Check required sections
            echo ""
            echo -e "${BOLD}REQUIRED SECTIONS${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

            if grep -qi "## Overview\|## Introduction\|## About" "$GUIDE_FILE"; then
                check "Overview section" "pass"
            else
                check "Overview section" "fail" "Missing ## Overview"
            fi

            if grep -qi "## Prerequisites\|## Requirements\|## Before" "$GUIDE_FILE"; then
                check "Prerequisites section" "pass"
            else
                check "Prerequisites section" "warn" "Consider adding ## Prerequisites"
            fi

            if grep -qi "## Authentication\|## Auth\|## Credentials\|## Login" "$GUIDE_FILE"; then
                check "Authentication section" "pass"
            else
                check "Authentication section" "fail" "Missing ## Authentication"
            fi

            if grep -qi "## Setup\|## Configuration\|## Getting Started\|## Connect" "$GUIDE_FILE"; then
                check "Setup section" "pass"
            else
                check "Setup section" "fail" "Missing ## Setup Steps"
            fi

            if grep -qi "## Troubleshooting\|## Common Issues\|## Problems\|## FAQ" "$GUIDE_FILE"; then
                check "Troubleshooting section" "pass"
            else
                check "Troubleshooting section" "warn" "Consider adding ## Troubleshooting"
            fi

            if grep -qi "## Edge Cases\|## Limitations\|## Known Issues\|## Quirks" "$GUIDE_FILE"; then
                check "Edge Cases section" "pass"
            else
                check "Edge Cases section" "warn" "Consider adding ## Edge Cases"
            fi

            if grep -qi "## References\|## Links\|## Resources\|https://rclone.org" "$GUIDE_FILE"; then
                check "References section" "pass"
            else
                check "References section" "warn" "Consider adding ## References"
            fi

            # Check for rclone docs link
            echo ""
            echo -e "${BOLD}EXTERNAL LINKS${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

            if grep -q "rclone.org" "$GUIDE_FILE"; then
                check "rclone docs linked" "pass"
            else
                check "rclone docs linked" "warn" "Add link to rclone.org docs"
            fi

            # Check word count (should be substantial)
            WORD_COUNT=$(wc -w < "$GUIDE_FILE" | tr -d ' ')
            if [[ $WORD_COUNT -ge 300 ]]; then
                check "Sufficient content ($WORD_COUNT words)" "pass"
            elif [[ $WORD_COUNT -ge 150 ]]; then
                check "Content length ($WORD_COUNT words)" "warn" "Consider expanding"
            else
                check "Content length ($WORD_COUNT words)" "fail" "Too brief, need more detail"
            fi

        else
            check "Guide file exists" "fail" "Not found in docs/providers/"
            echo ""
            echo "   Expected one of:"
            echo "   - docs/providers/${PROVIDER_UPPER}_GUIDE.md"
            echo "   - docs/providers/${PROVIDER_LOWER}_GUIDE.md"
        fi
    else
        echo "   No provider name specified"
        echo "   Usage: ./scripts/check-dod.sh --research [provider-name]"
        echo ""
        echo "   Checking for any provider guides..."

        GUIDE_COUNT=$(find docs/providers -name "*_GUIDE.md" 2>/dev/null | wc -l | tr -d ' ')
        if [[ $GUIDE_COUNT -gt 0 ]]; then
            check "Provider guides exist" "pass"
            echo "         Found $GUIDE_COUNT guide(s) in docs/providers/"
        else
            check "Provider guides exist" "warn" "No guides found in docs/providers/"
        fi
    fi

    echo ""

    # Check for completion report
    echo -e "${BOLD}COMPLETION REPORT${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    REPORT_COUNT=$(find .claude-team/outputs -name "*COMPLETE.md" -mtime -1 2>/dev/null | wc -l | tr -d ' ')
    if [[ $REPORT_COUNT -gt 0 ]]; then
        check "Recent completion report" "pass"
    else
        check "Recent completion report" "warn" "No completion report in last 24h"
    fi

    echo ""

    # Git status
    echo -e "${BOLD}GIT STATUS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    UNCOMMITTED=$(git status --porcelain | wc -l | tr -d ' ')
    if [[ "$UNCOMMITTED" == "0" ]]; then
        check "Changes committed" "pass"
    else
        check "Changes committed" "warn" "$UNCOMMITTED uncommitted file(s)"
    fi

    echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CODE MODE (Original behavior)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

else
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
fi

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
