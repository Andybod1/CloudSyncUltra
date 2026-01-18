#!/bin/bash

# Project Ops Kit - Launch Multiple Workers
# Opens 4 Terminal windows ready for worker assignment

# Auto-detect project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🚀 Launching 4 Worker Terminals..."

osascript << EOF
tell application "Terminal"
    activate
    do script "cd $REPO_DIR && claude"
    delay 0.5
    do script "cd $REPO_DIR && claude"
    delay 0.5
    do script "cd $REPO_DIR && claude"
    delay 0.5
    do script "cd $REPO_DIR && claude"
end tell
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  4 WORKER TERMINALS OPENED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Paste startup commands from Strategic Partner into each terminal."
echo ""
echo "Project: $REPO_DIR"
echo ""
