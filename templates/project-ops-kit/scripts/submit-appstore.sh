#!/bin/bash

###############################################################################
# submit-appstore.sh - Submit app to App Store Connect
# Usage: ./scripts/submit-appstore.sh [ipa_or_pkg_path]
#
# Environment variables required:
#   APPLE_ID           - Your Apple ID email
#   APPLE_APP_PASSWORD - App-specific password from appleid.apple.com
#   APPLE_TEAM_ID      - Your Apple Team ID (optional)
#
# Options:
#   -h, --help         Show this help message
#   --validate-only    Only validate, don't upload
#   --dry-run          Test the process without actual submission
###############################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_RESET='\033[0m'
readonly COLOR_BOLD='\033[1m'

# Globals
DRY_RUN=false
VALIDATE_ONLY=false
APP_PATH=""
UPLOAD_TOOL=""  # Will be set to 'altool' or 'transporter'

# Show usage
show_usage() {
    grep "^# " "$0" | sed 's/^# //' | head -n 20
    exit 0
}

# Error handler
error_exit() {
    echo -e "${COLOR_RED}❌ Error: $1${COLOR_RESET}" >&2
    exit 1
}

# Success message
success_message() {
    echo -e "${COLOR_GREEN}✅ $1${COLOR_RESET}"
}

# Info message
info_message() {
    echo -e "${COLOR_BLUE}ℹ️  $1${COLOR_RESET}"
}

# Warning message
warning_message() {
    echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_RESET}"
}

# Progress message
progress_message() {
    echo -e "${COLOR_BOLD}➤ $1${COLOR_RESET}"
}

# Check prerequisites
check_prerequisites() {
    info_message "Checking prerequisites..."

    # Check for xcrun
    if ! command -v xcrun &> /dev/null; then
        error_exit "xcrun not found. Please install Xcode Command Line Tools"
    fi

    # Check for available upload tools
    if xcrun altool --version &> /dev/null 2>&1; then
        UPLOAD_TOOL="altool"
        info_message "Using altool for submission"
    elif command -v transporter &> /dev/null; then
        UPLOAD_TOOL="transporter"
        info_message "Using Transporter for submission"
    else
        error_exit "Neither altool nor Transporter found. Please install Xcode or Transporter"
    fi

    # Check environment variables
    if [[ -z "${APPLE_ID:-}" ]]; then
        error_exit "APPLE_ID environment variable not set"
    fi

    if [[ -z "${APPLE_APP_PASSWORD:-}" ]]; then
        error_exit "APPLE_APP_PASSWORD environment variable not set"
    fi

    success_message "Prerequisites checked"
}

# Validate app package
validate_package() {
    local package_path="$1"

    info_message "Validating app package..."

    # Check if path exists
    if [[ ! -f "$package_path" ]]; then
        error_exit "Package not found at: $package_path"
    fi

    # Check file extension
    local extension="${package_path##*.}"
    if [[ "$extension" != "ipa" ]] && [[ "$extension" != "pkg" ]]; then
        error_exit "Invalid package type. Expected .ipa or .pkg file"
    fi

    # Check file size
    local size=$(stat -f%z "$package_path" 2>/dev/null || stat -c%s "$package_path" 2>/dev/null || echo 0)
    if [[ $size -eq 0 ]]; then
        error_exit "Package file is empty"
    fi

    local size_mb=$((size / 1024 / 1024))
    info_message "Package size: ${size_mb}MB"

    success_message "Package validation passed"
}

# Validate with App Store Connect
validate_with_appstore() {
    local package_path="$1"

    progress_message "Validating with App Store Connect..."

    if [[ "$DRY_RUN" == true ]]; then
        warning_message "DRY RUN: Would validate $package_path"
        return 0
    fi

    local validation_output
    local validation_status=0

    if [[ "$UPLOAD_TOOL" == "altool" ]]; then
        # Use altool for validation
        validation_output=$(xcrun altool \
            --validate-app \
            --file "$package_path" \
            --username "$APPLE_ID" \
            --password "$APPLE_APP_PASSWORD" \
            ${APPLE_TEAM_ID:+--asc-provider "$APPLE_TEAM_ID"} \
            --output-format json \
            2>&1) || validation_status=$?
    else
        # Use Transporter for validation
        validation_output=$(transporter \
            -m verify \
            -assetFile "$package_path" \
            -u "$APPLE_ID" \
            -p "$APPLE_APP_PASSWORD" \
            ${APPLE_TEAM_ID:+-itc_provider "$APPLE_TEAM_ID"} \
            2>&1) || validation_status=$?
    fi

    if [[ $validation_status -ne 0 ]]; then
        echo -e "${COLOR_RED}Validation output:${COLOR_RESET}"
        echo "$validation_output"
        error_exit "App validation failed"
    fi

    success_message "App validation successful"
}

# Upload to App Store Connect
upload_to_appstore() {
    local package_path="$1"

    progress_message "Uploading to App Store Connect..."

    if [[ "$DRY_RUN" == true ]]; then
        warning_message "DRY RUN: Would upload $package_path"
        return 0
    fi

    info_message "This may take several minutes depending on file size and connection speed..."

    local upload_output
    local upload_status=0

    if [[ "$UPLOAD_TOOL" == "altool" ]]; then
        # Use altool for upload
        upload_output=$(xcrun altool \
            --upload-app \
            --file "$package_path" \
            --username "$APPLE_ID" \
            --password "$APPLE_APP_PASSWORD" \
            ${APPLE_TEAM_ID:+--asc-provider "$APPLE_TEAM_ID"} \
            --output-format json \
            2>&1) || upload_status=$?
    else
        # Use Transporter for upload
        upload_output=$(transporter \
            -m upload \
            -assetFile "$package_path" \
            -u "$APPLE_ID" \
            -p "$APPLE_APP_PASSWORD" \
            ${APPLE_TEAM_ID:+-itc_provider "$APPLE_TEAM_ID"} \
            2>&1) || upload_status=$?
    fi

    if [[ $upload_status -ne 0 ]]; then
        echo -e "${COLOR_RED}Upload output:${COLOR_RESET}"
        echo "$upload_output"
        error_exit "App upload failed"
    fi

    # Extract upload ID if available (altool JSON output)
    if [[ "$UPLOAD_TOOL" == "altool" ]]; then
        local upload_id=$(echo "$upload_output" | grep -o '"id":"[^"]*"' | cut -d'"' -f4 || echo "")
        if [[ -n "$upload_id" ]]; then
            info_message "Upload ID: $upload_id"
        fi
    fi

    success_message "App uploaded successfully"
}

# Show summary
show_summary() {
    local package_path="$1"
    local package_name=$(basename "$package_path")

    echo
    echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_GREEN}📱 App Store Submission Complete${COLOR_RESET}"
    echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
    info_message "Package: $package_name"
    info_message "Status: Successfully uploaded to App Store Connect"
    echo
    progress_message "Next steps:"
    echo "  1. Log in to App Store Connect"
    echo "  2. Complete app information if needed"
    echo "  3. Submit for review"
    echo
    echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════${COLOR_RESET}"
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                ;;
            --validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                APP_PATH="$1"
                shift
                ;;
        esac
    done

    # Check if app path provided
    if [[ -z "$APP_PATH" ]]; then
        error_exit "No package path provided. Usage: $0 [ipa_or_pkg_path]"
    fi

    # Convert to absolute path
    APP_PATH=$(cd "$(dirname "$APP_PATH")" && pwd)/$(basename "$APP_PATH")

    echo -e "${COLOR_BLUE}╔══════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_BLUE}║           App Store Connect Submission Tool              ║${COLOR_RESET}"
    echo -e "${COLOR_BLUE}╚══════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo

    # Run submission process
    check_prerequisites
    validate_package "$APP_PATH"
    validate_with_appstore "$APP_PATH"

    if [[ "$VALIDATE_ONLY" == true ]]; then
        success_message "Validation complete. Use without --validate-only to upload."
        exit 0
    fi

    upload_to_appstore "$APP_PATH"
    show_summary "$APP_PATH"
}

# Handle errors
trap 'echo -e "${COLOR_RED}Script interrupted${COLOR_RESET}"; exit 1' INT TERM

# Run main
main "$@"