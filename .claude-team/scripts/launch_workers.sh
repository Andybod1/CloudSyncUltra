#!/bin/bash

# Launch 4 Workers (Sonnet) for CloudSync Ultra
# Strategic Partner (Desktop Claude) manages directly - no Lead needed

echo "🚀 Launching 4 Workers..."
echo ""

# Open 4 Terminal windows
osascript << 'EOF'
tell application "Terminal"
    activate
    
    -- Dev-1 (UI)
    do script "cd ~/Claude && echo '=== DEV-1 (UI) ===' && claude"
    delay 0.5
    
    -- Dev-2 (Engine)
    do script "cd ~/Claude && echo '=== DEV-2 (Engine) ===' && claude"
    delay 0.5
    
    -- Dev-3 (Services)
    do script "cd ~/Claude && echo '=== DEV-3 (Services) ===' && claude"
    delay 0.5
    
    -- QA (Testing)
    do script "cd ~/Claude && echo '=== QA (Testing) ===' && claude"
end tell
EOF

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  4 WORKER TERMINALS OPENED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Paste these commands in each terminal:"
echo ""
echo "DEV-1 (UI):"
echo "  Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work."
echo ""
echo "DEV-2 (Engine):"
echo "  Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work."
echo ""
echo "DEV-3 (Services):"
echo "  Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work."
echo ""
echo "QA (Testing):"
echo "  Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "When workers finish, tell Desktop Claude: 'Workers done'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
