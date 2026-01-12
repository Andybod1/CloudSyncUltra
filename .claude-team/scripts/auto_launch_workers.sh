#!/bin/bash

# CloudSync Ultra - Automated Worker Launcher
# Launches Claude Code workers with tasks automatically

TEAM_DIR="/Users/antti/Claude/.claude-team"
TASKS_DIR="$TEAM_DIR/tasks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CloudSync Ultra - Auto Worker Launcher   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check which tasks exist and have content
WORKERS=()
COMMANDS=()

if [ -s "$TASKS_DIR/TASK_DEV1.md" ]; then
    WORKERS+=("Dev-1")
    COMMANDS+=("Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.")
fi

if [ -s "$TASKS_DIR/TASK_DEV2.md" ]; then
    WORKERS+=("Dev-2")
    COMMANDS+=("Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.")
fi

if [ -s "$TASKS_DIR/TASK_DEV3.md" ]; then
    WORKERS+=("Dev-3")
    COMMANDS+=("Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.")
fi

if [ -s "$TASKS_DIR/TASK_QA.md" ]; then
    WORKERS+=("QA")
    COMMANDS+=("Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.")
fi

if [ ${#WORKERS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No task files found. Create tasks first.${NC}"
    exit 1
fi

echo -e "${GREEN}Launching ${#WORKERS[@]} workers:${NC}"
for w in "${WORKERS[@]}"; do
    echo "  • $w"
done
echo ""

# Launch each worker in a new Terminal tab with claude and auto-send command
for i in "${!WORKERS[@]}"; do
    WORKER="${WORKERS[$i]}"
    CMD="${COMMANDS[$i]}"
    
    echo -e "${YELLOW}Launching $WORKER...${NC}"
    
    osascript <<EOF
tell application "Terminal"
    activate
    
    -- Create new tab
    tell application "System Events" to keystroke "t" using command down
    delay 0.5
    
    -- Navigate and launch claude
    do script "cd /Users/antti/Claude && claude" in front window
    
    -- Wait for claude to start
    delay 3
    
    -- Send the task command
    tell application "System Events"
        keystroke "$CMD"
        delay 0.2
        keystroke return
    end tell
end tell
EOF
    
    # Wait between launches to avoid race conditions
    sleep 2
done

echo ""
echo -e "${GREEN}✅ All workers launched!${NC}"
echo ""
echo "Workers are now executing their tasks."
echo "Monitor progress: cat $TEAM_DIR/STATUS.md"
echo ""
