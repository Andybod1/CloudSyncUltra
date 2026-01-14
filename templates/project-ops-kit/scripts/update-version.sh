#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Update Version - Update version in all documentation files                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/project.conf"

cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NEW_VERSION="$1"

if [[ -z "$NEW_VERSION" ]]; then
    echo "Usage: ./scripts/update-version.sh <version>"
    echo "Example: ./scripts/update-version.sh 1.0.1"
    exit 1
fi

# Remove 'v' prefix if provided
NEW_VERSION="${NEW_VERSION#v}"

OLD_VERSION=$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]' || echo "0.0.0")

echo ""
echo "Updating version: $OLD_VERSION → $NEW_VERSION"
echo ""

# Update VERSION.txt first
echo "$NEW_VERSION" > VERSION.txt
echo -e "  ${GREEN}✓${NC} VERSION.txt"

# Update other files
for file in "${VERSION_FILES[@]}"; do
    if [[ "$file" == "VERSION.txt" ]]; then
        continue
    fi
    
    if [[ -f "$PROJECT_ROOT/$file" ]]; then
        if grep -q "$OLD_VERSION" "$PROJECT_ROOT/$file" 2>/dev/null; then
            sed -i '' "s/$OLD_VERSION/$NEW_VERSION/g" "$PROJECT_ROOT/$file"
            echo -e "  ${GREEN}✓${NC} $file"
        else
            echo -e "  ${YELLOW}~${NC} $file (no version found, skipped)"
        fi
    fi
done

echo ""
echo -e "${GREEN}Version updated to $NEW_VERSION${NC}"
echo "Run ./scripts/version-check.sh to verify"
