#!/bin/bash
#
# CloudSync Ultra - App Icon Generator
# Issue #77: Create App Icon Set (CRITICAL - Blocking Release)
#
# This script generates all required macOS app icon sizes from a master 1024x1024 PNG.
#
# Prerequisites:
#   - macOS with sips (built-in) or ImageMagick installed
#   - Master icon file: icon_master_1024x1024.png (1024x1024 pixels)
#
# Usage:
#   ./generate_icons.sh [master_file.png]
#   ./generate_icons.sh --from-svg [svg_file.svg]
#   ./generate_icons.sh --help
#
# If no master file is specified, defaults to icon_master_1024x1024.png
#
# Output: All required icon sizes in the current directory
#
# Author: Brand Designer Agent
# Date: January 14, 2026
# Version: 2.0.0
#
# Changelog:
#   v2.0.0 - Added SVG conversion support, improved error handling
#   v1.0.0 - Initial release

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MASTER_FILE="${1:-icon_master_1024x1024.png}"
SVG_MODE=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    echo "CloudSync Ultra - App Icon Generator"
    echo ""
    echo "Usage:"
    echo "  ./generate_icons.sh [master_file.png]      Generate icons from PNG master"
    echo "  ./generate_icons.sh --from-svg [file.svg]  Convert SVG to PNG then generate"
    echo "  ./generate_icons.sh --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./generate_icons.sh                        Use default icon_master_1024x1024.png"
    echo "  ./generate_icons.sh my_icon.png            Use custom PNG file"
    echo "  ./generate_icons.sh --from-svg icon.svg    Convert SVG to PNG first"
    echo ""
    echo "Requirements:"
    echo "  - macOS with sips (built-in) OR ImageMagick (convert/magick)"
    echo "  - For SVG: Inkscape, librsvg (rsvg-convert), or ImageMagick with SVG support"
    echo ""
    exit 0
}

# Function to convert SVG to PNG
convert_svg_to_png() {
    local SVG_FILE="$1"
    local PNG_OUTPUT="$SCRIPT_DIR/icon_master_1024x1024.png"

    echo -e "${CYAN}Converting SVG to 1024x1024 PNG...${NC}"

    if command -v inkscape &> /dev/null; then
        inkscape "$SVG_FILE" --export-type=png --export-filename="$PNG_OUTPUT" --export-width=1024 --export-height=1024
    elif command -v rsvg-convert &> /dev/null; then
        rsvg-convert -w 1024 -h 1024 "$SVG_FILE" -o "$PNG_OUTPUT"
    elif command -v magick &> /dev/null; then
        magick -background none -size 1024x1024 "$SVG_FILE" "$PNG_OUTPUT"
    elif command -v convert &> /dev/null; then
        convert -background none -size 1024x1024 "$SVG_FILE" "$PNG_OUTPUT"
    else
        echo -e "${RED}Error: No SVG converter found (inkscape, rsvg-convert, or ImageMagick)${NC}"
        echo "Please install one of:"
        echo "  - brew install inkscape"
        echo "  - brew install librsvg"
        echo "  - brew install imagemagick"
        exit 1
    fi

    if [ -f "$PNG_OUTPUT" ]; then
        echo -e "${GREEN}SVG converted successfully to: $PNG_OUTPUT${NC}"
        MASTER_FILE="icon_master_1024x1024.png"
    else
        echo -e "${RED}SVG conversion failed${NC}"
        exit 1
    fi
}

# Parse arguments
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_help
fi

if [ "$1" == "--from-svg" ]; then
    SVG_MODE=true
    SVG_FILE="${2:-icon_master_template.svg}"
    if [ ! -f "$SCRIPT_DIR/$SVG_FILE" ]; then
        echo -e "${RED}Error: SVG file '$SVG_FILE' not found${NC}"
        exit 1
    fi
    convert_svg_to_png "$SCRIPT_DIR/$SVG_FILE"
fi

# Print banner
echo -e "${BLUE}"
echo "=================================================="
echo "  CloudSync Ultra - App Icon Generator v2.0"
echo "  Issue #77: Create App Icon Set"
echo "=================================================="
echo -e "${NC}"

# Check if master file exists
if [ ! -f "$SCRIPT_DIR/$MASTER_FILE" ]; then
    echo -e "${RED}Error: Master icon file '$MASTER_FILE' not found in $SCRIPT_DIR${NC}"
    echo ""
    echo "Please provide a 1024x1024 PNG master icon file."
    echo "You can:"
    echo "  1. Create the icon in Figma/Sketch/Affinity Designer"
    echo "  2. Export as 1024x1024 PNG"
    echo "  3. Save as '$MASTER_FILE' in this directory"
    echo "  4. Run this script again"
    echo ""
    echo "See the design specification in APP_ICON_COMPLETE.md for details."
    exit 1
fi

# Verify master file dimensions
echo -e "${YELLOW}Checking master file dimensions...${NC}"

# Use sips on macOS, fallback to ImageMagick identify
if command -v sips &> /dev/null; then
    DIMENSIONS=$(sips -g pixelWidth -g pixelHeight "$SCRIPT_DIR/$MASTER_FILE" 2>/dev/null | grep -E 'pixel(Width|Height)' | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    WIDTH=$(echo $DIMENSIONS | cut -d'x' -f1)
    HEIGHT=$(echo $DIMENSIONS | cut -d'x' -f2)
elif command -v identify &> /dev/null; then
    DIMENSIONS=$(identify -format "%wx%h" "$SCRIPT_DIR/$MASTER_FILE")
    WIDTH=$(echo $DIMENSIONS | cut -d'x' -f1)
    HEIGHT=$(echo $DIMENSIONS | cut -d'x' -f2)
else
    echo -e "${YELLOW}Warning: Cannot verify dimensions (sips/ImageMagick not found)${NC}"
    echo "Proceeding with icon generation..."
    WIDTH=1024
    HEIGHT=1024
fi

if [ "$WIDTH" != "1024" ] || [ "$HEIGHT" != "1024" ]; then
    echo -e "${YELLOW}Warning: Master file is ${WIDTH}x${HEIGHT}, recommended size is 1024x1024${NC}"
    echo "Icon quality may be affected. Continue? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

echo -e "${GREEN}Master file verified: ${WIDTH}x${HEIGHT}${NC}"
echo ""

# Define icon sizes
# Format: "filename:pixel_size"
# Note: @2x means the file contains 2x pixels for the given logical size
declare -a ICON_SIZES=(
    "icon_16x16.png:16"
    "icon_16x16@2x.png:32"
    "icon_32x32.png:32"
    "icon_32x32@2x.png:64"
    "icon_128x128.png:128"
    "icon_128x128@2x.png:256"
    "icon_256x256.png:256"
    "icon_256x256@2x.png:512"
    "icon_512x512.png:512"
    "icon_512x512@2x.png:1024"
)

echo -e "${BLUE}Generating icon sizes...${NC}"
echo ""

# Generate icons
for SIZE_INFO in "${ICON_SIZES[@]}"; do
    FILENAME="${SIZE_INFO%%:*}"
    PIXELS="${SIZE_INFO##*:}"

    OUTPUT_PATH="$SCRIPT_DIR/$FILENAME"

    echo -n "  Creating $FILENAME (${PIXELS}x${PIXELS} px)... "

    if command -v sips &> /dev/null; then
        # Use macOS sips (built-in, fast, high quality)
        sips -z "$PIXELS" "$PIXELS" "$SCRIPT_DIR/$MASTER_FILE" --out "$OUTPUT_PATH" > /dev/null 2>&1
    elif command -v convert &> /dev/null; then
        # Use ImageMagick convert
        convert "$SCRIPT_DIR/$MASTER_FILE" -resize "${PIXELS}x${PIXELS}" -quality 100 "$OUTPUT_PATH"
    elif command -v magick &> /dev/null; then
        # Use ImageMagick 7 syntax
        magick "$SCRIPT_DIR/$MASTER_FILE" -resize "${PIXELS}x${PIXELS}" -quality 100 "$OUTPUT_PATH"
    else
        echo -e "${RED}FAILED${NC}"
        echo "Error: No image processing tool found (sips, convert, or magick)"
        exit 1
    fi

    if [ -f "$OUTPUT_PATH" ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAILED${NC}"
        exit 1
    fi
done

echo ""
echo -e "${GREEN}=================================================="
echo "  Icon generation complete!"
echo "==================================================${NC}"
echo ""
echo "Generated files:"
ls -la "$SCRIPT_DIR"/icon_*.png 2>/dev/null | awk '{print "  " $9 " (" $5 " bytes)"}'
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Build the app in Xcode"
echo "  2. Check icon appears correctly in:"
echo "     - Dock (various sizes)"
echo "     - Finder (list, icon, column views)"
echo "     - Spotlight search results"
echo "     - About dialog"
echo "  3. Test on both light and dark mode backgrounds"
echo ""
echo -e "${GREEN}Done!${NC}"
