#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Archive Output Reports - Move old worker reports to dated folders         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

OUTPUTS_DIR="$PROJECT_ROOT/.claude-team/outputs"
ARCHIVE_DIR="$PROJECT_ROOT/.claude-team/archive"
TODAY=$(date +%Y-%m-%d)
DRY_RUN=false

[[ "$1" == "--dry-run" ]] && DRY_RUN=true

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Archive Output Reports                          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

FILE_COUNT=$(find "$OUTPUTS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

if [[ "$FILE_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} No output files to archive"
    exit 0
fi

echo -e "Found ${YELLOW}$FILE_COUNT${NC} output files to archive"
echo ""

ARCHIVE_TODAY="$ARCHIVE_DIR/$TODAY"

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${DIM}[DRY RUN] Would create: $ARCHIVE_TODAY${NC}"
else
    mkdir -p "$ARCHIVE_TODAY"
    echo -e "Created archive folder: ${DIM}$ARCHIVE_TODAY${NC}"
fi

MOVED=0
for file in "$OUTPUTS_DIR"/*.md; do
    [[ -f "$file" ]] || continue
    filename=$(basename "$file")
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${DIM}[DRY RUN] Would move: $filename${NC}"
    else
        mv "$file" "$ARCHIVE_TODAY/"
        echo -e "  ${GREEN}→${NC} $filename"
    fi
    ((MOVED++))
done

echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}DRY RUN:${NC} Would archive $MOVED files"
    echo "Run without --dry-run to execute"
else
    echo -e "${GREEN}✓${NC} Archived $MOVED files to $ARCHIVE_TODAY/"
fi
echo ""
