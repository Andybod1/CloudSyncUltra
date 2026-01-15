# PROJECT_NAME - Project Knowledge

> **For Claude Project Context** - Essential info for every conversation
> **Version:** X.X.X | **Updated:** YYYY-MM-DD

---

## Project Identity

| Key | Value |
|-----|-------|
| **App** | PROJECT_NAME - DESCRIPTION |
| **Tech** | FRAMEWORK + BACKEND |
| **Location** | `/path/to/project/` |
| **GitHub** | https://github.com/USER/REPO |
| **Human** | NAME |

---

## What It Does

Brief description of what the project does:
- Feature 1
- Feature 2
- Feature 3

---

## Team Architecture

### Core Team (5 Workers)
```
Strategic Partner (This Claude - Opus 4.5)
    ├── Dev-1 (UI)       → Views, Components
    ├── Dev-2 (Engine)   → Core logic
    ├── Dev-3 (Services) → Models, Services
    ├── QA (Testing)     → Tests/
    └── Dev-Ops          → Git, GitHub, Docs
```

### Specialized Agents (On-Demand)
```
    ├── UX-Designer      → UI/UX analysis
    ├── Product-Manager  → Strategy, requirements
    ├── Architect        → System design
    ├── Security-Auditor → Security review
    ├── Performance-Eng  → Optimization
    └── Tech-Writer      → Documentation
```

### Model Rules
| Agent Type | Model | /think |
|------------|-------|--------|
| Dev-1, Dev-2, Dev-3 | **Opus** | M/L/XL tickets |
| QA, Dev-Ops | **Opus** | Always |
| Specialized | **Opus** | Always |

---

## Worker Launch

```bash
# Core team
~/.claude-team/scripts/launch_single_worker.sh dev-1 opus
~/.claude-team/scripts/launch_single_worker.sh dev-2 opus
~/.claude-team/scripts/launch_single_worker.sh dev-3 opus
~/.claude-team/scripts/launch_single_worker.sh qa opus
~/.claude-team/scripts/launch_single_worker.sh dev-ops opus
```

---

## File Structure

```
/path/to/project/
├── src/                     # Source code
├── tests/                   # Tests
├── docs/                    # Documentation
├── .claude-team/
│   ├── STATUS.md            # Worker status
│   ├── TRIAGE_GUIDE.md      # Ticket assignment
│   ├── tasks/TASK_*.md      # Active tasks
│   ├── outputs/*.md         # Reports
│   └── templates/*.md       # Briefings
└── CHANGELOG.md
```

---

## Essential Commands

```bash
# Build & Test (customize for your stack)
cd /path/to/project && your-build-command
your-test-command

# GitHub
gh issue list
gh issue view <number>

# Dashboard
./scripts/dashboard.sh
```

---

## Current State

### Just Completed: vX.X.X
- ✅ Feature 1
- ✅ Feature 2

### In Progress
- 🔄 Feature 3
- 🔄 Feature 4

---

## Key Reminders

1. **Triage tickets** → Use TRIAGE_GUIDE.md
2. **Delegate ALL implementation** to workers
3. **QA = Opus + /think**
4. **Ask stakeholder** if requirements unclear

---

*Update this file after every sprint*
