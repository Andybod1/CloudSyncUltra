#!/bin/bash

# CloudSync Ultra - Batch Worker Launcher with Model Selection
# Reads model assignments from WORKER_MODELS.conf

SCRIPT_DIR="/Users/antti/Claude/.claude-team/scripts"
TASKS_DIR="/Users/antti/Claude/.claude-team/tasks"
TEAM_DIR="/Users/antti/Claude/.claude-team"
CONFIG_FILE="$TEAM_DIR/WORKER_MODELS.conf"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CloudSync Ultra - Batch Worker Launcher  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Default models - ALL USE OPUS
DEV1_MODEL="opus"
DEV2_MODEL="opus"
DEV3_MODEL="opus"
QA_MODEL="opus"

# Read config file if exists
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${CYAN}Reading model assignments from WORKER_MODELS.conf${NC}"
    source "$CONFIG_FILE"
    echo ""
fi

# Track what we launch
LAUNCHED=0

# Check and launch each worker if task exists
if [ -s "$TASKS_DIR/TASK_DEV1.md" ]; then
    echo -e "${YELLOW}Launching Dev-1 (UI) with ${DEV1_MODEL}...${NC}"
    "$SCRIPT_DIR/launch_single_worker.sh" DEV1 "$DEV1_MODEL"
    LAUNCHED=$((LAUNCHED + 1))
    sleep 3
fi

if [ -s "$TASKS_DIR/TASK_DEV2.md" ]; then
    echo -e "${YELLOW}Launching Dev-2 (Engine) with ${DEV2_MODEL}...${NC}"
    "$SCRIPT_DIR/launch_single_worker.sh" DEV2 "$DEV2_MODEL"
    LAUNCHED=$((LAUNCHED + 1))
    sleep 3
fi

if [ -s "$TASKS_DIR/TASK_DEV3.md" ]; then
    echo -e "${YELLOW}Launching Dev-3 (Services) with ${DEV3_MODEL}...${NC}"
    "$SCRIPT_DIR/launch_single_worker.sh" DEV3 "$DEV3_MODEL"
    LAUNCHED=$((LAUNCHED + 1))
    sleep 3
fi

if [ -s "$TASKS_DIR/TASK_QA.md" ]; then
    echo -e "${YELLOW}Launching QA (Testing) with ${QA_MODEL}...${NC}"
    "$SCRIPT_DIR/launch_single_worker.sh" QA "$QA_MODEL"
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
