#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Context Restore - Quick Onboarding for New Claude Sessions               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/project.conf"

cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Gather data
VERSION=$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]' || echo "unknown")
LAST_COMMIT=$(git log -1 --format="%h %s" 2>/dev/null | cut -c1-60 || echo "unknown")
LAST_COMMIT_AGO=$(git log -1 --format="%cr" 2>/dev/null || echo "unknown")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Issue counts
OPEN_ISSUES=$(gh issue list --state open --json number 2>/dev/null | jq length 2>/dev/null || echo "?")
CRITICAL=$(gh issue list --label "priority:critical" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
IN_PROGRESS=$(gh issue list --label "in-progress" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")

# Workers
WORKERS_ACTIVE=$(grep -c "🔄" "$PROJECT_ROOT/.claude-team/STATUS.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
WORKERS_IDLE=$(grep -c "💤" "$PROJECT_ROOT/.claude-team/STATUS.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
[[ -z "$WORKERS_ACTIVE" ]] && WORKERS_ACTIVE=0
[[ -z "$WORKERS_IDLE" ]] && WORKERS_IDLE=0

# Recent commits
RECENT_COMMITS=$(git log -5 --format="%h %s" 2>/dev/null | cut -c1-55)

echo ""
echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║              ${PROJECT_NAME^^} — CONTEXT RESTORE                            ║${NC}"
echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}📦 PROJECT${NC}"
echo -e "   App:        $PROJECT_NAME"
echo -e "   Desc:       $PROJECT_DESCRIPTION"
echo -e "   Version:    ${GREEN}v$VERSION${NC}"
echo -e "   Branch:     ${CYAN}$BRANCH${NC}"
echo -e "   GitHub:     $GITHUB_URL"
echo ""

echo -e "${BOLD}📍 CURRENT STATE${NC}"
echo -e "   Last commit: ${DIM}$LAST_COMMIT${NC}"
echo -e "               ${DIM}($LAST_COMMIT_AGO)${NC}"
echo -e "   Issues:      $OPEN_ISSUES open ($CRITICAL critical, $IN_PROGRESS in-progress)"
echo -e "   Workers:     $WORKERS_ACTIVE active, $WORKERS_IDLE idle"
echo ""

echo -e "${BOLD}📋 RECENT COMMITS${NC}"
echo "$RECENT_COMMITS" | while read line; do
    echo -e "   ${DIM}$line${NC}"
done
echo ""

echo -e "${BOLD}⚡ QUICK COMMANDS${NC}"
echo -e "   ${DIM}./scripts/dashboard.sh${NC}        # Full health dashboard"
echo -e "   ${DIM}./scripts/release.sh X.X.X${NC}   # Release new version"
echo -e "   ${DIM}gh issue list${NC}                # View all issues"
echo -e "   ${DIM}cat .claude-team/STATUS.md${NC}   # Worker status"
echo ""

echo -e "${BOLD}📂 KEY FILES${NC}"
echo -e "   ${DIM}CLAUDE_PROJECT_KNOWLEDGE.md${NC}  # Project overview"
echo -e "   ${DIM}.claude-team/STATUS.md${NC}       # Worker coordination"
echo -e "   ${DIM}.claude-team/RECOVERY.md${NC}     # Recovery guide"
echo -e "   ${DIM}project.conf${NC}                 # Project settings"
echo ""

# Alerts
if [[ "$CRITICAL" -gt 0 ]] || [[ "$IN_PROGRESS" -gt 0 ]]; then
    echo -e "${BOLD}⚠️  ALERTS${NC}"
    [[ "$CRITICAL" -gt 0 ]] && echo -e "   ${RED}●${NC} $CRITICAL critical issue(s) need attention"
    [[ "$IN_PROGRESS" -gt 0 ]] && echo -e "   ${YELLOW}●${NC} $IN_PROGRESS issue(s) in progress"
    echo ""
fi

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${DIM}Context restored. Ready to work!${NC}"
echo ""
