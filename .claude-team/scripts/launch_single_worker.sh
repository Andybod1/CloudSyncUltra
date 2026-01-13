#!/bin/bash

# Launch a single worker with model selection
# Usage: ./launch_single_worker.sh [DEV1|DEV2|DEV3|QA|DEVOPS] [sonnet|opus]

WORKER="$1"
MODEL="${2:-opus}"  # Default to opus if not specified
TEAM_DIR="/Users/antti/Claude/.claude-team"

if [ -z "$WORKER" ]; then
    echo "Usage: $0 [DEV1|DEV2|DEV3|QA|DEVOPS] [sonnet|opus]"
    echo ""
    echo "Workers:"
    echo "  DEV1   - UI (Views, ViewModels, Components)"
    echo "  DEV2   - Engine (RcloneManager)"
    echo "  DEV3   - Services (Models, Managers)"
    echo "  QA     - Testing (ALWAYS Opus + extended thinking)"
    echo "  DEVOPS - Integration (ALWAYS Opus + extended thinking)"
    echo ""
    echo "Models:"
    echo "  sonnet - Fast, for simple tasks (XS, S) - Dev workers only"
    echo "  opus   - Deep reasoning, for complex tasks (M, L, XL)"
    echo ""
    echo "Note: QA and DEVOPS always use Opus regardless of model argument"
    exit 1
fi

# Determine worker settings first
case "$WORKER" in
    DEV1|dev1)
        BRIEFING="DEV1_BRIEFING.md"
        TASK="TASK_DEV1.md"
        NAME="Dev-1 (UI)"
        FORCE_OPUS=false
        ;;
    DEV2|dev2)
        BRIEFING="DEV2_BRIEFING.md"
        TASK="TASK_DEV2.md"
        NAME="Dev-2 (Engine)"
        FORCE_OPUS=false
        ;;
    DEV3|dev3)
        BRIEFING="DEV3_BRIEFING.md"
        TASK="TASK_DEV3.md"
        NAME="Dev-3 (Services)"
        FORCE_OPUS=false
        ;;
    QA|qa)
        BRIEFING="QA_BRIEFING.md"
        TASK="TASK_QA.md"
        NAME="QA (Testing)"
        FORCE_OPUS=true
        ;;
    DEVOPS|devops|dev-ops)
        BRIEFING="DEVOPS_BRIEFING.md"
        TASK="TASK_DEVOPS.md"
        NAME="Dev-Ops (Integration)"
        FORCE_OPUS=true
        ;;
    *)
        echo "Unknown worker: $WORKER"
        echo "Use: DEV1, DEV2, DEV3, QA, or DEVOPS"
        exit 1
        ;;
esac

# Force Opus for QA and Dev-Ops
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

CMD="Read /Users/antti/Claude/.claude-team/templates/$BRIEFING then read and execute /Users/antti/Claude/.claude-team/tasks/$TASK. Update STATUS.md as you work."

echo "Launching $NAME with $MODEL_NAME..."

# Open new Terminal window, cd, launch claude with model, and send command
osascript -e "
tell application \"Terminal\"
    activate
    do script \"cd /Users/antti/Claude && echo 'Starting $NAME ($MODEL_NAME)...' && claude $MODEL_FLAG\"
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
