#!/bin/bash
#
# Technical Debt Tracking
# Records complexity and code quality metrics over time for trend analysis
#
# Usage:
#   ./scripts/track-tech-debt.sh              # Record current metrics
#   ./scripts/track-tech-debt.sh --report     # Show trend report
#   ./scripts/track-tech-debt.sh --json       # Output as JSON
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

METRICS_DIR=".claude-team/metrics"
DEBT_CSV="$METRICS_DIR/tech-debt.csv"
DEBT_JSON="$METRICS_DIR/tech-debt-latest.json"

REPORT=false
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --report|-r)
            REPORT=true
            shift
            ;;
        --json|-j)
            JSON_OUTPUT=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --report, -r   Show trend report"
            echo "  --json, -j     Output as JSON"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Ensure metrics directory exists
mkdir -p "$METRICS_DIR"

# Initialize CSV if needed
if [[ ! -f "$DEBT_CSV" ]]; then
    echo "date,version,commit,files,errors,warnings,large_files,deep_nesting,force_unwraps,long_functions,todo_count,fixme_count" > "$DEBT_CSV"
fi

# Show report mode
if [[ "$REPORT" == true ]]; then
    echo ""
    echo -e "${BLUE}${BOLD}Technical Debt Trend Report${NC}"
    echo -e "${DIM}═══════════════════════════════════════${NC}"
    echo ""

    if [[ ! -f "$DEBT_CSV" ]] || [[ $(wc -l < "$DEBT_CSV") -le 1 ]]; then
        echo -e "${YELLOW}No data recorded yet. Run without --report to record metrics.${NC}"
        exit 0
    fi

    # Show last 10 entries
    echo -e "${CYAN}${BOLD}Recent History:${NC}"
    echo ""
    printf "%-12s %-10s %-8s %-8s %-10s\n" "Date" "Version" "Errors" "Warnings" "Large Files"
    echo "────────────────────────────────────────────────────────"

    tail -10 "$DEBT_CSV" | while IFS=',' read -r date version commit files errors warnings large_files rest; do
        [[ "$date" == "date" ]] && continue
        printf "%-12s %-10s %-8s %-8s %-10s\n" "$date" "$version" "$errors" "$warnings" "$large_files"
    done

    echo ""

    # Calculate trend
    FIRST_ERRORS=$(tail -10 "$DEBT_CSV" | head -1 | cut -d',' -f5)
    LAST_ERRORS=$(tail -1 "$DEBT_CSV" | cut -d',' -f5)

    FIRST_WARNINGS=$(tail -10 "$DEBT_CSV" | head -1 | cut -d',' -f6)
    LAST_WARNINGS=$(tail -1 "$DEBT_CSV" | cut -d',' -f6)

    echo -e "${CYAN}${BOLD}Trend (last 10 records):${NC}"

    if [[ "$LAST_ERRORS" -lt "$FIRST_ERRORS" ]]; then
        DIFF=$((FIRST_ERRORS - LAST_ERRORS))
        echo -e "  Errors:   ${GREEN}↓ -$DIFF${NC} ($FIRST_ERRORS → $LAST_ERRORS)"
    elif [[ "$LAST_ERRORS" -gt "$FIRST_ERRORS" ]]; then
        DIFF=$((LAST_ERRORS - FIRST_ERRORS))
        echo -e "  Errors:   ${RED}↑ +$DIFF${NC} ($FIRST_ERRORS → $LAST_ERRORS)"
    else
        echo -e "  Errors:   ${DIM}→ No change${NC} ($LAST_ERRORS)"
    fi

    if [[ "$LAST_WARNINGS" -lt "$FIRST_WARNINGS" ]]; then
        DIFF=$((FIRST_WARNINGS - LAST_WARNINGS))
        echo -e "  Warnings: ${GREEN}↓ -$DIFF${NC} ($FIRST_WARNINGS → $LAST_WARNINGS)"
    elif [[ "$LAST_WARNINGS" -gt "$FIRST_WARNINGS" ]]; then
        DIFF=$((LAST_WARNINGS - FIRST_WARNINGS))
        echo -e "  Warnings: ${RED}↑ +$DIFF${NC} ($FIRST_WARNINGS → $LAST_WARNINGS)"
    else
        echo -e "  Warnings: ${DIM}→ No change${NC} ($LAST_WARNINGS)"
    fi

    echo ""
    exit 0
fi

# Collect metrics
echo ""
echo -e "${BLUE}${BOLD}Recording Technical Debt Metrics${NC}"
echo -e "${DIM}═══════════════════════════════════════${NC}"
echo ""

DATE=$(date +%Y-%m-%d)
VERSION=$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]' || echo "unknown")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

echo -e "Date:    ${CYAN}$DATE${NC}"
echo -e "Version: ${CYAN}$VERSION${NC}"
echo -e "Commit:  ${CYAN}$COMMIT${NC}"
echo ""

# Run complexity check silently
echo -e "${DIM}Running complexity analysis...${NC}"

COMPLEXITY_OUTPUT=$("$SCRIPT_DIR/complexity-check.sh" --warn-only 2>&1 || true)

# Extract metrics
FILES=$(echo "$COMPLEXITY_OUTPUT" | grep "Files checked:" | grep -oE '[0-9]+' | head -1 || echo "0")
ERRORS=$(echo "$COMPLEXITY_OUTPUT" | grep "Errors:" | grep -oE '[0-9]+' | head -1 || echo "0")
WARNINGS=$(echo "$COMPLEXITY_OUTPUT" | grep "Warnings:" | grep -oE '[0-9]+' | head -1 || echo "0")

# Count specific issues
LARGE_FILES=$(echo "$COMPLEXITY_OUTPUT" | grep -c "File too long" || echo "0")
DEEP_NESTING=$(echo "$COMPLEXITY_OUTPUT" | grep -c "Deep nesting" || echo "0")
FORCE_UNWRAPS=$(echo "$COMPLEXITY_OUTPUT" | grep -c "Force unwrap" || echo "0")
LONG_FUNCTIONS=$(echo "$COMPLEXITY_OUTPUT" | grep -c "Function too long" || echo "0")

# Count TODOs and FIXMEs in code
TODO_COUNT=$(grep -r "TODO:" --include="*.swift" . 2>/dev/null | wc -l | tr -d ' ' || echo "0")
FIXME_COUNT=$(grep -r "FIXME:" --include="*.swift" . 2>/dev/null | wc -l | tr -d ' ' || echo "0")

echo -e "${CYAN}Metrics collected:${NC}"
echo -e "  Files checked:  $FILES"
echo -e "  Errors:         $ERRORS"
echo -e "  Warnings:       $WARNINGS"
echo -e "  Large files:    $LARGE_FILES"
echo -e "  Deep nesting:   $DEEP_NESTING"
echo -e "  Force unwraps:  $FORCE_UNWRAPS"
echo -e "  Long functions: $LONG_FUNCTIONS"
echo -e "  TODOs:          $TODO_COUNT"
echo -e "  FIXMEs:         $FIXME_COUNT"
echo ""

# Record to CSV
echo "$DATE,$VERSION,$COMMIT,$FILES,$ERRORS,$WARNINGS,$LARGE_FILES,$DEEP_NESTING,$FORCE_UNWRAPS,$LONG_FUNCTIONS,$TODO_COUNT,$FIXME_COUNT" >> "$DEBT_CSV"

# Save latest as JSON
cat > "$DEBT_JSON" << EOF
{
  "date": "$DATE",
  "version": "$VERSION",
  "commit": "$COMMIT",
  "metrics": {
    "files_checked": $FILES,
    "errors": $ERRORS,
    "warnings": $WARNINGS,
    "large_files": $LARGE_FILES,
    "deep_nesting": $DEEP_NESTING,
    "force_unwraps": $FORCE_UNWRAPS,
    "long_functions": $LONG_FUNCTIONS,
    "todo_count": $TODO_COUNT,
    "fixme_count": $FIXME_COUNT
  },
  "debt_score": $((ERRORS * 10 + LARGE_FILES * 5 + LONG_FUNCTIONS * 3 + FORCE_UNWRAPS)),
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Calculate debt score
DEBT_SCORE=$((ERRORS * 10 + LARGE_FILES * 5 + LONG_FUNCTIONS * 3 + FORCE_UNWRAPS))

echo -e "${BOLD}Technical Debt Score: ${NC}"
if [[ $DEBT_SCORE -lt 50 ]]; then
    echo -e "  ${GREEN}${BOLD}$DEBT_SCORE${NC} ${GREEN}(Low)${NC}"
elif [[ $DEBT_SCORE -lt 150 ]]; then
    echo -e "  ${YELLOW}${BOLD}$DEBT_SCORE${NC} ${YELLOW}(Moderate)${NC}"
else
    echo -e "  ${RED}${BOLD}$DEBT_SCORE${NC} ${RED}(High - consider refactoring)${NC}"
fi

echo ""
echo -e "${GREEN}Recorded to: $DEBT_CSV${NC}"

# Output JSON if requested
if [[ "$JSON_OUTPUT" == true ]]; then
    echo ""
    echo -e "${CYAN}JSON Output:${NC}"
    cat "$DEBT_JSON"
fi

echo ""
