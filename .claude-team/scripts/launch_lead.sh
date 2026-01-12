#!/bin/bash

# Launch Lead Agent
# Runs Claude Code with Opus model for Lead Agent role

echo "🚀 Launching Lead Agent (Opus)..."
echo ""
echo "Opening new Terminal with Claude Code..."
echo ""

osascript << 'EOF'
tell application "Terminal"
    activate
    do script "cd ~/Claude && echo '🎯 LEAD AGENT' && echo '' && echo 'Paste this command:' && echo '' && echo 'Read /Users/antti/Claude/.claude-team/LEAD/LEAD_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/STRATEGIC/DIRECTIVE.md. Create task files, update WORKSTREAM.md, and output worker launch commands.' && echo '' && claude"
end tell
EOF

echo ""
echo "✅ Lead Agent terminal opened"
echo ""
echo "Paste the startup command shown in the terminal."
