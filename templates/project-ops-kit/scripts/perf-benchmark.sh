#!/bin/bash
#
# Performance Benchmark Script
# Runs XCTest performance tests and tracks metrics over time
#
# Usage: ./scripts/perf-benchmark.sh [--baseline]
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
NC='\033[0m'

BASELINE_FILE=".claude-team/metrics/perf-baseline.json"
RESULTS_FILE="/tmp/perf-results.json"

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              PERFORMANCE BENCHMARKS                           ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for baseline mode
SAVE_BASELINE=false
if [[ "$1" == "--baseline" ]]; then
    SAVE_BASELINE=true
    echo -e "${YELLOW}Running in baseline mode - results will be saved${NC}"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Run performance tests
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BLUE}[1/3]${NC} Running performance tests..."

# Run tests and capture output
TEST_OUTPUT=$(xcodebuild test \
    -project CloudSyncApp.xcodeproj \
    -scheme CloudSyncApp \
    -destination 'platform=macOS' \
    -only-testing:CloudSyncAppTests \
    2>&1) || true

# Extract performance metrics from output
echo ""
echo -e "${BLUE}[2/3]${NC} Extracting metrics..."

# Parse performance test results
# XCTest outputs: "measured [Time, seconds] average: X.XXX"
PERF_RESULTS=$(echo "$TEST_OUTPUT" | grep -E "measured \[.*\] average:" || echo "")

if [[ -n "$PERF_RESULTS" ]]; then
    echo -e "${GREEN}Found performance metrics:${NC}"
    echo "$PERF_RESULTS" | while read -r line; do
        echo "  • $line"
    done
else
    echo -e "${YELLOW}No performance test metrics found${NC}"
    echo "Add performance tests using measure { } blocks in XCTest"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build time benchmark
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${BLUE}[3/3]${NC} Measuring build time..."

# Clean build for accurate timing
xcodebuild clean -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -quiet 2>/dev/null || true

# Time the build
BUILD_START=$(date +%s)
xcodebuild build \
    -project CloudSyncApp.xcodeproj \
    -scheme CloudSyncApp \
    -destination 'platform=macOS' \
    -quiet 2>&1 || BUILD_FAILED=1
BUILD_END=$(date +%s)

BUILD_TIME=$((BUILD_END - BUILD_START))

if [[ -n "$BUILD_FAILED" ]]; then
    echo -e "${RED}❌ Build failed${NC}"
else
    echo -e "${GREEN}✅ Build time: ${BUILD_TIME}s${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Compare with baseline
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}RESULTS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create results JSON
cat > "$RESULTS_FILE" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]')",
  "build_time_seconds": $BUILD_TIME,
  "commit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
}
EOF

echo "Build Time: ${BUILD_TIME}s"

# Compare with baseline if exists
if [[ -f "$BASELINE_FILE" ]]; then
    BASELINE_BUILD=$(grep -o '"build_time_seconds": [0-9]*' "$BASELINE_FILE" | grep -o '[0-9]*' || echo "0")

    if [[ "$BASELINE_BUILD" -gt 0 ]]; then
        DIFF=$((BUILD_TIME - BASELINE_BUILD))
        PCT=$((DIFF * 100 / BASELINE_BUILD))

        echo "Baseline:   ${BASELINE_BUILD}s"

        if [[ $DIFF -gt 0 ]]; then
            if [[ $PCT -gt 20 ]]; then
                echo -e "${RED}Change:     +${DIFF}s (+${PCT}%) ⚠️ Significant regression${NC}"
            else
                echo -e "${YELLOW}Change:     +${DIFF}s (+${PCT}%)${NC}"
            fi
        elif [[ $DIFF -lt 0 ]]; then
            echo -e "${GREEN}Change:     ${DIFF}s (${PCT}%) ✅ Improvement${NC}"
        else
            echo "Change:     No change"
        fi
    fi
else
    echo -e "${YELLOW}No baseline found. Run with --baseline to create one.${NC}"
fi

# Save as baseline if requested
if [[ "$SAVE_BASELINE" == true ]]; then
    mkdir -p "$(dirname "$BASELINE_FILE")"
    cp "$RESULTS_FILE" "$BASELINE_FILE"
    echo ""
    echo -e "${GREEN}✅ Baseline saved to $BASELINE_FILE${NC}"
fi

echo ""

# Cleanup
rm -f "$RESULTS_FILE"
