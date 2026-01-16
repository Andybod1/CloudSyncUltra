#!/bin/bash
#
# Check File Ownership
# Verifies if a file is within a worker's domain
#
# Usage: ./scripts/check-ownership.sh <file-path> <worker-id>
# Example: ./scripts/check-ownership.sh CloudSyncApp/Views/TasksView.swift dev-1
#

FILE="$1"
WORKER=$(echo "$2" | tr '[:upper:]' '[:lower:]')

if [ -z "$FILE" ] || [ -z "$WORKER" ]; then
    echo "Usage: $0 <file-path> <worker-id>"
    echo "Example: $0 CloudSyncApp/Views/TasksView.swift dev-1"
    echo ""
    echo "Workers: dev-1, dev-2, dev-3, qa, devops"
    exit 1
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              FILE OWNERSHIP CHECK                             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "File:   $FILE"
echo "Worker: $WORKER"
echo ""

# Determine file owner
OWNER=""

if echo "$FILE" | grep -qE "^CloudSyncApp/Views/|^CloudSyncApp/ViewModels/|^CloudSyncApp/Components/|^CloudSyncApp/Styles/"; then
    OWNER="dev-1"
elif echo "$FILE" | grep -qE "RcloneManager\.swift|TransferOptimizer\.swift"; then
    OWNER="dev-2"
elif echo "$FILE" | grep -qE "^CloudSyncApp/Models/|^CloudSyncApp/Managers/"; then
    OWNER="dev-3"
elif echo "$FILE" | grep -qE "^CloudSyncAppTests/|^CloudSyncAppUITests/"; then
    OWNER="qa"
elif echo "$FILE" | grep -qE "^\.claude-team/|^scripts/|^\.github/|^docs/"; then
    OWNER="devops"
elif echo "$FILE" | grep -qE "CloudSyncAppApp\.swift|MainWindow\.swift|ContentView\.swift|Info\.plist"; then
    OWNER="shared"
else
    OWNER="unknown"
fi

echo "Owner:  $OWNER"
echo ""

# Check authorization
if [ "$OWNER" = "shared" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  SHARED FILE - Requires Strategic Partner approval"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 2
elif [ "$OWNER" = "unknown" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❓ UNKNOWN OWNERSHIP - Check with Strategic Partner"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 2
elif [ "$OWNER" = "$WORKER" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ AUTHORIZED - $WORKER owns this file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ NOT AUTHORIZED - File belongs to $OWNER, not $WORKER"
    echo ""
    echo "   Action: Write a blocking report and alert Strategic Partner"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi
