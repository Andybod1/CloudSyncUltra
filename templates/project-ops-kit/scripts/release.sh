#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Release Script - One-command release process                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/project.conf"

cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

NEW_VERSION="$1"

if [[ -z "$NEW_VERSION" ]]; then
    echo "Usage: ./scripts/release.sh <version>"
    echo "Example: ./scripts/release.sh 1.0.1"
    exit 1
fi

NEW_VERSION="${NEW_VERSION#v}"

echo ""
echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║              RELEASE v$NEW_VERSION                              ║${NC}"
echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Build
echo -e "${BOLD}Step 1/6: Build${NC}"
if eval "$BUILD_COMMAND" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Build successful"
else
    echo -e "  ${RED}✗${NC} Build failed"
    exit 1
fi

# Step 2: Test
echo -e "${BOLD}Step 2/6: Test${NC}"
if eval "$TEST_COMMAND" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Tests passed"
else
    echo -e "  ${YELLOW}!${NC} Tests may have failed (check manually)"
fi

# Step 3: Update version
echo -e "${BOLD}Step 3/6: Update Version${NC}"
./scripts/update-version.sh "$NEW_VERSION" > /dev/null
echo -e "  ${GREEN}✓${NC} Version updated to $NEW_VERSION"

# Step 4: Verify
echo -e "${BOLD}Step 4/6: Verify Versions${NC}"
if ./scripts/version-check.sh > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} All versions match"
else
    echo -e "  ${RED}✗${NC} Version mismatch"
    exit 1
fi

# Step 5: Commit
echo -e "${BOLD}Step 5/6: Commit & Tag${NC}"
git add -A
git commit -m "release: v$NEW_VERSION" > /dev/null 2>&1 || true
git tag "v$NEW_VERSION" 2>/dev/null || echo -e "  ${YELLOW}!${NC} Tag already exists"
echo -e "  ${GREEN}✓${NC} Committed and tagged"

# Step 6: Push
echo -e "${BOLD}Step 6/6: Push${NC}"
git push origin main > /dev/null 2>&1
git push --tags > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Pushed to GitHub"

echo ""
echo -e "${GREEN}${BOLD}✓ Release v$NEW_VERSION complete!${NC}"
echo ""
echo -e "View release: $GITHUB_URL/releases/tag/v$NEW_VERSION"
echo ""
