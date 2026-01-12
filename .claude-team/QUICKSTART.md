# CloudSync Ultra - Parallel Development Team

## Quick Start Guide

### Team Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                   Claude Desktop App (Lead)                     │
│         Architecture • Planning • Coordination                  │
└─────┬───────────┬───────────┬───────────┬───────────────────────┘
      │           │           │           │
      ▼           ▼           ▼           ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│  Dev-1  │ │  Dev-2  │ │  Dev-3  │ │   QA    │
│   CLI   │ │   CLI   │ │   CLI   │ │   CLI   │
│UI Layer │ │ Core    │ │Services │ │ Testing │
│         │ │ Engine  │ │         │ │         │
└─────────┘ └─────────┘ └─────────┘ └─────────┘
```

### Worker Domains

| Worker | Focus | Files Owned |
|--------|-------|-------------|
| Dev-1 | UI Layer | Views/, ViewModels/, Components/, ContentView, SettingsView |
| Dev-2 | Core Engine | RcloneManager.swift (the big one!) |
| Dev-3 | Services | SyncManager, EncryptionManager, KeychainManager, ProtonDriveManager, Models/ |
| QA | Testing | CloudSyncAppTests/ |

---

### Startup Commands

**You have 4 Claude Code terminals open. Paste these commands:**

**Terminal 1 — Dev-1 (UI Layer):**
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

**Terminal 2 — Dev-2 (Core Engine):**
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

**Terminal 3 — Dev-3 (Services):**
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

**Terminal 4 — QA (Testing):**
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

---

## Workflow

### 1. You Tell Lead What You Want
Talk to Lead Claude (Desktop App) with your request.

### 2. Lead Creates Tasks
Lead breaks down the work and writes:
- `.claude-team/tasks/TASK_DEV1.md`
- `.claude-team/tasks/TASK_DEV2.md`
- `.claude-team/tasks/TASK_DEV3.md`
- `.claude-team/tasks/TASK_QA.md`

### 3. You Dispatch to Workers
Paste startup commands in each terminal.

### 4. Workers Execute
Each worker:
- Reads their briefing
- Reads their task
- Updates STATUS.md as they work
- Writes completion report when done

### 5. Lead Integrates
Lead monitors STATUS.md, reviews outputs, integrates work.

---

## File Structure

```
/Users/antti/Claude/.claude-team/
├── WORKSTREAM.md          # Sprint overview (Lead manages)
├── STATUS.md              # Real-time status (Workers update)
├── tasks/
│   ├── TASK_DEV1.md       # UI Layer task
│   ├── TASK_DEV2.md       # Core Engine task
│   ├── TASK_DEV3.md       # Services task
│   └── TASK_QA.md         # Testing task
├── outputs/
│   ├── DEV1_COMPLETE.md   # Dev-1 completion reports
│   ├── DEV2_COMPLETE.md   # Dev-2 completion reports
│   ├── DEV3_COMPLETE.md   # Dev-3 completion reports
│   └── QA_REPORT.md       # QA test reports
├── templates/
│   ├── DEV1_BRIEFING.md   # UI Layer instructions
│   ├── DEV2_BRIEFING.md   # Core Engine instructions
│   ├── DEV3_BRIEFING.md   # Services instructions
│   └── QA_BRIEFING.md     # QA instructions
└── scripts/
    ├── launch_dev1.sh
    ├── launch_dev2.sh
    ├── launch_dev3.sh
    ├── launch_qa.sh
    └── launch_team.sh
```

---

## Monitoring Progress

Ask Lead Claude to check status, or run:
```bash
cat /Users/antti/Claude/.claude-team/STATUS.md
```
