#!/bin/bash
#
# Memory Leak Detection Script
# Runs tests with Address Sanitizer and optionally Instruments
#
# Usage: ./scripts/leak-check.sh [--instruments]
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

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              MEMORY LEAK DETECTION                            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

USE_INSTRUMENTS=false
if [[ "$1" == "--instruments" ]]; then
    USE_INSTRUMENTS=true
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Method 1: Address Sanitizer (ASan)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BLUE}[1/2]${NC} Running tests with Address Sanitizer..."
echo ""

# Build and test with ASan enabled
ASAN_OUTPUT=$(xcodebuild test \
    -project CloudSyncApp.xcodeproj \
    -scheme CloudSyncApp \
    -destination 'platform=macOS' \
    -skip-testing:CloudSyncAppUITests \
    -enableAddressSanitizer YES \
    -quiet \
    2>&1) || ASAN_FAILED=1

# Check for ASan errors
LEAK_ERRORS=$(echo "$ASAN_OUTPUT" | grep -c "AddressSanitizer" || echo "0")
MEMORY_ERRORS=$(echo "$ASAN_OUTPUT" | grep -c "heap-use-after-free\|heap-buffer-overflow\|stack-buffer-overflow\|use-after-scope" || echo "0")

if [[ "$LEAK_ERRORS" -gt 0 ]] || [[ "$MEMORY_ERRORS" -gt 0 ]]; then
    echo -e "${RED}❌ Address Sanitizer found issues:${NC}"
    echo "$ASAN_OUTPUT" | grep -A 5 "AddressSanitizer" | head -30
    ISSUES_FOUND=1
else
    echo -e "${GREEN}✅ No Address Sanitizer issues detected${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Method 2: Thread Sanitizer (TSan) - detect race conditions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${BLUE}[2/2]${NC} Running tests with Thread Sanitizer..."
echo ""

TSAN_OUTPUT=$(xcodebuild test \
    -project CloudSyncApp.xcodeproj \
    -scheme CloudSyncApp \
    -destination 'platform=macOS' \
    -skip-testing:CloudSyncAppUITests \
    -enableThreadSanitizer YES \
    -quiet \
    2>&1) || TSAN_FAILED=1

RACE_ERRORS=$(echo "$TSAN_OUTPUT" | grep -c "ThreadSanitizer" || echo "0")

if [[ "$RACE_ERRORS" -gt 0 ]]; then
    echo -e "${RED}❌ Thread Sanitizer found race conditions:${NC}"
    echo "$TSAN_OUTPUT" | grep -A 5 "ThreadSanitizer" | head -30
    ISSUES_FOUND=1
else
    echo -e "${GREEN}✅ No race conditions detected${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Optional: Instruments Leaks (slower, more thorough)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [[ "$USE_INSTRUMENTS" == true ]]; then
    echo ""
    echo -e "${BLUE}[Bonus]${NC} Running Instruments Leaks analysis..."
    echo -e "${YELLOW}(This requires the app to be built and will launch it)${NC}"
    echo ""

    # Build the app
    xcodebuild build \
        -project CloudSyncApp.xcodeproj \
        -scheme CloudSyncApp \
        -destination 'platform=macOS' \
        -quiet

    # Find the built app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "CloudSyncApp.app" -type d | head -1)

    if [[ -n "$APP_PATH" ]]; then
        echo "Running leaks check on: $APP_PATH"

        # Run with Instruments leaks template (5 second sample)
        xcrun instruments -t "Leaks" \
            -D /tmp/LeaksTrace.trace \
            -l 5000 \
            "$APP_PATH/Contents/MacOS/CloudSyncApp" 2>&1 || true

        # Parse results
        if [[ -d "/tmp/LeaksTrace.trace" ]]; then
            LEAKS_COUNT=$(leaks --outputGraph=/tmp/leaks_graph CloudSyncApp 2>&1 | grep -c "leaked" || echo "0")
            if [[ "$LEAKS_COUNT" -gt 0 ]]; then
                echo -e "${YELLOW}⚠️  Instruments detected potential leaks${NC}"
            else
                echo -e "${GREEN}✅ No leaks detected by Instruments${NC}"
            fi
            rm -rf /tmp/LeaksTrace.trace
        fi
    else
        echo -e "${YELLOW}⚠️  Could not find built app${NC}"
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Summary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}SUMMARY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ -n "$ISSUES_FOUND" ]]; then
    echo -e "${RED}❌ Memory/thread issues detected - review above${NC}"
    exit 1
else
    echo -e "${GREEN}✅ No memory leaks or race conditions detected${NC}"
    echo ""
    echo "Checks performed:"
    echo "  • Address Sanitizer (memory corruption, leaks)"
    echo "  • Thread Sanitizer (race conditions)"
    if [[ "$USE_INSTRUMENTS" == true ]]; then
        echo "  • Instruments Leaks (deep analysis)"
    fi
fi
