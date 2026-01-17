#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - Install Xcode Templates                                 ║
# ║  Adds CloudSync-specific file templates to Xcode                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/install-templates.sh
#
# Installs templates to: ~/Library/Developer/Xcode/Templates/File Templates/CloudSync/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_SOURCE="$SCRIPT_DIR/xcode-templates"
TEMPLATES_DEST="$HOME/Library/Developer/Xcode/Templates/File Templates/CloudSync"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║     Installing Xcode Templates                                ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if source templates exist
if [[ ! -d "$TEMPLATES_SOURCE" ]]; then
    echo -e "${YELLOW}⚠${NC} Template source directory not found: $TEMPLATES_SOURCE"
    exit 1
fi

# Create destination directory
mkdir -p "$TEMPLATES_DEST"

# Copy templates
echo -e "${BOLD}Installing templates...${NC}"
echo ""

TEMPLATE_COUNT=0
for template in "$TEMPLATES_SOURCE"/*.xctemplate; do
    if [[ -d "$template" ]]; then
        template_name=$(basename "$template")
        cp -r "$template" "$TEMPLATES_DEST/"
        echo -e "  ${GREEN}✓${NC} $template_name"
        TEMPLATE_COUNT=$((TEMPLATE_COUNT + 1))
    fi
done

echo ""
echo -e "${BLUE}${BOLD}─────────────────────────────────────────────────────────────────${NC}"

if [[ $TEMPLATE_COUNT -gt 0 ]]; then
    echo -e "${GREEN}${BOLD}✓ Installed $TEMPLATE_COUNT template(s)${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo -e "  1. Open Xcode"
    echo -e "  2. File → New → File..."
    echo -e "  3. Scroll down to ${CYAN}CloudSync${NC} section"
    echo -e "  4. Select template and click Next"
    echo ""
    echo -e "${BOLD}Installed to:${NC}"
    echo -e "  $TEMPLATES_DEST"
else
    echo -e "${YELLOW}⚠${NC} No templates found to install"
fi
echo ""
