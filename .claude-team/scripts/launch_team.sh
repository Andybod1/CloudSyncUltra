#!/bin/bash
# Launch Full Team - Opens 4 terminal windows with all workers
# Usage: ./launch_team.sh

echo "🚀 Launching CloudSync Ultra Development Team..."
echo ""

# Open Dev-1 in new terminal window
osascript -e 'tell application "Terminal"
    do script "cd /Users/antti/Claude && echo \"🔵 Dev-1 (UI Layer) Terminal\" && claude"
end tell'

sleep 1

# Open Dev-2 in new terminal window
osascript -e 'tell application "Terminal"
    do script "cd /Users/antti/Claude && echo \"🟢 Dev-2 (Core Engine) Terminal\" && claude"
end tell'

sleep 1

# Open Dev-3 in new terminal window
osascript -e 'tell application "Terminal"
    do script "cd /Users/antti/Claude && echo \"🟣 Dev-3 (Services) Terminal\" && claude"
end tell'

sleep 1

# Open QA in new terminal window
osascript -e 'tell application "Terminal"
    do script "cd /Users/antti/Claude && echo \"🟡 QA (Testing) Terminal\" && claude"
end tell'

echo ""
echo "✅ Team launched in 4 separate Terminal windows"
echo ""
echo "📋 Paste startup commands in each terminal (see QUICKSTART.md)"
