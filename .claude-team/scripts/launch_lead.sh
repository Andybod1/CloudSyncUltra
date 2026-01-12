#!/bin/bash

# Launch Lead Agent (Opus) for CloudSync Ultra
# This script opens a new terminal with Claude Code using Opus model

echo "🚀 Launching Lead Agent..."

# Open new Terminal window with Claude Code
osascript << 'EOF'
tell application "Terminal"
    activate
    do script "cd ~/Claude && claude --model opus"
end tell
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  LEAD AGENT TERMINAL OPENED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Paste this startup command in the Lead terminal:"
echo ""
echo "  Read /Users/antti/Claude/.claude-team/LEAD/LEAD_BRIEFING.md then check STRATEGIC/DIRECTIVE.md for current directive and execute it. Update STATUS.md and write LEAD_REPORT.md when complete."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
