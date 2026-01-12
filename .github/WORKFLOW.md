# GitHub Issues Workflow

> **Recovery-Safe**: All state is stored on GitHub Issues. Survives device/power failures.

---

## Quick Commands

```bash
# View all open issues
gh issue list

# View by status
gh issue list --label "triage"      # Needs planning
gh issue list --label "ready"       # Ready for workers
gh issue list --label "in-progress" # Being worked on
gh issue list --label "needs-review" # Awaiting review

# View by worker assignment
gh issue list --label "worker:dev-1"
gh issue list --label "worker:dev-2"
gh issue list --label "worker:dev-3"
gh issue list --label "worker:qa"

# View by priority
gh issue list --label "priority:critical"
gh issue list --label "priority:high"

# Create quick issue
gh issue create --title "[Bug]: Description" --label "bug,triage"
gh issue create --title "[Feature]: Description" --label "enhancement,triage"
```

---

## Workflow States (Labels)

| Label | Meaning | Who Manages |
|-------|---------|-------------|
| `triage` | New issue, needs planning | Strategic Partner reviews |
| `ready` | Planned, ready for workers | Strategic Partner sets |
| `in-progress` | Currently being worked on | Auto when workers start |
| `needs-review` | Work done, needs integration | Workers set when done |
| `blocked` | Waiting on dependency | Anyone can set |

---

## Issue Lifecycle

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           ISSUE LIFECYCLE                                │
│                                                                          │
│   [New Issue]                                                            │
│       │                                                                  │
│       ▼                                                                  │
│   ┌─────────┐   Strategic Partner    ┌─────────┐                         │
│   │ triage  │ ───────────────────▶   │  ready  │                         │
│   └─────────┘   plans & assigns      └─────────┘                         │
│                                           │                              │
│                                           ▼  Andy launches workers       │
│                                      ┌─────────────┐                     │
│                                      │ in-progress │                     │
│                                      └─────────────┘                     │
│                                           │                              │
│                                           ▼  Worker completes            │
│                                      ┌──────────────┐                    │
│                                      │ needs-review │                    │
│                                      └──────────────┘                    │
│                                           │                              │
│                                           ▼  Strategic Partner reviews   │
│                                        [CLOSED]                          │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Label Categories

### Status Labels
- `triage` - Needs review and planning
- `ready` - Planned and ready for workers  
- `in-progress` - Currently being worked on
- `needs-review` - Waiting for Strategic Partner review
- `blocked` - Blocked by dependency

### Type Labels
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `task` - Internal development task
- `documentation` - Documentation updates

### Component Labels
- `component:ui` - UI/Views (Dev-1 domain)
- `component:engine` - Core Engine (Dev-2 domain)
- `component:services` - Services/Models (Dev-3 domain)
- `component:tests` - Testing (QA domain)
- `component:menu-bar` - Menu bar functionality
- `component:encryption` - Encryption features
- `component:scheduling` - Scheduled sync features

### Worker Assignment
- `worker:dev-1` - Assigned to Dev-1 (UI)
- `worker:dev-2` - Assigned to Dev-2 (Engine)
- `worker:dev-3` - Assigned to Dev-3 (Services)
- `worker:qa` - Assigned to QA
- `worker:strategic` - Strategic Partner handles

### Priority Labels
- `priority:critical` - Must fix immediately
- `priority:high` - Important, do soon
- `priority:medium` - Normal priority
- `priority:low` - Nice to have

### Size Labels (T-Shirt Sizing)
- `size:xs` - < 30 minutes
- `size:s` - 30 min - 1 hour
- `size:m` - 1-2 hours
- `size:l` - 2-4 hours
- `size:xl` - 4+ hours (consider splitting)

---

## Creating Issues

### From Command Line (Quick)
```bash
# Bug report
gh issue create --title "[Bug]: Transfer fails for large files" \
  --label "bug,triage,component:engine"

# Feature request  
gh issue create --title "[Feature]: Add bandwidth throttling" \
  --label "enhancement,triage,component:engine"

# Internal task
gh issue create --title "[Task]: Refactor RcloneManager" \
  --label "task,internal,component:engine"
```

### From GitHub Web (Detailed)
1. Go to https://github.com/andybod1-lang/CloudSyncUltra/issues/new/choose
2. Select template (Bug Report, Feature Request, or Internal Task)
3. Fill out form
4. Submit

---

## Strategic Partner Workflow

### 1. Review Triage Queue
```bash
gh issue list --label "triage"
```

### 2. Plan Issue
- Read issue details: `gh issue view <number>`
- Determine complexity, assign worker labels
- Add size estimate label
- Add component label

### 3. Mark Ready
```bash
gh issue edit <number> --remove-label "triage" --add-label "ready,worker:dev-2,size:m"
```

### 4. Create Worker Tasks
When Andy is ready to run workers, create task files referencing issue:
```markdown
# TASK_DEV2.md
## Implements Issue #47

[Task details...]
```

### 5. After Workers Complete
```bash
# Move to review
gh issue edit <number> --remove-label "in-progress" --add-label "needs-review"

# After integration, close with comment
gh issue close <number> --comment "Implemented in commit abc123. Tested and merged."
```

---

## Linking Commits to Issues

Always reference issues in commit messages:

```bash
git commit -m "Add bandwidth throttling controls

Implements #47
- Added BandwidthSettings model
- Updated RcloneManager with --bwlimit
- Added UI controls in SettingsView"
```

This creates automatic links in GitHub.

---

## Recovery After Crash

All state is on GitHub. After crash:

```bash
# Check what's in progress
gh issue list --label "in-progress"

# Check what needs review
gh issue list --label "needs-review"

# Check what's ready to work on
gh issue list --label "ready"
```

---

## Dashboard View

Create a quick dashboard:

```bash
echo "=== TRIAGE (needs planning) ===" && gh issue list --label "triage"
echo ""
echo "=== READY (for workers) ===" && gh issue list --label "ready"  
echo ""
echo "=== IN PROGRESS ===" && gh issue list --label "in-progress"
echo ""
echo "=== NEEDS REVIEW ===" && gh issue list --label "needs-review"
```

---

*Last Updated: 2025-01-12*
