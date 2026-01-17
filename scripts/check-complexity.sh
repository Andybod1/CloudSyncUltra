#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - Complexity Checker                                       ║
# ║  Find functions that are too complex (high cyclomatic complexity)           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/check-complexity.sh [--threshold N]
#
# Heuristic: counts decision points (if, guard, switch, for, while, catch, &&, ||)
# Default threshold: 10

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

THRESHOLD=10
[[ "$1" == "--threshold" && -n "$2" ]] && THRESHOLD=$2

cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║     Complexity Checker (threshold: $THRESHOLD)                        ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

COMPLEX_FUNCS=()
TOTAL_FUNCS=0
HIGH_COMPLEXITY=0

# Find all Swift files
SWIFT_FILES=$(find CloudSyncApp -name "*.swift" -type f 2>/dev/null)

for file in $SWIFT_FILES; do
    # Extract function names and their bodies (simplified heuristic)
    # Look for func declarations
    FUNCS=$(grep -n "func " "$file" | grep -v "//" || true)

    while IFS= read -r func_line; do
        [[ -z "$func_line" ]] && continue

        LINE_NUM=$(echo "$func_line" | cut -d: -f1)
        FUNC_NAME=$(echo "$func_line" | sed 's/.*func \([^(]*\).*/\1/' | xargs)

        # Get next 100 lines to analyze function body (rough heuristic)
        BODY=$(sed -n "${LINE_NUM},$((LINE_NUM + 100))p" "$file" 2>/dev/null || true)

        # Count decision points (simplified cyclomatic complexity)
        count_pattern() {
            local count=$(echo "$BODY" | grep -c "$1" 2>/dev/null || true)
            echo "${count:-0}"
        }
        DECISIONS=1  # Base complexity
        DECISIONS=$((DECISIONS + $(count_pattern " if ")))
        DECISIONS=$((DECISIONS + $(count_pattern "guard ")))
        DECISIONS=$((DECISIONS + $(count_pattern " else if ")))
        DECISIONS=$((DECISIONS + $(count_pattern "switch ")))
        DECISIONS=$((DECISIONS + $(count_pattern "case ")))
        DECISIONS=$((DECISIONS + $(count_pattern " for ")))
        DECISIONS=$((DECISIONS + $(count_pattern " while ")))
        DECISIONS=$((DECISIONS + $(count_pattern " catch ")))
        DECISIONS=$((DECISIONS + $(count_pattern " && ")))
        DECISIONS=$((DECISIONS + $(count_pattern " || ")))
        DECISIONS=$((DECISIONS + $(count_pattern "\? ")))

        TOTAL_FUNCS=$((TOTAL_FUNCS + 1))

        if [[ $DECISIONS -gt $THRESHOLD ]]; then
            HIGH_COMPLEXITY=$((HIGH_COMPLEXITY + 1))
            SHORT_FILE=$(echo "$file" | sed 's|CloudSyncApp/||')
            COMPLEX_FUNCS+=("$DECISIONS|$SHORT_FILE:$LINE_NUM|$FUNC_NAME")
        fi
    done <<< "$FUNCS"
done

# Sort by complexity (highest first)
IFS=$'\n' SORTED=($(sort -t'|' -k1 -rn <<< "${COMPLEX_FUNCS[*]}"))
unset IFS

echo -e "${BOLD}Summary:${NC}"
echo -e "  Functions analyzed: $TOTAL_FUNCS"
echo -e "  Above threshold ($THRESHOLD): $HIGH_COMPLEXITY"
echo ""

if [[ $HIGH_COMPLEXITY -gt 0 ]]; then
    echo -e "${YELLOW}${BOLD}High Complexity Functions:${NC}"
    echo ""

    printf "  ${BOLD}%-6s %-40s %s${NC}\n" "Score" "Location" "Function"
    echo "  ────────────────────────────────────────────────────────────────────"

    for entry in "${SORTED[@]}"; do
        SCORE=$(echo "$entry" | cut -d'|' -f1)
        LOCATION=$(echo "$entry" | cut -d'|' -f2)
        FUNC=$(echo "$entry" | cut -d'|' -f3)

        if [[ $SCORE -gt 20 ]]; then
            COLOR=$RED
        elif [[ $SCORE -gt 15 ]]; then
            COLOR=$YELLOW
        else
            COLOR=$CYAN
        fi

        printf "  ${COLOR}%-6s${NC} %-40s %s\n" "$SCORE" "$LOCATION" "$FUNC"
    done

    echo ""
    echo -e "${YELLOW}Consider refactoring functions with complexity > $THRESHOLD${NC}"
else
    echo -e "${GREEN}✓ All functions are within complexity threshold${NC}"
fi
