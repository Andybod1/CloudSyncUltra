#!/bin/bash
# Launch Dev-3 Worker
# Usage: ./launch_dev3.sh

cd /Users/antti/Claude

echo "🚀 Launching Dev-3 (Services) Worker..."
echo ""
echo "Starting Claude Code with Dev-3 briefing..."
echo ""

claude -p "You are Dev-3, a services developer. First, read your briefing at /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md to understand your role. Then read your current task at /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md and execute it. Update STATUS.md as you work."
