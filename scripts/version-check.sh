#!/bin/bash

# version-check.sh - Single Source of Truth Version Validator
# Ensures all documentation files reference the correct version from VERSION.txt
#
# Usage:
#   ./scripts/version-check.sh          # Check only
#   ./scripts/version-check.sh --fix    # Check and fix mismatches

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/VERSION.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if VERSION.txt exists
if [[ ! -f "$VERSION_FILE" ]]; then
    echo -e "${RED}ERROR: VERSION.txt not found at $VERSION_FILE${NC}"
    exit 1
fi

# Read the source of truth version
VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Version Check - Source of Truth: v$VERSION${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Track results
ERRORS=0
CHECKED=0
FIXED=0

# Function to check a file for version
check_file() {
    local file="$1"
    local pattern="$2"
    local fix_pattern="$3"
    local description="$4"
    
    if [[ ! -f "$file" ]]; then
        echo -e "${YELLOW}⚠ SKIP: $description - File not found${NC}"
        return
    fi
    
    ((CHECKED++))
    
    # Check if version matches
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓ OK:   $description${NC}"
    else
        echo -e "${RED}✗ FAIL: $description${NC}"
        
        # Show what was found
        local found=$(grep -oE "[0-9]+\.[0-9]+\.[0-9]+" "$file" | head -1)
        if [[ -n "$found" ]]; then
            echo -e "        Found: v$found, Expected: v$VERSION"
        fi
        
        # Fix if requested
        if [[ "$1" == "--fix" ]] || [[ "$2" == "--fix" ]]; then
            if [[ -n "$fix_pattern" ]]; then
                # This would require more complex sed logic per file
                echo -e "${YELLOW}        Auto-fix not yet implemented for this file${NC}"
            fi
        fi
        
        ((ERRORS++))
    fi
}

# Check all documentation files
echo "Checking documentation files..."
echo ""

# CLAUDE_PROJECT_KNOWLEDGE.md - looks for "Version:** 2.0.19"
check_file \
    "$PROJECT_ROOT/CLAUDE_PROJECT_KNOWLEDGE.md" \
    "Version:.* $VERSION" \
    "" \
    "CLAUDE_PROJECT_KNOWLEDGE.md"

# STATUS.md - looks for "Version: v2.0.19"
check_file \
    "$PROJECT_ROOT/.claude-team/STATUS.md" \
    "Version: v$VERSION" \
    "" \
    ".claude-team/STATUS.md"

# RECOVERY.md - looks for "Current Version:** v2.0.19"
check_file \
    "$PROJECT_ROOT/.claude-team/RECOVERY.md" \
    "Current Version:.* v$VERSION" \
    "" \
    ".claude-team/RECOVERY.md"

# CHANGELOG.md - looks for "## [2.0.19]" as first version entry
check_file \
    "$PROJECT_ROOT/CHANGELOG.md" \
    "## \[$VERSION\]" \
    "" \
    "CHANGELOG.md (has entry)"

# PROJECT_CONTEXT.md - looks for version
check_file \
    "$PROJECT_ROOT/.claude-team/PROJECT_CONTEXT.md" \
    "Version:.* $VERSION\|version.* $VERSION" \
    "" \
    ".claude-team/PROJECT_CONTEXT.md"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Summary
if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✓ All $CHECKED files match VERSION.txt (v$VERSION)${NC}"
    exit 0
else
    echo -e "${RED}✗ $ERRORS of $CHECKED files have version mismatches${NC}"
    echo ""
    echo -e "${YELLOW}To fix, update the files to reference v$VERSION${NC}"
    echo -e "${YELLOW}Or run: ./scripts/update-version.sh $VERSION${NC}"
    exit 1
fi
