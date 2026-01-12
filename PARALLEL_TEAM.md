# Parallel Development Team

CloudSync Ultra uses a parallel development system with multiple Claude AI agents working simultaneously.

## Team Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                        Andy (Human)                             │
│                   Decisions • Direction                         │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Lead Claude (Opus 4.5)                        │
│         Architecture • Task Breakdown • Integration             │
└──────┬──────────┬──────────┬──────────┬─────────────────────────┘
       │          │          │          │
       ▼          ▼          ▼          ▼
   ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐
   │ Dev-1 │  │ Dev-2 │  │ Dev-3 │  │  QA   │
   │Sonnet │  │Sonnet │  │Sonnet │  │Sonnet │
   │  UI   │  │Engine │  │Service│  │ Test  │
   └───────┘  └───────┘  └───────┘  └───────┘
```

## Worker Domains

| Worker | Role | Files Owned |
|--------|------|-------------|
| Dev-1 | UI Layer | Views/, ViewModels/, Components/, ContentView, SettingsView |
| Dev-2 | Core Engine | RcloneManager.swift |
| Dev-3 | Services | SyncManager, EncryptionManager, KeychainManager, ProtonDriveManager, Models/ |
| QA | Testing | CloudSyncAppTests/ |

## Quick Start

### 1. Open 4 Terminal windows

In each terminal:
```bash
cd ~/Claude
claude
```

### 2. Paste startup commands

**Terminal 1 (Dev-1):**
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

**Terminal 2 (Dev-2):**
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

**Terminal 3 (Dev-3):**
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

**Terminal 4 (QA):**
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

### 3. When prompted for permissions

Select: "Yes, allow all edits during this session"

## File Structure

```
.claude-team/
├── WORKSTREAM.md          # Sprint overview (Lead manages)
├── STATUS.md              # Real-time status (Workers update)
├── QUICKSTART.md          # Detailed how-to guide
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
│   ├── DEV1_BRIEFING.md   # UI Layer role instructions
│   ├── DEV2_BRIEFING.md   # Core Engine role instructions
│   ├── DEV3_BRIEFING.md   # Services role instructions
│   └── QA_BRIEFING.md     # QA role instructions
└── scripts/
    ├── launch_team.sh     # Launch all 4 workers
    └── launch_dev*.sh     # Individual launchers
```

## Workflow

1. **Tell Lead Claude** what you want to build
2. **Lead creates tasks** in `.claude-team/tasks/`
3. **Launch workers** in Terminal
4. **Workers execute** and update STATUS.md
5. **Lead integrates** completed work

## Monitoring Progress

Check STATUS.md:
```bash
cat ~/.claude-team/STATUS.md
```

Or ask Lead Claude for a status update.

## Benefits

- **~4x speedup** on parallelizable work
- **Zero conflicts** via domain separation
- **Real-time visibility** via STATUS.md
- **Quality built-in** with parallel QA
