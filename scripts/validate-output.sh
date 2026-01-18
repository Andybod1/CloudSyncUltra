#!/bin/bash
#
# Worker Output Validation Script
# Validates that worker output files have all required sections
#
# Usage:
#   ./scripts/validate-output.sh <output-file.md>
#   ./scripts/validate-output.sh --all              # Validate all outputs
#   ./scripts/validate-output.sh --type dev <file>  # Validate as dev task
#   ./scripts/validate-output.sh --type arch <file> # Validate as architecture study
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Required sections for different output types
ARCH_SECTIONS=(
    "Executive Summary"
    "Current Implementation Status"
    "rclone Backend Analysis|Backend Analysis|Protocol Analysis"
    "Recommendation|Recommendations"
    "Implementation Checklist|Checklist|Next Steps"
)

DEV_SECTIONS=(
    "What was done|Summary|Changes Made"
    "Files changed|Files Modified|Modified Files"
    "How to test|Testing|Test Plan"
)

RESEARCH_SECTIONS=(
    "Executive Summary|Summary"
    "Findings|Analysis|Research"
    "Recommendation|Recommendations|Conclusion"
)

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║              OUTPUT VALIDATION                                ║${NC}"
    echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

detect_type() {
    local file="$1"
    local basename=$(basename "$file")

    if [[ "$basename" =~ ^ARCH ]]; then
        echo "arch"
    elif [[ "$basename" =~ ^DEV ]]; then
        echo "dev"
    elif [[ "$basename" =~ ^RESEARCH ]]; then
        echo "research"
    elif [[ "$basename" =~ _COMPLETE\.md$ ]]; then
        echo "dev"
    else
        # Default to arch for integration studies
        echo "arch"
    fi
}

validate_file() {
    local file="$1"
    local type="$2"
    local errors=0
    local warnings=0

    if [[ ! -f "$file" ]]; then
        echo -e "${RED}✗ File not found: $file${NC}"
        return 1
    fi

    local content=$(cat "$file")
    local filename=$(basename "$file")

    echo -e "${BOLD}Validating: ${BLUE}$filename${NC} (type: $type)"
    echo ""

    # Select sections based on type
    local sections=()
    case "$type" in
        arch)
            sections=("${ARCH_SECTIONS[@]}")
            ;;
        dev)
            sections=("${DEV_SECTIONS[@]}")
            ;;
        research)
            sections=("${RESEARCH_SECTIONS[@]}")
            ;;
    esac

    # Check each required section
    for section_pattern in "${sections[@]}"; do
        # Split pattern by | for alternatives
        IFS='|' read -ra alternatives <<< "$section_pattern"
        local found=false
        local matched_section=""

        for alt in "${alternatives[@]}"; do
            # Case-insensitive search for section header
            if echo "$content" | grep -qi "^#.*$alt\|^##.*$alt\|^###.*$alt"; then
                found=true
                matched_section="$alt"
                break
            fi
        done

        if $found; then
            echo -e "  ${GREEN}✓${NC} ${matched_section}"
        else
            echo -e "  ${RED}✗${NC} ${alternatives[0]} - ${RED}MISSING${NC}"
            errors=$((errors + 1))
        fi
    done

    # Additional checks
    echo ""
    echo -e "${BOLD}Additional Checks:${NC}"

    # Check for status field
    if echo "$content" | grep -qi "Status.*Complete\|Status.*Done\|Status.*Finished"; then
        echo -e "  ${GREEN}✓${NC} Status marked complete"
    else
        echo -e "  ${YELLOW}⚠${NC} Status not marked complete"
        warnings=$((warnings + 1))
    fi

    # Check for date
    if echo "$content" | grep -qi "Date.*202[0-9]"; then
        echo -e "  ${GREEN}✓${NC} Date present"
    else
        echo -e "  ${YELLOW}⚠${NC} Date missing"
        warnings=$((warnings + 1))
    fi

    # Check minimum length (at least 50 lines for arch, 20 for dev)
    local line_count=$(wc -l < "$file" | tr -d ' ')
    local min_lines=20
    [[ "$type" == "arch" ]] && min_lines=50

    if [[ $line_count -ge $min_lines ]]; then
        echo -e "  ${GREEN}✓${NC} Length OK ($line_count lines)"
    else
        echo -e "  ${YELLOW}⚠${NC} Short output ($line_count lines, expected $min_lines+)"
        warnings=$((warnings + 1))
    fi

    # Check for code blocks in dev tasks
    if [[ "$type" == "dev" ]]; then
        if echo "$content" | grep -q '```'; then
            echo -e "  ${GREEN}✓${NC} Code blocks present"
        else
            echo -e "  ${YELLOW}⚠${NC} No code blocks found"
            warnings=$((warnings + 1))
        fi
    fi

    # Summary
    echo ""
    echo -e "${BOLD}─────────────────────────────────────────────────────────────────${NC}"

    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✓ PASSED${NC} - All checks passed"
        return 0
    elif [[ $errors -eq 0 ]]; then
        echo -e "${YELLOW}${BOLD}⚠ PASSED WITH WARNINGS${NC} - $warnings warning(s)"
        return 0
    else
        echo -e "${RED}${BOLD}✗ FAILED${NC} - $errors required section(s) missing, $warnings warning(s)"
        return 1
    fi
}

validate_all() {
    local output_dir="$PROJECT_ROOT/.claude-team/outputs"
    local total=0
    local passed=0
    local failed=0

    print_header

    if [[ ! -d "$output_dir" ]]; then
        echo -e "${RED}Output directory not found: $output_dir${NC}"
        exit 1
    fi

    for file in "$output_dir"/*.md; do
        [[ -f "$file" ]] || continue
        total=$((total + 1))

        local type=$(detect_type "$file")

        if validate_file "$file" "$type"; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
        fi

        echo ""
    done

    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}SUMMARY:${NC} $passed/$total passed, $failed failed"

    if [[ $failed -gt 0 ]]; then
        exit 1
    fi
}

# Main
print_header

TYPE=""
FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all|-a)
            validate_all
            exit $?
            ;;
        --type|-t)
            TYPE="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options] <output-file.md>"
            echo ""
            echo "Options:"
            echo "  --all, -a          Validate all output files"
            echo "  --type, -t TYPE    Specify type: arch, dev, research"
            echo "  --help, -h         Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 .claude-team/outputs/ARCH1_141_SEAFILE.md"
            echo "  $0 --type dev DEV1_COMPLETE.md"
            echo "  $0 --all"
            exit 0
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

if [[ -z "$FILE" ]]; then
    echo -e "${RED}Error: No file specified${NC}"
    echo "Usage: $0 [--type arch|dev|research] <output-file.md>"
    echo "       $0 --all"
    exit 1
fi

# Auto-detect type if not specified
if [[ -z "$TYPE" ]]; then
    TYPE=$(detect_type "$FILE")
fi

validate_file "$FILE" "$TYPE"
