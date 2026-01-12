#!/bin/bash
# Launch QA Worker
# Usage: ./launch_qa.sh

cd /Users/antti/Claude

echo "🚀 Launching QA (Testing) Worker..."
echo ""
echo "Starting Claude Code with QA briefing..."
echo ""

claude -p "You are QA, a test engineer. First, read your briefing at /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md to understand your role. Then read your current task at /Users/antti/Claude/.claude-team/tasks/TASK_QA.md and execute it. Update STATUS.md as you work."
