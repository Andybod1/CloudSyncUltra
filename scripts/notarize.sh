#!/bin/bash

###############################################################################
# notarize.sh - Notarize macOS app for distribution
# Usage: ./scripts/notarize.sh [app_path]
#
# Environment variables required:
#   APPLE_ID           - Your Apple ID email
#   APPLE_TEAM_ID      - Your Apple Team ID
#   APPLE_APP_PASSWORD - App-specific password from appleid.apple.com
#
# Options:
#   -h, --help    Show this help message
#   --dry-run     Test the process without actual submission
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

# Globals
DRY_RUN=false
APP_PATH=""

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

# Show spinner
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    echo -n " "
    while ps -p "$pid" > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b"
    done
    echo "    "
}

# Check prerequisites
check_prerequisites() {
    info_message "Checking prerequisites..."

    # Check for xcrun notarytool
    if ! command -v xcrun &> /dev/null; then
        error_exit "xcrun not found. Please install Xcode Command Line Tools"
    fi

    if ! xcrun notarytool --version &> /dev/null 2>&1; then
        error_exit "notarytool not found. Please update to Xcode 13 or later"
    fi

    # Check environment variables
    if [[ -z "${APPLE_ID:-}" ]]; then
        error_exit "APPLE_ID environment variable not set"
    fi

    if [[ -z "${APPLE_TEAM_ID:-}" ]]; then
        error_exit "APPLE_TEAM_ID environment variable not set"
    fi

    if [[ -z "${APPLE_APP_PASSWORD:-}" ]]; then
        error_exit "APPLE_APP_PASSWORD environment variable not set"
    fi

    success_message "Prerequisites checked"
}

# Validate app bundle
validate_app() {
    local app_path="$1"

    info_message "Validating app bundle..."

    # Check if path exists
    if [[ ! -e "$app_path" ]]; then
        error_exit "App not found at: $app_path"
    fi

    # Check if it's a valid app bundle
    if [[ ! -d "$app_path" ]] || [[ ! "$app_path" == *.app ]]; then
        error_exit "Invalid app bundle. Expected a .app directory"
    fi

    # Check for Info.plist
    if [[ ! -f "$app_path/Contents/Info.plist" ]]; then
        error_exit "No Info.plist found in app bundle"
    fi

    # Check if app is signed
    if ! codesign -v "$app_path" &> /dev/null; then
        error_exit "App is not signed. Please sign before notarization"
    fi

    success_message "App validation passed"
}

# Create ZIP archive
create_archive() {
    local app_path="$1"
    local app_name=$(basename "$app_path")
    local zip_path="${app_path%.app}-notarization.zip"

    info_message "Creating ZIP archive..."

    # Remove existing ZIP if present
    rm -f "$zip_path"

    # Create ZIP with ditto (preserves code signatures)
    if ditto -c -k --keepParent "$app_path" "$zip_path"; then
        success_message "Archive created: $zip_path"
        echo "$zip_path"
    else
        error_exit "Failed to create ZIP archive"
    fi
}

# Submit for notarization
submit_notarization() {
    local zip_path="$1"
    local app_name=$(basename "$zip_path" .zip)

    info_message "Submitting app for notarization..."

    if [[ "$DRY_RUN" == true ]]; then
        warning_message "DRY RUN: Would submit $zip_path for notarization"
        echo "dry-run-submission-id"
        return 0
    fi

    # Submit using notarytool
    local output
    output=$(xcrun notarytool submit \
        "$zip_path" \
        --apple-id "$APPLE_ID" \
        --team-id "$APPLE_TEAM_ID" \
        --password "$APPLE_APP_PASSWORD" \
        --wait \
        2>&1) || {
        error_exit "Notarization submission failed: $output"
    }

    # Extract submission ID from output
    local submission_id
    submission_id=$(echo "$output" | grep -E "id: [a-f0-9-]+" | head -1 | cut -d' ' -f2)

    if [[ -z "$submission_id" ]]; then
        error_exit "Failed to extract submission ID from output"
    fi

    success_message "Notarization submitted with ID: $submission_id"
    echo "$submission_id"
}

# Wait for notarization
wait_for_notarization() {
    local submission_id="$1"

    info_message "Waiting for notarization to complete..."

    if [[ "$DRY_RUN" == true ]]; then
        warning_message "DRY RUN: Would wait for notarization"
        return 0
    fi

    # Poll for status in background
    (
        while true; do
            local status
            status=$(xcrun notarytool info \
                "$submission_id" \
                --apple-id "$APPLE_ID" \
                --team-id "$APPLE_TEAM_ID" \
                --password "$APPLE_APP_PASSWORD" \
                2>&1 | grep "status:" | awk '{print $2}')

            case "$status" in
                "Accepted")
                    exit 0
                    ;;
                "Invalid"|"Rejected")
                    exit 1
                    ;;
                *)
                    sleep 30
                    ;;
            esac
        done
    ) &

    local poll_pid=$!

    # Show spinner while waiting
    show_spinner $poll_pid

    # Check exit status
    if wait $poll_pid; then
        success_message "Notarization successful!"
    else
        # Get log for debugging
        local log_output
        log_output=$(xcrun notarytool log \
            "$submission_id" \
            --apple-id "$APPLE_ID" \
            --team-id "$APPLE_TEAM_ID" \
            --password "$APPLE_APP_PASSWORD" \
            2>&1)
        error_exit "Notarization failed. Log:\n$log_output"
    fi
}

# Staple notarization ticket
staple_ticket() {
    local app_path="$1"

    info_message "Stapling notarization ticket..."

    if [[ "$DRY_RUN" == true ]]; then
        warning_message "DRY RUN: Would staple ticket to $app_path"
        return 0
    fi

    if xcrun stapler staple "$app_path"; then
        success_message "Notarization ticket stapled successfully!"
    else
        error_exit "Failed to staple notarization ticket"
    fi
}

# Clean up temporary files
cleanup() {
    local zip_path="$1"

    if [[ -f "$zip_path" ]]; then
        info_message "Cleaning up temporary files..."
        rm -f "$zip_path"
        success_message "Cleanup complete"
    fi
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
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
        error_exit "No app path provided. Usage: $0 [app_path]"
    fi

    # Convert to absolute path
    APP_PATH=$(cd "$(dirname "$APP_PATH")" && pwd)/$(basename "$APP_PATH")

    echo -e "${COLOR_BLUE}╔══════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_BLUE}║             macOS App Notarization Tool                  ║${COLOR_RESET}"
    echo -e "${COLOR_BLUE}╚══════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo

    # Run notarization process
    check_prerequisites
    validate_app "$APP_PATH"

    # Create archive
    ZIP_PATH=$(create_archive "$APP_PATH")

    # Submit and wait
    SUBMISSION_ID=$(submit_notarization "$ZIP_PATH")
    wait_for_notarization "$SUBMISSION_ID"

    # Staple ticket
    staple_ticket "$APP_PATH"

    # Cleanup
    cleanup "$ZIP_PATH"

    echo
    success_message "🎉 Notarization complete! Your app is ready for distribution."
    info_message "App location: $APP_PATH"
}

# Handle errors
trap 'echo -e "${COLOR_RED}Script interrupted${COLOR_RESET}"; exit 1' INT TERM

# Run main
main "$@"