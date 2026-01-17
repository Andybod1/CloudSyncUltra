#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - Dead Code Detector                                       ║
# ║  Find potentially unused code in the codebase                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/check-dead-code.sh
#
# Checks:
# 1. Unused private functions/methods
# 2. Unused private properties
# 3. Unused imports
# 4. Empty files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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
echo -e "${BLUE}${BOLD}║     Dead Code Detector                                        ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

WARNINGS=0

# ─────────────────────────────────────────────────────────────────────────────
# Check 1: Unused private functions
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}[1/4] Checking for unused private functions...${NC}"

PRIVATE_FUNCS=$(grep -rn "private func \|private static func \|fileprivate func " CloudSyncApp/ --include="*.swift" 2>/dev/null || true)
UNUSED_FUNCS=()

while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    FILE=$(echo "$line" | cut -d: -f1)
    FUNC_NAME=$(echo "$line" | sed 's/.*func \([a-zA-Z0-9_]*\).*/\1/')

    # Check if function is called anywhere (excluding its definition)
    CALLS=$(grep -r "$FUNC_NAME" CloudSyncApp/ --include="*.swift" 2>/dev/null | grep -v "func $FUNC_NAME" | grep -c "" || echo "0")

    if [[ "$CALLS" -eq 0 ]]; then
        SHORT_FILE=$(echo "$FILE" | sed 's|CloudSyncApp/||')
        LINE_NUM=$(echo "$line" | cut -d: -f2)
        UNUSED_FUNCS+=("$SHORT_FILE:$LINE_NUM - $FUNC_NAME()")
        WARNINGS=$((WARNINGS + 1))
    fi
done <<< "$PRIVATE_FUNCS"

if [[ ${#UNUSED_FUNCS[@]} -gt 0 ]]; then
    echo -e "  ${YELLOW}⚠ Potentially unused:${NC}"
    for func in "${UNUSED_FUNCS[@]:0:10}"; do
        echo -e "    ${CYAN}$func${NC}"
    done
    if [[ ${#UNUSED_FUNCS[@]} -gt 10 ]]; then
        echo -e "    ... and $((${#UNUSED_FUNCS[@]} - 10)) more"
    fi
else
    echo -e "  ${GREEN}✓${NC} No obviously unused private functions"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Check 2: Unused private properties
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}[2/4] Checking for unused private properties...${NC}"

PRIVATE_PROPS=$(grep -rn "private var \|private let \|private lazy var " CloudSyncApp/ --include="*.swift" 2>/dev/null | grep -v "//" || true)
UNUSED_PROPS=()

while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    FILE=$(echo "$line" | cut -d: -f1)
    PROP_NAME=$(echo "$line" | sed 's/.*\(var\|let\) \([a-zA-Z0-9_]*\).*/\2/')

    # Skip common patterns
    [[ "$PROP_NAME" == "_" ]] && continue
    [[ ${#PROP_NAME} -lt 2 ]] && continue

    # Check if property is used (excluding definition)
    USES=$(grep -r "\b$PROP_NAME\b" "$FILE" 2>/dev/null | grep -v "private \(var\|let\|lazy\)" | grep -c "" || echo "0")

    if [[ "$USES" -le 1 ]]; then
        SHORT_FILE=$(echo "$FILE" | sed 's|CloudSyncApp/||')
        LINE_NUM=$(echo "$line" | cut -d: -f2)
        UNUSED_PROPS+=("$SHORT_FILE:$LINE_NUM - $PROP_NAME")
        WARNINGS=$((WARNINGS + 1))
    fi
done <<< "$PRIVATE_PROPS"

if [[ ${#UNUSED_PROPS[@]} -gt 0 ]]; then
    echo -e "  ${YELLOW}⚠ Potentially unused:${NC}"
    for prop in "${UNUSED_PROPS[@]:0:10}"; do
        echo -e "    ${CYAN}$prop${NC}"
    done
    if [[ ${#UNUSED_PROPS[@]} -gt 10 ]]; then
        echo -e "    ... and $((${#UNUSED_PROPS[@]} - 10)) more"
    fi
else
    echo -e "  ${GREEN}✓${NC} No obviously unused private properties"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Check 3: Unused imports
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}[3/4] Checking for potentially unused imports...${NC}"

# Common imports that are often unused
SUSPICIOUS_IMPORTS=0

for file in $(find CloudSyncApp -name "*.swift" -type f 2>/dev/null); do
    # Check for Combine import without usage
    if grep -q "^import Combine" "$file" 2>/dev/null; then
        if ! grep -q "Publisher\|Subscriber\|AnyPublisher\|@Published\|sink\|assign" "$file" 2>/dev/null; then
            SHORT_FILE=$(echo "$file" | sed 's|CloudSyncApp/||')
            echo -e "  ${YELLOW}⚠${NC} $SHORT_FILE: import Combine (may be unused)"
            SUSPICIOUS_IMPORTS=$((SUSPICIOUS_IMPORTS + 1))
        fi
    fi
done

if [[ $SUSPICIOUS_IMPORTS -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} No suspicious unused imports detected"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Check 4: Empty or near-empty files
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}[4/4] Checking for empty/stub files...${NC}"

EMPTY_FILES=0

for file in $(find CloudSyncApp -name "*.swift" -type f 2>/dev/null); do
    # Count non-comment, non-empty lines
    CODE_LINES=$(grep -v "^[[:space:]]*$\|^[[:space:]]*//\|^[[:space:]]*\*\|^[[:space:]]*/\*" "$file" 2>/dev/null | wc -l | tr -d ' ')

    if [[ $CODE_LINES -lt 5 ]]; then
        SHORT_FILE=$(echo "$file" | sed 's|CloudSyncApp/||')
        echo -e "  ${YELLOW}⚠${NC} $SHORT_FILE ($CODE_LINES lines of code)"
        EMPTY_FILES=$((EMPTY_FILES + 1))
    fi
done

if [[ $EMPTY_FILES -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} No empty or stub files"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}${BOLD}─────────────────────────────────────────────────────────────────${NC}"

TOTAL=$((${#UNUSED_FUNCS[@]} + ${#UNUSED_PROPS[@]} + SUSPICIOUS_IMPORTS + EMPTY_FILES))

if [[ $TOTAL -gt 0 ]]; then
    echo -e "${YELLOW}${BOLD}⚠ Found $TOTAL potential dead code issues${NC}"
    echo -e "  Review these manually - some may be false positives"
else
    echo -e "${GREEN}${BOLD}✓ No obvious dead code detected${NC}"
fi
