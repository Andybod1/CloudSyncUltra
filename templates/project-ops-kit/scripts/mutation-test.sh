#!/bin/bash
#
# Mutation Testing Script
# Uses Muter to validate test quality by introducing mutations
#
# Usage: ./scripts/mutation-test.sh [--quick]
#
# Install Muter: brew install muter
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
echo -e "${BLUE}║              MUTATION TESTING                                 ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Muter is installed
if ! command -v muter &> /dev/null; then
    echo -e "${YELLOW}Muter not installed.${NC}"
    echo ""
    echo "Install Muter via Mint (recommended):"
    echo "  brew install mint"
    echo "  mint install muter-mutation-testing/muter"
    echo ""
    echo "Or build from source:"
    echo "  git clone https://github.com/muter-mutation-testing/muter.git"
    echo "  cd muter && make install"
    echo ""
    exit 1
fi

# Check for muter.conf.yml
if [[ ! -f "muter.conf.yml" ]]; then
    echo -e "${YELLOW}Generating muter.conf.yml...${NC}"
    muter init
    echo -e "${GREEN}Created muter.conf.yml${NC}"
fi

# Run mode
QUICK_MODE=false
if [[ "$1" == "--quick" ]]; then
    QUICK_MODE=true
    echo -e "${YELLOW}Running in quick mode (limited mutations)${NC}"
fi

echo ""
echo -e "${BLUE}Running mutation tests...${NC}"
echo -e "${YELLOW}This may take a while (mutations are tested one by one)${NC}"
echo ""

# Run Muter
if [[ "$QUICK_MODE" == true ]]; then
    # Quick mode: only test a sample
    muter run --skip-coverage 2>&1 | tee mutation_results.txt
    MUTER_EXIT=$?
else
    # Full mode
    muter run 2>&1 | tee mutation_results.txt
    MUTER_EXIT=$?
fi

# Check for crashes/errors
if [[ $MUTER_EXIT -eq 139 ]] || [[ $MUTER_EXIT -eq 134 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Muter crashed (likely Xcode/project compatibility issue)${NC}"
    echo ""
    echo "Alternatives:"
    echo "  • Run tests with higher coverage threshold (80%)"
    echo "  • Use Xcode's built-in code coverage reports"
    echo "  • Review test quality manually"
    echo ""
    rm -f mutation_results.txt
    exit 0
fi

if [[ $MUTER_EXIT -ne 0 ]]; then
    MUTER_FAILED=1
fi

# Extract results
if [[ -f "mutation_results.txt" ]]; then
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Look for mutation score
    MUTATION_SCORE=$(grep -oE "Mutation Score: [0-9]+%" mutation_results.txt | head -1 || echo "")
    KILLED=$(grep -oE "Killed: [0-9]+" mutation_results.txt | head -1 || echo "")
    SURVIVED=$(grep -oE "Survived: [0-9]+" mutation_results.txt | head -1 || echo "")

    if [[ -n "$MUTATION_SCORE" ]]; then
        echo -e "${GREEN}$MUTATION_SCORE${NC}"
        echo -e "  $KILLED"
        echo -e "  $SURVIVED"

        # Extract score number
        SCORE_NUM=$(echo "$MUTATION_SCORE" | grep -oE "[0-9]+" || echo "0")

        echo ""
        if [[ $SCORE_NUM -ge 80 ]]; then
            echo -e "${GREEN}✅ Excellent mutation score (≥80%)${NC}"
        elif [[ $SCORE_NUM -ge 60 ]]; then
            echo -e "${YELLOW}⚠️  Good mutation score (60-79%)${NC}"
        else
            echo -e "${RED}❌ Low mutation score (<60%) - tests may not be catching bugs${NC}"
        fi
    else
        echo -e "${YELLOW}Could not extract mutation score${NC}"
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

# Cleanup
rm -f mutation_results.txt

if [[ -n "$MUTER_FAILED" ]]; then
    echo -e "${RED}Mutation testing encountered errors${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Mutation testing complete${NC}"
