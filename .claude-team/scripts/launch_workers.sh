#!/bin/bash

# Launch 4 Workers (Sonnet) for CloudSync Ultra

echo "🚀 Launching 4 Worker Agents..."

osascript << 'EOF'
tell application "Terminal"
    activate
    do script "cd ~/Claude && claude"
    delay 0.5
    do script "cd ~/Claude && claude"
    delay 0.5
    do script "cd ~/Claude && claude"
    delay 0.5
    do script "cd ~/Claude && claude"
end tell
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  4 WORKER TERMINALS OPENED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Paste startup commands from Desktop Claude into each terminal."
echo ""
