#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Version Check - Validate all docs have consistent version                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/project.conf"

cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

VERSION=$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]')

if [[ -z "$VERSION" ]]; then
    echo -e "${RED}ERROR: VERSION.txt not found or empty${NC}"
    exit 1
fi

echo "Checking version consistency (expected: v$VERSION)"
echo ""

ERRORS=0

for file in "${VERSION_FILES[@]}"; do
    if [[ -f "$PROJECT_ROOT/$file" ]]; then
        if grep -q "$VERSION" "$PROJECT_ROOT/$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $file"
        else
            echo -e "  ${RED}✗${NC} $file (version mismatch)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "  ${RED}?${NC} $file (file not found)"
    fi
done

echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}FAILED: $ERRORS file(s) have version mismatch${NC}"
    echo "Run: ./scripts/update-version.sh $VERSION"
    exit 1
else
    echo -e "${GREEN}SUCCESS: All files match version $VERSION${NC}"
    exit 0
fi
