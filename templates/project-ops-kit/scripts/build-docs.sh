#!/bin/bash
#
# build-docs.sh - Build Swift-DocC documentation
#
# Usage:
#   ./scripts/build-docs.sh          # Build docs
#   ./scripts/build-docs.sh --open   # Build and open in Xcode
#   ./scripts/build-docs.sh --serve  # Build and start local server
#
# Prerequisites:
#   - Xcode 14.0+ installed
#   - A .docc documentation catalog in your project
#
# Setup:
#   1. Create YourApp/YourApp.docc/ folder
#   2. Add YourApp.md landing page (see template below)
#   3. Run this script
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Auto-detect project name from .xcodeproj
PROJECT_FILE=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*.xcodeproj" | head -1)
if [ -z "$PROJECT_FILE" ]; then
    echo "Error: No .xcodeproj found in project root"
    exit 1
fi
PROJECT_NAME=$(basename "$PROJECT_FILE" .xcodeproj)

DOCS_OUTPUT="$PROJECT_ROOT/docs/api"
DERIVED_DATA="$PROJECT_ROOT/.build/DerivedData"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              Documentation Builder (Swift-DocC)              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Project: $PROJECT_NAME"
echo ""

# Parse arguments
OPEN_DOCS=false
SERVE_DOCS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --open)
            OPEN_DOCS=true
            shift
            ;;
        --serve)
            SERVE_DOCS=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--open] [--serve]"
            echo ""
            echo "Options:"
            echo "  --open   Open documentation in Xcode after build"
            echo "  --serve  Start local web server for documentation"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check for .docc catalog
DOCC_CATALOG=$(find "$PROJECT_ROOT" -name "*.docc" -type d | head -1)
if [ -z "$DOCC_CATALOG" ]; then
    echo -e "${YELLOW}No .docc catalog found. Creating template...${NC}"
    echo ""

    # Create .docc catalog
    mkdir -p "$PROJECT_ROOT/$PROJECT_NAME/$PROJECT_NAME.docc/Resources"

    # Create landing page
    cat > "$PROJECT_ROOT/$PROJECT_NAME/$PROJECT_NAME.docc/$PROJECT_NAME.md" << 'LANDING_EOF'
# ``PROJECT_NAME``

Brief description of your project.

## Overview

Detailed overview of what your project does and its main features.

## Topics

### Essentials

- <doc:GettingStarted>

### Core Types

- ``YourMainType``
- ``AnotherType``

LANDING_EOF

    # Replace PROJECT_NAME placeholder
    sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_ROOT/$PROJECT_NAME/$PROJECT_NAME.docc/$PROJECT_NAME.md"

    # Create GettingStarted article
    cat > "$PROJECT_ROOT/$PROJECT_NAME/$PROJECT_NAME.docc/GettingStarted.md" << 'ARTICLE_EOF'
# Getting Started

Learn how to set up and use the project.

## Overview

Step-by-step guide for getting started.

### Installation

1. Clone the repository
2. Open in Xcode
3. Build and run

### Basic Usage

Describe basic usage here.

ARTICLE_EOF

    echo -e "${GREEN}Created documentation catalog at:${NC}"
    echo "  $PROJECT_ROOT/$PROJECT_NAME/$PROJECT_NAME.docc/"
    echo ""
    echo "Edit the landing page and articles, then run this script again."
    exit 0
fi

# Clean previous build
echo -e "${YELLOW}Cleaning previous documentation build...${NC}"
rm -rf "$DERIVED_DATA"
mkdir -p "$DERIVED_DATA"
mkdir -p "$DOCS_OUTPUT"

# Build documentation
echo -e "${YELLOW}Building documentation with DocC...${NC}"
echo ""

cd "$PROJECT_ROOT"

xcodebuild docbuild \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -destination 'platform=macOS' \
    -derivedDataPath "$DERIVED_DATA" \
    2>&1 | grep -E "(Building|Compiling|error:|warning:.*docc|BUILD)" || true

# Find the built documentation archive
DOCC_ARCHIVE=$(find "$DERIVED_DATA" -name "*.doccarchive" -type d | head -1)

if [ -z "$DOCC_ARCHIVE" ]; then
    echo -e "${RED}Error: Documentation archive not found${NC}"
    echo "Build may have failed. Run with full output to debug:"
    echo "  xcodebuild docbuild -project $PROJECT_NAME.xcodeproj -scheme $PROJECT_NAME"
    exit 1
fi

echo ""
echo -e "${GREEN}Documentation archive created:${NC}"
echo "  $DOCC_ARCHIVE"

# Export to static HTML (optional)
echo ""
echo -e "${YELLOW}Exporting to static HTML...${NC}"

xcrun docc process-archive transform-for-static-hosting \
    "$DOCC_ARCHIVE" \
    --output-path "$DOCS_OUTPUT" \
    --hosting-base-path "$PROJECT_NAME" \
    2>/dev/null && {
    echo -e "${GREEN}Static HTML exported to: $DOCS_OUTPUT${NC}"
} || {
    echo -e "${YELLOW}Static export skipped (requires Xcode 14+)${NC}"
}

# Summary
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Documentation Ready                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Documentation Archive: $DOCC_ARCHIVE"
echo ""
echo "To view in Xcode:"
echo "  1. Open $PROJECT_NAME.xcodeproj"
echo "  2. Product → Build Documentation (⌃⇧⌘D)"
echo "  3. Window → Developer Documentation"
echo ""

# Open documentation if requested
if [ "$OPEN_DOCS" = true ]; then
    echo -e "${GREEN}Opening documentation...${NC}"
    open "$DOCC_ARCHIVE"
fi

# Start local server if requested
if [ "$SERVE_DOCS" = true ]; then
    if [ -d "$DOCS_OUTPUT" ] && [ -f "$DOCS_OUTPUT/index.html" ]; then
        echo -e "${GREEN}Starting local server at http://localhost:8000${NC}"
        cd "$DOCS_OUTPUT"
        python3 -m http.server 8000
    else
        echo -e "${YELLOW}Opening archive in Xcode instead...${NC}"
        open "$DOCC_ARCHIVE"
    fi
fi

echo -e "${GREEN}Done!${NC}"
