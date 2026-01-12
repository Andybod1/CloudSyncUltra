#!/bin/bash
# Launch Dev-2 Worker
# Usage: ./launch_dev2.sh

cd /Users/antti/Claude

echo "🚀 Launching Dev-2 (Backend) Worker..."
echo ""
echo "Starting Claude Code with Dev-2 briefing..."
echo ""

claude -p "You are Dev-2, a backend developer. First, read your briefing at /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md to understand your role. Then read your current task at /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md and execute it. Update STATUS.md as you work."
