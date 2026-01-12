#!/bin/bash

# CloudSync Ultra - Batch Worker Launcher
# Launches all workers with pending tasks automatically

SCRIPT_DIR="/Users/antti/Claude/.claude-team/scripts"
TASKS_DIR="/Users/antti/Claude/.claude-team/tasks"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CloudSync Ultra - Batch Worker Launcher  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Track what we launch
LAUNCHED=0

# Check and launch each worker if task exists
if [ -s "$TASKS_DIR/TASK_DEV1.md" ]; then
    echo -e "${YELLOW}Launching Dev-1 (UI)...${NC}"
    "$SCRIPT_DIR/launch_single_worker.sh" DEV1
    LAUNCHED=$((LAUNCHED + 1))
    sleep 3
fi

if [ -s "$TASKS_DIR/TASK_DEV2.md" ]; then
    echo -e "${YELLOW}Launching Dev-2 (Engine)...${NC}"
    "$SCRIPT_DIR/launch_single_worker.sh" DEV2
    LAUNCHED=$((LAUNCHED + 1))
    sleep 3
fi

if [ -s "$TASKS_DIR/TASK_DEV3.md" ]; then
    echo -e "${YELLOW}Launching Dev-3 (Services)...${NC}"
    "$SCRIPT_DIR/launch_single_worker.sh" DEV3
    LAUNCHED=$((LAUNCHED + 1))
    sleep 3
fi

if [ -s "$TASKS_DIR/TASK_QA.md" ]; then
    echo -e "${YELLOW}Launching QA (Testing)...${NC}"
    "$SCRIPT_DIR/launch_single_worker.sh" QA
    LAUNCHED=$((LAUNCHED + 1))
fi

echo ""
if [ $LAUNCHED -eq 0 ]; then
    echo -e "${YELLOW}No task files found with content.${NC}"
    echo "Create tasks in $TASKS_DIR first."
else
    echo -e "${GREEN}✅ Launched $LAUNCHED worker(s)!${NC}"
    echo ""
    echo "Monitor progress:"
    echo "  cat /Users/antti/Claude/.claude-team/STATUS.md"
fi
