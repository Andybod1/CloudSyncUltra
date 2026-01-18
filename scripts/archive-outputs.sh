#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Archive Output Reports                                                    ║
# ║  Moves worker output files to sprint-based archive folders                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage:
#   ./scripts/archive-outputs.sh              # Archive to current sprint folder
#   ./scripts/archive-outputs.sh --sprint 2.0.39  # Archive to specific sprint
#   ./scripts/archive-outputs.sh --auto       # Auto-detect sprint from STATUS.md
#   ./scripts/archive-outputs.sh --dry-run    # Preview without moving
#   ./scripts/archive-outputs.sh --validate   # Validate outputs before archiving

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUTS_DIR="$PROJECT_ROOT/.claude-team/outputs"
ARCHIVE_DIR="$PROJECT_ROOT/.claude-team/archive"
STATUS_FILE="$PROJECT_ROOT/.claude-team/STATUS.md"

DRY_RUN=false
VALIDATE=false
SPRINT=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║           Archive Output Reports                          ║${NC}"
    echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --validate|-v)
            VALIDATE=true
            shift
            ;;
        --sprint|-s)
            SPRINT="$2"
            shift 2
            ;;
        --auto|-a)
            # Auto-detect sprint from STATUS.md
            if [[ -f "$STATUS_FILE" ]]; then
                SPRINT=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$STATUS_FILE" | head -1 | tr -d 'v')
            fi
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --dry-run, -n       Preview without moving files"
            echo "  --validate, -v      Validate outputs before archiving"
            echo "  --sprint, -s VER    Archive to specific sprint (e.g., 2.0.39)"
            echo "  --auto, -a          Auto-detect sprint from STATUS.md"
            echo "  --help, -h          Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Default to date-based if no sprint specified
if [[ -z "$SPRINT" ]]; then
    SPRINT=$(date +%Y-%m-%d)
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$SPRINT"
else
    ARCHIVE_FOLDER="$ARCHIVE_DIR/v$SPRINT"
fi

print_header

# Count files
FILE_COUNT=$(find "$OUTPUTS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

if [[ "$FILE_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} No output files to archive"
    exit 0
fi

echo -e "Found ${YELLOW}${BOLD}$FILE_COUNT${NC} output files to archive"
echo -e "Target: ${CYAN}$ARCHIVE_FOLDER${NC}"
echo ""

# Validate outputs if requested
if [[ "$VALIDATE" == true ]]; then
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}VALIDATING OUTPUTS${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    VALIDATION_FAILED=0
    for file in "$OUTPUTS_DIR"/*.md; do
        [[ -f "$file" ]] || continue
        filename=$(basename "$file")

        if "$SCRIPT_DIR/validate-output.sh" "$file" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $filename"
        else
            echo -e "  ${RED}✗${NC} $filename - validation failed"
            VALIDATION_FAILED=$((VALIDATION_FAILED + 1))
        fi
    done

    echo ""
    if [[ $VALIDATION_FAILED -gt 0 ]]; then
        echo -e "${RED}${BOLD}$VALIDATION_FAILED file(s) failed validation${NC}"
        echo -e "${YELLOW}Run without --validate to archive anyway, or fix the issues${NC}"
        exit 1
    fi
    echo -e "${GREEN}All files passed validation${NC}"
    echo ""
fi

# Create archive directory
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${DIM}[DRY RUN] Would create: $ARCHIVE_FOLDER${NC}"
else
    mkdir -p "$ARCHIVE_FOLDER"
fi

# Move files
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}ARCHIVING FILES${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

MOVED=0
for file in "$OUTPUTS_DIR"/*.md; do
    [[ -f "$file" ]] || continue
    filename=$(basename "$file")

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${DIM}[DRY RUN] Would move: $filename${NC}"
    else
        mv "$file" "$ARCHIVE_FOLDER/"
        echo -e "  ${GREEN}→${NC} $filename"
    fi
    ((MOVED++))
done

# Create archive summary
if [[ "$DRY_RUN" != true ]]; then
    SUMMARY_FILE="$ARCHIVE_FOLDER/ARCHIVE_SUMMARY.md"
    cat > "$SUMMARY_FILE" << EOF
# Archive Summary

**Sprint:** v$SPRINT
**Archived:** $(date +"%Y-%m-%d %H:%M")
**Files:** $MOVED

## Contents

EOF
    for file in "$ARCHIVE_FOLDER"/*.md; do
        [[ -f "$file" ]] || continue
        filename=$(basename "$file")
        [[ "$filename" == "ARCHIVE_SUMMARY.md" ]] && continue
        echo "- $filename" >> "$SUMMARY_FILE"
    done
fi

# Summary
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}${BOLD}DRY RUN:${NC} Would archive $MOVED files to $ARCHIVE_FOLDER/"
    echo -e "Run without --dry-run to execute"
else
    echo -e "${GREEN}${BOLD}✓ Archived $MOVED files${NC} to $ARCHIVE_FOLDER/"
    echo -e "${DIM}Summary written to ARCHIVE_SUMMARY.md${NC}"
fi
echo ""
