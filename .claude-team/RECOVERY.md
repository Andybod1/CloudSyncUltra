# CloudSync Ultra - Crash Recovery Guide

> **All work is tracked via GitHub Issues** - survives any crash automatically.
> **Current Version:** v2.0.24
> **Last Updated:** 2026-01-15

---

## Quick Recovery (Copy-Paste Ready)

### For Strategic Partner (New Desktop Claude Chat)
```
Read these files to restore context for CloudSync Ultra:

1. /Users/antti/Claude/.claude-team/PROJECT_CONTEXT.md
2. /Users/antti/Claude/.claude-team/STATUS.md  
3. /Users/antti/Claude/CHANGELOG.md
4. /Users/antti/Claude/.claude-team/RECOVERY.md

Then tell me what state we're in and what needs to happen next.
```

---

## Immediate Steps After Crash

### 1. Check GitHub Issues (Your Work Queue)
```bash
cd ~/Claude

# What's in progress?
gh issue list -l in-progress

# What's ready to work?
gh issue list -l ready

# All open issues
gh issue list
```

### 2. Check Git Status
```bash
cd ~/Claude && git status --short

# If uncommitted work:
git add -A && git commit -m "WIP: Recovery after crash"
git push origin main
```

### 3. Verify Build Works
```bash
cd ~/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

## Team Architecture

### Core Team (5 Workers)
```
Strategic Partner (Desktop Claude - Opus 4.5)
    ├── Dev-1 (UI)       → Views, ViewModels, Components
    ├── Dev-2 (Engine)   → RcloneManager.swift
    ├── Dev-3 (Services) → Models, *Manager.swift
    ├── QA (Testing)     → CloudSyncAppTests/
    └── Dev-Ops          → Git, GitHub, Docs, Research
```

### Specialized Agents (On-Demand)
```
    ├── UX-Designer         → UI/UX analysis, user flows
    ├── Product-Manager     → Strategy, requirements, roadmap
    ├── Architect           → System design, refactoring
    ├── Security-Auditor    → Security review, vulnerabilities
    ├── Performance-Eng     → Deep optimization analysis
    ├── Tech-Writer         → Documentation, guides
    ├── Brand-Designer      → Brand identity, visual assets
    ├── QA-Automation       → UI tests, CI/CD, coverage
    └── Marketing-Strategist → Growth, ASO, campaigns
```

### Model Rules
| Agent Type | Model |
|------------|-------|
| Dev-1, Dev-2, Dev-3 | Sonnet XS/S, Opus M/L/XL |
| QA, Dev-Ops | **ALWAYS Opus + /think** |
| All Specialized | **ALWAYS Opus + /think hard** |

### Ticket Triage Process
When evaluating tickets, assign to specialized agents when appropriate:
- Implementation work → Core team
- UX/design questions → UX-Designer
- Strategy/roadmap → Product-Manager
- Architecture decisions → Architect
- Security concerns → Security-Auditor
- Performance analysis → Performance-Engineer
- Documentation → Tech-Writer

Full guide: `.claude-team/TRIAGE_GUIDE.md`

---

## Launch Workers

### Core Team
```bash
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-2 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-3 sonnet
~/Claude/.claude-team/scripts/launch_single_worker.sh qa opus
~/Claude/.claude-team/scripts/launch_single_worker.sh devops opus
```

### Specialized Agents
```bash
~/Claude/.claude-team/scripts/launch_single_worker.sh ux-designer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh product-manager opus
~/Claude/.claude-team/scripts/launch_single_worker.sh architect opus
~/Claude/.claude-team/scripts/launch_single_worker.sh security-auditor opus
~/Claude/.claude-team/scripts/launch_single_worker.sh performance-eng opus
~/Claude/.claude-team/scripts/launch_single_worker.sh tech-writer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh brand-designer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh qa-automation opus
~/Claude/.claude-team/scripts/launch_single_worker.sh marketing-strategist opus
```

---

## Startup Commands (Paste into Claude Code)

### Core Team
```
Dev-1: Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.

Dev-2: Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.

Dev-3: Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.

QA: Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.

Dev-Ops: Read /Users/antti/Claude/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.
```

### Specialized Agents
```
UX-Designer: Read /Users/antti/Claude/.claude-team/templates/UX_DESIGNER_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_UX_DESIGNER.md. Update STATUS.md as you work.

Product-Manager: Read /Users/antti/Claude/.claude-team/templates/PRODUCT_MANAGER_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_PRODUCT_MANAGER.md. Update STATUS.md as you work.

Architect: Read /Users/antti/Claude/.claude-team/templates/ARCHITECT_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_ARCHITECT.md. Update STATUS.md as you work.

Security-Auditor: Read /Users/antti/Claude/.claude-team/templates/SECURITY_AUDITOR_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_SECURITY_AUDITOR.md. Update STATUS.md as you work.

Performance-Engineer: Read /Users/antti/Claude/.claude-team/templates/PERFORMANCE_ENGINEER_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_PERFORMANCE_ENGINEER.md. Update STATUS.md as you work.

Tech-Writer: Read /Users/antti/Claude/.claude-team/templates/TECH_WRITER_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_TECH_WRITER.md. Update STATUS.md as you work.

Brand-Designer: Read /Users/antti/Claude/.claude-team/templates/BRAND_DESIGNER_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_BRAND_DESIGNER.md. Update STATUS.md as you work.

QA-Automation: Read /Users/antti/Claude/.claude-team/templates/QA_AUTOMATION_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA_AUTOMATION.md. Update STATUS.md as you work.

Marketing-Strategist: Read /Users/antti/Claude/.claude-team/templates/MARKETING_STRATEGIST_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_MARKETING_STRATEGIST.md. Update STATUS.md as you work.
```

---

## Current State (v2.0.24)

### Just Completed: v2.0.24 "Launch Ready"
- ✅ **StoreKit 2 Subscriptions** (#46) - Free/Pro/Team tiers
- ✅ **Security Hardening** (#74) - Path sanitization, secure file handling
- ✅ **Legal Compliance** - Privacy Policy, ToS, GDPR/CCPA docs
- ✅ **Marketing Package** - Positioning, landing page, press kit
- ✅ **App Store Assets** (#78) - Description, keywords, metadata
- ✅ **841 tests** (831 passing, 10 expected failures)

### v2.0.22 Sprint
- ✅ Quick Actions Menu (#49) - Cmd+Shift+N shortcut
- ✅ Provider-Specific Chunk Sizes (#73)
- ✅ Transfer Preview (#55) - Dry-run support

### v2.0.17: Accessibility & Infrastructure
- VoiceOver labels + keyboard shortcuts
- OSLog replaced print() statements
- Help system (HelpManager)
- Onboarding infrastructure (OnboardingManager)

### v2.0.16: Performance & Security
- TransferOptimizer with dynamic parallelism
- App Sandbox enabled
- Path validation, secure temp files
- rclone.conf secured (0o600)

### Recent Completed
- v2.0.15: iCloud Phase 1, Crash reporting, UX audit
- v2.0.14: Performance 2x boost
- v2.0.13: Schedule time display, 12/24 hour setting
- v2.0.12: Sidebar reordering, bandwidth throttling

### Open Issues
| # | Title | Priority |
|---|-------|----------|
| #87 | Fix 11 failing unit tests | Critical |
| #80-83 | Onboarding sprint | High |
| #70 | Universal Dynamic Parallelism | High |
| #77 | Create App Icon Set | High |

---

## Key File Locations

```
/Users/antti/Claude/
├── CloudSyncApp/                 # Source code
├── CloudSyncAppTests/            # Tests (743 passing)
├── CLAUDE_PROJECT_KNOWLEDGE.md   # Claude context
├── .claude-team/
│   ├── STATUS.md                 # Live worker status
│   ├── TRIAGE_GUIDE.md           # Ticket assignment guide
│   ├── SPECIALIZED_AGENTS.md     # Agent roster
│   ├── RECOVERY.md               # This file
│   ├── tasks/TASK_*.md           # Active tasks
│   ├── outputs/*_COMPLETE.md     # Reports
│   ├── templates/*_BRIEFING.md   # All briefings
│   └── scripts/                  # Launch scripts
└── CHANGELOG.md
```

---

## Common Commands

```bash
# Build & Launch
cd ~/Claude && xcodebuild build 2>&1 | tail -5
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# Tests
xcodebuild test -destination 'platform=macOS' 2>&1 | grep "Executed"

# GitHub
gh issue list
gh issue view <number>

# Git
git status --short
git log --oneline -5
```

---

## Memory Reminders for Strategic Partner

1. **Triage tickets** → Use TRIAGE_GUIDE.md to assign core team OR specialized agents
2. **Delegate ALL implementation** to workers
3. **QA = Opus + /think | Specialized = Opus + /think hard**
4. **Ask Andy** if requirements unclear
5. **Update GitHub** after each sprint
6. **Update CHANGELOG.md** after each sprint

---

*Last Updated: 2026-01-14*
*CloudSync Ultra v2.0.24*
