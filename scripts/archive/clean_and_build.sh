#!/bin/bash

# CloudSync Ultra - Clean Build Script
# Use this when Xcode shows old/cached builds

echo "🧹 Cleaning CloudSync Ultra..."

# Kill running app
killall CloudSyncApp 2>/dev/null

# Clean Xcode build
cd /Users/antti/Claude
xcodebuild clean -project CloudSyncApp.xcodeproj -scheme CloudSyncApp > /dev/null 2>&1

# Delete DerivedData cache
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*

echo "✅ Clean complete!"
echo ""
echo "🔨 Building fresh version..."

# Build fresh
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' build 2>&1 | grep -E "(BUILD|error)" | tail -5

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo "🚀 Launching app..."
    
    # Find and launch the app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "CloudSyncApp.app" -type d 2>/dev/null | head -1)
    
    if [ -n "$APP_PATH" ]; then
        open "$APP_PATH"
        echo "✅ CloudSync Ultra launched with fresh build!"
    else
        echo "❌ Could not find built app"
    fi
else
    echo "❌ Build failed. Check errors above."
    exit 1
fi
