#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Setup Script - Initialize project operations structure                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/project.conf"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║              PROJECT OPERATIONS SETUP                     ║${NC}"
echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}Setting up: $PROJECT_NAME${NC}"
echo ""

# Create directories
echo -e "${BOLD}Creating directories...${NC}"
mkdir -p "$PROJECT_ROOT/.claude-team/tasks"
mkdir -p "$PROJECT_ROOT/.claude-team/outputs"
mkdir -p "$PROJECT_ROOT/.claude-team/archive"
mkdir -p "$PROJECT_ROOT/.claude-team/templates"
mkdir -p "$PROJECT_ROOT/.github/workflows"
echo -e "  ${GREEN}✓${NC} .claude-team/ structure"
echo -e "  ${GREEN}✓${NC} .github/workflows/"

# Create VERSION.txt if missing
if [[ ! -f "$PROJECT_ROOT/VERSION.txt" ]]; then
    echo "0.1.0" > "$PROJECT_ROOT/VERSION.txt"
    echo -e "  ${GREEN}✓${NC} VERSION.txt (0.1.0)"
fi

# Create STATUS.md if missing
if [[ ! -f "$PROJECT_ROOT/.claude-team/STATUS.md" ]]; then
    cat > "$PROJECT_ROOT/.claude-team/STATUS.md" << 'EOF'
# Team Status

## Workers

| Worker | Status | Current Task |
|--------|--------|--------------|
| Dev-1 | 💤 Idle | - |
| Dev-2 | 💤 Idle | - |
| Dev-3 | 💤 Idle | - |
| QA | 💤 Idle | - |
| Dev-Ops | 💤 Idle | - |

## Current Sprint

None active

## Last Updated

$(date)
EOF
    echo -e "  ${GREEN}✓${NC} .claude-team/STATUS.md"
fi

# Create RECOVERY.md if missing
if [[ ! -f "$PROJECT_ROOT/.claude-team/RECOVERY.md" ]]; then
    cat > "$PROJECT_ROOT/.claude-team/RECOVERY.md" << EOF
# Recovery Guide

## Quick Start

\`\`\`bash
./scripts/restore-context.sh  # Get context
./scripts/dashboard.sh        # Check health
\`\`\`

## Project: $PROJECT_NAME

**Version:** $(cat "$PROJECT_ROOT/VERSION.txt")
**GitHub:** $GITHUB_URL

## Key Commands

\`\`\`bash
$BUILD_COMMAND
$TEST_COMMAND
\`\`\`
EOF
    echo -e "  ${GREEN}✓${NC} .claude-team/RECOVERY.md"
fi

# Make scripts executable
chmod +x "$PROJECT_ROOT/scripts/"*.sh
echo -e "  ${GREEN}✓${NC} Scripts made executable"

echo ""
echo -e "${GREEN}${BOLD}✓ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit project.conf with your settings"
echo "  2. Run ./scripts/dashboard.sh"
echo "  3. Customize .github/workflows/ci.yml for your stack"
echo ""
