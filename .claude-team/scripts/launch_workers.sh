#!/bin/bash

# Launch all 4 Workers (Sonnet) for CloudSync Ultra
# Opens 4 Terminal windows with Claude Code

echo "🚀 Launching 4 Worker Agents..."

# Open 4 Terminal windows
osascript << 'EOF'
tell application "Terminal"
    activate
    
    -- Dev-1 (UI)
    do script "cd ~/Claude && claude"
    delay 0.5
    
    -- Dev-2 (Engine)
    do script "cd ~/Claude && claude"
    delay 0.5
    
    -- Dev-3 (Services)
    do script "cd ~/Claude && claude"
    delay 0.5
    
    -- QA (Testing)
    do script "cd ~/Claude && claude"
end tell
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  4 WORKER TERMINALS OPENED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Paste these startup commands in each terminal:"
echo ""
echo "Terminal 1 (Dev-1 UI):"
echo "  Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work."
echo ""
echo "Terminal 2 (Dev-2 Engine):"
echo "  Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work."
echo ""
echo "Terminal 3 (Dev-3 Services):"
echo "  Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work."
echo ""
echo "Terminal 4 (QA Testing):"
echo "  Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
