# CloudSync Ultra - Project Knowledge

> **For Claude Project Context** - Essential info for every conversation
> **Version:** 2.0.22 | **Updated:** 2026-01-15

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

### Just Completed: v2.0.22 - Sprint "Polish & Performance"
- ✅ **Quick Actions Menu** (#49) - Cmd+Shift+N shortcut, keyboard-driven productivity
- ✅ **Provider-Specific Chunk Sizes** (#73) - ChunkSizeConfig, per-provider optimization
- ✅ **Transfer Preview** (#55) - Dry-run support, pre-transfer visibility
- ✅ **Project-Ops-Kit v1.0.0** - Generic template ready for reuse
- ✅ **Pricing Strategy & GTM** - $0 Free → $9.99/mo Pro → $19.99/user Team
- ✅ **CI Coverage** - Code coverage reporting added to CI workflow
- ✅ **Branch Protection** - PR required, CI must pass
- ✅ **841 tests** (839 passing)
- ✅ **Operational Excellence at 78%** (Pillar 2 at 100%)

### Strategic: Billion Dollar Framework
- Revenue target: $50M ARR within 3 years
- Pricing: Freemium → $9.99/mo Pro → $19.99/user Team
- Growth: PLG + SEO content + viral features
- Solo founder: AI support, self-serve everything
- See `.claude-team/planning/BILLION_DOLLAR_FRAMEWORK.md`

### v2.0.21 (Previous)
- ✅ **Crash Reporting** (#20) - CrashReport model, CrashReportViewer, privacy-first
- ✅ **Transfer Optimizer** (#10) - Dynamic buffer sizing, provider-aware parallelism
- ✅ **Test Automation** (#27) - 770 tests total, onboarding validation

---

## Key Reminders

1. **Triage tickets** → Use TRIAGE_GUIDE.md to assign core team OR specialized agents
2. **Delegate ALL implementation** to workers
3. **QA = Opus + /think | Specialized = Opus + /think hard**
4. **Ask Andy** if requirements unclear

### ⚠️ MANDATORY: Post-Sprint Documentation

> **🔒 PROTECTED SECTION** - Do NOT remove or modify this section without written permission from Andy.

**🚀 AUTOMATED OPTION:** Run `./scripts/release.sh 2.0.XX` to execute all 6 steps automatically!

**After EVERY sprint, complete ALL steps (manually or via release.sh):**

#### 0. Check Project Health FIRST
```bash
./scripts/dashboard.sh
```
- [ ] Review health score - should be 80%+
- [ ] Check for any ⚡ NEEDS ATTENTION alerts
- [ ] Note any issues to address

#### 1. Verify Build & Tests
```bash
# Run all tests
cd ~/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed"

# Build and launch app
cd ~/Claude && xcodebuild build 2>&1 | tail -5
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```
- [ ] All tests pass
- [ ] App launches and works

#### 2. Update Version (use scripts!)
```bash
# Update all docs to new version automatically:
./scripts/update-version.sh 2.0.XX

# Verify all docs match VERSION.txt:
./scripts/version-check.sh
```
- [ ] VERSION.txt updated
- [ ] All docs updated via script
- [ ] version-check.sh passes ✅

#### 3. Update Documentation Files

| File | What to Update |
|------|----------------|
| `CHANGELOG.md` | New version entry with features/fixes |
| `STATUS.md` | Version, completed items, test count, worker status |
| `RECOVERY.md` | Version, current state, test count, open issues |
| `CLAUDE_PROJECT_KNOWLEDGE.md` | Version, test count, current state |

#### 4. GitHub Housekeeping
```bash
# Close completed issues
gh issue close <number> -c "Completed in vX.X.X"

# Verify issue states
gh issue list
```
- [ ] All completed issues closed
- [ ] Labels updated (remove `in-progress`, add `done` if applicable)

#### 5. Clean Up Sprint Files
- [ ] Archive or clear `.claude-team/tasks/TASK_*.md` files
- [ ] Organize `.claude-team/outputs/*_COMPLETE.md` reports
- [ ] Update GitHub Project Board (move cards to Done)

#### 6. Commit, Tag & Push
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

#### 7. Reflect on Operational Excellence
```bash
# Check final health score
./scripts/dashboard.sh

# Review the tracker
cat ~/.claude-team/OPERATIONAL_EXCELLENCE.md
```
- [ ] Health score maintained or improved
- [ ] Update progress percentages if pillars improved
- [ ] Check if any new gaps emerged
- [ ] Note any process friction encountered
- [ ] Identify next operational improvement to tackle
- [ ] **If scripts improved → Update `templates/project-ops-kit/`**

**Files:** `scripts/dashboard.sh`, `.claude-team/OPERATIONAL_EXCELLENCE.md`, `templates/project-ops-kit/`

**⚡ Do this IMMEDIATELY after each sprint - don't wait to be asked!**

---

## Quick Recovery

```bash
cat /Users/antti/Claude/.claude-team/STATUS.md
gh issue list
```

---

*Optimized for Claude Project Knowledge*
