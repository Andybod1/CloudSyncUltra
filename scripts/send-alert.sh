#!/bin/bash
#
# Webhook Alert Script
# Sends alerts to Slack or Discord webhooks for CI/health events
#
# Usage:
#   ./scripts/send-alert.sh --slack "https://hooks.slack.com/..." --message "Build failed"
#   ./scripts/send-alert.sh --discord "https://discord.com/api/webhooks/..." --message "Deploy complete"
#   ./scripts/send-alert.sh --config .webhook-config --ci-failure
#   ./scripts/send-alert.sh --config .webhook-config --health-drop 85
#
# Config file format (.webhook-config):
#   SLACK_WEBHOOK=https://hooks.slack.com/services/...
#   DISCORD_WEBHOOK=https://discord.com/api/webhooks/...
#   ALERT_ON_FAILURE=true
#   ALERT_ON_SUCCESS=false
#   HEALTH_THRESHOLD=90
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

SLACK_WEBHOOK=""
DISCORD_WEBHOOK=""
MESSAGE=""
CONFIG_FILE=""
CI_FAILURE=false
CI_SUCCESS=false
HEALTH_DROP=""
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --slack|-s)
            SLACK_WEBHOOK="$2"
            shift 2
            ;;
        --discord|-d)
            DISCORD_WEBHOOK="$2"
            shift 2
            ;;
        --message|-m)
            MESSAGE="$2"
            shift 2
            ;;
        --config|-c)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --ci-failure)
            CI_FAILURE=true
            shift
            ;;
        --ci-success)
            CI_SUCCESS=true
            shift
            ;;
        --health-drop)
            HEALTH_DROP="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Webhook options:"
            echo "  --slack, -s URL     Slack webhook URL"
            echo "  --discord, -d URL   Discord webhook URL"
            echo "  --config, -c FILE   Load webhooks from config file"
            echo ""
            echo "Message options:"
            echo "  --message, -m TEXT  Custom message to send"
            echo "  --ci-failure        Send CI failure alert"
            echo "  --ci-success        Send CI success alert"
            echo "  --health-drop PCT   Send health drop alert"
            echo ""
            echo "Other:"
            echo "  --dry-run           Show what would be sent without sending"
            echo "  --help, -h          Show this help"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Load config if provided
if [[ -n "$CONFIG_FILE" ]] && [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    [[ -z "$SLACK_WEBHOOK" ]] && SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"
    [[ -z "$DISCORD_WEBHOOK" ]] && DISCORD_WEBHOOK="${DISCORD_WEBHOOK:-}"
fi

# Check for webhooks
if [[ -z "$SLACK_WEBHOOK" ]] && [[ -z "$DISCORD_WEBHOOK" ]]; then
    echo -e "${YELLOW}No webhook configured. Use --slack or --discord to specify.${NC}"
    echo ""
    echo "To set up webhooks, create a config file:"
    echo ""
    echo "  echo 'SLACK_WEBHOOK=https://hooks.slack.com/services/...' > .webhook-config"
    echo "  echo 'DISCORD_WEBHOOK=https://discord.com/api/webhooks/...' >> .webhook-config"
    echo ""
    echo "Then run:"
    echo "  ./scripts/send-alert.sh --config .webhook-config --message 'Test'"
    exit 0
fi

# Get project info
VERSION=$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]' || echo "unknown")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
REPO="CloudSync Ultra"

# Generate message based on alert type
if [[ "$CI_FAILURE" == true ]]; then
    TITLE="CI Build Failed"
    COLOR="danger"
    DISCORD_COLOR=15158332  # Red
    MESSAGE="${MESSAGE:-CI build failed on branch $BRANCH (commit $COMMIT)}"
    EMOJI=":x:"
elif [[ "$CI_SUCCESS" == true ]]; then
    TITLE="CI Build Passed"
    COLOR="good"
    DISCORD_COLOR=3066993  # Green
    MESSAGE="${MESSAGE:-CI build passed on branch $BRANCH (commit $COMMIT)}"
    EMOJI=":white_check_mark:"
elif [[ -n "$HEALTH_DROP" ]]; then
    TITLE="Health Score Drop"
    COLOR="warning"
    DISCORD_COLOR=15844367  # Yellow
    MESSAGE="${MESSAGE:-Health score dropped to ${HEALTH_DROP}% (threshold: 90%)}"
    EMOJI=":warning:"
else
    TITLE="CloudSync Ultra Alert"
    COLOR="#0099ff"
    DISCORD_COLOR=39423  # Blue
    EMOJI=":bell:"
fi

# Prepare Slack payload
SLACK_PAYLOAD=$(cat << EOF
{
  "attachments": [
    {
      "color": "$COLOR",
      "title": "$EMOJI $TITLE",
      "text": "$MESSAGE",
      "fields": [
        {
          "title": "Project",
          "value": "$REPO v$VERSION",
          "short": true
        },
        {
          "title": "Branch",
          "value": "$BRANCH",
          "short": true
        }
      ],
      "footer": "CloudSync CI",
      "ts": $(date +%s)
    }
  ]
}
EOF
)

# Prepare Discord payload
DISCORD_PAYLOAD=$(cat << EOF
{
  "embeds": [
    {
      "title": "$TITLE",
      "description": "$MESSAGE",
      "color": $DISCORD_COLOR,
      "fields": [
        {
          "name": "Project",
          "value": "$REPO v$VERSION",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "$BRANCH",
          "inline": true
        },
        {
          "name": "Commit",
          "value": "$COMMIT",
          "inline": true
        }
      ],
      "footer": {
        "text": "CloudSync CI"
      },
      "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    }
  ]
}
EOF
)

echo ""
echo -e "${BLUE}${BOLD}Sending Alert${NC}"
echo -e "${DIM}═══════════════════════════════════════${NC}"
echo ""
echo -e "Title:   ${CYAN}$TITLE${NC}"
echo -e "Message: ${DIM}$MESSAGE${NC}"
echo ""

# Send to Slack
if [[ -n "$SLACK_WEBHOOK" ]]; then
    echo -e "Slack: "
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${YELLOW}[DRY RUN] Would send to Slack${NC}"
        echo "$SLACK_PAYLOAD" | head -5
    else
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
            -X POST \
            -H 'Content-type: application/json' \
            --data "$SLACK_PAYLOAD" \
            "$SLACK_WEBHOOK" 2>&1 || echo "error")

        if [[ "$RESPONSE" == "200" ]]; then
            echo -e "  ${GREEN}Sent successfully${NC}"
        else
            echo -e "  ${RED}Failed (HTTP $RESPONSE)${NC}"
        fi
    fi
fi

# Send to Discord
if [[ -n "$DISCORD_WEBHOOK" ]]; then
    echo -e "Discord: "
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${YELLOW}[DRY RUN] Would send to Discord${NC}"
        echo "$DISCORD_PAYLOAD" | head -5
    else
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
            -X POST \
            -H 'Content-type: application/json' \
            --data "$DISCORD_PAYLOAD" \
            "$DISCORD_WEBHOOK" 2>&1 || echo "error")

        if [[ "$RESPONSE" == "204" ]] || [[ "$RESPONSE" == "200" ]]; then
            echo -e "  ${GREEN}Sent successfully${NC}"
        else
            echo -e "  ${RED}Failed (HTTP $RESPONSE)${NC}"
        fi
    fi
fi

echo ""
