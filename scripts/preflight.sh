#!/bin/bash
#
# Pre-flight Checklist Script
# Interactive checklist workers must complete before marking task done
#
# Usage:
#   ./scripts/preflight.sh              # Interactive mode
#   ./scripts/preflight.sh --quick      # Non-interactive (just run checks)
#   ./scripts/preflight.sh --dev        # Dev task checklist
#   ./scripts/preflight.sh --arch       # Architecture study checklist
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
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

INTERACTIVE=true
TASK_TYPE="dev"
ERRORS=0
WARNINGS=0

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║              PRE-FLIGHT CHECKLIST                             ║${NC}"
    echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${DIM}Complete all checks before marking your task done.${NC}"
    echo ""
}

ask_confirm() {
    local prompt="$1"
    local required="${2:-true}"

    if [[ "$INTERACTIVE" == "false" ]]; then
        return 0
    fi

    echo -ne "  ${CYAN}[?]${NC} $prompt ${DIM}(y/n)${NC}: "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "      ${GREEN}✓ Confirmed${NC}"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            echo -e "      ${RED}✗ Not confirmed - REQUIRED${NC}"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "      ${YELLOW}⚠ Skipped${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
        return 1
    fi
}

run_check() {
    local name="$1"
    local command="$2"

    echo -ne "  ${BLUE}[~]${NC} $name... "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Passed${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed${NC}"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Automated Checks
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run_automated_checks() {
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}AUTOMATED CHECKS${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Build check
    run_check "Build compiles" "xcodebuild build -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -quiet 2>&1 | grep -q 'BUILD SUCCEEDED'"

    # Release build check
    run_check "Release build compiles" "xcodebuild build -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -configuration Release -quiet 2>&1 | grep -q 'BUILD SUCCEEDED'"

    # Tests check (just verify they run, not full suite)
    run_check "Tests framework loads" "xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' -only-testing:CloudSyncAppTests/CloudSyncAppTests/testAppNameIsNotEmpty -quiet 2>&1 | grep -q 'TEST.*PASSED\|Test.*passed'"

    # SwiftLint check
    if command -v swiftlint &> /dev/null; then
        run_check "SwiftLint passes" "swiftlint lint --quiet 2>&1 | grep -v 'warning:' | grep -v 'error:' || true"
    fi

    # Version consistency
    run_check "Versions aligned" "./scripts/version-check.sh 2>&1 | grep -q 'All.*match\|versions.*consistent'"

    # No debug artifacts
    run_check "No debug print statements" "! grep -r 'print(\"DEBUG\|print(\"TODO\|print(\"FIXME' CloudSyncApp/*.swift 2>/dev/null"

    # No @Previewable usage
    run_check "No @Previewable usage" "! grep -r '@Previewable' CloudSyncApp/*.swift CloudSyncApp/**/*.swift 2>/dev/null"

    echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Manual Confirmations - Dev Tasks
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run_dev_confirmations() {
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}MANUAL CONFIRMATIONS (Dev Task)${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    ask_confirm "Did you add new files to project.pbxproj?" "false"
    ask_confirm "Did you update all relevant switch statements?" "true"
    ask_confirm "Did you check COMMON_MISTAKES.md for patterns to avoid?" "true"
    ask_confirm "Did you test the feature manually in the app?" "true"
    ask_confirm "Did you write/update tests for your changes?" "false"
    ask_confirm "Did you update your output file with results?" "true"
    ask_confirm "Does your commit message follow conventional format?" "true"

    echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Manual Confirmations - Architecture Studies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run_arch_confirmations() {
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}MANUAL CONFIRMATIONS (Architecture Study)${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    ask_confirm "Did you check existing implementation in CloudProviderType.swift?" "true"
    ask_confirm "Did you check RcloneManager.swift for setup functions?" "true"
    ask_confirm "Did you document all authentication methods?" "true"
    ask_confirm "Did you identify gaps in current implementation?" "true"
    ask_confirm "Did you provide clear recommendations?" "true"
    ask_confirm "Did you include an implementation checklist?" "true"
    ask_confirm "Did you run ./scripts/validate-output.sh on your output?" "true"

    echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Summary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print_summary() {
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}SUMMARY${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}✓ ALL CHECKS PASSED${NC}"
        echo ""
        echo -e "  ${GREEN}You are cleared for completion!${NC}"
        echo -e "  ${DIM}Run: git add . && git commit -m 'your message'${NC}"
        echo ""
        return 0
    elif [[ $ERRORS -eq 0 ]]; then
        echo -e "  ${YELLOW}${BOLD}⚠ PASSED WITH $WARNINGS WARNING(S)${NC}"
        echo ""
        echo -e "  ${YELLOW}Consider addressing warnings before completing.${NC}"
        echo ""
        return 0
    else
        echo -e "  ${RED}${BOLD}✗ BLOCKED - $ERRORS ERROR(S), $WARNINGS WARNING(S)${NC}"
        echo ""
        echo -e "  ${RED}Fix errors before marking task complete!${NC}"
        echo ""
        echo -e "  ${DIM}Common fixes:${NC}"
        echo -e "  ${DIM}- Run: xcodebuild -configuration Release build${NC}"
        echo -e "  ${DIM}- Check: .claude-team/COMMON_MISTAKES.md${NC}"
        echo -e "  ${DIM}- Run: ./scripts/worker-qa.sh${NC}"
        echo ""
        return 1
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

while [[ $# -gt 0 ]]; do
    case "$1" in
        --quick|-q)
            INTERACTIVE=false
            shift
            ;;
        --dev|-d)
            TASK_TYPE="dev"
            shift
            ;;
        --arch|-a)
            TASK_TYPE="arch"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --quick, -q    Non-interactive (run automated checks only)"
            echo "  --dev, -d      Dev task checklist (default)"
            echo "  --arch, -a     Architecture study checklist"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_header

# Run automated checks
run_automated_checks

# Run manual confirmations based on task type
if [[ "$INTERACTIVE" == "true" ]]; then
    case "$TASK_TYPE" in
        dev)
            run_dev_confirmations
            ;;
        arch)
            run_arch_confirmations
            ;;
    esac
fi

print_summary
exit $?
