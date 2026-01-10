#!/bin/bash

# CloudSync Build Script
# Simple script to build the app

set -e  # Exit on error

echo "🚀 CloudSync Build Script"
echo "========================="
echo ""

# Check if we're in the right directory
if [ ! -f "CloudSyncApp.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Must run from CloudSyncApp directory"
    echo "   Current directory: $(pwd)"
    exit 1
fi

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode not installed"
    echo "   Please install Xcode from the Mac App Store"
    exit 1
fi

# Check for rclone
echo "📦 Checking dependencies..."
if command -v rclone &> /dev/null; then
    echo "   ✓ rclone installed: $(rclone version | head -n1)"
else
    echo "   ⚠️  rclone not found"
    echo "   Install with: brew install rclone"
    read -p "   Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Ask for build type
echo ""
echo "Select build type:"
echo "  1) Debug (faster build, for development)"
echo "  2) Release (optimized, for distribution)"
read -p "Choice (1 or 2): " choice

case $choice in
    1)
        CONFIGURATION="Debug"
        ;;
    2)
        CONFIGURATION="Release"
        ;;
    *)
        echo "Invalid choice. Using Debug."
        CONFIGURATION="Debug"
        ;;
esac

echo ""
echo "🔨 Building CloudSync ($CONFIGURATION)..."
echo ""

# Clean build folder
xcodebuild clean \
    -project CloudSyncApp.xcodeproj \
    -scheme CloudSyncApp \
    -configuration "$CONFIGURATION" \
    > /dev/null 2>&1 || true

# Build
xcodebuild build \
    -project CloudSyncApp.xcodeproj \
    -scheme CloudSyncApp \
    -configuration "$CONFIGURATION" \
    -derivedDataPath ./build

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    
    APP_PATH="./build/Build/Products/$CONFIGURATION/CloudSyncApp.app"
    
    if [ -d "$APP_PATH" ]; then
        echo "📍 App location:"
        echo "   $APP_PATH"
        echo ""
        
        # Show app size
        APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
        echo "📊 App size: $APP_SIZE"
        echo ""
        
        # Ask to run
        read -p "▶️  Run the app now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🚀 Launching CloudSync..."
            open "$APP_PATH"
            echo ""
            echo "👀 Look for the cloud icon in your menu bar!"
        fi
        
        # Ask to install
        echo ""
        read -p "📥 Install to /Applications? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp -r "$APP_PATH" /Applications/
            echo "✅ Installed to /Applications/CloudSyncApp.app"
        fi
    else
        echo "⚠️  App not found at expected location"
    fi
else
    echo ""
    echo "❌ Build failed with exit code $BUILD_EXIT_CODE"
    echo "   Check the output above for errors"
    exit 1
fi

echo ""
echo "Done! 🎉"
