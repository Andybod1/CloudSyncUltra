#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - Command Center Dashboard                                ║
# ║  One person. Billion-dollar operations. Complete visibility.               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/dashboard.sh [--quick]
#   --quick    Skip slow operations (git fetch, etc.)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
QUICK_MODE=false

[[ "$1" == "--quick" ]] && QUICK_MODE=true

cd "$PROJECT_ROOT"

# ═══════════════════════════════════════════════════════════════════════════
# COLORS & FORMATTING
# ═══════════════════════════════════════════════════════════════════════════
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════════════════
# DATA COLLECTION
# ═══════════════════════════════════════════════════════════════════════════

# Version info
VERSION=$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]' || echo "unknown")
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

# Git info
LAST_COMMIT=$(git log -1 --format="%h" 2>/dev/null || echo "?")
LAST_COMMIT_MSG=$(git log -1 --format="%s" 2>/dev/null | cut -c1-40 || echo "?")
LAST_COMMIT_AGO=$(git log -1 --format="%cr" 2>/dev/null || echo "?")
COMMITS_TODAY=$(git log --since="midnight" --oneline 2>/dev/null | wc -l | tr -d ' ')
UNCOMMITTED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')

# Issue counts
OPEN_ISSUES=$(gh issue list --state open --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
CLOSED_ISSUES=$(gh issue list --state closed --limit 500 --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
IN_PROGRESS=$(gh issue list --label "in-progress" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
READY=$(gh issue list --label "ready" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
TRIAGE=$(gh issue list --label "triage" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
CRITICAL=$(gh issue list --label "priority:critical" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
HIGH=$(gh issue list --label "priority:high" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")

# Issues opened/closed in last 7 days (velocity)
OPENED_7D=$(gh issue list --state all --json createdAt --limit 500 2>/dev/null | jq "[.[] | select(.createdAt > \"$(date -v-7d +%Y-%m-%dT%H:%M:%SZ)\")] | length" 2>/dev/null || echo "0")
CLOSED_7D=$(gh issue list --state closed --json closedAt --limit 500 2>/dev/null | jq "[.[] | select(.closedAt > \"$(date -v-7d +%Y-%m-%dT%H:%M:%SZ)\")] | length" 2>/dev/null || echo "0")
VELOCITY=$((CLOSED_7D - OPENED_7D))

# Issue age tracking - oldest open issues
OLDEST_ISSUE=""
STALE_COUNT=0
if command -v gh &> /dev/null; then
    # Get oldest issue age in days
    OLDEST_DATE=$(gh issue list --state open --json createdAt --limit 1 --jq '.[0].createdAt' 2>/dev/null || echo "")
    if [[ -n "$OLDEST_DATE" ]]; then
        OLDEST_DAYS=$(( ($(date +%s) - $(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$OLDEST_DATE" +%s 2>/dev/null || echo $(date +%s))) / 86400 ))
        OLDEST_ISSUE="$OLDEST_DAYS days"
    fi
    # Count stale issues (>30 days old)
    STALE_COUNT=$(gh issue list --state open --json createdAt 2>/dev/null | jq "[.[] | select(.createdAt < \"$(date -v-30d +%Y-%m-%dT%H:%M:%SZ)\")] | length" 2>/dev/null || echo "0")
fi

# Test count and trend (from metrics CSV)
TEST_COUNT="0"
TEST_TREND=""
if [[ -f ".claude-team/metrics/test-counts.csv" ]]; then
    TEST_COUNT=$(tail -1 .claude-team/metrics/test-counts.csv | cut -d',' -f3)
    # Get first and last to calculate trend
    FIRST_COUNT=$(sed -n '2p' .claude-team/metrics/test-counts.csv | cut -d',' -f3)
    if [[ -n "$FIRST_COUNT" ]] && [[ "$FIRST_COUNT" -gt 0 ]]; then
        TEST_DIFF=$((TEST_COUNT - FIRST_COUNT))
        if [[ $TEST_DIFF -gt 0 ]]; then
            TEST_TREND="↑+${TEST_DIFF}"
        elif [[ $TEST_DIFF -lt 0 ]]; then
            TEST_TREND="↓${TEST_DIFF}"
        fi
    fi
else
    TEST_COUNT="855"
fi

# ═══════════════════════════════════════════════════════════════════════════
# QUICK WINS DATA (Sprint, Alerts, Heartbeat, Branch)
# ═══════════════════════════════════════════════════════════════════════════

# Sprint Progress (from SPRINT_STATUS.md)
SPRINT_NAME=""
SPRINT_DONE=0
SPRINT_TOTAL=0
if [[ -f ".claude-team/SPRINT_STATUS.md" ]]; then
    SPRINT_NAME=$(grep -m1 "^# Sprint:" .claude-team/SPRINT_STATUS.md 2>/dev/null | sed 's/# Sprint: //' | tr -d '\n' || echo "")
    # Count tasks with ✅ COMPLETED in the phase tables
    SPRINT_DONE=$(grep -E "^\| [0-9]+.*✅" .claude-team/SPRINT_STATUS.md 2>/dev/null | wc -l | tr -d ' ')
    # Count all task rows (lines starting with | followed by a number)
    SPRINT_TOTAL=$(grep -E "^\| [0-9]+" .claude-team/SPRINT_STATUS.md 2>/dev/null | wc -l | tr -d ' ')
fi

# Recent Alerts (last 3 from ALERTS.md)
RECENT_ALERTS=""
if [[ -f ".claude-team/ALERTS.md" ]]; then
    RECENT_ALERTS=$(grep -E "^⚠️|^🔄" .claude-team/ALERTS.md 2>/dev/null | tail -3)
fi

# Worker Heartbeat (time since task files were modified)
WORKER_HEARTBEAT=""
if [[ -d ".claude-team/tasks" ]]; then
    NEWEST_TASK=$(find .claude-team/tasks -name "TASK_DEV*.md" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1)
    if [[ -n "$NEWEST_TASK" ]]; then
        TASK_TIME=$(echo "$NEWEST_TASK" | cut -d' ' -f1)
        TASK_FILE=$(echo "$NEWEST_TASK" | cut -d' ' -f2 | xargs basename)
        NOW=$(date +%s)
        MINS_AGO=$(( (NOW - TASK_TIME) / 60 ))
        if [[ $MINS_AGO -lt 60 ]]; then
            WORKER_HEARTBEAT="${MINS_AGO}m ago (${TASK_FILE})"
        else
            HOURS_AGO=$(( MINS_AGO / 60 ))
            WORKER_HEARTBEAT="${HOURS_AGO}h ago (${TASK_FILE})"
        fi
    fi
fi

# Branch Info (current branch, ahead/behind)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
BRANCH_STATUS=""
if [[ "$QUICK_MODE" != true ]]; then
    git fetch origin --quiet 2>/dev/null
    AHEAD=$(git rev-list --count origin/${CURRENT_BRANCH}..HEAD 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count HEAD..origin/${CURRENT_BRANCH} 2>/dev/null || echo "0")
    if [[ "$AHEAD" -gt 0 ]] && [[ "$BEHIND" -gt 0 ]]; then
        BRANCH_STATUS="↑${AHEAD} ↓${BEHIND}"
    elif [[ "$AHEAD" -gt 0 ]]; then
        BRANCH_STATUS="↑${AHEAD} ahead"
    elif [[ "$BEHIND" -gt 0 ]]; then
        BRANCH_STATUS="↓${BEHIND} behind"
    else
        BRANCH_STATUS="✓ synced"
    fi
fi

# CI status and build success rate
CI_STATUS="❌"
CI_TEXT="Not configured"
CI_SUCCESS_RATE=""
CI_COLOR=$RED

if [[ -f ".github/workflows/ci.yml" ]]; then
    # Fetch last 20 workflow runs to calculate success rate
    if command -v gh &> /dev/null && [[ "$QUICK_MODE" != true ]]; then
        RUNS_JSON=$(gh run list --limit 20 --json status,conclusion 2>/dev/null || echo "[]")
        if [[ "$RUNS_JSON" != "[]" ]]; then
            TOTAL_RUNS=$(echo "$RUNS_JSON" | jq 'length' 2>/dev/null || echo 0)
            if [[ $TOTAL_RUNS -gt 0 ]]; then
                SUCCESS_RUNS=$(echo "$RUNS_JSON" | jq '[.[] | select(.conclusion == "success")] | length' 2>/dev/null || echo 0)
                SUCCESS_RATE=$(( (SUCCESS_RUNS * 100) / TOTAL_RUNS ))

                # Set color based on success rate
                if [[ $SUCCESS_RATE -ge 90 ]]; then
                    CI_COLOR=$GREEN
                elif [[ $SUCCESS_RATE -ge 70 ]]; then
                    CI_COLOR=$YELLOW
                else
                    CI_COLOR=$RED
                fi

                CI_STATUS="✅"
                CI_TEXT="${SUCCESS_RATE}% ($SUCCESS_RUNS/$TOTAL_RUNS passed)"
                CI_SUCCESS_RATE=$SUCCESS_RATE
            else
                CI_STATUS="✅"
                CI_TEXT="No recent runs"
            fi
        else
            CI_STATUS="✅"
            CI_TEXT="Configured"
        fi
    else
        CI_STATUS="✅"
        CI_TEXT="Configured"
    fi
fi

# Build check (actual xcodebuild verification)
BUILD_STATUS="⏭️"
BUILD_TEXT="Skipped"
BUILD_COLOR=$YELLOW

if [[ "$QUICK_MODE" != true ]] && [[ -f "CloudSyncApp.xcodeproj/project.pbxproj" ]]; then
    BUILD_OUTPUT=$(xcodebuild build -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | tail -5)
    if echo "$BUILD_OUTPUT" | grep -q "BUILD SUCCEEDED"; then
        BUILD_STATUS="✅"
        BUILD_TEXT="Passing"
        BUILD_COLOR=$GREEN
    else
        BUILD_STATUS="❌"
        BUILD_TEXT="Failing"
        BUILD_COLOR=$RED
    fi
fi

# Version check
VERSION_OK="✅"
if ! ./scripts/version-check.sh > /dev/null 2>&1; then
    VERSION_OK="❌"
fi

# Worker status from STATUS.md
WORKERS_ACTIVE=$(grep -c "🔄" "$PROJECT_ROOT/.claude-team/STATUS.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
WORKERS_IDLE=$(grep -c "💤" "$PROJECT_ROOT/.claude-team/STATUS.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
[[ -z "$WORKERS_ACTIVE" ]] && WORKERS_ACTIVE=0
[[ -z "$WORKERS_IDLE" ]] && WORKERS_IDLE=0
WORKERS_TOTAL=$((WORKERS_ACTIVE + WORKERS_IDLE))

# Output files accumulation
OUTPUT_FILES=$(find "$PROJECT_ROOT/.claude-team/outputs" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

# ═══════════════════════════════════════════════════════════════════════════
# HEALTH SCORE CALCULATION
# ═══════════════════════════════════════════════════════════════════════════

HEALTH_SCORE=100
HEALTH_ISSUES=""

# Deductions
# CI health deductions
if [[ "$CI_STATUS" == "❌" ]]; then
    HEALTH_SCORE=$((HEALTH_SCORE - 15))
    HEALTH_ISSUES+="No CI pipeline. "
elif [[ -n "$CI_SUCCESS_RATE" ]] && [[ "$CI_SUCCESS_RATE" -lt 90 ]]; then
    if [[ "$CI_SUCCESS_RATE" -lt 70 ]]; then
        HEALTH_SCORE=$((HEALTH_SCORE - 10))
        HEALTH_ISSUES+="CI build rate low (${CI_SUCCESS_RATE}%). "
    else
        HEALTH_SCORE=$((HEALTH_SCORE - 5))
        HEALTH_ISSUES+="CI build rate warning (${CI_SUCCESS_RATE}%). "
    fi
fi
[[ "$BUILD_STATUS" == "❌" ]] && HEALTH_SCORE=$((HEALTH_SCORE - 20)) && HEALTH_ISSUES+="Build failing! "
[[ "$VERSION_OK" == "❌" ]] && HEALTH_SCORE=$((HEALTH_SCORE - 10)) && HEALTH_ISSUES+="Version mismatch. "
[[ "$CRITICAL" -gt 0 ]] && HEALTH_SCORE=$((HEALTH_SCORE - 10)) && HEALTH_ISSUES+="$CRITICAL critical issues. "
[[ "$TRIAGE" -gt 10 ]] && HEALTH_SCORE=$((HEALTH_SCORE - 5)) && HEALTH_ISSUES+="Triage backlog ($TRIAGE). "
[[ "$UNCOMMITTED" -gt 5 ]] && HEALTH_SCORE=$((HEALTH_SCORE - 5)) && HEALTH_ISSUES+="Uncommitted changes ($UNCOMMITTED). "
[[ "$OUTPUT_FILES" -gt 20 ]] && HEALTH_SCORE=$((HEALTH_SCORE - 5)) && HEALTH_ISSUES+="Output files piling up ($OUTPUT_FILES). "
[[ "$VELOCITY" -lt -5 ]] && HEALTH_SCORE=$((HEALTH_SCORE - 10)) && HEALTH_ISSUES+="Negative velocity. "
[[ "$STALE_COUNT" -gt 5 ]] && HEALTH_SCORE=$((HEALTH_SCORE - 5)) && HEALTH_ISSUES+="$STALE_COUNT stale issues. "

# Health color
HEALTH_COLOR=$GREEN
[[ $HEALTH_SCORE -lt 80 ]] && HEALTH_COLOR=$YELLOW
[[ $HEALTH_SCORE -lt 60 ]] && HEALTH_COLOR=$RED

# Velocity indicator
VELOCITY_ICON="━"
VELOCITY_COLOR=$YELLOW
if [[ $VELOCITY -gt 0 ]]; then
    VELOCITY_ICON="↑"
    VELOCITY_COLOR=$GREEN
elif [[ $VELOCITY -lt 0 ]]; then
    VELOCITY_ICON="↓"
    VELOCITY_COLOR=$RED
fi

# ═══════════════════════════════════════════════════════════════════════════
# HEALTH HISTORY TRACKING
# ═══════════════════════════════════════════════════════════════════════════

HEALTH_HISTORY_FILE=".claude-team/metrics/health-history.csv"
HEALTH_TREND=""
HEALTH_PREV=""

# Create metrics directory if needed
mkdir -p .claude-team/metrics

# Create health history file with header if it doesn't exist
if [[ ! -f "$HEALTH_HISTORY_FILE" ]]; then
    echo "date,time,health_score,issues" > "$HEALTH_HISTORY_FILE"
fi

# Record current health score (once per hour max to avoid spam)
LAST_RECORD_TIME=$(tail -1 "$HEALTH_HISTORY_FILE" 2>/dev/null | cut -d',' -f1,2 | tr ',' 'T')
CURRENT_HOUR=$(date +%Y-%m-%dT%H)
if [[ "$LAST_RECORD_TIME" != "$CURRENT_HOUR"* ]] && [[ -n "$HEALTH_SCORE" ]]; then
    echo "$(date +%Y-%m-%d),$(date +%H:%M),$HEALTH_SCORE,\"${HEALTH_ISSUES:-none}\"" >> "$HEALTH_HISTORY_FILE"
fi

# Calculate health trend (compare to 24 hours ago if available)
if [[ -f "$HEALTH_HISTORY_FILE" ]]; then
    LINE_COUNT=$(wc -l < "$HEALTH_HISTORY_FILE" | tr -d ' ')
    if [[ $LINE_COUNT -gt 1 ]]; then
        # Get previous score (second to last line)
        HEALTH_PREV=$(tail -2 "$HEALTH_HISTORY_FILE" | head -1 | cut -d',' -f3)
        if [[ -n "$HEALTH_PREV" ]] && [[ "$HEALTH_PREV" =~ ^[0-9]+$ ]]; then
            HEALTH_DIFF=$((HEALTH_SCORE - HEALTH_PREV))
            if [[ $HEALTH_DIFF -gt 0 ]]; then
                HEALTH_TREND="↑+${HEALTH_DIFF}"
            elif [[ $HEALTH_DIFF -lt 0 ]]; then
                HEALTH_TREND="↓${HEALTH_DIFF}"
            else
                HEALTH_TREND="━"
            fi
        fi
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# OPEN PULL REQUESTS
# ═══════════════════════════════════════════════════════════════════════════

OPEN_PRS=0
PR_DETAILS=""
if command -v gh &> /dev/null; then
    PR_JSON=$(gh pr list --state open --json number,title,author --limit 5 2>/dev/null || echo "[]")
    OPEN_PRS=$(echo "$PR_JSON" | jq 'length' 2>/dev/null || echo "0")
    if [[ "$OPEN_PRS" -gt 0 ]]; then
        PR_DETAILS=$(echo "$PR_JSON" | jq -r '.[] | "#\(.number) \(.title | .[0:30])"' 2>/dev/null | head -3)
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# DISPLAY DASHBOARD
# ═══════════════════════════════════════════════════════════════════════════

clear 2>/dev/null || true

echo ""
echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║              CLOUDSYNC ULTRA — COMMAND CENTER                             ║${NC}"
echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"

# Health Score Bar
echo ""
echo -e "${BOLD}   HEALTH SCORE${NC}"
echo -ne "   "
FILLED=$((HEALTH_SCORE / 5))
EMPTY=$((20 - FILLED))
echo -ne "${HEALTH_COLOR}"
for ((i=0; i<FILLED; i++)); do echo -ne "█"; done
echo -ne "${DIM}"
for ((i=0; i<EMPTY; i++)); do echo -ne "░"; done
HEALTH_DISPLAY="${HEALTH_SCORE}%"
[[ -n "$HEALTH_TREND" ]] && HEALTH_DISPLAY="${HEALTH_SCORE}% ${HEALTH_TREND}"
echo -e "${NC} ${HEALTH_COLOR}${BOLD}${HEALTH_DISPLAY}${NC}"

if [[ -n "$HEALTH_ISSUES" ]]; then
    echo -e "   ${DIM}Issues: ${HEALTH_ISSUES}${NC}"
fi

echo ""
echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"

# Three Column Layout
echo ""
printf "${BOLD}   %-25s %-25s %-25s${NC}\n" "📦 RELEASE" "🧪 QUALITY" "📈 VELOCITY"
echo -e "${DIM}   ─────────────────────── ─────────────────────── ───────────────────────${NC}"
TEST_DISPLAY="$TEST_COUNT ✅"
[[ -n "$TEST_TREND" ]] && TEST_DISPLAY="$TEST_COUNT $TEST_TREND"
printf "   Version:    ${GREEN}%-13s${NC} Tests:     ${GREEN}%-13s${NC} 7-Day:     ${VELOCITY_COLOR}%s %+d${NC}\n" "v$VERSION" "$TEST_DISPLAY" "$VELOCITY_ICON" "$VELOCITY"
printf "   Tag:        ${CYAN}%-13s${NC} Build:     ${BUILD_COLOR}%-13s${NC} Opened:    %-13s\n" "$LATEST_TAG" "$BUILD_TEXT $BUILD_STATUS" "$OPENED_7D"
printf "   Versions:   %-13s CI:        ${CI_COLOR}%-20s${NC} Closed:    ${GREEN}%-13s${NC}\n" "$VERSION_OK" "$CI_STATUS $CI_TEXT" "$CLOSED_7D"

echo ""
echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"
echo ""

printf "${BOLD}   %-25s %-25s %-25s${NC}\n" "📋 ISSUES" "👥 WORKERS" "🔧 STATUS"
echo -e "${DIM}   ─────────────────────── ─────────────────────── ───────────────────────${NC}"
printf "   Open:       %-13s Active:    ${YELLOW}%-13s${NC} Commits today: %-8s\n" "$OPEN_ISSUES" "$WORKERS_ACTIVE" "$COMMITS_TODAY"
printf "   Critical:   ${RED}%-13s${NC} Idle:      ${DIM}%-13s${NC} Uncommitted:   %-8s\n" "$CRITICAL" "$WORKERS_IDLE" "$UNCOMMITTED"
printf "   High:       ${YELLOW}%-13s${NC} Total:     %-13s Output files:  %-8s\n" "$HIGH" "$WORKERS_TOTAL" "$OUTPUT_FILES"
printf "   Ready:      ${GREEN}%-13s${NC}                           Oldest issue:  %-8s\n" "$READY" "${OLDEST_ISSUE:-N/A}"
PR_COLOR=$NC
[[ "$OPEN_PRS" -gt 0 ]] && PR_COLOR=$CYAN
printf "   Triage:     ${RED}%-13s${NC}                           Open PRs:      ${PR_COLOR}%-8s${NC}\n" "$TRIAGE" "$OPEN_PRS"
printf "   In Progress:${DIM}%-13s${NC}                           Stale (>30d):  %-8s\n" "$IN_PROGRESS" "$STALE_COUNT"

echo ""
echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"
echo ""

# Sprint & Git Section
printf "${BOLD}   %-25s %-50s${NC}\n" "🏃 SPRINT" "🌿 GIT"
echo -e "${DIM}   ─────────────────────── ──────────────────────────────────────────────────${NC}"
if [[ -n "$SPRINT_NAME" ]]; then
    SPRINT_PROGRESS=""
    if [[ $SPRINT_TOTAL -gt 0 ]]; then
        SPRINT_PROGRESS="($SPRINT_DONE/$SPRINT_TOTAL done)"
    fi
    printf "   %-25s Branch:    %-40s\n" "$SPRINT_NAME" "$CURRENT_BRANCH"
    printf "   Progress:   %-13s Remote:    %-40s\n" "$SPRINT_PROGRESS" "${BRANCH_STATUS:-checking...}"
else
    printf "   %-25s Branch:    %-40s\n" "No active sprint" "$CURRENT_BRANCH"
    printf "   %-25s Remote:    %-40s\n" "" "${BRANCH_STATUS:-checking...}"
fi
if [[ -n "$WORKER_HEARTBEAT" ]]; then
    printf "   Heartbeat:  %-60s\n" "$WORKER_HEARTBEAT"
fi

# Recent Alerts
if [[ -n "$RECENT_ALERTS" ]]; then
    echo ""
    echo -e "${DIM}   Recent alerts:${NC}"
    echo "$RECENT_ALERTS" | while read -r alert; do
        echo -e "   ${DIM}$alert${NC}"
    done
fi

echo ""
echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"

# Alerts Section
echo ""
echo -e "${BOLD}   ⚡ NEEDS ATTENTION${NC}"
echo ""

ALERT_COUNT=0

if [[ "$BUILD_STATUS" == "❌" ]]; then
    echo -e "   ${RED}●${NC} BUILD FAILING - fix immediately before shipping"
    ((ALERT_COUNT++))
fi

if [[ "$CRITICAL" -gt 0 ]]; then
    echo -e "   ${RED}●${NC} $CRITICAL critical issue(s) need immediate attention"
    ((ALERT_COUNT++))
fi

if [[ "$CI_STATUS" == "❌" ]]; then
    echo -e "   ${YELLOW}●${NC} CI pipeline not configured - broken builds can ship"
    ((ALERT_COUNT++))
fi

if [[ "$VERSION_OK" == "❌" ]]; then
    echo -e "   ${YELLOW}●${NC} Version mismatch in documentation"
    ((ALERT_COUNT++))
fi

if [[ "$TRIAGE" -gt 10 ]]; then
    echo -e "   ${YELLOW}●${NC} $TRIAGE issues need triage - backlog growing"
    ((ALERT_COUNT++))
fi

if [[ "$IN_PROGRESS" -eq 0 ]] && [[ "$WORKERS_ACTIVE" -eq 0 ]]; then
    echo -e "   ${BLUE}●${NC} No work in progress - ready for next sprint"
    ((ALERT_COUNT++))
fi

if [[ "$UNCOMMITTED" -gt 5 ]]; then
    echo -e "   ${YELLOW}●${NC} $UNCOMMITTED uncommitted changes"
    ((ALERT_COUNT++))
fi

if [[ "$OUTPUT_FILES" -gt 20 ]]; then
    echo -e "   ${DIM}●${NC} $OUTPUT_FILES output reports - consider archiving"
    ((ALERT_COUNT++))
fi

if [[ "$STALE_COUNT" -gt 5 ]]; then
    echo -e "   ${YELLOW}●${NC} $STALE_COUNT stale issues (>30 days) need attention"
    ((ALERT_COUNT++))
fi

if [[ "$OPEN_PRS" -gt 0 ]]; then
    echo -e "   ${CYAN}●${NC} $OPEN_PRS open pull request(s) awaiting review"
    ((ALERT_COUNT++))
fi

if [[ $ALERT_COUNT -eq 0 ]]; then
    echo -e "   ${GREEN}✓${NC} All clear - project is healthy"
fi

echo ""
echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"

# Last Activity
echo ""
echo -e "${DIM}   Last commit: $LAST_COMMIT $LAST_COMMIT_MSG ($LAST_COMMIT_AGO)${NC}"
echo ""

# Quick Commands
echo -e "${DIM}   Commands: ./scripts/release.sh X.X.X │ gh issue list │ cat .claude-team/STATUS.md${NC}"
echo ""
