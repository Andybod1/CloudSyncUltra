#!/bin/bash
#
# Auto-generate Release Notes
# Creates release notes from conventional commits since last tag
#
# Usage: ./scripts/generate-release-notes.sh [version]
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
BOLD='\033[1m'
NC='\033[0m'

# Get version
VERSION="${1:-$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]')}"

echo ""
echo -e "${BLUE}${BOLD}Generating Release Notes for v${VERSION}${NC}"
echo ""

# Find the previous tag
PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")

if [[ -z "$PREV_TAG" ]]; then
    echo -e "${YELLOW}No previous tag found, using all commits${NC}"
    COMMIT_RANGE="HEAD"
else
    echo -e "Changes since: ${PREV_TAG}"
    COMMIT_RANGE="${PREV_TAG}..HEAD"
fi

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
    # Skip empty lines
    [[ -z "$commit" ]] && continue

    # Parse conventional commit format
    if [[ "$commit" =~ ^feat(\(.+\))?:\ (.+)$ ]]; then
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
        # Non-conventional commits
        if [[ ! "$commit" =~ ^Merge ]]; then
            OTHER+="- $commit\n"
        fi
    fi
done < <(git log --pretty=format:"%s" $COMMIT_RANGE 2>/dev/null)

# Generate markdown
OUTPUT_FILE="/tmp/release-notes-v${VERSION}.md"

cat > "$OUTPUT_FILE" << EOF
# CloudSync Ultra v${VERSION}

Released: $(date +%Y-%m-%d)

EOF

# Add sections if they have content
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

# Add footer
cat >> "$OUTPUT_FILE" << EOF

---

## Installation

Download the latest release from the [Releases page](https://github.com/Andybod1/CloudSyncUltra/releases).

## Full Changelog

[v${PREV_TAG:-"initial"}...v${VERSION}](https://github.com/Andybod1/CloudSyncUltra/compare/${PREV_TAG:-"initial"}...v${VERSION})
EOF

# Display the notes
echo -e "${GREEN}${BOLD}Generated Release Notes:${NC}"
echo ""
cat "$OUTPUT_FILE"
echo ""
echo -e "${GREEN}Saved to: ${OUTPUT_FILE}${NC}"

# Copy to clipboard if available
if command -v pbcopy &> /dev/null; then
    cat "$OUTPUT_FILE" | pbcopy
    echo -e "${GREEN}✅ Copied to clipboard${NC}"
fi
