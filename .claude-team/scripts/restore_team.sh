#!/bin/bash
# CloudSync Ultra - Parallel Team Recovery Script
# Run this after computer restart to restore the development team
#
# Usage: ./restore_team.sh

echo "🔄 CloudSync Ultra - Parallel Team Recovery"
echo "============================================"
echo ""

# Check Node.js
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
else
    echo "❌ Node.js not found. Installing..."
    brew install node
fi

# Check Claude Code
if command -v claude &> /dev/null; then
    echo "✅ Claude Code: $(claude --version)"
else
    echo "❌ Claude Code not found. Installing..."
    npm install -g @anthropic-ai/claude-code
fi

# Verify team infrastructure
TEAM_DIR="/Users/antti/Claude/.claude-team"
if [ -d "$TEAM_DIR" ]; then
    echo "✅ Team infrastructure: Found"
else
    echo "❌ Team infrastructure not found. Pulling from git..."
    cd /Users/antti/Claude && git pull origin main
fi

echo ""
echo "============================================"
echo "📋 Recovery Complete!"
echo "============================================"
echo ""
echo "To launch the team, open 4 Terminal windows and run:"
echo ""
echo "  cd ~/Claude && claude"
echo ""
echo "Then paste these startup commands:"
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ Dev-1: Read ~/.claude-team/templates/DEV1_BRIEFING.md then  │"
echo "│        read and execute ~/.claude-team/tasks/TASK_DEV1.md   │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ Dev-2: Read ~/.claude-team/templates/DEV2_BRIEFING.md then  │"
echo "│        read and execute ~/.claude-team/tasks/TASK_DEV2.md   │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ Dev-3: Read ~/.claude-team/templates/DEV3_BRIEFING.md then  │"
echo "│        read and execute ~/.claude-team/tasks/TASK_DEV3.md   │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ QA:    Read ~/.claude-team/templates/QA_BRIEFING.md then    │"
echo "│        read and execute ~/.claude-team/tasks/TASK_QA.md     │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""
echo "Or run: ~/.claude-team/scripts/launch_team.sh"
echo ""
