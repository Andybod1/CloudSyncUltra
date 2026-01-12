#!/bin/bash

# Launch Workers (Dev-1, Dev-2, Dev-3, QA)
# Opens 4 Terminal windows with Claude Code

echo "🚀 Launching 4 Worker Agents..."
echo ""

# Dev-1
osascript << 'EOF'
tell application "Terminal"
    activate
    do script "cd ~/Claude && echo '👷 DEV-1 (UI Layer)' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.' && echo '' && claude"
end tell
EOF

sleep 1

# Dev-2
osascript << 'EOF'
tell application "Terminal"
    do script "cd ~/Claude && echo '👷 DEV-2 (Core Engine)' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.' && echo '' && claude"
end tell
EOF

sleep 1

# Dev-3
osascript << 'EOF'
tell application "Terminal"
    do script "cd ~/Claude && echo '👷 DEV-3 (Services)' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.' && echo '' && claude"
end tell
EOF

sleep 1

# QA
osascript << 'EOF'
tell application "Terminal"
    do script "cd ~/Claude && echo '🧪 QA (Testing)' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.' && echo '' && claude"
end tell
EOF

echo ""
echo "✅ 4 Worker terminals opened"
echo ""
echo "Paste the startup commands shown in each terminal."
echo "When prompted for permissions, select 'Yes, allow all edits during this session'"
