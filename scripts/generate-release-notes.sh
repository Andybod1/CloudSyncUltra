#!/bin/bash
#
# Auto-generate Release Notes
# Creates release notes from conventional commits since last tag
#
# Usage:
#   ./scripts/generate-release-notes.sh [version]         # Full release notes
#   ./scripts/generate-release-notes.sh --appstore [ver]  # App Store format
#   ./scripts/generate-release-notes.sh --save [ver]      # Save to releases/
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
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

APPSTORE=false
SAVE=false
VERSION=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --appstore|-a)
            APPSTORE=true
            shift
            ;;
        --save|-s)
            SAVE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options] [version]"
            echo ""
            echo "Options:"
            echo "  --appstore, -a   Generate App Store format (shorter)"
            echo "  --save, -s       Save to releases/ directory"
            echo "  --help, -h       Show this help"
            exit 0
            ;;
        *)
            VERSION="$1"
            shift
            ;;
    esac
done

# Get version if not provided
VERSION="${VERSION:-$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]')}"

echo ""
echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║           Release Notes Generator                         ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Version: ${CYAN}${BOLD}v${VERSION}${NC}"

# Find the previous tag
PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")

if [[ -z "$PREV_TAG" ]]; then
    echo -e "${YELLOW}No previous tag found, using last 50 commits${NC}"
    COMMIT_RANGE="HEAD~50..HEAD"
else
    echo -e "Since: ${DIM}${PREV_TAG}${NC}"
    COMMIT_RANGE="${PREV_TAG}..HEAD"
fi

# Count commits
COMMIT_COUNT=$(git log --oneline $COMMIT_RANGE 2>/dev/null | wc -l | tr -d ' ')
echo -e "Commits: ${DIM}${COMMIT_COUNT}${NC}"
echo ""

# Collect commits by type
FEATURES=""
FIXES=""
DOCS=""
CHORE=""
PERF=""
REFACTOR=""
OTHER=""

while IFS= read -r commit; do
    [[ -z "$commit" ]] && continue

    # Parse conventional commit format
    if [[ "$commit" =~ ^feat(\(.+\))?!?:\ (.+)$ ]]; then
        FEATURES+="- ${BASH_REMATCH[2]}\n"
    elif [[ "$commit" =~ ^fix(\(.+\))?:\ (.+)$ ]]; then
        FIXES+="- ${BASH_REMATCH[2]}\n"
    elif [[ "$commit" =~ ^docs(\(.+\))?:\ (.+)$ ]]; then
        DOCS+="- ${BASH_REMATCH[2]}\n"
    elif [[ "$commit" =~ ^perf(\(.+\))?:\ (.+)$ ]]; then
        PERF+="- ${BASH_REMATCH[2]}\n"
    elif [[ "$commit" =~ ^refactor(\(.+\))?:\ (.+)$ ]]; then
        REFACTOR+="- ${BASH_REMATCH[2]}\n"
    elif [[ "$commit" =~ ^(chore|ci|build|test)(\(.+\))?:\ (.+)$ ]]; then
        CHORE+="- ${BASH_REMATCH[3]}\n"
    else
        if [[ ! "$commit" =~ ^Merge && ! "$commit" =~ ^Co-Authored ]]; then
            OTHER+="- $commit\n"
        fi
    fi
done < <(git log --pretty=format:"%s" $COMMIT_RANGE 2>/dev/null)

# Generate output
if [[ "$APPSTORE" == true ]]; then
    # App Store format (shorter, no markdown)
    OUTPUT=""

    if [[ -n "$FEATURES" ]]; then
        OUTPUT+="NEW:\n"
        OUTPUT+="$FEATURES\n"
    fi

    if [[ -n "$FIXES" ]]; then
        OUTPUT+="FIXED:\n"
        OUTPUT+="$FIXES\n"
    fi

    if [[ -n "$PERF" ]]; then
        OUTPUT+="IMPROVED:\n"
        OUTPUT+="$PERF\n"
    fi

    # App Store has 4000 char limit
    OUTPUT_CLEAN=$(echo -e "$OUTPUT" | head -c 3900)

    echo -e "${GREEN}${BOLD}App Store Release Notes:${NC}"
    echo ""
    echo -e "$OUTPUT_CLEAN"

    # Save if requested
    if [[ "$SAVE" == true ]]; then
        mkdir -p "$PROJECT_ROOT/releases"
        echo -e "$OUTPUT_CLEAN" > "$PROJECT_ROOT/releases/v${VERSION}-appstore.txt"
        echo ""
        echo -e "${GREEN}Saved to: releases/v${VERSION}-appstore.txt${NC}"
    fi

    # Copy to clipboard
    if command -v pbcopy &> /dev/null; then
        echo -e "$OUTPUT_CLEAN" | pbcopy
        echo -e "${GREEN}✓ Copied to clipboard${NC}"
    fi

else
    # Full markdown format
    OUTPUT_FILE="/tmp/release-notes-v${VERSION}.md"

    cat > "$OUTPUT_FILE" << EOF
# CloudSync Ultra v${VERSION}

**Released:** $(date +%Y-%m-%d)
**Commits:** $COMMIT_COUNT

EOF

    if [[ -n "$FEATURES" ]]; then
        echo -e "## ✨ New Features\n" >> "$OUTPUT_FILE"
        echo -e "$FEATURES" >> "$OUTPUT_FILE"
    fi

    if [[ -n "$FIXES" ]]; then
        echo -e "## 🐛 Bug Fixes\n" >> "$OUTPUT_FILE"
        echo -e "$FIXES" >> "$OUTPUT_FILE"
    fi

    if [[ -n "$PERF" ]]; then
        echo -e "## ⚡ Performance\n" >> "$OUTPUT_FILE"
        echo -e "$PERF" >> "$OUTPUT_FILE"
    fi

    if [[ -n "$REFACTOR" ]]; then
        echo -e "## 🔨 Refactoring\n" >> "$OUTPUT_FILE"
        echo -e "$REFACTOR" >> "$OUTPUT_FILE"
    fi

    if [[ -n "$DOCS" ]]; then
        echo -e "## 📚 Documentation\n" >> "$OUTPUT_FILE"
        echo -e "$DOCS" >> "$OUTPUT_FILE"
    fi

    if [[ -n "$CHORE" ]]; then
        echo -e "## 🔧 Maintenance\n" >> "$OUTPUT_FILE"
        echo -e "$CHORE" >> "$OUTPUT_FILE"
    fi

    if [[ -n "$OTHER" ]]; then
        echo -e "## Other Changes\n" >> "$OUTPUT_FILE"
        echo -e "$OTHER" >> "$OUTPUT_FILE"
    fi

    cat >> "$OUTPUT_FILE" << EOF

---

## Installation

Download the latest release from the [Releases page](https://github.com/Andybod1/CloudSyncUltra/releases).

## Full Changelog

[${PREV_TAG:-"initial"}...v${VERSION}](https://github.com/Andybod1/CloudSyncUltra/compare/${PREV_TAG:-"initial"}...v${VERSION})
EOF

    echo -e "${GREEN}${BOLD}Generated Release Notes:${NC}"
    echo ""
    cat "$OUTPUT_FILE"

    # Save if requested
    if [[ "$SAVE" == true ]]; then
        mkdir -p "$PROJECT_ROOT/releases"
        cp "$OUTPUT_FILE" "$PROJECT_ROOT/releases/v${VERSION}.md"
        echo ""
        echo -e "${GREEN}Saved to: releases/v${VERSION}.md${NC}"
    fi

    # Copy to clipboard
    if command -v pbcopy &> /dev/null; then
        cat "$OUTPUT_FILE" | pbcopy
        echo ""
        echo -e "${GREEN}✓ Copied to clipboard${NC}"
    fi
fi

echo ""
