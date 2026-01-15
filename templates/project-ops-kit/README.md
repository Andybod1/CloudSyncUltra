# Project Ops Kit 🛠️

> **A complete operational excellence template for Claude-powered parallel development**

This kit provides everything needed to run a professional software project with Claude Code workers handling parallel development tasks. Battle-tested on real production projects.

**Version:** 1.0.0

---

## Quick Start

```bash
# 1. Copy the kit to your project
cp -r templates/project-ops-kit/* /path/to/your/project/

# 2. Run setup
cd /path/to/your/project
chmod +x scripts/*.sh .claude-team/scripts/*.sh
./scripts/setup.sh

# 3. Customize
# - Edit project.json with your project details
# - Edit VERSION.txt with your version
# - Fill in CLAUDE_PROJECT_KNOWLEDGE.md with project context
# - Customize .claude-team/templates/*_BRIEFING.md for your domain

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
│   ├── DEFINITION_OF_DONE.md  # Quality checklist
│   ├── WORKER_MODELS.conf     # Model configuration
│   ├── metrics/               # Historical data (test counts, etc.)
│   ├── outputs/               # Worker completion reports
│   ├── planning/              # Feature plans
│   ├── retros/                # Sprint retrospectives
│   ├── scripts/               # Worker launch scripts
│   │   ├── launch_single_worker.sh
│   │   ├── launch_workers.sh
│   │   ├── auto_launch_workers.sh
│   │   ├── ticket.sh
│   │   └── launch_all_workers.sh
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
│   ├── generate-stats.sh      # Statistics generator
│   ├── install-hooks.sh       # Git hooks installer
│   ├── pre-commit             # Quality gate hook
│   ├── record-test-count.sh   # Test trend tracking
│   ├── release.sh             # Automated release
│   ├── restore-context.sh     # Session recovery
│   ├── save-session.sh        # Quick session summary
│   ├── setup.sh               # Initial setup
│   ├── update-version.sh      # Version updater
│   └── version-check.sh       # Version validator
├── docs/
│   ├── RUNBOOK.md             # Operations runbook
│   └── decisions/             # Architecture decisions
├── CLAUDE_PROJECT_KNOWLEDGE.md # Project context for Claude
├── OPERATIONAL_EXCELLENCE.md   # Ops improvement tracker
├── README.md                   # This file
├── VERSION.txt                 # Single source of version
└── project.json                # Centralized project config
```

---

## Core Concepts

### 1. Parallel Development with Workers

The kit supports 5 core workers + 9 specialized agents:

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
- Brand-Designer, QA-Automation, Marketing-Strategist

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
| `generate-stats.sh` | Generate project statistics |

### Worker Scripts

| Script | Purpose |
|--------|---------|
| `launch_single_worker.sh` | Launch one worker with model |
| `launch_workers.sh` | Launch 4 empty terminals |
| `auto_launch_workers.sh` | Auto-launch workers with tasks |
| `ticket.sh` | Ticket management CLI |

---

## Customization

### For Your Stack

1. **Edit `scripts/dashboard.sh`** - Update build/test commands
2. **Edit `scripts/release.sh`** - Add your release steps
3. **Edit `scripts/pre-commit`** - Customize quality checks
4. **Edit `.github/workflows/ci.yml`** - Configure CI for your stack

### For Your Team

1. **Edit `.claude-team/templates/*_BRIEFING.md`** - Customize for your domain
2. **Fill in `CLAUDE_PROJECT_KNOWLEDGE.md`** - Add project-specific context
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
./.claude-team/scripts/ticket.sh ready

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

## Branch Protection Setup

Protect your main branch to ensure all changes go through CI:

```bash
# Using GitHub CLI (recommended)
gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
  --field required_status_checks='{"strict":true,"contexts":["build-and-test"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"dismiss_stale_reviews":true,"require_code_owner_reviews":false}' \
  --field restrictions=null

# Verify it's enabled
gh api repos/{owner}/{repo}/branches/main/protection
```

Or manually in GitHub: Settings → Branches → Add rule for `main` → Enable PR requirements + status checks

---

## CI Code Coverage Setup

The CI template includes code coverage examples for multiple languages:

1. **Enable coverage in your test command** (see `.github/workflows/ci.yml`)
2. **Set coverage threshold** (optional but recommended)
3. **View reports in GitHub Actions artifacts**
4. **Get coverage summary in PR comments**

Example for Node.js:
```yaml
- name: Run Tests with Coverage
  run: npm test -- --coverage --reporters=default --reporters=jest-junit
```

---

## Post-Sprint Checklist

**⚠️ MANDATORY:** After every sprint, use the automated release process:

```bash
# Automated (recommended) - handles all 7 steps
./scripts/release.sh X.X.X

# Manual - see full checklist
cat CLAUDE_PROJECT_KNOWLEDGE.md | grep -A 80 "MANDATORY: Post-Sprint"
```

The checklist ensures:
- ✅ Health check passes
- ✅ All tests pass
- ✅ Version updated everywhere
- ✅ Documentation updated
- ✅ GitHub issues closed
- ✅ Sprint files archived
- ✅ Git tagged and pushed

---

## Recovery Process

When recovering from a crash or session loss:

```bash
# 1. Quick recovery script
./scripts/restore-context.sh

# 2. Or manual recovery
cd {PROJECT_ROOT}
gh issue list -l in-progress    # See what was being worked on
git status                       # Check for uncommitted changes
./scripts/dashboard.sh           # Verify project health
```

For full recovery guide, see `RECOVERY.md` which includes:
- Worker restart commands
- State recovery sources
- Troubleshooting steps
- Emergency reset procedures

---

## Ticket CLI

Quick ticket management from the command line:

```bash
# List all open issues
./.claude-team/scripts/ticket.sh list

# Show issues ready for workers
./.claude-team/scripts/ticket.sh ready

# Quick issue creation
./.claude-team/scripts/ticket.sh quick "Add dark mode support"

# Add idea to local inbox
./.claude-team/scripts/ticket.sh idea "Explore caching options"

# View specific issue
./.claude-team/scripts/ticket.sh view 42

# Backup GitHub issues locally
./.claude-team/scripts/ticket.sh backup
```

---

## Credits

Developed through iterative improvement on real production projects.
Battle-tested operational patterns for AI-assisted parallel development.

---

*Version: 1.0.0 | Updated: 2025-01-15*
