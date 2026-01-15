#!/bin/bash

# update-version.sh - Update version across all documentation files
# Updates VERSION.txt and all docs that reference the version
#
# Usage:
#   ./scripts/update-version.sh 2.0.20

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check argument
if [[ -z "$1" ]]; then
    echo -e "${RED}Usage: $0 <new-version>${NC}"
    echo "Example: $0 2.0.20"
    exit 1
fi

NEW_VERSION="$1"
OLD_VERSION=$(cat "$PROJECT_ROOT/VERSION.txt" | tr -d '[:space:]')
TODAY=$(date +%Y-%m-%d)

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Updating Version: v$OLD_VERSION → v$NEW_VERSION${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to update file
update_file() {
    local file="$1"
    local search="$2"
    local replace="$3"
    local description="$4"
    
    if [[ ! -f "$file" ]]; then
        echo -e "${YELLOW}⚠ SKIP: $description - File not found${NC}"
        return
    fi
    
    if grep -q "$search" "$file" 2>/dev/null; then
        sed -i '' "s|$search|$replace|g" "$file"
        echo -e "${GREEN}✓ Updated: $description${NC}"
    else
        echo -e "${YELLOW}⚠ Pattern not found in $description${NC}"
    fi
}

# 1. Update VERSION.txt (source of truth)
echo "$NEW_VERSION" > "$PROJECT_ROOT/VERSION.txt"
echo -e "${GREEN}✓ Updated: VERSION.txt${NC}"

# 2. Update CLAUDE_PROJECT_KNOWLEDGE.md
update_file \
    "$PROJECT_ROOT/CLAUDE_PROJECT_KNOWLEDGE.md" \
    "Version:.* $OLD_VERSION" \
    "Version:** $NEW_VERSION | **Updated:** $TODAY" \
    "CLAUDE_PROJECT_KNOWLEDGE.md"

# 3. Update STATUS.md
update_file \
    "$PROJECT_ROOT/.claude-team/STATUS.md" \
    "Version: v$OLD_VERSION" \
    "Version: v$NEW_VERSION" \
    ".claude-team/STATUS.md"

# 4. Update RECOVERY.md (header)
update_file \
    "$PROJECT_ROOT/.claude-team/RECOVERY.md" \
    "Current Version:.* v$OLD_VERSION" \
    "Current Version:** v$NEW_VERSION" \
    ".claude-team/RECOVERY.md (header)"

# 5. Update RECOVERY.md (footer)
update_file \
    "$PROJECT_ROOT/.claude-team/RECOVERY.md" \
    "CloudSync Ultra v$OLD_VERSION" \
    "CloudSync Ultra v$NEW_VERSION" \
    ".claude-team/RECOVERY.md (footer)"

# 6. Update PROJECT_CONTEXT.md if exists
if [[ -f "$PROJECT_ROOT/.claude-team/PROJECT_CONTEXT.md" ]]; then
    update_file \
        "$PROJECT_ROOT/.claude-team/PROJECT_CONTEXT.md" \
        "Version:.* $OLD_VERSION" \
        "Version:** $NEW_VERSION | **Updated:** $TODAY" \
        ".claude-team/PROJECT_CONTEXT.md"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Version updated to v$NEW_VERSION${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Add CHANGELOG.md entry for v$NEW_VERSION"
echo "  2. Run: ./scripts/version-check.sh"
echo "  3. Commit: git add -A && git commit -m 'chore: Bump version to v$NEW_VERSION'"
echo "  4. Tag: git tag v$NEW_VERSION"
echo "  5. Push: git push --tags origin main"
