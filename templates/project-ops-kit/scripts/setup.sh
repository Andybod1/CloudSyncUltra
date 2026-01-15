#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Setup Script - Initialize project operations structure                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/setup.sh
#
# This script:
# 1. Creates the .claude-team directory structure
# 2. Replaces {PROJECT_ROOT} placeholders with actual paths
# 3. Sets up initial files (STATUS.md, RECOVERY.md, etc.)
# 4. Makes scripts executable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load project configuration
if [[ -f "$PROJECT_ROOT/project.conf" ]]; then
    source "$PROJECT_ROOT/project.conf"
else
    echo "Warning: project.conf not found. Using defaults."
    PROJECT_NAME=$(basename "$PROJECT_ROOT")
    GITHUB_URL=""
    BUILD_COMMAND="# Configure your build command"
    TEST_COMMAND="# Configure your test command"
fi

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
echo -e "${BOLD}Location:   $PROJECT_ROOT${NC}"
echo ""

# Create directories
echo -e "${BOLD}Creating directories...${NC}"
mkdir -p "$PROJECT_ROOT/.claude-team/tasks"
mkdir -p "$PROJECT_ROOT/.claude-team/outputs"
mkdir -p "$PROJECT_ROOT/.claude-team/archive"
mkdir -p "$PROJECT_ROOT/.claude-team/templates"
mkdir -p "$PROJECT_ROOT/.claude-team/tickets"
mkdir -p "$PROJECT_ROOT/.github/workflows"
mkdir -p "$PROJECT_ROOT/.github/ISSUE_TEMPLATE"
echo -e "  ${GREEN}✓${NC} .claude-team/ structure"
echo -e "  ${GREEN}✓${NC} .github/workflows/"

# Replace {PROJECT_ROOT} placeholders in template files
echo -e "${BOLD}Configuring templates...${NC}"
PLACEHOLDER_COUNT=0
for file in "$PROJECT_ROOT/.claude-team/templates/"*.md "$PROJECT_ROOT/.claude-team/"*.md; do
    if [[ -f "$file" ]]; then
        if grep -q "{PROJECT_ROOT}" "$file" 2>/dev/null; then
            sed -i '' "s|{PROJECT_ROOT}|$PROJECT_ROOT|g" "$file"
            PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + 1))
        fi
    fi
done
echo -e "  ${GREEN}✓${NC} Replaced {PROJECT_ROOT} in $PLACEHOLDER_COUNT files"

# Create VERSION.txt if missing
if [[ ! -f "$PROJECT_ROOT/VERSION.txt" ]]; then
    echo "1.0.0" > "$PROJECT_ROOT/VERSION.txt"
    echo -e "  ${GREEN}✓${NC} VERSION.txt (1.0.0)"
else
    echo -e "  ${YELLOW}○${NC} VERSION.txt already exists"
fi

# Create STATUS.md if missing
if [[ ! -f "$PROJECT_ROOT/.claude-team/STATUS.md" ]]; then
    cat > "$PROJECT_ROOT/.claude-team/STATUS.md" << EOF
# Team Status - $PROJECT_NAME

## Workers

| Worker | Status | Current Task | Est. Time |
|--------|--------|--------------|-----------|
| Dev-1 | 💤 Idle | - | - |
| Dev-2 | 💤 Idle | - | - |
| Dev-3 | 💤 Idle | - | - |
| QA | 💤 Idle | - | - |
| Dev-Ops | 💤 Idle | - | - |

## Current Sprint

None active

## Quick Commands

\`\`\`bash
./scripts/dashboard.sh          # Project health
./scripts/restore-context.sh    # Session onboarding
gh issue list                   # View issues
\`\`\`

## Last Updated

$(date '+%Y-%m-%d %H:%M:%S')
EOF
    echo -e "  ${GREEN}✓${NC} .claude-team/STATUS.md"
else
    echo -e "  ${YELLOW}○${NC} STATUS.md already exists"
fi

# Create RECOVERY.md if missing
if [[ ! -f "$PROJECT_ROOT/.claude-team/RECOVERY.md" ]]; then
    cat > "$PROJECT_ROOT/.claude-team/RECOVERY.md" << EOF
# Recovery Guide - $PROJECT_NAME

## Quick Start

\`\`\`bash
./scripts/restore-context.sh  # Get context
./scripts/dashboard.sh        # Check health
\`\`\`

## Project Info

**Version:** $(cat "$PROJECT_ROOT/VERSION.txt")
**Location:** $PROJECT_ROOT
**GitHub:** $GITHUB_URL

## Key Commands

\`\`\`bash
# Build
$BUILD_COMMAND

# Test
$TEST_COMMAND
\`\`\`

## File Structure

\`\`\`
$PROJECT_ROOT/
├── .claude-team/
│   ├── STATUS.md        # Worker coordination
│   ├── RECOVERY.md      # This file
│   ├── templates/       # Worker briefings
│   ├── tasks/           # Current task files
│   └── outputs/         # Completion reports
├── scripts/
│   ├── dashboard.sh     # Health dashboard
│   ├── restore-context.sh
│   └── release.sh
└── VERSION.txt
\`\`\`

## Recovery Scenarios

### After Session Restart
1. Run: \`./scripts/restore-context.sh\`
2. Check: \`.claude-team/STATUS.md\` for active work
3. Resume from last task file

### After Git Pull
1. Run: \`./scripts/dashboard.sh\`
2. Check for new issues: \`gh issue list\`
3. Review recent commits: \`git log --oneline -10\`
EOF
    echo -e "  ${GREEN}✓${NC} .claude-team/RECOVERY.md"
else
    echo -e "  ${YELLOW}○${NC} RECOVERY.md already exists"
fi

# Create ticket inbox files
if [[ ! -f "$PROJECT_ROOT/.claude-team/tickets/INBOX.md" ]]; then
    cat > "$PROJECT_ROOT/.claude-team/tickets/INBOX.md" << EOF
# Ticket Inbox

Drop quick notes here for processing by Strategic Partner.

---

EOF
    echo -e "  ${GREEN}✓${NC} .claude-team/tickets/INBOX.md"
fi

if [[ ! -f "$PROJECT_ROOT/.claude-team/tickets/ACTIVE.md" ]]; then
    cat > "$PROJECT_ROOT/.claude-team/tickets/ACTIVE.md" << EOF
# Active Tickets

Local backup of in-progress work.

---

EOF
    echo -e "  ${GREEN}✓${NC} .claude-team/tickets/ACTIVE.md"
fi

# Make scripts executable
chmod +x "$PROJECT_ROOT/scripts/"*.sh 2>/dev/null || true
chmod +x "$PROJECT_ROOT/scripts/pre-commit" 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Scripts made executable"

# Install git hooks (optional)
echo ""
read -p "Install git hooks for pre-commit checks? [y/N]: " install_hooks
if [[ "$install_hooks" =~ ^[Yy]$ ]]; then
    "$PROJECT_ROOT/scripts/install-hooks.sh"
fi

echo ""
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✓ Setup complete!${NC}"
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit project.conf with your project settings"
echo "  2. Run ./scripts/dashboard.sh to verify setup"
echo "  3. Customize scripts for your tech stack"
echo "  4. Create CLAUDE_PROJECT_KNOWLEDGE.md for your project"
echo ""
