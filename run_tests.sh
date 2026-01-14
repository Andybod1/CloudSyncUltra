#!/bin/bash
# Run CloudSyncApp tests from command line
# Usage: ./run_tests.sh [test_name]
# Examples:
#   ./run_tests.sh                              # Run all tests
#   ./run_tests.sh OnboardingManagerTests       # Run specific test class
#   ./run_tests.sh testFirstLaunchShowsOnboarding  # Run specific test method

cd "$(dirname "$0")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧪 CloudSync Ultra Test Runner${NC}"
echo "================================"

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found. Please install Xcode.${NC}"
    exit 1
fi

# Build arguments
SCHEME="CloudSyncApp"
DESTINATION="platform=macOS"

if [ -n "$1" ]; then
    # Run specific test
    echo -e "Running test: ${GREEN}$1${NC}"
    xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"CloudSyncAppTests/$1" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | xcpretty || xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"CloudSyncAppTests/$1" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
else
    # Run all tests
    echo -e "Running ${GREEN}all tests${NC}..."
    xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | xcpretty || xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "\n${GREEN}✅ Tests passed!${NC}"
else
    echo -e "\n${RED}❌ Tests failed!${NC}"
fi

exit $EXIT_CODE
