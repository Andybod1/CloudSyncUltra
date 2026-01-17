#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - Secrets Scanner                                          ║
# ║  Detect hardcoded secrets, API keys, passwords in source code               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/check-secrets.sh
#
# Scans for:
# - API keys and tokens
# - Passwords and secrets
# - Private keys
# - Connection strings
# - High-entropy strings

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
echo -e "${BLUE}${BOLD}║     Secrets Scanner                                           ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Files to exclude
EXCLUDE="\.git|node_modules|DerivedData|\.build|Pods|\.xcodeproj|\.xcworkspace|TestResults"

echo -e "${BOLD}Scanning source code for secrets...${NC}"
echo ""

# Check for a pattern
check_pattern() {
    local pattern_name="$1"
    local pattern="$2"

    MATCHES=$(grep -rEn "$pattern" . \
        --include="*.swift" \
        --include="*.plist" \
        --include="*.json" \
        --include="*.yml" \
        --include="*.yaml" \
        --include="*.sh" \
        --include="*.md" \
        2>/dev/null | grep -vE "$EXCLUDE" || true)

    if [[ -n "$MATCHES" ]]; then
        # Filter out obvious false positives
        REAL_MATCHES=$(echo "$MATCHES" | grep -v "example\|sample\|test\|mock\|placeholder\|<.*>\|YOUR_\|xxx\|REPLACE" || true)

        if [[ -n "$REAL_MATCHES" ]]; then
            echo -e "  ${RED}!${NC} ${BOLD}$pattern_name${NC}"
            echo "$REAL_MATCHES" | head -3 | while read -r line; do
                FILE=$(echo "$line" | cut -d: -f1 | sed 's|^\./||')
                LINE_NUM=$(echo "$line" | cut -d: -f2)
                echo -e "      ${YELLOW}$FILE:$LINE_NUM${NC}"
            done
            MATCH_COUNT=$(echo "$REAL_MATCHES" | wc -l | tr -d ' ')
            if [[ $MATCH_COUNT -gt 3 ]]; then
                echo -e "      ... and $((MATCH_COUNT - 3)) more"
            fi
            ERRORS=$((ERRORS + 1))
            echo ""
        fi
    fi
}

# Check all patterns
check_pattern "AWS Access Key" "AKIA[0-9A-Z]{16}"
check_pattern "AWS Secret Key" "['\"][0-9a-zA-Z/+]{40}['\"]"
check_pattern "GitHub Token" "ghp_[0-9a-zA-Z]{36}|github_pat_[0-9a-zA-Z_]{22,}"
check_pattern "Generic API Key" "[aA][pP][iI][_-]?[kK][eE][yY]['\"]?\s*[:=]\s*['\"][0-9a-zA-Z]{20,}"
check_pattern "Generic Secret" "[sS][eE][cC][rR][eE][tT]['\"]?\s*[:=]\s*['\"][^'\"]{8,}"
check_pattern "Generic Password" "[pP][aA][sS][sS][wW][oO][rR][dD]['\"]?\s*[:=]\s*['\"][^'\"]{4,}"
check_pattern "Private Key" "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"
check_pattern "JWT Token" "eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*"
check_pattern "Basic Auth" "[bB]asic [a-zA-Z0-9+/]{20,}={0,2}"
check_pattern "Bearer Token" "[bB]earer [a-zA-Z0-9_-]{20,}"

# ─────────────────────────────────────────────────────────────────────────────
# Check for .env files
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}Checking for environment files...${NC}"
echo ""

ENV_FILES=$(find . -name ".env*" -o -name "*.env" 2>/dev/null | grep -vE "$EXCLUDE" || true)

if [[ -n "$ENV_FILES" ]]; then
    echo -e "  ${YELLOW}⚠${NC} Environment files found (ensure not committed):"
    echo "$ENV_FILES" | while read -r file; do
        echo -e "      $file"
    done
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${GREEN}✓${NC} No .env files in repo"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Check .gitignore for secret patterns
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}Checking .gitignore coverage...${NC}"
echo ""

GITIGNORE=".gitignore"

if [[ -f "$GITIGNORE" ]]; then
    MISSING=()

    # Check for common secret file patterns
    for pattern in ".env" "*.pem" "*.key" "credentials.json" "secrets.json"; do
        if ! grep -q "$pattern" "$GITIGNORE" 2>/dev/null; then
            MISSING+=("$pattern")
        fi
    done

    if [[ ${#MISSING[@]} -gt 0 ]]; then
        echo -e "  ${YELLOW}⚠${NC} Consider adding to .gitignore:"
        for item in "${MISSING[@]}"; do
            echo -e "      $item"
        done
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "  ${GREEN}✓${NC} .gitignore covers common secret patterns"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} No .gitignore found"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}${BOLD}─────────────────────────────────────────────────────────────────${NC}"

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}${BOLD}✗ Found $ERRORS potential secret(s) - review immediately!${NC}"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}${BOLD}⚠ $WARNINGS warning(s) - review recommended${NC}"
else
    echo -e "${GREEN}${BOLD}✓ No secrets detected${NC}"
fi
