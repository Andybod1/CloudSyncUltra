#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Code Complexity Checker                                                   ║
# ║  Analyzes Swift code for complexity metrics and potential issues           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage:
#   ./scripts/complexity-check.sh              # Check all Swift files
#   ./scripts/complexity-check.sh --file X.swift  # Check specific file
#   ./scripts/complexity-check.sh --warn-only  # Don't fail, just warn
#   ./scripts/complexity-check.sh --strict     # Stricter thresholds
#
# Thresholds:
#   Function length: 50 lines (default), 30 lines (strict)
#   File length: 500 lines (default), 300 lines (strict)
#   Nesting depth: 4 levels (default), 3 levels (strict)
#   Parameters: 5 (default), 4 (strict)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$PROJECT_ROOT/CloudSyncApp"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Default thresholds
MAX_FUNCTION_LINES=50
MAX_FILE_LINES=500
MAX_NESTING=4
MAX_PARAMS=5
WARN_ONLY=false
SPECIFIC_FILE=""

# Counters
ERRORS=0
WARNINGS=0
FILES_CHECKED=0

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║           Code Complexity Checker                         ║${NC}"
    echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --file|-f)
            SPECIFIC_FILE="$2"
            shift 2
            ;;
        --warn-only|-w)
            WARN_ONLY=true
            shift
            ;;
        --strict|-s)
            MAX_FUNCTION_LINES=30
            MAX_FILE_LINES=300
            MAX_NESTING=3
            MAX_PARAMS=4
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --file, -f FILE   Check specific file"
            echo "  --warn-only, -w   Don't fail, just warn"
            echo "  --strict, -s      Use stricter thresholds"
            echo "  --help, -h        Show this help"
            echo ""
            echo "Default thresholds:"
            echo "  Function length: 50 lines"
            echo "  File length: 500 lines"
            echo "  Nesting depth: 4 levels"
            echo "  Parameters: 5"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_header

echo -e "${BOLD}Thresholds:${NC}"
echo -e "  Function lines: ${CYAN}$MAX_FUNCTION_LINES${NC}"
echo -e "  File lines: ${CYAN}$MAX_FILE_LINES${NC}"
echo -e "  Nesting depth: ${CYAN}$MAX_NESTING${NC}"
echo -e "  Parameters: ${CYAN}$MAX_PARAMS${NC}"
echo ""

report_issue() {
    local level="$1"
    local file="$2"
    local line="$3"
    local message="$4"

    local relative_file="${file#$PROJECT_ROOT/}"

    if [[ "$level" == "error" ]]; then
        echo -e "  ${RED}✗${NC} ${relative_file}:${line} - ${RED}$message${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} ${relative_file}:${line} - ${YELLOW}$message${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
}

check_file() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_file="${file#$PROJECT_ROOT/}"

    FILES_CHECKED=$((FILES_CHECKED + 1))

    # Check file length
    local line_count=$(wc -l < "$file" | tr -d ' ')
    if [[ $line_count -gt $MAX_FILE_LINES ]]; then
        report_issue "error" "$file" "1" "File too long: $line_count lines (max $MAX_FILE_LINES)"
    fi

    # Check for long functions
    local in_func=false
    local func_start=0
    local func_name=""
    local brace_count=0
    local line_num=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_num=$((line_num + 1))

        # Detect function start
        if echo "$line" | grep -qE '^\s*(func|init|deinit)\s+'; then
            if [[ "$in_func" == false ]]; then
                in_func=true
                func_start=$line_num
                func_name=$(echo "$line" | grep -oE '(func|init|deinit)\s+[a-zA-Z0-9_]+' | head -1)
                brace_count=0
            fi
        fi

        # Count braces
        if [[ "$in_func" == true ]]; then
            local open=$(echo "$line" | tr -cd '{' | wc -c)
            local close=$(echo "$line" | tr -cd '}' | wc -c)
            brace_count=$((brace_count + open - close))

            # Function ended
            if [[ $brace_count -le 0 && $func_start -gt 0 ]]; then
                local func_length=$((line_num - func_start + 1))
                if [[ $func_length -gt $MAX_FUNCTION_LINES ]]; then
                    report_issue "error" "$file" "$func_start" "Function too long: $func_name ($func_length lines, max $MAX_FUNCTION_LINES)"
                fi
                in_func=false
                func_start=0
            fi
        fi

        # Check for deep nesting (count leading spaces/tabs for indentation)
        local indent=$(echo "$line" | sed 's/[^ \t].*//' | tr '\t' '    ' | wc -c)
        local nesting_level=$((indent / 4))
        if [[ $nesting_level -gt $MAX_NESTING && ! "$line" =~ ^[[:space:]]*$ && ! "$line" =~ ^[[:space:]]*/\* && ! "$line" =~ ^[[:space:]]*// ]]; then
            report_issue "warning" "$file" "$line_num" "Deep nesting: level $nesting_level (max $MAX_NESTING)"
        fi

        # Check for many parameters
        if echo "$line" | grep -qE 'func\s+[a-zA-Z0-9_]+\s*\('; then
            local param_count=$(echo "$line" | grep -o ',' | wc -l)
            param_count=$((param_count + 1))
            # Only count if line has opening paren with params
            if echo "$line" | grep -qE '\([^)]+'; then
                if [[ $param_count -gt $MAX_PARAMS ]]; then
                    report_issue "warning" "$file" "$line_num" "Too many parameters: $param_count (max $MAX_PARAMS)"
                fi
            fi
        fi

        # Check for force unwraps
        if echo "$line" | grep -qE '[a-zA-Z0-9_]+!' && ! echo "$line" | grep -qE '//|/\*|\*/|IBOutlet|IBAction'; then
            # Exclude common patterns
            if ! echo "$line" | grep -qE 'try!|as!|fatalError|precondition|assert'; then
                report_issue "warning" "$file" "$line_num" "Force unwrap detected"
            fi
        fi

    done < "$file"
}

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}CHECKING FILES${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ -n "$SPECIFIC_FILE" ]]; then
    if [[ -f "$SPECIFIC_FILE" ]]; then
        check_file "$SPECIFIC_FILE"
    else
        echo -e "${RED}File not found: $SPECIFIC_FILE${NC}"
        exit 1
    fi
else
    # Check all Swift files
    while IFS= read -r -d '' file; do
        check_file "$file"
    done < <(find "$SOURCE_DIR" -name "*.swift" -type f -print0 2>/dev/null)
fi

# Summary
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}SUMMARY${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Files checked: ${CYAN}$FILES_CHECKED${NC}"
echo -e "  Errors: ${RED}$ERRORS${NC}"
echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}✓ All complexity checks passed!${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}${BOLD}⚠ Passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    if [[ "$WARN_ONLY" == true ]]; then
        echo -e "${YELLOW}${BOLD}⚠ $ERRORS error(s) found (warn-only mode)${NC}"
        exit 0
    else
        echo -e "${RED}${BOLD}✗ Failed with $ERRORS error(s)${NC}"
        echo ""
        echo -e "${DIM}Use --warn-only to ignore errors${NC}"
        exit 1
    fi
fi
