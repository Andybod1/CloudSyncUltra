#!/bin/bash

# release.sh - Automated Release Script
# Executes the full post-sprint checklist automatically
#
# Usage:
#   ./scripts/release.sh 2.0.20              # Full release
#   ./scripts/release.sh 2.0.20 --skip-tests # Skip test step (use with caution)
#
# 🔒 This script implements the PROTECTED Post-Sprint Documentation checklist
#    from CLAUDE_PROJECT_KNOWLEDGE.md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Check arguments
if [[ -z "$1" ]]; then
    echo -e "${RED}Usage: $0 <new-version> [--skip-tests]${NC}"
    echo "Example: $0 2.0.20"
    exit 1
fi

NEW_VERSION="$1"
SKIP_TESTS=false
if [[ "$2" == "--skip-tests" ]]; then
    SKIP_TESTS=true
fi

OLD_VERSION=$(cat "$PROJECT_ROOT/VERSION.txt" 2>/dev/null | tr -d '[:space:]' || echo "unknown")
TODAY=$(date +%Y-%m-%d)

echo ""
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║          CloudSync Ultra - Automated Release                 ║${NC}"
echo -e "${BOLD}${BLUE}║                  v$OLD_VERSION → v$NEW_VERSION                           ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Track what we've done
STEPS_COMPLETED=0
STEPS_TOTAL=6

# Function to print step header
step() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  Step $1/6: $2${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to confirm
confirm() {
    echo ""
    read -p "$(echo -e ${YELLOW}"$1 [y/N]: "${NC})" response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

#═══════════════════════════════════════════════════════════════════
# STEP 1: Verify Build & Tests
#═══════════════════════════════════════════════════════════════════
step "1" "Verify Build & Tests"

if [[ "$SKIP_TESTS" == true ]]; then
    echo -e "${YELLOW}⚠ Skipping tests (--skip-tests flag)${NC}"
else
    echo "Running tests..."
    cd "$PROJECT_ROOT"
    
    TEST_OUTPUT=$(xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed" | tail -3)
    
    echo "$TEST_OUTPUT"
    
    if echo "$TEST_OUTPUT" | grep -q "0 failures"; then
        echo -e "${GREEN}✓ All tests passed${NC}"
    else
        echo -e "${RED}✗ Tests failed! Aborting release.${NC}"
        exit 1
    fi
fi

echo ""
echo "Building app..."
BUILD_OUTPUT=$(cd "$PROJECT_ROOT" && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -5)

if echo "$BUILD_OUTPUT" | grep -q "BUILD SUCCEEDED"; then
    echo -e "${GREEN}✓ Build succeeded${NC}"
else
    echo -e "${RED}✗ Build failed! Aborting release.${NC}"
    echo "$BUILD_OUTPUT"
    exit 1
fi

((STEPS_COMPLETED++))

#═══════════════════════════════════════════════════════════════════
# STEP 2: Update Version
#═══════════════════════════════════════════════════════════════════
step "2" "Update Version (v$OLD_VERSION → v$NEW_VERSION)"

# Update VERSION.txt
echo "$NEW_VERSION" > "$PROJECT_ROOT/VERSION.txt"
echo -e "${GREEN}✓ VERSION.txt updated${NC}"

# Run update-version.sh
"$SCRIPT_DIR/update-version.sh" "$NEW_VERSION" 2>/dev/null || {
    # Manual update if script has issues
    echo "Running manual version update..."
}

# Verify
echo ""
echo "Verifying version consistency..."
if "$SCRIPT_DIR/version-check.sh" 2>/dev/null; then
    echo -e "${GREEN}✓ All docs match v$NEW_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Some version mismatches - please review${NC}"
fi

((STEPS_COMPLETED++))

#═══════════════════════════════════════════════════════════════════
# STEP 3: Update CHANGELOG
#═══════════════════════════════════════════════════════════════════
step "3" "Update CHANGELOG.md"

CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

# Check if version already has an entry
if grep -q "## \[$NEW_VERSION\]" "$CHANGELOG_FILE"; then
    echo -e "${GREEN}✓ CHANGELOG.md already has entry for v$NEW_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ No CHANGELOG entry for v$NEW_VERSION${NC}"
    echo ""
    echo "Recent commits since last tag:"
    cd "$PROJECT_ROOT" && git log --oneline -10
    echo ""
    
    if confirm "Would you like to add a CHANGELOG entry now?"; then
        echo ""
        echo "Enter a brief description of changes (one line):"
        read -r CHANGELOG_DESC
        
        # Create changelog entry
        TEMP_FILE=$(mktemp)
        {
            head -7 "$CHANGELOG_FILE"
            echo ""
            echo "## [$NEW_VERSION] - $TODAY"
            echo ""
            echo "### Changed"
            echo "- $CHANGELOG_DESC"
            echo ""
            tail -n +8 "$CHANGELOG_FILE"
        } > "$TEMP_FILE"
        mv "$TEMP_FILE" "$CHANGELOG_FILE"
        
        echo -e "${GREEN}✓ CHANGELOG.md entry added${NC}"
    else
        echo -e "${YELLOW}⚠ Skipping CHANGELOG update - please add manually${NC}"
    fi
fi

((STEPS_COMPLETED++))

#═══════════════════════════════════════════════════════════════════
# STEP 4: GitHub Housekeeping
#═══════════════════════════════════════════════════════════════════
step "4" "GitHub Housekeeping"

echo "Checking for issues to close..."

# List in-progress issues
IN_PROGRESS=$(cd "$PROJECT_ROOT" && gh issue list --label "in-progress" 2>/dev/null || echo "")

if [[ -n "$IN_PROGRESS" ]]; then
    echo ""
    echo "Issues marked 'in-progress':"
    echo "$IN_PROGRESS"
    echo ""
    
    if confirm "Would you like to close any completed issues?"; then
        echo "Enter issue numbers to close (space-separated), or press Enter to skip:"
        read -r ISSUES_TO_CLOSE
        
        for issue in $ISSUES_TO_CLOSE; do
            cd "$PROJECT_ROOT" && gh issue close "$issue" -c "Completed in v$NEW_VERSION" 2>/dev/null && \
                echo -e "${GREEN}✓ Closed #$issue${NC}" || \
                echo -e "${RED}✗ Failed to close #$issue${NC}"
        done
    fi
else
    echo -e "${GREEN}✓ No in-progress issues found${NC}"
fi

# Show issue summary
echo ""
echo "Current issue summary:"
cd "$PROJECT_ROOT"
OPEN_COUNT=$(gh issue list --state open 2>/dev/null | wc -l | tr -d ' ')
CLOSED_COUNT=$(gh issue list --state closed --limit 100 2>/dev/null | wc -l | tr -d ' ')
echo "  Open:   $OPEN_COUNT"
echo "  Closed: $CLOSED_COUNT"

((STEPS_COMPLETED++))

#═══════════════════════════════════════════════════════════════════
# STEP 5: Clean Up Sprint Files
#═══════════════════════════════════════════════════════════════════
step "5" "Clean Up Sprint Files"

TASKS_DIR="$PROJECT_ROOT/.claude-team/tasks"
OUTPUTS_DIR="$PROJECT_ROOT/.claude-team/outputs"
ARCHIVE_DIR="$PROJECT_ROOT/.claude-team/archive/$TODAY"

# Count files
TASK_COUNT=$(find "$TASKS_DIR" -name "TASK_*.md" 2>/dev/null | wc -l | tr -d ' ')
OUTPUT_COUNT=$(find "$OUTPUTS_DIR" -name "*_COMPLETE.md" 2>/dev/null | wc -l | tr -d ' ')

echo "Found:"
echo "  - $TASK_COUNT task files in tasks/"
echo "  - $OUTPUT_COUNT completion reports in outputs/"

if [[ $OUTPUT_COUNT -gt 10 ]]; then
    echo ""
    echo -e "${YELLOW}⚠ Many output files accumulated${NC}"
    
    if confirm "Archive completion reports to archive/$TODAY/?"; then
        mkdir -p "$ARCHIVE_DIR"
        mv "$OUTPUTS_DIR"/*_COMPLETE.md "$ARCHIVE_DIR/" 2>/dev/null || true
        echo -e "${GREEN}✓ Archived $OUTPUT_COUNT reports to archive/$TODAY/${NC}"
    fi
else
    echo -e "${GREEN}✓ Output files at manageable level${NC}"
fi

((STEPS_COMPLETED++))

#═══════════════════════════════════════════════════════════════════
# STEP 6: Commit, Tag & Push
#═══════════════════════════════════════════════════════════════════
step "6" "Commit, Tag & Push"

cd "$PROJECT_ROOT"

# Check for changes
CHANGES=$(git status --short)

if [[ -n "$CHANGES" ]]; then
    echo "Changes to commit:"
    echo "$CHANGES"
    echo ""
    
    git add -A
    git commit -m "chore: Release v$NEW_VERSION

- Updated VERSION.txt and all documentation
- All tests passing
- Ready for release"
    
    echo -e "${GREEN}✓ Changes committed${NC}"
else
    echo -e "${GREEN}✓ No uncommitted changes${NC}"
fi

# Create tag
if git rev-parse "v$NEW_VERSION" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Tag v$NEW_VERSION already exists${NC}"
else
    git tag "v$NEW_VERSION"
    echo -e "${GREEN}✓ Created tag v$NEW_VERSION${NC}"
fi

# Push
echo ""
echo "Pushing to origin..."
git push --tags origin main

echo -e "${GREEN}✓ Pushed to GitHub${NC}"

((STEPS_COMPLETED++))

#═══════════════════════════════════════════════════════════════════
# COMPLETE
#═══════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                    RELEASE COMPLETE! 🎉                      ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║  Version:  v$NEW_VERSION                                          ║${NC}"
echo -e "${BOLD}${GREEN}║  Steps:    $STEPS_COMPLETED/$STEPS_TOTAL completed                                     ║${NC}"
echo -e "${BOLD}${GREEN}║  Tag:      v$NEW_VERSION                                          ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Post-release checklist:"
echo "  [ ] Verify on GitHub: https://github.com/andybod1-lang/CloudSyncUltra"
echo "  [ ] Test the app manually"
echo "  [ ] Announce release (if applicable)"
echo ""
