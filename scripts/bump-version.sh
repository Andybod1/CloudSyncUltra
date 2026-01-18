#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Auto Version Bump                                                         ║
# ║  Automatically bump version based on commit type (semver)                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage:
#   ./scripts/bump-version.sh              # Auto-detect from recent commits
#   ./scripts/bump-version.sh --major      # Force major bump (1.0.0 → 2.0.0)
#   ./scripts/bump-version.sh --minor      # Force minor bump (1.0.0 → 1.1.0)
#   ./scripts/bump-version.sh --patch      # Force patch bump (1.0.0 → 1.0.1)
#   ./scripts/bump-version.sh --dry-run    # Preview without changing files
#
# Commit type mapping (conventional commits):
#   feat!: / BREAKING CHANGE: → major
#   feat: → minor
#   fix: / docs: / style: / refactor: / test: / chore: → patch

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/VERSION.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

BUMP_TYPE=""
DRY_RUN=false
SINCE_TAG=""

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║           Auto Version Bump                               ║${NC}"
    echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE" | tr -d '[:space:]'
    else
        echo "0.0.0"
    fi
}

# Parse version into components
parse_version() {
    local version="$1"
    # Remove 'v' prefix if present
    version="${version#v}"

    MAJOR=$(echo "$version" | cut -d. -f1)
    MINOR=$(echo "$version" | cut -d. -f2)
    PATCH=$(echo "$version" | cut -d. -f3)

    # Default to 0 if empty
    MAJOR=${MAJOR:-0}
    MINOR=${MINOR:-0}
    PATCH=${PATCH:-0}
}

# Bump version based on type
bump_version() {
    local type="$1"

    case "$type" in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
    esac

    echo "${MAJOR}.${MINOR}.${PATCH}"
}

# Analyze commits to determine bump type
analyze_commits() {
    local since="${1:-}"
    local log_range=""

    # Get the last tag or use all commits
    if [[ -n "$since" ]]; then
        log_range="$since..HEAD"
    else
        # Try to get last tag
        local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
        if [[ -n "$last_tag" ]]; then
            log_range="$last_tag..HEAD"
            echo -e "${DIM}Analyzing commits since $last_tag${NC}"
        else
            log_range="HEAD~20..HEAD"
            echo -e "${DIM}Analyzing last 20 commits${NC}"
        fi
    fi

    # Check for breaking changes
    if git log "$log_range" --oneline 2>/dev/null | grep -qiE '!:|BREAKING CHANGE'; then
        echo "major"
        return
    fi

    # Check for features
    if git log "$log_range" --oneline 2>/dev/null | grep -qE '^[a-f0-9]+ feat(\(|:)'; then
        echo "minor"
        return
    fi

    # Default to patch
    echo "patch"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --major)
            BUMP_TYPE="major"
            shift
            ;;
        --minor)
            BUMP_TYPE="minor"
            shift
            ;;
        --patch)
            BUMP_TYPE="patch"
            shift
            ;;
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --since)
            SINCE_TAG="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --major         Force major version bump"
            echo "  --minor         Force minor version bump"
            echo "  --patch         Force patch version bump"
            echo "  --dry-run, -n   Preview without changing files"
            echo "  --since TAG     Analyze commits since TAG"
            echo "  --help, -h      Show this help"
            echo ""
            echo "Auto-detection rules:"
            echo "  Breaking changes (feat!:, BREAKING CHANGE:) → major"
            echo "  Features (feat:) → minor"
            echo "  Everything else → patch"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_header

# Get current version
CURRENT=$(get_current_version)
parse_version "$CURRENT"

echo -e "Current version: ${CYAN}${BOLD}$CURRENT${NC}"
echo ""

# Determine bump type
if [[ -z "$BUMP_TYPE" ]]; then
    echo -e "${BOLD}Analyzing commits...${NC}"
    BUMP_TYPE=$(analyze_commits "$SINCE_TAG")
    echo -e "Detected bump type: ${YELLOW}${BOLD}$BUMP_TYPE${NC}"
else
    echo -e "Forced bump type: ${YELLOW}${BOLD}$BUMP_TYPE${NC}"
fi

# Calculate new version
NEW_VERSION=$(bump_version "$BUMP_TYPE")

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${DIM}$CURRENT${NC} → ${GREEN}${BOLD}$NEW_VERSION${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}${BOLD}DRY RUN:${NC} Would update version to $NEW_VERSION"
    echo ""
    echo -e "Files that would be updated:"
    echo -e "  ${DIM}- VERSION.txt${NC}"
    echo -e "  ${DIM}- (via ./scripts/update-version.sh)${NC}"
    echo ""
    echo -e "Run without --dry-run to apply changes"
    exit 0
fi

# Apply the version bump using existing script
echo -e "Updating version files..."
"$SCRIPT_DIR/update-version.sh" "$NEW_VERSION"

echo ""
echo -e "${GREEN}${BOLD}✓ Version bumped to $NEW_VERSION${NC}"
echo ""
echo -e "Next steps:"
echo -e "  ${DIM}1. Review changes: git diff${NC}"
echo -e "  ${DIM}2. Commit: git commit -am 'chore: bump version to $NEW_VERSION'${NC}"
echo -e "  ${DIM}3. Tag: git tag v$NEW_VERSION${NC}"
echo -e "  ${DIM}4. Or use: ./scripts/release.sh $NEW_VERSION${NC}"
echo ""
