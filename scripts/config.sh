#!/bin/bash
#
# Config Access Script
# Read configuration values from the central project.json
#
# Usage:
#   ./scripts/config.sh                           # Show all config
#   ./scripts/config.sh get thresholds.coverage.minimum
#   ./scripts/config.sh get version
#   ./scripts/config.sh list thresholds
#   ./scripts/config.sh validate
#
# In other scripts:
#   source scripts/config.sh
#   MAX_LINES=$(config_get thresholds.complexity.maxFileLines)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/project.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Check if jq is available
HAS_JQ=false
if command -v jq &> /dev/null; then
    HAS_JQ=true
fi

# Function to get a config value
config_get() {
    local path="$1"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo ""
        return 1
    fi

    if [[ "$HAS_JQ" == true ]]; then
        # Use jq for proper JSON parsing
        # Convert dot notation to jq path: a.b.c -> .a.b.c
        local jq_path=".$path"
        jq -r "$jq_path // empty" "$CONFIG_FILE" 2>/dev/null
    else
        # Fallback: simple grep/sed for basic paths
        # Only works for simple dot-notation paths to scalar values
        local key=$(echo "$path" | rev | cut -d. -f1 | rev)
        grep "\"$key\"" "$CONFIG_FILE" | head -1 | sed 's/.*: *"\?\([^",}]*\)"\?.*/\1/' | tr -d ' '
    fi
}

# Function to list keys at a path
config_list() {
    local path="$1"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Config file not found: $CONFIG_FILE" >&2
        return 1
    fi

    if [[ "$HAS_JQ" == true ]]; then
        local jq_path="."
        if [[ -n "$path" ]]; then
            jq_path=".$path"
        fi
        jq -r "$jq_path | keys[]" "$CONFIG_FILE" 2>/dev/null
    else
        echo "jq required for list operation" >&2
        return 1
    fi
}

# Function to validate config
config_validate() {
    local errors=0

    echo -e "${BLUE}${BOLD}Validating project.json${NC}"
    echo ""

    # Check file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${RED}ERROR: Config file not found: $CONFIG_FILE${NC}"
        return 1
    fi

    # Check valid JSON
    if [[ "$HAS_JQ" == true ]]; then
        if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
            echo -e "${RED}ERROR: Invalid JSON syntax${NC}"
            return 1
        fi
        echo -e "${GREEN}  Valid JSON syntax${NC}"
    fi

    # Check required fields
    local required_fields=(
        "name"
        "version"
        "thresholds.coverage.minimum"
        "thresholds.complexity.maxFileLines"
        "paths.source"
    )

    for field in "${required_fields[@]}"; do
        local value=$(config_get "$field")
        if [[ -z "$value" ]]; then
            echo -e "${RED}  Missing required field: $field${NC}"
            ((errors++))
        else
            echo -e "${GREEN}  $field: $value${NC}"
        fi
    done

    # Check version matches VERSION.txt
    local json_version=$(config_get "version")
    local file_version=$(cat "$PROJECT_ROOT/VERSION.txt" 2>/dev/null | tr -d '[:space:]')

    if [[ "$json_version" != "$file_version" ]]; then
        echo -e "${YELLOW}  WARNING: Version mismatch - project.json: $json_version, VERSION.txt: $file_version${NC}"
        ((errors++))
    else
        echo -e "${GREEN}  Version synced with VERSION.txt${NC}"
    fi

    echo ""
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}Validation passed${NC}"
        return 0
    else
        echo -e "${RED}${BOLD}Validation failed: $errors error(s)${NC}"
        return 1
    fi
}

# Function to show all config
config_show() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Config file not found: $CONFIG_FILE" >&2
        return 1
    fi

    echo -e "${BLUE}${BOLD}Project Configuration${NC}"
    echo -e "${DIM}$CONFIG_FILE${NC}"
    echo ""

    if [[ "$HAS_JQ" == true ]]; then
        jq -C '.' "$CONFIG_FILE"
    else
        cat "$CONFIG_FILE"
    fi
}

# Function to show thresholds summary
config_thresholds() {
    echo -e "${BLUE}${BOLD}Quality Thresholds${NC}"
    echo ""

    echo -e "${CYAN}Coverage:${NC}"
    echo "  Minimum:  $(config_get thresholds.coverage.minimum)%"
    echo "  Target:   $(config_get thresholds.coverage.target)%"
    echo "  CI Gate:  $(config_get thresholds.coverage.ci)%"
    echo ""

    echo -e "${CYAN}Complexity:${NC}"
    echo "  Max Function Lines: $(config_get thresholds.complexity.maxFunctionLines)"
    echo "  Max File Lines:     $(config_get thresholds.complexity.maxFileLines)"
    echo "  Max Nesting Depth:  $(config_get thresholds.complexity.maxNestingDepth)"
    echo "  Max Parameters:     $(config_get thresholds.complexity.maxParameters)"
    echo ""

    echo -e "${CYAN}Binary:${NC}"
    echo "  Max Size:    $(config_get thresholds.binary.maxSizeMB) MB"
    echo "  Baseline:    $(config_get thresholds.binary.baselineKB) KB"
    echo "  Alert at:    +$(config_get thresholds.binary.alertOnIncreasePercent)%"
    echo ""

    echo -e "${CYAN}PR:${NC}"
    echo "  Warn at:  $(config_get thresholds.pr.warnLinesChanged) lines"
    echo "  Block at: $(config_get thresholds.pr.blockLinesChanged) lines"
}

# Export function for use in other scripts
export -f config_get 2>/dev/null || true

# Main command handling
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly (not sourced)

    case "${1:-}" in
        get)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 get <path>" >&2
                echo "Example: $0 get thresholds.coverage.minimum" >&2
                exit 1
            fi
            config_get "$2"
            ;;
        list)
            config_list "${2:-}"
            ;;
        validate)
            config_validate
            ;;
        thresholds)
            config_thresholds
            ;;
        --help|-h)
            echo "Usage: $0 [command] [args]"
            echo ""
            echo "Commands:"
            echo "  (none)      Show all configuration"
            echo "  get PATH    Get a specific value (e.g., thresholds.coverage.minimum)"
            echo "  list PATH   List keys at path"
            echo "  validate    Validate configuration"
            echo "  thresholds  Show thresholds summary"
            echo ""
            echo "Examples:"
            echo "  $0 get version"
            echo "  $0 get thresholds.complexity.maxFileLines"
            echo "  $0 list thresholds"
            echo ""
            echo "In other scripts:"
            echo "  source scripts/config.sh"
            echo "  MAX=$(config_get thresholds.complexity.maxFileLines)"
            ;;
        *)
            config_show
            ;;
    esac
fi
