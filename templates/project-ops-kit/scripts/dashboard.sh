#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Command Center Dashboard                                                  ║
# ║  One-glance project health with automatic alerts                          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load project config
source "$PROJECT_ROOT/project.conf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

cd "$PROJECT_ROOT"

# ─────────────────────────────────────────────────────────────────────────────
# GATHER METRICS
# ─────────────────────────────────────────────────────────────────────────────

VERSION=$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]' || echo "0.0.0")
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Git stats
LAST_COMMIT=$(git log -1 --format="%h %s" 2>/dev/null | cut -c1-50 || echo "none")
LAST_COMMIT_AGO=$(git log -1 --format="%cr" 2>/dev/null || echo "unknown")
COMMITS_TODAY=$(git log --since="midnight" --oneline 2>/dev/null | wc -l | tr -d ' ')
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# Issue counts (GitHub)
OPEN_ISSUES=$(gh issue list --state open --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
CRITICAL=$(gh issue list --label "priority:critical" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
HIGH=$(gh issue list --label "priority:high" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
READY=$(gh issue list --label "ready" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
TRIAGE=$(gh issue list --label "triage" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
IN_PROGRESS=$(gh issue list --label "in-progress" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")

# Velocity (7-day)
OPENED_7D=$(gh issue list --state all --json createdAt 2>/dev/null | jq "[.[] | select(.createdAt > \"$(date -v-7d +%Y-%m-%d)\")] | length" 2>/dev/null || echo "0")
CLOSED_7D=$(gh issue list --state closed --json closedAt 2>/dev/null | jq "[.[] | select(.closedAt > \"$(date -v-7d +%Y-%m-%d)\")] | length" 2>/dev/null || echo "0")
VELOCITY=$((CLOSED_7D - OPENED_7D))

# Workers
WORKERS_ACTIVE=$(grep -c "🔄" "$PROJECT_ROOT/.claude-team/STATUS.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
WORKERS_IDLE=$(grep -c "💤" "$PROJECT_ROOT/.claude-team/STATUS.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
[[ -z "$WORKERS_ACTIVE" ]] && WORKERS_ACTIVE=0
[[ -z "$WORKERS_IDLE" ]] && WORKERS_IDLE=0
WORKERS_TOTAL=$((WORKERS_ACTIVE + WORKERS_IDLE))

# Output files
OUTPUT_FILES=$(find "$PROJECT_ROOT/.claude-team/outputs" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

# CI status
CI_CONFIGURED="❌ Not configured"
[[ -f "$PROJECT_ROOT/$CI_WORKFLOW" ]] && CI_CONFIGURED="✅ Configured"

# Version check
VERSION_OK="✅"
./scripts/version-check.sh > /dev/null 2>&1 || VERSION_OK="❌"

# Build status (from last CI run if available)
BUILD_STATUS="${GREEN}Unknown${NC}"
LAST_RUN=$(gh run list --limit 1 --json conclusion 2>/dev/null | jq -r '.[0].conclusion' 2>/dev/null || echo "unknown")
[[ "$LAST_RUN" == "success" ]] && BUILD_STATUS="${GREEN}Passing ✅${NC}"
[[ "$LAST_RUN" == "failure" ]] && BUILD_STATUS="${RED}Failing ❌${NC}"

# Test count (from project config or detected)
TEST_COUNT="?"

# ─────────────────────────────────────────────────────────────────────────────
# CALCULATE HEALTH SCORE
# ─────────────────────────────────────────────────────────────────────────────

HEALTH=100
HEALTH_ISSUES=""

[[ "$CI_CONFIGURED" == *"❌"* ]] && { HEALTH=$((HEALTH - 15)); HEALTH_ISSUES+="No CI. "; }
[[ "$VERSION_OK" == "❌" ]] && { HEALTH=$((HEALTH - 10)); HEALTH_ISSUES+="Version mismatch. "; }
[[ "$CRITICAL" -gt 0 ]] && { HEALTH=$((HEALTH - 10)); HEALTH_ISSUES+="$CRITICAL critical issues. "; }
[[ "$TRIAGE" -gt ${TRIAGE_THRESHOLD:-10} ]] && { HEALTH=$((HEALTH - 5)); HEALTH_ISSUES+="Triage backlog ($TRIAGE). "; }
[[ "$UNCOMMITTED" -gt ${UNCOMMITTED_THRESHOLD:-5} ]] && { HEALTH=$((HEALTH - 5)); HEALTH_ISSUES+="Uncommitted changes ($UNCOMMITTED). "; }
[[ "$OUTPUT_FILES" -gt ${OUTPUT_FILE_THRESHOLD:-20} ]] && { HEALTH=$((HEALTH - 5)); HEALTH_ISSUES+="Output files piling up ($OUTPUT_FILES). "; }
[[ "$VELOCITY" -lt 0 ]] && { HEALTH=$((HEALTH - 10)); HEALTH_ISSUES+="Negative velocity. "; }

[[ $HEALTH -lt 0 ]] && HEALTH=0

# Health bar
HEALTH_BAR=""
FILLED=$((HEALTH / 5))
EMPTY=$((20 - FILLED))
for ((i=0; i<FILLED; i++)); do HEALTH_BAR+="█"; done
for ((i=0; i<EMPTY; i++)); do HEALTH_BAR+="░"; done

HEALTH_COLOR=$GREEN
[[ $HEALTH -lt 80 ]] && HEALTH_COLOR=$YELLOW
[[ $HEALTH -lt 60 ]] && HEALTH_COLOR=$RED

# Velocity indicator
VELOCITY_INDICATOR="${YELLOW}━ +0${NC}"
[[ $VELOCITY -gt 0 ]] && VELOCITY_INDICATOR="${GREEN}↑ +$VELOCITY${NC}"
[[ $VELOCITY -lt 0 ]] && VELOCITY_INDICATOR="${RED}↓ $VELOCITY${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# DISPLAY
# ─────────────────────────────────────────────────────────────────────────────

clear
echo ""
echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║              ${PROJECT_NAME^^} — COMMAND CENTER                             ║${NC}"
echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Health Score
echo -e "${BOLD}   HEALTH SCORE${NC}"
echo -e "   ${HEALTH_COLOR}${HEALTH_BAR}${NC} ${HEALTH_COLOR}${BOLD}${HEALTH}%${NC}"
[[ -n "$HEALTH_ISSUES" ]] && echo -e "   ${DIM}Issues: ${HEALTH_ISSUES}${NC}"
echo ""

echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"
echo ""

# Three columns
echo -e "${BOLD}   📦 RELEASE              🧪 QUALITY              📈 VELOCITY            ${NC}"
echo -e "${DIM}   ─────────────────────── ─────────────────────── ───────────────────────${NC}"
printf "   Version:    ${GREEN}%-13s${NC} Tests:     ${GREEN}%-13s${NC} 7-Day:     %b\n" "v$VERSION" "$TEST_COUNT" "$VELOCITY_INDICATOR"
printf "   Tag:        ${CYAN}%-13s${NC} Build:     %b    Opened:    %-13s\n" "$LATEST_TAG" "$BUILD_STATUS" "$OPENED_7D"
printf "   Versions:   %-13s CI:        %-13s Closed:    ${GREEN}%-13s${NC}\n" "$VERSION_OK" "$CI_CONFIGURED" "$CLOSED_7D"
echo ""

echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"
echo ""

# Issues and Workers
echo -e "${BOLD}   📋 ISSUES               👥 WORKERS              🔧 STATUS              ${NC}"
echo -e "${DIM}   ─────────────────────── ─────────────────────── ───────────────────────${NC}"
printf "   Open:       %-13s Active:    ${YELLOW}%-13s${NC} Commits today: %-8s\n" "$OPEN_ISSUES" "$WORKERS_ACTIVE" "$COMMITS_TODAY"
printf "   Critical:   ${RED}%-13s${NC} Idle:      ${DIM}%-13s${NC} Uncommitted:   %-8s\n" "$CRITICAL" "$WORKERS_IDLE" "$UNCOMMITTED"
printf "   High:       ${YELLOW}%-13s${NC} Total:     %-13s Output files:  %-8s\n" "$HIGH" "$WORKERS_TOTAL" "$OUTPUT_FILES"
printf "   Ready:      ${GREEN}%-13s${NC}\n" "$READY"
printf "   Triage:     ${RED}%-13s${NC}\n" "$TRIAGE"
echo ""

echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"
echo ""

# Alerts
echo -e "${BOLD}   ⚡ NEEDS ATTENTION${NC}"
echo ""
ALERTS=0
[[ "$CRITICAL" -gt 0 ]] && { echo -e "   ${RED}●${NC} $CRITICAL critical issue(s) need immediate attention"; ALERTS=$((ALERTS+1)); }
[[ "$TRIAGE" -gt ${TRIAGE_THRESHOLD:-10} ]] && { echo -e "   ${YELLOW}●${NC} $TRIAGE issues need triage - backlog growing"; ALERTS=$((ALERTS+1)); }
[[ "$IN_PROGRESS" -eq 0 ]] && [[ "$WORKERS_ACTIVE" -eq 0 ]] && { echo -e "   ${BLUE}●${NC} No work in progress - ready for next sprint"; ALERTS=$((ALERTS+1)); }
[[ "$OUTPUT_FILES" -gt ${OUTPUT_FILE_THRESHOLD:-20} ]] && { echo -e "   ${DIM}●${NC} $OUTPUT_FILES output reports - consider archiving"; ALERTS=$((ALERTS+1)); }
[[ "$ALERTS" -eq 0 ]] && echo -e "   ${GREEN}●${NC} All clear!"
echo ""

echo -e "${BOLD}${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${DIM}   Last commit: $LAST_COMMIT ($LAST_COMMIT_AGO)${NC}"
echo ""
echo -e "${DIM}   Commands: ./scripts/release.sh X.X.X │ gh issue list │ cat .claude-team/STATUS.md${NC}"
echo ""
