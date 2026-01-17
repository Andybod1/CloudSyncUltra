#!/bin/bash
#
# Worker QA Check Script
# Run this before marking any task complete
#
# Usage: ./scripts/worker-qa.sh [optional: new-file.swift]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              WORKER QA CHECKLIST                              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0
WARNINGS=0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. BUILD CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. BUILD CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BUILD_OUTPUT=$(xcodebuild build -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -quiet 2>&1) || true
if echo "$BUILD_OUTPUT" | grep -q "BUILD SUCCEEDED"; then
    echo "   ✅ BUILD SUCCEEDED"
else
    echo "   ❌ BUILD FAILED"
    echo ""
    echo "   Error details:"
    echo "$BUILD_OUTPUT" | grep -A 2 "error:" | head -20
    echo ""
    echo "   ⛔ DO NOT mark task complete until build passes!"
    ERRORS=$((ERRORS + 1))
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. TEST CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. TEST CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "   Running tests (this may take a moment)..."
TEST_OUTPUT=$(xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' -quiet 2>&1) || true

# Extract test results
TEST_SUMMARY=$(echo "$TEST_OUTPUT" | grep -E "Executed [0-9]+ test" | tail -1)
FAILURE_COUNT=$(echo "$TEST_OUTPUT" | grep -oE "[0-9]+ failure" | head -1 | grep -oE "[0-9]+" || echo "0")

if [[ "$FAILURE_COUNT" == "0" ]] && [[ -n "$TEST_SUMMARY" ]]; then
    echo "   ✅ ALL TESTS PASSED"
    echo "   $TEST_SUMMARY"
else
    echo "   ❌ TESTS FAILED"
    echo "   $TEST_SUMMARY"
    echo ""
    echo "   Failed tests:"
    echo "$TEST_OUTPUT" | grep -E "failed|error:" | head -10
    echo ""
    echo "   ⛔ DO NOT mark task complete until tests pass!"
    ERRORS=$((ERRORS + 1))
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. VERSION CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. VERSION CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ -x "./scripts/version-check.sh" ]]; then
    if ./scripts/version-check.sh > /dev/null 2>&1; then
        VERSION=$(cat VERSION.txt | tr -d '[:space:]')
        echo "   ✅ Versions aligned (v$VERSION)"
    else
        echo "   ⚠️  Version mismatch detected"
        echo "   Run: ./scripts/update-version.sh <version>"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "   ⚠️  version-check.sh not found"
    WARNINGS=$((WARNINGS + 1))
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. WARNING CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. WARNING CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

WARNING_COUNT=$(echo "$BUILD_OUTPUT" | grep -c "warning:" 2>/dev/null || echo "0")
if [ "$WARNING_COUNT" -eq 0 ]; then
    echo "   ✅ No warnings"
else
    echo "   ⚠️  $WARNING_COUNT warning(s) found"
    echo "   Consider fixing warnings before completing"
    WARNINGS=$((WARNINGS + 1))
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. NEW FILE CHECK (if provided)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ -n "$1" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "5. NEW FILE CHECK: $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    FILENAME=$(basename "$1")
    if grep -q "$FILENAME" CloudSyncApp.xcodeproj/project.pbxproj 2>/dev/null; then
        echo "   ✅ File is in Xcode project"
    else
        echo "   ❌ File NOT in Xcode project!"
        echo "   ⚠️  The file exists but won't compile!"
        echo "   📋 Ask Strategic Partner to add it via Xcode"
        ERRORS=$((ERRORS + 1))
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 6. GIT STATUS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. GIT STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

MODIFIED=$(git status --porcelain | grep "^ M\|^M " | wc -l | tr -d ' ')
UNTRACKED=$(git status --porcelain | grep "^??" | wc -l | tr -d ' ')

echo "   Modified files: $MODIFIED"
echo "   Untracked files: $UNTRACKED"

if [ "$UNTRACKED" -gt 0 ]; then
    echo ""
    echo "   Untracked files:"
    git status --porcelain | grep "^??" | head -10
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SUMMARY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "   ❌ Build:    $(echo "$BUILD_OUTPUT" | grep -q "BUILD SUCCEEDED" && echo "PASSED" || echo "FAILED")"
    echo "   ❌ Tests:    FAILED"
    echo "   ⚠️  Warnings: $WARNING_COUNT"
    echo "   📁 Modified: $MODIFIED files"
    echo "   📁 New:      $UNTRACKED files"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ QA CHECK FAILED - DO NOT mark task complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    exit 1
else
    echo "   ✅ Build:    PASSED"
    echo "   ✅ Tests:    PASSED"
    echo "   ⚠️  Warnings: $WARNING_COUNT"
    echo "   📁 Modified: $MODIFIED files"
    echo "   📁 New:      $UNTRACKED files"
    echo ""
    if [ $WARNINGS -gt 0 ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⚠️  QA CHECK PASSED (with $WARNINGS warning(s))"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✅ QA CHECK PASSED - OK to mark task complete"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
    echo ""
fi
