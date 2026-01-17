#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - License Compliance Checker                               ║
# ║  Verify all dependencies have compatible licenses                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/check-licenses.sh
#
# Checks:
# 1. Swift Package dependencies (Package.resolved)
# 2. Known compatible licenses (MIT, Apache 2.0, BSD)
# 3. Flags GPL and unknown licenses for review

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║     License Compliance Checker                                ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Compatible licenses (app-store safe)
COMPATIBLE="MIT|Apache-2.0|BSD-2-Clause|BSD-3-Clause|ISC|Zlib|Unlicense|CC0"

# Copyleft licenses (need review)
COPYLEFT="GPL|LGPL|AGPL|MPL"

WARNINGS=0
ERRORS=0

# ─────────────────────────────────────────────────────────────────────────────
# Check 1: Swift Package Dependencies
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}Swift Package Dependencies:${NC}"
echo ""

PACKAGE_RESOLVED="CloudSyncApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

if [[ -f "$PACKAGE_RESOLVED" ]]; then
    # Parse Package.resolved for dependencies
    DEPS=$(cat "$PACKAGE_RESOLVED" | jq -r '.pins[]?.identity // .object.pins[]?.package // empty' 2>/dev/null || true)

    if [[ -z "$DEPS" ]]; then
        echo -e "  ${GREEN}✓${NC} No Swift package dependencies"
    else
        while IFS= read -r dep; do
            [[ -z "$dep" ]] && continue

            # Check for known packages and their licenses
            case "$dep" in
                "swift-argument-parser")
                    echo -e "  ${GREEN}✓${NC} $dep (Apache-2.0)"
                    ;;
                "swift-collections"|"swift-algorithms"|"swift-numerics")
                    echo -e "  ${GREEN}✓${NC} $dep (Apache-2.0)"
                    ;;
                "swift-crypto"|"swift-nio")
                    echo -e "  ${GREEN}✓${NC} $dep (Apache-2.0)"
                    ;;
                "alamofire"|"Alamofire")
                    echo -e "  ${GREEN}✓${NC} $dep (MIT)"
                    ;;
                "kingfisher"|"Kingfisher")
                    echo -e "  ${GREEN}✓${NC} $dep (MIT)"
                    ;;
                "realm"|"Realm")
                    echo -e "  ${YELLOW}⚠${NC} $dep (Apache-2.0 with REALM license)"
                    WARNINGS=$((WARNINGS + 1))
                    ;;
                *)
                    echo -e "  ${YELLOW}?${NC} $dep (license unknown - verify manually)"
                    WARNINGS=$((WARNINGS + 1))
                    ;;
            esac
        done <<< "$DEPS"
    fi
else
    echo -e "  ${GREEN}✓${NC} No Package.resolved found (no SPM dependencies)"
fi

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Check 2: Bundled dependencies (if any)
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}Bundled Dependencies:${NC}"
echo ""

# Check for LICENSE files in project
LICENSES=$(find . -name "LICENSE*" -o -name "LICENCE*" -o -name "COPYING*" 2>/dev/null | grep -v ".git" | grep -v "DerivedData" || true)

if [[ -n "$LICENSES" ]]; then
    while IFS= read -r license_file; do
        [[ -z "$license_file" ]] && continue

        CONTENT=$(head -20 "$license_file" 2>/dev/null || true)

        if echo "$CONTENT" | grep -qiE "MIT License|Permission is hereby granted"; then
            echo -e "  ${GREEN}✓${NC} $license_file (MIT)"
        elif echo "$CONTENT" | grep -qiE "Apache License|Version 2.0"; then
            echo -e "  ${GREEN}✓${NC} $license_file (Apache-2.0)"
        elif echo "$CONTENT" | grep -qiE "BSD"; then
            echo -e "  ${GREEN}✓${NC} $license_file (BSD)"
        elif echo "$CONTENT" | grep -qiE "GPL|General Public License"; then
            echo -e "  ${RED}!${NC} $license_file (GPL - review required)"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "  ${YELLOW}?${NC} $license_file (unknown - review)"
            WARNINGS=$((WARNINGS + 1))
        fi
    done <<< "$LICENSES"
else
    echo -e "  ${GREEN}✓${NC} No bundled dependency licenses found"
fi

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Check 3: rclone (bundled binary)
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}External Tools:${NC}"
echo ""

echo -e "  ${GREEN}✓${NC} rclone (MIT License)"
echo -e "      https://github.com/rclone/rclone/blob/master/COPYING"

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}${BOLD}─────────────────────────────────────────────────────────────────${NC}"

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}${BOLD}✗ $ERRORS license issue(s) need review${NC}"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}${BOLD}⚠ $WARNINGS license(s) need verification${NC}"
else
    echo -e "${GREEN}${BOLD}✓ All licenses compatible${NC}"
fi
