#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - TODO/FIXME Tracker                                       ║
# ║  Find and report all TODO, FIXME, HACK comments in codebase                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/check-todos.sh [--json]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
JSON_OUTPUT=false

[[ "$1" == "--json" ]] && JSON_OUTPUT=true

cd "$PROJECT_ROOT"

# Colors (only for non-JSON output)
if [[ "$JSON_OUTPUT" == false ]]; then
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    GREEN='\033[0;32m'
    BOLD='\033[1m'
    NC='\033[0m'
fi

# Search patterns
PATTERNS="TODO|FIXME|HACK|XXX|BUG"

# Find all occurrences
TODOS=$(grep -rn --include="*.swift" -E "//.*($PATTERNS)" CloudSyncApp/ 2>/dev/null || true)

# Count helper function
count_matches() {
    local pattern="$1"
    if [[ -z "$TODOS" ]]; then
        echo 0
    else
        local cnt
        cnt=$(echo "$TODOS" | grep -c "$pattern" 2>/dev/null) || cnt=0
        echo "$cnt"
    fi
}

TODO_COUNT=$(count_matches "TODO")
FIXME_COUNT=$(count_matches "FIXME")
HACK_COUNT=$(echo "$TODOS" | grep -cE "HACK|XXX" 2>/dev/null) || HACK_COUNT=0
if [[ -z "$TODOS" ]]; then
    TOTAL=0
else
    TOTAL=$(echo "$TODOS" | wc -l | tr -d ' ')
fi

if [[ "$JSON_OUTPUT" == true ]]; then
    # JSON output for automation
    echo "{"
    echo "  \"total\": $TOTAL,"
    echo "  \"todo\": $TODO_COUNT,"
    echo "  \"fixme\": $FIXME_COUNT,"
    echo "  \"hack\": $HACK_COUNT,"
    echo "  \"items\": ["

    FIRST=true
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        FILE=$(echo "$line" | cut -d: -f1)
        LINE_NUM=$(echo "$line" | cut -d: -f2)
        CONTENT=$(echo "$line" | cut -d: -f3- | sed 's/"/\\"/g' | xargs)
        TYPE="TODO"
        echo "$line" | grep -q "FIXME" && TYPE="FIXME"
        echo "$line" | grep -q "HACK\|XXX" && TYPE="HACK"

        if [[ "$FIRST" == true ]]; then
            FIRST=false
        else
            echo ","
        fi
        printf '    {"file": "%s", "line": %s, "type": "%s", "text": "%s"}' "$FILE" "$LINE_NUM" "$TYPE" "$CONTENT"
    done <<< "$TODOS"

    echo ""
    echo "  ]"
    echo "}"
else
    # Human-readable output
    echo ""
    echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║     TODO/FIXME Tracker                                        ║${NC}"
    echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${BOLD}Summary:${NC}"
    echo -e "  ${CYAN}TODO:${NC}  $TODO_COUNT"
    echo -e "  ${YELLOW}FIXME:${NC} $FIXME_COUNT"
    echo -e "  ${RED}HACK:${NC}  $HACK_COUNT"
    echo -e "  ${BOLD}Total:${NC} $TOTAL"
    echo ""

    if [[ $TOTAL -gt 0 ]]; then
        echo -e "${BOLD}Details:${NC}"
        echo ""

        # Group by type
        if [[ $FIXME_COUNT -gt 0 ]]; then
            echo -e "${YELLOW}━━━ FIXME (needs attention) ━━━${NC}"
            echo "$TODOS" | grep "FIXME" | while read -r line; do
                FILE=$(echo "$line" | cut -d: -f1 | sed 's|CloudSyncApp/||')
                LINE_NUM=$(echo "$line" | cut -d: -f2)
                CONTENT=$(echo "$line" | cut -d: -f3- | sed 's|.*FIXME[: ]*||' | xargs)
                echo -e "  ${CYAN}$FILE:$LINE_NUM${NC} $CONTENT"
            done
            echo ""
        fi

        if [[ $HACK_COUNT -gt 0 ]]; then
            echo -e "${RED}━━━ HACK/XXX (technical debt) ━━━${NC}"
            echo "$TODOS" | grep -E "HACK|XXX" | while read -r line; do
                FILE=$(echo "$line" | cut -d: -f1 | sed 's|CloudSyncApp/||')
                LINE_NUM=$(echo "$line" | cut -d: -f2)
                CONTENT=$(echo "$line" | cut -d: -f3- | sed 's|.*\(HACK\|XXX\)[: ]*||' | xargs)
                echo -e "  ${CYAN}$FILE:$LINE_NUM${NC} $CONTENT"
            done
            echo ""
        fi

        if [[ $TODO_COUNT -gt 0 ]]; then
            echo -e "${CYAN}━━━ TODO (future work) ━━━${NC}"
            echo "$TODOS" | grep "TODO" | head -20 | while read -r line; do
                FILE=$(echo "$line" | cut -d: -f1 | sed 's|CloudSyncApp/||')
                LINE_NUM=$(echo "$line" | cut -d: -f2)
                CONTENT=$(echo "$line" | cut -d: -f3- | sed 's|.*TODO[: ]*||' | xargs)
                echo -e "  ${CYAN}$FILE:$LINE_NUM${NC} $CONTENT"
            done
            if [[ $TODO_COUNT -gt 20 ]]; then
                echo -e "  ${BOLD}... and $((TODO_COUNT - 20)) more${NC}"
            fi
            echo ""
        fi
    else
        echo -e "${GREEN}✓ No TODOs, FIXMEs, or HACKs found!${NC}"
    fi
fi
