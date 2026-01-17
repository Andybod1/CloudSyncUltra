#!/bin/bash
#
# Documentation Link Checker
# Validates internal links in markdown files
#
# Usage: ./scripts/check-doc-links.sh
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
echo -e "${BLUE}║              Documentation Link Checker                       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

BROKEN=0
CHECKED=0
WARNINGS=0

# Find all markdown files
MD_FILES=$(find . -name "*.md" -type f \
    -not -path "./.git/*" \
    -not -path "./build/*" \
    -not -path "./DerivedData/*" \
    -not -path "./templates/project-ops-kit/*" \
    2>/dev/null)

for file in $MD_FILES; do
    # Extract relative links from markdown: [text](path) or [text](path#anchor)
    # Skip URLs (http/https), anchors only (#), and images
    LINKS=$(grep -oE '\[([^\]]+)\]\(([^)]+)\)' "$file" 2>/dev/null | \
            grep -oE '\]\([^)]+\)' | \
            sed 's/\](//' | sed 's/)//' | \
            grep -v '^http' | \
            grep -v '^#' | \
            grep -v '\.png$' | \
            grep -v '\.jpg$' | \
            grep -v '\.gif$' | \
            grep -v '\.svg$' || true)

    if [[ -z "$LINKS" ]]; then
        continue
    fi

    FILE_DIR=$(dirname "$file")

    while IFS= read -r link; do
        [[ -z "$link" ]] && continue

        # Remove anchor part
        LINK_PATH=$(echo "$link" | cut -d'#' -f1)

        [[ -z "$LINK_PATH" ]] && continue

        CHECKED=$((CHECKED + 1))

        # Resolve relative path
        if [[ "$LINK_PATH" == /* ]]; then
            # Absolute path from repo root
            TARGET=".$LINK_PATH"
        else
            # Relative to current file
            TARGET="$FILE_DIR/$LINK_PATH"
        fi

        # Normalize path
        TARGET=$(cd "$PROJECT_ROOT" && realpath -m "$TARGET" 2>/dev/null || echo "$TARGET")

        # Check if target exists
        if [[ ! -e "$TARGET" ]]; then
            echo -e "${RED}✗${NC} Broken link in ${file}:"
            echo -e "  Link: ${YELLOW}${link}${NC}"
            echo -e "  Target not found: ${TARGET}"
            BROKEN=$((BROKEN + 1))
        fi
    done <<< "$LINKS"
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}RESULTS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Links checked: $CHECKED"

if [[ $BROKEN -gt 0 ]]; then
    echo -e "${RED}Broken links:  $BROKEN${NC}"
    echo ""
    echo -e "${RED}❌ Documentation has broken links${NC}"
    exit 1
else
    echo -e "${GREEN}Broken links:  0${NC}"
    echo ""
    echo -e "${GREEN}✅ All documentation links valid${NC}"
fi
