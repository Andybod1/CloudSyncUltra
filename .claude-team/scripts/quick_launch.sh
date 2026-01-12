#!/bin/bash
# CloudSync Ultra - One-Click Team Launcher
# Opens 4 Terminal windows with Claude Code ready for the parallel team
#
# Usage: ./quick_launch.sh

echo "🚀 Launching CloudSync Ultra Parallel Team..."

# Open Terminal 1 - Dev-1
osascript << 'END1'
tell application "Terminal"
    activate
    do script "cd /Users/antti/Claude && echo '🔵 DEV-1 (UI Layer)' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.' && echo '' && claude"
end tell
END1

sleep 0.5

# Open Terminal 2 - Dev-2
osascript << 'END2'
tell application "Terminal"
    do script "cd /Users/antti/Claude && echo '🟢 DEV-2 (Core Engine)' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.' && echo '' && claude"
end tell
END2

sleep 0.5

# Open Terminal 3 - Dev-3
osascript << 'END3'
tell application "Terminal"
    do script "cd /Users/antti/Claude && echo '🟣 DEV-3 (Services)' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.' && echo '' && claude"
end tell
END3

sleep 0.5

# Open Terminal 4 - QA
osascript << 'END4'
tell application "Terminal"
    do script "cd /Users/antti/Claude && echo '🟡 QA (Testing)' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.' && echo '' && claude"
end tell
END4

echo ""
echo "✅ 4 Terminal windows opened with Claude Code"
echo ""
echo "Each window shows the startup command to paste."
echo "When prompted for permissions, select option 2:"
echo "  'Yes, allow all edits during this session'"
echo ""
