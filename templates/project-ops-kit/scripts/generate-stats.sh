#!/bin/bash
# generate-stats.sh - Auto-generate project statistics
# Usage: ./scripts/generate-stats.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

PROJECT_NAME=$(basename "$PROJECT_ROOT")
echo "📊 $PROJECT_NAME - Project Statistics"
echo "========================================"
echo ""

# Version
VERSION=$(cat VERSION.txt 2>/dev/null || echo "unknown")
echo "Version: $VERSION"
echo ""

# Code stats
echo "📁 Code Statistics:"
echo "-------------------"

# Source files count (customize pattern for your project)
SOURCE_FILES=$(find . -name "*.swift" -o -name "*.ts" -o -name "*.py" -o -name "*.go" 2>/dev/null | grep -v test | grep -v spec | wc -l | tr -d ' ')
echo "Source files: $SOURCE_FILES"

# Lines of code (approximate)
LOC=$(find . \( -name "*.swift" -o -name "*.ts" -o -name "*.py" -o -name "*.go" \) 2>/dev/null | grep -v test | grep -v spec | xargs wc -l 2>/dev/null | tail -1 | tr -d ' ' | cut -d't' -f1)
echo "Lines of code: ~${LOC:-0}"

# Test files
TEST_FILES=$(find . -name "*Test*" -o -name "*test*" -o -name "*spec*" 2>/dev/null | wc -l | tr -d ' ')
echo "Test files: $TEST_FILES"

# Test count (from last run if available)
if [ -f ".claude-team/metrics/test_counts.csv" ]; then
    LAST_TEST_COUNT=$(tail -1 .claude-team/metrics/test_counts.csv | cut -d',' -f2)
    echo "Tests: $LAST_TEST_COUNT"
fi

echo ""

# Git stats
echo "📈 Git Statistics:"
echo "------------------"
TOTAL_COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
echo "Total commits: $TOTAL_COMMITS"

CONTRIBUTORS=$(git shortlog -sn --all 2>/dev/null | wc -l | tr -d ' ')
echo "Contributors: $CONTRIBUTORS"

LAST_COMMIT=$(git log -1 --format="%h %s" 2>/dev/null || echo "none")
echo "Last commit: $LAST_COMMIT"

echo ""

# GitHub issues (if gh available)
if command -v gh &> /dev/null; then
    echo "🎫 GitHub Issues:"
    echo "-----------------"
    OPEN_ISSUES=$(gh issue list --state open --json number 2>/dev/null | grep -c "number" || echo "0")
    CLOSED_ISSUES=$(gh issue list --state closed --limit 1000 --json number 2>/dev/null | grep -c "number" || echo "0")
    echo "Open issues: $OPEN_ISSUES"
    echo "Closed issues: $CLOSED_ISSUES"
    echo ""
fi

# Documentation
echo "📚 Documentation:"
echo "-----------------"
MD_FILES=$(find . -name "*.md" -not -path "./archive/*" -not -path "./.git/*" | wc -l | tr -d ' ')
echo "Markdown files: $MD_FILES"

DOC_LINES=$(find docs -name "*.md" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
echo "Documentation lines: ~$DOC_LINES"

echo ""

# Project-specific stats
echo "📌 Project-specific:"
echo "--------------------"
echo "(Customize this section for your project)"

echo ""
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
