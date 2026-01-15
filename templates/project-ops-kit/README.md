# Project Ops Kit 🛠️

> **A complete operational excellence template for Claude-powered parallel development**

This kit provides everything needed to run a professional software project with Claude Code workers handling parallel development tasks.

---

## Quick Start

```bash
# 1. Copy the kit to your project
cp -r templates/project-ops-kit/* /path/to/your/project/

# 2. Run setup
cd /path/to/your/project
./scripts/setup.sh

# 3. Customize
# - Edit project.json with your project details
# - Edit VERSION.txt with your version
# - Edit CLAUDE_PROJECT_KNOWLEDGE.md with project context
# - Update .claude-team/templates/*_BRIEFING.md for your domain

# 4. Install git hooks
./scripts/install-hooks.sh

# 5. Launch workers
./.claude-team/scripts/launch_single_worker.sh dev-1 opus
```

---

## What's Included

### 📁 Directory Structure

```
project-ops-kit/
├── .claude-team/
│   ├── STATUS.md              # Worker status tracking
│   ├── TICKETS.md             # Ticket system guide
│   ├── TRIAGE_GUIDE.md        # Ticket assignment decisions
│   ├── SPECIALIZED_AGENTS.md  # On-demand specialist roster
│   ├── WORKER_MODELS.conf     # Model configuration
│   ├── metrics/               # Historical data (test counts, etc.)
│   ├── outputs/               # Worker completion reports
│   ├── planning/              # Feature plans
│   ├── scripts/               # Worker launch scripts
│   ├── sessions/              # Session summaries
│   ├── tasks/                 # Active worker tasks
│   ├── templates/             # Worker briefing templates
│   └── tickets/               # Ticket inbox/backup
├── .github/
│   ├── ISSUE_TEMPLATE/        # Bug, feature, task templates
│   └── workflows/ci.yml       # GitHub Actions CI
├── scripts/
│   ├── archive-outputs.sh     # Clean up reports
│   ├── dashboard.sh           # Project health dashboard
│   ├── install-hooks.sh       # Git hooks installer
│   ├── pre-commit             # Quality gate hook
│   ├── record-test-count.sh   # Test trend tracking
│   ├── release.sh             # Automated release
│   ├── restore-context.sh     # Session recovery
│   ├── save-session.sh        # Quick session summary
│   ├── setup.sh               # Initial setup
│   ├── update-version.sh      # Version updater
│   └── version-check.sh       # Version validator
├── CLAUDE_PROJECT_KNOWLEDGE.md # Project context for Claude
├── OPERATIONAL_EXCELLENCE.md   # Ops improvement tracker
├── README.md                   # This file
├── VERSION.txt                 # Single source of version
└── project.json                # Centralized project config
```

---

## Core Concepts

### 1. Parallel Development with Workers

The kit supports 5 core workers + 6 specialized agents:

**Core Team:**
| Worker | Role | Domain |
|--------|------|--------|
| Dev-1 | UI | Views, Components, ViewModels |
| Dev-2 | Engine | Core business logic |
| Dev-3 | Services | Models, Managers, Services |
| QA | Testing | All test files |
| Dev-Ops | Operations | Scripts, docs, CI/CD |

**Specialized Agents (on-demand):**
- UX-Designer, Product-Manager, Architect
- Security-Auditor, Performance-Engineer, Tech-Writer

### 2. Ticket Triage System

Use `TRIAGE_GUIDE.md` to decide who handles each ticket:
- Implementation → Core workers
- Analysis/Strategy → Specialized agents
- Operations → Dev-Ops

### 3. Quality Gates

Pre-commit hooks enforce:
- Syntax validation
- Build verification
- Version consistency
- No debug artifacts
- No large files

### 4. Single Source of Truth

- Version: `VERSION.txt`
- Config: `project.json`
- Test metrics: `.claude-team/metrics/`

---

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `dashboard.sh` | Show project health score |
| `release.sh X.X.X` | Full automated release |
| `version-check.sh` | Validate version alignment |
| `update-version.sh X.X.X` | Update all version refs |
| `install-hooks.sh` | Install pre-commit hooks |
| `record-test-count.sh` | Track test count trend |
| `save-session.sh` | Quick session summary |
| `restore-context.sh` | Recover session context |
| `archive-outputs.sh` | Clean up old reports |

---

## Customization

### For Your Stack

1. **Edit `scripts/dashboard.sh`** - Update build/test commands
2. **Edit `scripts/release.sh`** - Add your release steps
3. **Edit `scripts/pre-commit`** - Customize quality checks
4. **Edit `.github/workflows/ci.yml`** - Configure CI for your stack

### For Your Team

1. **Edit `.claude-team/templates/*_BRIEFING.md`** - Customize for your domain
2. **Edit `CLAUDE_PROJECT_KNOWLEDGE.md`** - Add project-specific context
3. **Edit `project.json`** - Configure paths and commands

---

## Operational Excellence

Track your operational maturity with `OPERATIONAL_EXCELLENCE.md`:

**Six Pillars:**
1. Automation First (scripts, CI)
2. Quality Gates (hooks, PR rules)
3. Single Source of Truth (configs)
4. Metrics & Visibility (dashboard)
5. Knowledge Management (docs)
6. Business Operations (release, support)

---

## Best Practices

### Starting a Sprint
```bash
# 1. Check health
./scripts/dashboard.sh

# 2. Review tickets
gh issue list --label "ready"

# 3. Launch workers
./.claude-team/scripts/launch_single_worker.sh dev-1 opus
```

### Ending a Sprint
```bash
# 1. Run release script
./scripts/release.sh X.X.X

# 2. Save session
./scripts/save-session.sh

# 3. Archive outputs
./scripts/archive-outputs.sh
```

### Recovery After Crash
```bash
# Quick context restore
./scripts/restore-context.sh
```

---

## Credits

Developed through iterative improvement on CloudSync Ultra project.
Battle-tested operational patterns for AI-assisted development.

---

*Version: 2.0 | Updated: 2026-01-15*
