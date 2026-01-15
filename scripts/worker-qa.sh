#!/bin/bash
#
# Worker QA Check Script
# Run this before marking any task complete
#
# Usage: ./scripts/worker-qa.sh [optional: new-file.swift]
#

set -e

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              WORKER QA CHECKLIST                              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

cd ~/Claude

# 1. Build Check
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. BUILD CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BUILD_OUTPUT=$(xcodebuild build 2>&1)
if echo "$BUILD_OUTPUT" | grep -q "BUILD SUCCEEDED"; then
    echo "   ✅ BUILD SUCCEEDED"
else
    echo "   ❌ BUILD FAILED"
    echo ""
    echo "   Error details:"
    echo "$BUILD_OUTPUT" | grep -A 2 "error:" | head -20
    echo ""
    echo "   ⛔ DO NOT mark task complete until build passes!"
    exit 1
fi

# 2. New File Check (if provided)
if [ -n "$1" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "2. NEW FILE CHECK: $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    FILENAME=$(basename "$1")
    if grep -q "$FILENAME" CloudSyncApp.xcodeproj/project.pbxproj 2>/dev/null; then
        echo "   ✅ File is in Xcode project"
    else
        echo "   ❌ File NOT in Xcode project!"
        echo "   ⚠️  The file exists but won't compile!"
        echo "   📋 Ask Strategic Partner to add it via Xcode"
        exit 1
    fi
fi

# 3. Warning Check
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. WARNING CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

WARNING_COUNT=$(echo "$BUILD_OUTPUT" | grep -c "warning:" 2>/dev/null || echo "0")
if [ "$WARNING_COUNT" -eq 0 ]; then
    echo "   ✅ No warnings"
else
    echo "   ⚠️  $WARNING_COUNT warning(s) found"
    echo "   Consider fixing warnings before completing"
fi

# 4. Uncommitted Changes
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. GIT STATUS"
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

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "   ✅ Build:    PASSED"
echo "   ⚠️  Warnings: $WARNING_COUNT"
echo "   📁 Modified: $MODIFIED files"
echo "   📁 New:      $UNTRACKED files"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ QA CHECK PASSED - OK to mark task complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
