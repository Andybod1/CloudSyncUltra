#!/bin/bash

# Project Ops Kit - Single Worker Launcher
# Usage: ./launch_single_worker.sh [WORKER] [sonnet|opus]

WORKER="$1"
MODEL="${2:-opus}"  # Default to opus if not specified

# Auto-detect project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEAM_DIR="$REPO_DIR/.claude-team"

if [ -z "$WORKER" ]; then
    echo "Usage: $0 [WORKER] [sonnet|opus]"
    echo ""
    echo "=== CORE TEAM ==="
    echo "  dev-1        UI (Views, ViewModels, Components)"
    echo "  dev-2        Engine (Core Business Logic)"
    echo "  dev-3        Services (Models, Managers)"
    echo "  qa           Testing (ALWAYS Opus)"
    echo "  devops       Git, GitHub, Docs (ALWAYS Opus)"
    echo ""
    echo "=== SPECIALIZED AGENTS ==="
    echo "  ux-designer        UX/UI Analysis (ALWAYS Opus)"
    echo "  product-manager    Strategy & Requirements (ALWAYS Opus)"
    echo "  architect          System Design (ALWAYS Opus)"
    echo "  security-auditor   Security Review (ALWAYS Opus)"
    echo "  performance-eng    Performance Analysis (ALWAYS Opus)"
    echo "  tech-writer        Documentation (ALWAYS Opus)"
    echo "  brand-designer     Visual Identity (ALWAYS Opus)"
    echo "  qa-automation      Test Automation (ALWAYS Opus)"
    echo "  marketing          Growth Strategy (ALWAYS Opus)"
    echo ""
    echo "Models:"
    echo "  sonnet - Fast, for simple tasks (XS/S)"
    echo "  opus   - Deep reasoning, for complex tasks (M/L/XL)"
    echo ""
    echo "Project: $REPO_DIR"
    exit 1
fi

# Normalize worker name (lowercase, handle variations)
WORKER_LOWER=$(echo "$WORKER" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

# Determine worker settings
case "$WORKER_LOWER" in
    dev1|dev-1)
        BRIEFING="DEV1_BRIEFING.md"
        TASK="TASK_DEV1.md"
        NAME="Dev-1 (UI)"
        FORCE_OPUS=false
        ;;
    dev2|dev-2)
        BRIEFING="DEV2_BRIEFING.md"
        TASK="TASK_DEV2.md"
        NAME="Dev-2 (Engine)"
        FORCE_OPUS=false
        ;;
    dev3|dev-3)
        BRIEFING="DEV3_BRIEFING.md"
        TASK="TASK_DEV3.md"
        NAME="Dev-3 (Services)"
        FORCE_OPUS=false
        ;;
    qa)
        BRIEFING="QA_BRIEFING.md"
        TASK="TASK_QA.md"
        NAME="QA (Testing)"
        FORCE_OPUS=true
        ;;
    devops|dev-ops)
        BRIEFING="DEVOPS_BRIEFING.md"
        TASK="TASK_DEVOPS.md"
        NAME="Dev-Ops (Integration)"
        FORCE_OPUS=true
        ;;
    ux-designer|ux|uxdesigner)
        BRIEFING="UX_DESIGNER_BRIEFING.md"
        TASK="TASK_UX_DESIGNER.md"
        NAME="UX-Designer"
        FORCE_OPUS=true
        ;;
    product-manager|pm|productmanager)
        BRIEFING="PRODUCT_MANAGER_BRIEFING.md"
        TASK="TASK_PRODUCT_MANAGER.md"
        NAME="Product-Manager"
        FORCE_OPUS=true
        ;;
    architect|arch)
        BRIEFING="ARCHITECT_BRIEFING.md"
        TASK="TASK_ARCHITECT.md"
        NAME="Architect"
        FORCE_OPUS=true
        ;;
    security-auditor|security|securityauditor)
        BRIEFING="SECURITY_AUDITOR_BRIEFING.md"
        TASK="TASK_SECURITY_AUDITOR.md"
        NAME="Security-Auditor"
        FORCE_OPUS=true
        ;;
    performance-eng|perf|performanceeng)
        BRIEFING="PERFORMANCE_ENGINEER_BRIEFING.md"
        TASK="TASK_PERFORMANCE_ENGINEER.md"
        NAME="Performance-Engineer"
        FORCE_OPUS=true
        ;;
    tech-writer|writer|techwriter)
        BRIEFING="TECH_WRITER_BRIEFING.md"
        TASK="TASK_TECH_WRITER.md"
        NAME="Tech-Writer"
        FORCE_OPUS=true
        ;;
    brand-designer|brand|branddesigner)
        BRIEFING="BRAND_DESIGNER_BRIEFING.md"
        TASK="TASK_BRAND_DESIGNER.md"
        NAME="Brand-Designer"
        FORCE_OPUS=true
        ;;
    qa-automation|qa-auto|qaautomation)
        BRIEFING="QA_AUTOMATION_BRIEFING.md"
        TASK="TASK_QA_AUTOMATION.md"
        NAME="QA-Automation"
        FORCE_OPUS=true
        ;;
    marketing-strategist|marketing|marketingstrategist)
        BRIEFING="MARKETING_STRATEGIST_BRIEFING.md"
        TASK="TASK_MARKETING_STRATEGIST.md"
        NAME="Marketing-Strategist"
        FORCE_OPUS=true
        ;;
    *)
        echo "Unknown worker: $WORKER"
        echo "Run without arguments to see available workers"
        exit 1
        ;;
esac

# Force Opus for specialized agents
if [ "$FORCE_OPUS" = true ]; then
    if [ "$MODEL" != "opus" ] && [ "$MODEL" != "OPUS" ]; then
        echo "⚠️  $NAME always uses Opus (overriding '$MODEL')"
    fi
    MODEL="opus"
fi

# Set model flags
case "$MODEL" in
    sonnet|SONNET)
        MODEL_FLAG="--model claude-sonnet-4-20250514"
        MODEL_NAME="Sonnet"
        ;;
    opus|OPUS)
        MODEL_FLAG="--model claude-opus-4-20250514"
        MODEL_NAME="Opus"
        ;;
    *)
        echo "Unknown model: $MODEL"
        echo "Use: sonnet or opus"
        exit 1
        ;;
esac

# Check if briefing exists
if [ ! -f "$TEAM_DIR/templates/$BRIEFING" ]; then
    echo "❌ Briefing not found: $TEAM_DIR/templates/$BRIEFING"
    exit 1
fi

CMD="Read $TEAM_DIR/templates/$BRIEFING then read and execute $TEAM_DIR/tasks/$TASK. Update STATUS.md as you work."

echo "Launching $NAME with $MODEL_NAME..."
echo "Project: $REPO_DIR"

# Open new Terminal window, cd, launch claude with model, and send command
osascript -e "
tell application \"Terminal\"
    activate
    do script \"cd $REPO_DIR && echo 'Starting $NAME ($MODEL_NAME)...' && claude $MODEL_FLAG\"
end tell
" 

# Wait for claude to initialize
sleep 4

# Send the command to the frontmost Terminal
osascript -e "
tell application \"Terminal\"
    activate
end tell
tell application \"System Events\"
    keystroke \"$CMD\"
    delay 0.3
    keystroke return
end tell
"

echo "✅ $NAME launched with $MODEL_NAME and task sent!"
