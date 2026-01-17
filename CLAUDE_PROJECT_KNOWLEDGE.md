# CloudSync Ultra - Project Knowledge

> **For Claude Project Context** - Essential info for every conversation
> **Version:** 2.0.34 | **Updated:** 2026-01-17

---

## Project Identity

| Key | Value |
|-----|-------|
| **App** | CloudSync Ultra - macOS cloud sync with 42 providers |
| **Tech** | SwiftUI + rclone |
| **Location** | `/Users/antti/Claude/` |
| **GitHub** | https://github.com/andybod1-lang/CloudSyncUltra |
| **Human** | Andy |

---

## What It Does

Syncs files between cloud services (Google Drive, Dropbox, Proton Drive, S3, etc.):
- Dual-pane file browser with drag & drop
- Per-remote encryption
- Scheduled sync (hourly/daily/weekly)
- Menu bar integration
- Bandwidth throttling
- 12/24 hour time format preference

---

## Team Architecture

### Core Team (5 Workers)
```
Strategic Partner (This Claude - Opus 4.5)
    ├── Dev-1 (UI)       → Views, ViewModels, Components
    ├── Dev-2 (Engine)   → RcloneManager.swift
    ├── Dev-3 (Services) → Models, *Manager.swift
    ├── QA (Testing)     → CloudSyncAppTests/
    └── Dev-Ops          → Git, GitHub, Docs, Research
```

### Specialized Agents (On-Demand)
```
    ├── UX-Designer      → UI/UX analysis, user flows
    ├── Product-Manager  → Strategy, requirements, roadmap
    ├── Architect        → System design, refactoring
    ├── Security-Auditor → Security review, vulnerabilities
    ├── Performance-Eng  → Deep optimization analysis
    └── Tech-Writer      → Documentation, guides
```

### Model Rules
| Agent Type | Model | /think |
|------------|-------|--------|
| Dev-1, Dev-2, Dev-3 | **Opus** | M/L/XL tickets or tricky implementations |
| QA, Dev-Ops | **Opus** | Always |
| All Specialized | **Opus** | Always (/think hard) |

**All workers use Opus.** Extended thinking (/think) is used for:
- M/L/XL sized tickets
- Tricky or complex implementations
- QA, Dev-Ops, and Specialized agents (always)

### Ticket Triage Process
When evaluating tickets, Strategic Partner decides assignment:
- **Implementation work** → Core team (Dev-1/2/3, QA, Dev-Ops)
- **Analysis/strategy/review** → Specialized agents

See `.claude-team/TRIAGE_GUIDE.md` for decision tree and examples.

---

## Worker Launch

> ⚠️ **IMPORTANT:** Always use the launch script - never launch workers manually via `claude` command directly. The script handles Terminal setup, briefing injection, and task assignment automatically.

```bash
# Core team (all use Opus)
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-2 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-3 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh qa opus
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-ops opus

# Specialized agents (all use Opus)
~/Claude/.claude-team/scripts/launch_single_worker.sh ux-designer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh product-manager opus
~/Claude/.claude-team/scripts/launch_single_worker.sh architect opus
~/Claude/.claude-team/scripts/launch_single_worker.sh security-auditor opus
~/Claude/.claude-team/scripts/launch_single_worker.sh revenue-engineer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh legal-advisor opus
~/Claude/.claude-team/scripts/launch_single_worker.sh marketing-lead opus
```

---

## File Structure

```
/Users/antti/Claude/
├── CloudSyncApp/                 # Source (SwiftUI)
├── CloudSyncAppTests/            # Tests (743 passing)
├── CloudSyncAppUITests/          # UI Tests (69 tests)
├── docs/                         # User documentation
├── .claude-team/
│   ├── STATUS.md                 # Live worker status
│   ├── TRIAGE_GUIDE.md           # Ticket assignment decisions
│   ├── SPECIALIZED_AGENTS.md     # Agent roster & usage
│   ├── tasks/TASK_*.md           # Active tasks
│   ├── outputs/*_COMPLETE.md     # Reports
│   ├── templates/*_BRIEFING.md   # Briefings
│   └── planning/*.md             # Feature plans
└── CHANGELOG.md
```

---

## Essential Commands

```bash
# Build & Launch
cd /Users/antti/Claude && xcodebuild build 2>&1 | tail -5
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# Tests
xcodebuild test -destination 'platform=macOS' 2>&1 | grep "Executed"

# GitHub
gh issue list
gh issue view <number>
```

---

## Current State

### Just Completed: v2.0.34 - Sprint "Bug Fix + Enterprise Providers"
- ✅ **Google Photos OAuth Fix** (#159) - Added read_only=true scope
- ✅ **Integration Studies Complete** - 5 provider research reports
  - SharePoint: Already works (MEDIUM for enterprise OAuth)
  - OneDrive Business: Already works (EASY)
  - Nextcloud: Already works via WebDAV (EASY)
  - MEGA: Needs 2FA field (MEDIUM)
  - Koofr: Already works (EASY)
- ✅ **Key Finding:** 4 of 5 providers need no code changes
- ✅ **855 tests** (0 unexpected failures)
- ✅ **Operational Excellence at 100%**

### Strategic: Billion Dollar Framework
- Revenue target: $50M ARR within 3 years
- Pricing: Freemium → $9.99/mo Pro → $19.99/user Team
- Growth: PLG + SEO content + viral features
- Solo founder: AI support, self-serve everything
- See `.claude-team/planning/BILLION_DOLLAR_FRAMEWORK.md`

### v2.0.27 (Previous)
- ✅ **Quick Actions Menu** (#49) - Cmd+Shift+N shortcut
- ✅ **Provider-Specific Chunk Sizes** (#73) - ChunkSizeConfig
- ✅ **Transfer Preview** (#55) - Dry-run support

---

## Key Reminders

1. **Launch workers via script** → `~/Claude/.claude-team/scripts/launch_single_worker.sh <worker> opus` (NEVER manually)
2. **Triage tickets** → Use TRIAGE_GUIDE.md to assign core team OR specialized agents
3. **Delegate ALL implementation** to workers
4. **QA = Opus + /think | Specialized = Opus + /think hard**
5. **Ask Andy** if requirements unclear

### ⚠️ MANDATORY: Post-Sprint Documentation

> **🔒 PROTECTED SECTION** - Do NOT remove or modify this section without written permission from Andy.

**🚀 AUTOMATED OPTION:** Run `./scripts/release.sh 2.0.XX` to execute steps 2-7 automatically!

**After EVERY sprint, complete ALL steps (manually or via release.sh):**

#### 1. Check Project Health FIRST
```bash
./scripts/dashboard.sh
```
- [ ] Review health score - should be 80%+
- [ ] Check for any ⚡ NEEDS ATTENTION alerts
- [ ] Note any issues to address

#### 2. Verify Build & Tests
```bash
# Run all tests
cd ~/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed"

# Build and launch app
cd ~/Claude && xcodebuild build 2>&1 | tail -5
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# Update test counts metric (use actual count from test output)
echo "$(date +%Y-%m-%d),2.0.XX,<TEST_COUNT>" >> .claude-team/metrics/test-counts.csv
```
- [ ] All tests pass
- [ ] App launches and works
- [ ] Test count added to `.claude-team/metrics/test-counts.csv`

#### 3. Update Version (use scripts!)
```bash
# Update all docs to new version automatically:
./scripts/update-version.sh 2.0.XX

# Verify all docs match VERSION.txt:
./scripts/version-check.sh
```
- [ ] VERSION.txt updated
- [ ] All docs updated via script
- [ ] version-check.sh passes ✅

#### 4. Update Documentation Files

| File | What to Update |
|------|----------------|
| `CHANGELOG.md` | New version entry with features/fixes |
| `STATUS.md` | Version, completed items, test count, worker status |
| `RECOVERY.md` | Version, current state, test count, open issues |
| `CLAUDE_PROJECT_KNOWLEDGE.md` | Version, test count, current state |

#### 5. GitHub Housekeeping
```bash
# Close completed issues
gh issue close <number> -c "Completed in vX.X.X"

# Verify issue states
gh issue list
```
- [ ] All completed issues closed
- [ ] Labels updated (remove `in-progress`, add `done` if applicable)

#### 6. Clean Up Sprint Files
- [ ] Archive or clear `.claude-team/tasks/TASK_*.md` files
- [ ] Organize `.claude-team/outputs/*_COMPLETE.md` reports
- [ ] Update GitHub Project Board (move cards to Done)

#### 7. Commit, Tag & Push
```bash
cd ~/Claude
git add -A
git commit -m "docs: Update documentation to vX.X.X"
git tag vX.X.X
git push --tags origin main
```
- [ ] Changes committed
- [ ] Version tagged
- [ ] Pushed to GitHub

#### 8. Reflect on Operational Excellence
```bash
# Check final health score
./scripts/dashboard.sh

# Review the tracker
cat .claude-team/OPERATIONAL_EXCELLENCE.md
```
- [ ] Health score maintained or improved
- [ ] Update progress percentages if pillars improved
- [ ] Check if any new gaps emerged
- [ ] Note any process friction encountered
- [ ] Identify next operational improvement to tackle
- [ ] **If scripts improved → Update `templates/project-ops-kit/`**

**Files:** `scripts/dashboard.sh`, `.claude-team/OPERATIONAL_EXCELLENCE.md`, `templates/project-ops-kit/`

#### 9. Sprint Retrospective
Quick reflection on the sprint to capture learnings:

| Question | Notes |
|----------|-------|
| **What went well?** | (successes, smooth processes, wins) |
| **What didn't go well?** | (friction, bugs, blockers, delays) |
| **What to improve?** | (process changes, tooling, documentation) |

- [ ] Noted 1-2 things that went well
- [ ] Identified any friction or issues encountered
- [ ] Captured improvement ideas for next sprint
- [ ] (Optional) Add retro notes to `.claude-team/retros/` if significant learnings

**Tip:** Keep it brief (2-3 min). Focus on actionable improvements, not blame.

#### 10. User-Facing Docs Check (Quarterly or Major Features)

| File | Check For |
|------|-----------|
| `README.md` | Feature list, provider count, build instructions |
| `GETTING_STARTED.md` | Onboarding flow, prerequisites, first steps |
| `PROJECT_OVERVIEW.md` | Architecture, feature highlights, provider count |
| `QUICKSTART.md` | Current workflows, keyboard shortcuts |
| `DEVELOPMENT.md` | Architecture diagrams, new components, test count |

- [ ] Provider count accurate (currently 42+)?
- [ ] New major features documented?
- [ ] Screenshots current (if any)?
- [ ] **If outdated → Create Tech-Writer task**

**Trigger:** Run this check when sprint includes user-facing features or quarterly.

**⚡ Do this IMMEDIATELY after each sprint - don't wait to be asked!**

#### 11. Daily Documentation Update (End of Day)

> **🔒 MANDATORY** - Update these files at the end of EVERY working day.

| File | What to Update |
|------|----------------|
| `CLAUDE_PROJECT_KNOWLEDGE.md` | Current state, recent changes, version |
| `DEVELOPMENT.md` | New components, architecture changes, test count |
| `GETTING_STARTED.md` | Setup steps, prerequisites, first-run flow |
| `PROJECT_OVERVIEW.md` | Feature list, architecture highlights |
| `QUICKSTART.md` | Common workflows, keyboard shortcuts |
| `README.md` | Feature list, badges, quick start |
| `RECOVERY.md` | Current state, open issues, recovery steps |
| `SETUP.md` | Installation, configuration, dependencies |
| `STATUS.md` | Current work state, what's in progress, blockers |
| `project.json` | Version, stats (tests, providers), updated date |
| `CONTRIBUTING.md` | Test count, prerequisites, coverage stats |
| `templates/project-ops-kit/` | Sync operational docs to template |

**Daily Checklist:**
- [ ] Review what changed today
- [ ] Update affected documentation files
- [ ] Ensure version numbers are consistent
- [ ] Commit documentation updates

**Why Daily?** Documentation debt compounds quickly. Small daily updates prevent large outdated docs.

---

#### Worker Workflow (Important!)

**Development Workers (Dev-1, Dev-2, Dev-3):**
```bash
# Launch via external terminal - NOT as subagents
.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
```
- Run in separate terminal sessions
- Handle sprint development tasks
- Follow Worker Quality Standards v2.1

**Strategic Partner Assistants (Subagents):**
```
# Use Task tool for SP's own parallel work
Task tool with subagent_type="general-purpose"
```
- Research, analysis, exploration
- File archiving, codebase searches
- NOT for development tasks

**Key distinction:** External workers = development team. Subagents = SP's assistants.

---

## Quick Recovery

```bash
cat /Users/antti/Claude/.claude-team/STATUS.md
gh issue list
```

---

*Optimized for Claude Project Knowledge*
