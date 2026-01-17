#!/bin/bash
# Record test count for trend tracking
# Usage: ./scripts/record-test-count.sh

METRICS_FILE=".claude-team/metrics/test-counts.csv"
mkdir -p .claude-team/metrics

# Get current test count
TEST_COUNT=$(xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep "Executed" | tail -1 | grep -oE "[0-9]+ tests" | grep -oE "[0-9]+")

if [ -z "$TEST_COUNT" ]; then
    echo "❌ Could not determine test count"
    exit 1
fi

# Get version
VERSION=$(cat VERSION.txt)

# Get date
DATE=$(date +%Y-%m-%d)

# Create header if file doesn't exist
if [ ! -f "$METRICS_FILE" ]; then
    echo "date,version,tests" > "$METRICS_FILE"
fi

# Append new record
echo "$DATE,$VERSION,$TEST_COUNT" >> "$METRICS_FILE"

echo "✅ Recorded: $TEST_COUNT tests (v$VERSION) on $DATE"

# Show recent trend
echo ""
echo "📈 Recent Test Count Trend:"
tail -5 "$METRICS_FILE" | column -t -s,
