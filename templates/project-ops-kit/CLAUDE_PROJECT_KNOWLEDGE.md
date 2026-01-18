# {{PROJECT_NAME}} - Project Knowledge

> **For Claude Project Context** - Essential info for every conversation
> **Version:** {{VERSION}} | **Updated:** {{DATE}}

---

## Project Identity

| Key | Value |
|-----|-------|
| **App** | {{PROJECT_NAME}} - {{PROJECT_DESCRIPTION}} |
| **Tech** | {{TECH_STACK}} |
| **Location** | {{PROJECT_PATH}} |
| **GitHub** | {{GITHUB_URL}} |
| **Human** | {{HUMAN_NAME}} |

---

## What It Does

{{PROJECT_SUMMARY}}

<!-- Example features - customize for your project -->
- Feature 1
- Feature 2
- Feature 3

---

## Team Architecture

### Core Team (5 Workers)
```
Strategic Partner (This Claude - Opus 4.5)
    ├── Dev-1 (UI)       → Views, ViewModels, Components
    ├── Dev-2 (Engine)   → Core business logic
    ├── Dev-3 (Services) → Models, *Manager.swift
    ├── QA (Testing)     → {{TEST_DIR}}
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
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh dev-1 opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh dev-2 opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh dev-3 opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh qa opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh dev-ops opus

# Specialized agents (all use Opus)
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh ux-designer opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh product-manager opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh architect opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh security-auditor opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh revenue-engineer opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh legal-advisor opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh marketing-lead opus
```

---

## File Structure

```
{{PROJECT_PATH}}
├── {{SOURCE_DIR}}/                # Source code
├── {{TEST_DIR}}/                  # Tests ({{TEST_COUNT}} passing)
├── docs/                          # User documentation
├── .claude-team/
│   ├── STATUS.md                  # Live worker status
│   ├── TRIAGE_GUIDE.md            # Ticket assignment decisions
│   ├── SPECIALIZED_AGENTS.md      # Agent roster & usage
│   ├── tasks/TASK_*.md            # Active tasks
│   ├── outputs/*_COMPLETE.md      # Reports
│   ├── templates/*_BRIEFING.md    # Briefings
│   └── planning/*.md              # Feature plans
└── CHANGELOG.md
```

---

## Essential Commands

```bash
# Build & Launch
cd {{PROJECT_PATH}} && {{BUILD_COMMAND}}
{{LAUNCH_COMMAND}}

# Tests
{{TEST_COMMAND}}

# GitHub
gh issue list
gh issue view <number>
```

---

## Current State

### Just Completed: {{VERSION}} - Sprint "{{SPRINT_NAME}}"
<!-- Update with recent accomplishments -->
- ✅ Feature 1
- ✅ Feature 2
- ✅ {{TEST_COUNT}} tests passing

### Strategic: Billion Dollar Framework
- Revenue target: $50M ARR within 3 years
- See `.claude-team/planning/BILLION_DOLLAR_FRAMEWORK.md`

---

## Key Reminders

1. **Launch workers via script** → `{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh <worker> opus` (NEVER manually)
2. **Triage tickets** → Use TRIAGE_GUIDE.md to assign core team OR specialized agents
3. **Delegate ALL implementation** to workers
4. **QA = Opus + /think | Specialized = Opus + /think hard**
5. **Ask {{HUMAN_NAME}}** if requirements unclear

### ⚠️ MANDATORY: Post-Sprint Documentation

> **🔒 PROTECTED SECTION** - Do NOT remove or modify this section without written permission from {{HUMAN_NAME}}.

**🚀 AUTOMATED OPTION:** Run `./scripts/release.sh X.X.XX` to execute all steps automatically!

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
cd {{PROJECT_PATH}} && {{TEST_COMMAND}}

# Build and launch app
cd {{PROJECT_PATH}} && {{BUILD_COMMAND}}
{{LAUNCH_COMMAND}}

# Update test counts metric (use actual count from test output)
echo "$(date +%Y-%m-%d),X.X.XX,<TEST_COUNT>" >> .claude-team/metrics/test-counts.csv
```
- [ ] All tests pass
- [ ] App launches and works
- [ ] Test count added to `.claude-team/metrics/test-counts.csv`

#### 2. Update Version (use scripts!)
```bash
# Update all docs to new version automatically:
./scripts/update-version.sh X.X.XX

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
cd {{PROJECT_PATH}}
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
cat .claude-team/OPERATIONAL_EXCELLENCE.md
```
- [ ] Health score maintained or improved
- [ ] Update progress percentages if pillars improved
- [ ] **If scripts improved → Update `templates/project-ops-kit/`**

#### 8. Sprint Retrospective
Quick reflection on the sprint to capture learnings:

| Question | Notes |
|----------|-------|
| **What went well?** | (successes, smooth processes, wins) |
| **What didn't go well?** | (friction, bugs, blockers, delays) |
| **What to improve?** | (process changes, tooling, documentation) |

- [ ] Noted 1-2 things that went well
- [ ] Identified any friction or issues encountered
- [ ] Captured improvement ideas for next sprint

**⚡ Do this IMMEDIATELY after each sprint - don't wait to be asked!**

---

#### Worker Workflow (Important!)

**Development Workers (Dev-1, Dev-2, Dev-3):**
```bash
# Launch via external terminal - NOT as subagents
.claude-team/scripts/launch_single_worker.sh dev-1 opus
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
cat {{PROJECT_PATH}}/.claude-team/STATUS.md
gh issue list
```

---

*Optimized for Claude Project Knowledge*
