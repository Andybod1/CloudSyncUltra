#!/bin/bash

# Full Team Launch - Two-Tier Architecture
# Launches Lead Agent + 4 Workers

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       CloudSync Ultra - Two-Tier Development Team             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Architecture:"
echo ""
echo "  Strategic Partner (Desktop App - already running)"
echo "         │"
echo "         ▼"
echo "  ┌─────────────┐"
echo "  │ Lead Agent  │ ◄── Terminal 1"
echo "  └──────┬──────┘"
echo "         │"
echo "    ┌────┼────┬────┐"
echo "    ▼    ▼    ▼    ▼"
echo "  Dev-1 Dev-2 Dev-3 QA  ◄── Terminals 2-5"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "Press Enter to launch Lead Agent..."

# Launch Lead
osascript << 'EOF'
tell application "Terminal"
    activate
    do script "cd ~/Claude && clear && echo '══════════════════════════════════════════════' && echo '  🎯 LEAD AGENT (Opus)' && echo '══════════════════════════════════════════════' && echo '' && echo 'Startup command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/LEAD/LEAD_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/STRATEGIC/DIRECTIVE.md. Create task files, update WORKSTREAM.md, and output worker launch commands.' && echo '' && echo '══════════════════════════════════════════════' && echo '' && claude"
end tell
EOF

echo ""
echo "✅ Lead Agent terminal opened"
echo ""
echo "   1. Paste the startup command in the Lead terminal"
echo "   2. Wait for Lead to create task files"
echo "   3. Lead will output: 'Tasks ready. Launch workers.'"
echo ""
read -p "Press Enter when Lead says to launch workers..."

echo ""
echo "Launching 4 Workers..."
echo ""

# Dev-1
osascript << 'EOF'
tell application "Terminal"
    do script "cd ~/Claude && clear && echo '══════════════════════════════════════════════' && echo '  👷 DEV-1 (UI Layer)' && echo '══════════════════════════════════════════════' && echo '' && echo 'Startup command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.' && echo '' && echo '══════════════════════════════════════════════' && echo '' && claude"
end tell
EOF
sleep 0.5

# Dev-2
osascript << 'EOF'
tell application "Terminal"
    do script "cd ~/Claude && clear && echo '══════════════════════════════════════════════' && echo '  👷 DEV-2 (Core Engine)' && echo '══════════════════════════════════════════════' && echo '' && echo 'Startup command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.' && echo '' && echo '══════════════════════════════════════════════' && echo '' && claude"
end tell
EOF
sleep 0.5

# Dev-3
osascript << 'EOF'
tell application "Terminal"
    do script "cd ~/Claude && clear && echo '══════════════════════════════════════════════' && echo '  👷 DEV-3 (Services)' && echo '══════════════════════════════════════════════' && echo '' && echo 'Startup command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.' && echo '' && echo '══════════════════════════════════════════════' && echo '' && claude"
end tell
EOF
sleep 0.5

# QA
osascript << 'EOF'
tell application "Terminal"
    do script "cd ~/Claude && clear && echo '══════════════════════════════════════════════' && echo '  🧪 QA (Testing)' && echo '══════════════════════════════════════════════' && echo '' && echo 'Startup command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.' && echo '' && echo '══════════════════════════════════════════════' && echo '' && claude"
end tell
EOF

echo ""
echo "✅ All 5 terminals opened"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Paste startup commands in each terminal"
echo "  2. When prompted: 'Yes, allow all edits during this session'"
echo "  3. Lead will monitor and integrate"
echo "  4. Lead writes LEAD_REPORT.md when done"
echo "  5. Strategic Partner reviews and commits"
echo ""
echo "Monitor progress: cat ~/.claude-team/STATUS.md"
echo ""
