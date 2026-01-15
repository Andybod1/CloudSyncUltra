#!/bin/bash

###############################################################################
# generate-changelog.sh - Generate changelog from conventional commits
# Usage: ./scripts/generate-changelog.sh [version] [--prepend]
#
# Options:
#   version   Optional version number (defaults to "Unreleased")
#   --prepend Prepend the output to CHANGELOG.md
#   -h        Show this help message
###############################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

# Colors for output
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_RESET='\033[0m'

# Show usage
show_usage() {
    grep "^# " "$0" | sed 's/^# //' | head -n 20
    exit 0
}

# Get last tag
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Parse commits since last tag
parse_commits() {
    local since_ref="${1:-}"
    local range_arg=""

    if [[ -n "$since_ref" ]]; then
        range_arg="${since_ref}..HEAD"
    fi

    # Get commits with conventional format
    git log $range_arg --pretty=format:'%H|%s|%an' --no-merges
}

# Group commits by type
group_commits_by_type() {
    local commits="$1"

    declare -A commit_groups
    commit_groups["feat"]=""
    commit_groups["fix"]=""
    commit_groups["docs"]=""
    commit_groups["test"]=""
    commit_groups["ops"]=""
    commit_groups["refactor"]=""
    commit_groups["chore"]=""
    commit_groups["other"]=""

    while IFS='|' read -r hash subject author; do
        [[ -z "$hash" ]] && continue

        # Extract type and description from conventional format
        if [[ "$subject" =~ ^([a-z]+)(\(.*\))?:\ (.+)$ ]]; then
            local type="${BASH_REMATCH[1]}"
            local scope="${BASH_REMATCH[2]}"
            local description="${BASH_REMATCH[3]}"

            # Shorten hash to 7 characters
            local short_hash="${hash:0:7}"

            # Create commit entry with link
            local entry="- ${description} ([${short_hash}](https://github.com/CloudKit/CloudCopy/commit/${hash}))"

            # Add to appropriate group
            case "$type" in
                feat|feature)
                    commit_groups["feat"]+="$entry"$'\n'
                    ;;
                fix|bugfix)
                    commit_groups["fix"]+="$entry"$'\n'
                    ;;
                docs|doc)
                    commit_groups["docs"]+="$entry"$'\n'
                    ;;
                test|tests)
                    commit_groups["test"]+="$entry"$'\n'
                    ;;
                ops|ci|build)
                    commit_groups["ops"]+="$entry"$'\n'
                    ;;
                refactor|ref)
                    commit_groups["refactor"]+="$entry"$'\n'
                    ;;
                chore|style|perf)
                    commit_groups["chore"]+="$entry"$'\n'
                    ;;
                *)
                    commit_groups["other"]+="$entry"$'\n'
                    ;;
            esac
        else
            # Non-conventional commits go to "other"
            local short_hash="${hash:0:7}"
            local entry="- ${subject} ([${short_hash}](https://github.com/CloudKit/CloudCopy/commit/${hash}))"
            commit_groups["other"]+="$entry"$'\n'
        fi
    done <<< "$commits"

    # Output grouped commits
    echo "${commit_groups[@]}"
    for type in feat fix docs test ops refactor chore other; do
        echo "TYPE:$type"
        echo "${commit_groups[$type]}"
    done
}

# Generate changelog entry
generate_changelog() {
    local version="$1"
    local last_tag="$2"
    local commits="$3"

    # Header
    echo "## [$version] - $(date +%Y-%m-%d)"
    echo

    # Get commit count
    local commit_count=$(echo "$commits" | grep -c '^[a-f0-9]' || echo 0)

    if [[ $commit_count -eq 0 ]]; then
        echo "No changes since last release."
        return
    fi

    echo "**${commit_count} changes** since ${last_tag:-initial commit}"
    echo

    # Group commits by type
    local grouped_output=""
    grouped_output=$(group_commits_by_type "$commits")

    # Output sections
    local has_content=false

    # Process each type
    while IFS= read -r line; do
        if [[ "$line" =~ ^TYPE:(.+)$ ]]; then
            local current_type="${BASH_REMATCH[1]}"
            # Read content for this type
            local content=""
            while IFS= read -r content_line; do
                if [[ "$content_line" =~ ^TYPE: ]] || [[ -z "$content_line" ]]; then
                    break
                fi
                if [[ -n "$content_line" ]] && [[ "$content_line" != "TYPE:"* ]]; then
                    content+="$content_line"$'\n'
                fi
            done

            # Output section if it has content
            if [[ -n "$content" ]] && [[ "$content" != $'\n' ]]; then
                case "$current_type" in
                    feat)
                        echo "### 🚀 Features"
                        ;;
                    fix)
                        echo "### 🐛 Bug Fixes"
                        ;;
                    docs)
                        echo "### 📚 Documentation"
                        ;;
                    test)
                        echo "### ✅ Tests"
                        ;;
                    ops)
                        echo "### ⚙️ Operations"
                        ;;
                    refactor)
                        echo "### ♻️ Refactoring"
                        ;;
                    chore)
                        echo "### 🔧 Chores"
                        ;;
                    other)
                        echo "### 📝 Other Changes"
                        ;;
                esac
                echo
                echo -n "$content"
                echo
                has_content=true
            fi
        fi
    done <<< "$grouped_output"

    # Add separator
    echo "---"
}

# Main function
main() {
    local version="Unreleased"
    local prepend=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                ;;
            --prepend)
                prepend=true
                shift
                ;;
            *)
                version="$1"
                shift
                ;;
        esac
    done

    # Get last tag
    echo -e "${COLOR_BLUE}Getting last tag...${COLOR_RESET}" >&2
    local last_tag=$(get_last_tag)

    if [[ -z "$last_tag" ]]; then
        echo -e "${COLOR_YELLOW}No previous tags found. Generating changelog from all commits.${COLOR_RESET}" >&2
    else
        echo -e "${COLOR_GREEN}Last tag: $last_tag${COLOR_RESET}" >&2
    fi

    # Get commits
    echo -e "${COLOR_BLUE}Parsing commits...${COLOR_RESET}" >&2
    local commits=$(parse_commits "$last_tag")

    # Generate changelog entry
    local changelog_entry=$(generate_changelog "$version" "$last_tag" "$commits")

    if [[ "$prepend" == true ]]; then
        echo -e "${COLOR_BLUE}Prepending to ${CHANGELOG_FILE}...${COLOR_RESET}" >&2

        # Create temp file with new entry
        local temp_file=$(mktemp)
        echo "$changelog_entry" > "$temp_file"
        echo >> "$temp_file"

        # Append existing changelog
        if [[ -f "$CHANGELOG_FILE" ]]; then
            cat "$CHANGELOG_FILE" >> "$temp_file"
        fi

        # Replace original file
        mv "$temp_file" "$CHANGELOG_FILE"

        echo -e "${COLOR_GREEN}✓ Changelog updated successfully!${COLOR_RESET}" >&2
        echo -e "${COLOR_BLUE}View changes: ${CHANGELOG_FILE}${COLOR_RESET}" >&2
    else
        # Just output to stdout
        echo "$changelog_entry"
    fi
}

# Run main
main "$@"