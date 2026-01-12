#!/bin/bash

# Launch a single worker - more reliable approach
# Usage: ./launch_single_worker.sh [DEV1|DEV2|DEV3|QA]

WORKER="$1"
TEAM_DIR="/Users/antti/Claude/.claude-team"

if [ -z "$WORKER" ]; then
    echo "Usage: $0 [DEV1|DEV2|DEV3|QA]"
    exit 1
fi

case "$WORKER" in
    DEV1|dev1)
        BRIEFING="DEV1_BRIEFING.md"
        TASK="TASK_DEV1.md"
        NAME="Dev-1 (UI)"
        ;;
    DEV2|dev2)
        BRIEFING="DEV2_BRIEFING.md"
        TASK="TASK_DEV2.md"
        NAME="Dev-2 (Engine)"
        ;;
    DEV3|dev3)
        BRIEFING="DEV3_BRIEFING.md"
        TASK="TASK_DEV3.md"
        NAME="Dev-3 (Services)"
        ;;
    QA|qa)
        BRIEFING="QA_BRIEFING.md"
        TASK="TASK_QA.md"
        NAME="QA (Testing)"
        ;;
    *)
        echo "Unknown worker: $WORKER"
        echo "Use: DEV1, DEV2, DEV3, or QA"
        exit 1
        ;;
esac

CMD="Read /Users/antti/Claude/.claude-team/templates/$BRIEFING then read and execute /Users/antti/Claude/.claude-team/tasks/$TASK. Update STATUS.md as you work."

echo "Launching $NAME..."

# Open new Terminal window, cd, launch claude, and send command
osascript -e "
tell application \"Terminal\"
    activate
    do script \"cd /Users/antti/Claude && echo 'Starting $NAME...' && claude\"
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

echo "✅ $NAME launched and task sent!"
