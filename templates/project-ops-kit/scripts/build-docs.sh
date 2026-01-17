#!/bin/bash
#
# build-docs.sh - Build Swift-DocC documentation for CloudSync Ultra
#
# Usage:
#   ./scripts/build-docs.sh          # Build docs
#   ./scripts/build-docs.sh --open   # Build and open in browser
#   ./scripts/build-docs.sh --serve  # Build and start local server
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="CloudSyncApp"
DOCS_OUTPUT="$PROJECT_ROOT/docs/api"
DERIVED_DATA="$PROJECT_ROOT/.build/DerivedData"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           CloudSync Ultra - Documentation Builder            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
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
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

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
    OTHER_DOCC_FLAGS="--warnings-as-errors" \
    2>&1 | grep -E "(Building|Compiling|Linking|warning:|error:|Build Preparation|DocC)" || true

# Find the built documentation archive
DOCC_ARCHIVE=$(find "$DERIVED_DATA" -name "*.doccarchive" -type d | head -1)

if [ -z "$DOCC_ARCHIVE" ]; then
    echo -e "${RED}Error: Documentation archive not found${NC}"
    echo "Build may have failed. Check Xcode for details."
    exit 1
fi

echo ""
echo -e "${GREEN}Documentation archive created:${NC}"
echo "  $DOCC_ARCHIVE"

# Export to static HTML (optional, for hosting)
echo ""
echo -e "${YELLOW}Exporting to static HTML...${NC}"

# Use docc to convert to static website
xcrun docc process-archive transform-for-static-hosting \
    "$DOCC_ARCHIVE" \
    --output-path "$DOCS_OUTPUT" \
    --hosting-base-path "CloudSyncUltra" \
    2>/dev/null || {
    echo -e "${YELLOW}Static export skipped (requires Xcode 14+)${NC}"
}

# Summary
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Documentation Ready                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Documentation Archive: $DOCC_ARCHIVE"
if [ -d "$DOCS_OUTPUT/index.html" ] || [ -f "$DOCS_OUTPUT/index.html" ]; then
    echo "Static HTML:          $DOCS_OUTPUT"
fi
echo ""
echo "To view in Xcode:"
echo "  1. Open CloudSyncApp.xcodeproj"
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
