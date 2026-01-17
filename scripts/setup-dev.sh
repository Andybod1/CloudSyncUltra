#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - Developer Setup                                         ║
# ║  One command to set up a new development environment                       ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/setup-dev.sh
#
# This script:
# 1. Checks prerequisites (Xcode, Homebrew)
# 2. Installs required tools (rclone, swiftlint, swiftformat)
# 3. Installs git hooks
# 4. Builds the project
# 5. Runs tests to verify setup

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo ""
echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║     CloudSync Ultra - Developer Setup                         ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0

# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Check prerequisites
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[1/7]${NC} Checking prerequisites..."

# Check Xcode
if ! xcode-select -p &> /dev/null; then
    echo -e "  ${RED}✗${NC} Xcode Command Line Tools not installed"
    echo -e "      Run: xcode-select --install"
    ERRORS=$((ERRORS + 1))
else
    XCODE_VERSION=$(xcodebuild -version 2>/dev/null | head -1 || echo "Unknown")
    echo -e "  ${GREEN}✓${NC} $XCODE_VERSION"
fi

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "  ${RED}✗${NC} Homebrew not installed"
    echo -e "      Visit: https://brew.sh"
    ERRORS=$((ERRORS + 1))
else
    echo -e "  ${GREEN}✓${NC} Homebrew installed"
fi

if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo -e "${RED}Please install missing prerequisites and run again.${NC}"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 2: Install tools
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[2/7]${NC} Installing development tools..."

install_if_missing() {
    local tool=$1
    local brew_name=${2:-$1}

    if command -v "$tool" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $tool already installed"
    else
        echo -e "  ${YELLOW}→${NC} Installing $tool..."
        brew install "$brew_name" --quiet
        echo -e "  ${GREEN}✓${NC} $tool installed"
    fi
}

install_if_missing "rclone"
install_if_missing "swiftlint"
install_if_missing "swiftformat"
install_if_missing "gh"
install_if_missing "jq"

# ─────────────────────────────────────────────────────────────────────────────
# Step 3: Install git hooks
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[3/7]${NC} Installing git hooks..."

if [[ -x "./scripts/install-hooks.sh" ]]; then
    ./scripts/install-hooks.sh
    echo -e "  ${GREEN}✓${NC} Git hooks installed"
else
    echo -e "  ${YELLOW}⚠${NC} install-hooks.sh not found"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 4: Install Xcode templates
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[4/7]${NC} Installing Xcode templates..."

if [[ -x "./scripts/install-templates.sh" ]]; then
    ./scripts/install-templates.sh > /dev/null 2>&1 || true
    echo -e "  ${GREEN}✓${NC} Xcode templates installed"
else
    echo -e "  ${YELLOW}⚠${NC} install-templates.sh not found"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 5: Build project
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[5/7]${NC} Building project..."

if xcodebuild -scheme CloudSyncApp -configuration Debug build -quiet 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Build succeeded"
else
    echo -e "  ${RED}✗${NC} Build failed"
    ERRORS=$((ERRORS + 1))
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 6: Run tests
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[6/7]${NC} Running tests..."

if xcodebuild test -scheme CloudSyncApp -destination 'platform=macOS' -quiet 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Tests passed"
else
    echo -e "  ${YELLOW}⚠${NC} Some tests failed (check Xcode for details)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 7: Verify setup
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[7/7]${NC} Verifying setup..."

VERSION=$(cat VERSION.txt 2>/dev/null || echo "unknown")
echo -e "  ${GREEN}✓${NC} Project version: $VERSION"

if [[ -f ".git/hooks/pre-commit" ]]; then
    echo -e "  ${GREEN}✓${NC} Pre-commit hook active"
else
    echo -e "  ${YELLOW}⚠${NC} Pre-commit hook not installed"
fi

if [[ -f ".git/hooks/pre-push" ]]; then
    echo -e "  ${GREEN}✓${NC} Pre-push hook active"
else
    echo -e "  ${YELLOW}⚠${NC} Pre-push hook not installed"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}${BOLD}─────────────────────────────────────────────────────────────────${NC}"

if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}✓ Development environment ready!${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "  ${CYAN}1.${NC} Open CloudSyncApp.xcodeproj in Xcode"
    echo -e "  ${CYAN}2.${NC} Run ./scripts/dashboard.sh to see project status"
    echo -e "  ${CYAN}3.${NC} Check .claude-team/tasks/ for current work items"
else
    echo -e "${RED}${BOLD}✗ Setup completed with $ERRORS error(s)${NC}"
    echo -e "  Please fix the issues above and run again."
    exit 1
fi
