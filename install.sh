#!/bin/bash

# CloudSync Installation Script
# Automates the complete setup process

set -e

echo "☁️  CloudSync Installation"
echo "=========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion)
REQUIRED_VERSION="13.0"

echo "📋 System Check"
echo "   macOS: $MACOS_VERSION"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$MACOS_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then 
    echo -e "   ${RED}✗ macOS 13.0 or later required${NC}"
    exit 1
else
    echo -e "   ${GREEN}✓ macOS version OK${NC}"
fi

# Check for Homebrew
echo ""
echo "🍺 Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    echo -e "   ${YELLOW}⚠ Homebrew not found${NC}"
    read -p "   Install Homebrew? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "   ${RED}✗ Homebrew required for rclone installation${NC}"
        exit 1
    fi
else
    echo -e "   ${GREEN}✓ Homebrew installed${NC}"
fi

# Check for rclone
echo ""
echo "📦 Checking rclone..."
if ! command -v rclone &> /dev/null; then
    echo -e "   ${YELLOW}⚠ rclone not found${NC}"
    read -p "   Install rclone? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Installing rclone..."
        brew install rclone
        echo -e "   ${GREEN}✓ rclone installed${NC}"
    else
        echo -e "   ${YELLOW}⚠ CloudSync will work but needs rclone${NC}"
    fi
else
    echo -e "   ${GREEN}✓ rclone installed: $(rclone version | head -n1)${NC}"
fi

# Check for Xcode
echo ""
echo "🔨 Checking Xcode..."
if ! command -v xcodebuild &> /dev/null; then
    echo -e "   ${RED}✗ Xcode not installed${NC}"
    echo "   Please install Xcode from the Mac App Store"
    echo "   https://apps.apple.com/us/app/xcode/id497799835"
    exit 1
else
    XCODE_VERSION=$(xcodebuild -version | head -n1)
    echo -e "   ${GREEN}✓ $XCODE_VERSION${NC}"
fi

# Proton Drive account
echo ""
echo "🔐 Proton Drive Account"
echo "   Do you have a Proton Drive account?"
read -p "   (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "   Create a free account at: https://proton.me/drive"
    echo "   Then re-run this installer."
    exit 0
fi

# Ask about rclone config
echo ""
echo "⚙️  rclone Configuration"
read -p "   Configure rclone with Proton Drive now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "   Starting rclone config..."
    echo "   Follow the prompts to configure Proton Drive"
    echo ""
    sleep 2
    rclone config
fi

# Build the app
echo ""
echo "🔨 Building CloudSync..."
read -p "   Build the app now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "build.sh" ]; then
        ./build.sh
    else
        echo -e "   ${YELLOW}⚠ build.sh not found. Building manually...${NC}"
        xcodebuild build \
            -project CloudSyncApp.xcodeproj \
            -scheme CloudSyncApp \
            -configuration Release \
            -derivedDataPath ./build
        
        if [ $? -eq 0 ]; then
            echo -e "   ${GREEN}✓ Build successful${NC}"
            APP_PATH="./build/Build/Products/Release/CloudSyncApp.app"
            
            # Install to Applications
            echo ""
            read -p "   Install to /Applications? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp -r "$APP_PATH" /Applications/
                echo -e "   ${GREEN}✓ Installed to /Applications/CloudSyncApp.app${NC}"
            fi
        else
            echo -e "   ${RED}✗ Build failed${NC}"
        fi
    fi
fi

# Setup launch at login
echo ""
echo "🚀 Launch at Login"
read -p "   Configure CloudSync to launch at login? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/CloudSyncApp.app", hidden:false}' 2>/dev/null || echo -e "   ${YELLOW}⚠ Please add manually in System Settings${NC}"
fi

# Summary
echo ""
echo "✅ Installation Complete!"
echo ""
echo "📝 Next Steps:"
echo "   1. Launch CloudSync (look for cloud icon in menu bar)"
echo "   2. Click icon → Preferences"
echo "   3. Configure your Proton Drive account (if not done via rclone)"
echo "   4. Select your sync folder"
echo "   5. Start syncing!"
echo ""
echo "📚 Documentation:"
echo "   - README.md - General usage"
echo "   - SETUP.md - Detailed setup guide"
echo "   - DEVELOPMENT.md - For developers"
echo ""
echo "Happy syncing! ☁️"
