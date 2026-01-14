#!/bin/bash

# CloudSync Ultra - App Launcher
# Launches your app so you can see it and use it

echo "🚀 Launching CloudSync Ultra..."
echo ""

APP_PATH="/Users/antti/Library/Developer/Xcode/DerivedData/CloudSyncApp-eqfknxkkaumskxbmezirpyltjfkf/Build/Products/Debug/CloudSyncApp.app"

if [ -d "$APP_PATH" ]; then
    open "$APP_PATH"
    echo "✅ CloudSync Ultra launched successfully!"
    echo ""
    echo "Your app is now running. You can:"
    echo "  • Browse files"
    echo "  • Connect cloud providers"
    echo "  • Transfer files"
    echo "  • Create sync tasks"
    echo ""
    echo "Press Ctrl+C to stop this script (app will keep running)"
    
    # Keep script running so you can see the message
    while true; do
        sleep 1
    done
else
    echo "❌ App not found. Building..."
    cd /Users/antti/Claude
    xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' build
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful! Running launcher again..."
        exec "$0"
    else
        echo "❌ Build failed. Check errors above."
        exit 1
    fi
fi
