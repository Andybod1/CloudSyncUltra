#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Project Ops Kit - Install Git Hooks                                       ║
# ║  Sets up pre-commit hooks for quality assurance                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/install-hooks.sh
#
# This installs:
#   - pre-commit: Runs before each commit (build check, syntax, etc.)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo ""
echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║          Installing Git Hooks                                 ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check we're in a git repo
if [[ ! -d "$PROJECT_ROOT/.git" ]]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Create hooks directory if needed
mkdir -p "$HOOKS_DIR"

# Install pre-commit hook
echo -e "${BLUE}Installing pre-commit hook...${NC}"

if [[ -f "$HOOKS_DIR/pre-commit" ]]; then
    echo -e "  ${YELLOW}⚠${NC} Existing pre-commit hook found"
    echo -e "  ${YELLOW}  Backing up to pre-commit.backup${NC}"
    mv "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit.backup"
fi

# Copy hook
cp "$SCRIPT_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

echo -e "  ${GREEN}✓${NC} pre-commit hook installed"

# Verify installation
echo ""
echo -e "${BLUE}Verifying installation...${NC}"

if [[ -x "$HOOKS_DIR/pre-commit" ]]; then
    echo -e "  ${GREEN}✓${NC} Hook is executable"
else
    echo -e "  ${RED}✗${NC} Hook not executable"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✓ Git hooks installed successfully!${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}What happens now:${NC}"
echo -e "  • Every commit will run automatic quality checks"
echo -e "  • Build failures will ${RED}block${NC} the commit"
echo -e "  • Version mismatches will show ${YELLOW}warnings${NC}"
echo ""
echo -e "  ${BOLD}Commands:${NC}"
echo -e "  • ${BLUE}git commit${NC}           - Normal commit (checks run)"
echo -e "  • ${BLUE}git commit --no-verify${NC} - Skip checks (emergency only)"
echo ""
echo -e "  ${BOLD}To uninstall:${NC}"
echo -e "  • ${BLUE}rm .git/hooks/pre-commit${NC}"
echo ""
