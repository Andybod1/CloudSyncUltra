#!/bin/bash
# Launch Dev-1 Worker
# Usage: ./launch_dev1.sh

cd /Users/antti/Claude

echo "🚀 Launching Dev-1 (Frontend) Worker..."
echo ""
echo "Starting Claude Code with Dev-1 briefing..."
echo ""

claude -p "You are Dev-1, a frontend developer. First, read your briefing at /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md to understand your role. Then read your current task at /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md and execute it. Update STATUS.md as you work."
