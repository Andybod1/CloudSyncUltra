#!/bin/bash
# Record test count for trend tracking
# Usage: ./scripts/record-test-count.sh
#
# TODO: Customize the test command for your project's tech stack
# Examples:
#   npm test 2>&1 | grep "tests"
#   pytest --co -q | wc -l
#   go test ./... 2>&1 | grep "ok"

METRICS_FILE=".claude-team/metrics/test-counts.csv"
mkdir -p .claude-team/metrics

# Get current test count
# TODO: Replace this with your project's test command
echo "TODO: Configure test command for your project"
echo "Examples:"
echo "  npm test -- --listTests 2>&1 | wc -l"
echo "  pytest --co -q 2>&1 | wc -l"
echo "  go test ./... -v 2>&1 | grep -c 'RUN'"
echo ""

# Placeholder - replace with actual test count extraction
TEST_COUNT=${1:-0}

if [ "$TEST_COUNT" -eq 0 ]; then
    echo "Usage: $0 <test-count>"
    echo "Or configure this script for automatic test counting"
    exit 1
fi

# Get version
VERSION=$(cat VERSION.txt 2>/dev/null || echo "unknown")

# Get date
DATE=$(date +%Y-%m-%d)

# Create header if file doesn't exist
if [ ! -f "$METRICS_FILE" ]; then
    echo "date,version,tests" > "$METRICS_FILE"
fi

# Append new record
echo "$DATE,$VERSION,$TEST_COUNT" >> "$METRICS_FILE"

echo "Recorded: $TEST_COUNT tests (v$VERSION) on $DATE"

# Show recent trend
echo ""
echo "Recent Test Count Trend:"
tail -5 "$METRICS_FILE" | column -t -s,
