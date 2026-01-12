# Parallel Development Team

CloudSync Ultra uses a **two-tier parallel development system** with strategic oversight and tactical execution.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ANDY (Human)                                   │
│                        Vision • Decisions • Direction                       │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                 STRATEGIC PARTNER (Desktop App - Opus 4.5)                  │
│                                                                             │
│   Architecture • Planning • Research • Documentation • Quality              │
│                                                                             │
│   Outputs: DIRECTIVE.md, SPRINT.md, ARCHITECTURE.md                         │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │ DIRECTIVE.md
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      LEAD AGENT (Claude Code CLI - Opus)                    │
│                                                                             │
│   Task breakdown • Worker coordination • Integration • Builds               │
│                                                                             │
│   Outputs: Task files, LEAD_REPORT.md                                       │
└──────┬──────────────┬──────────────┬──────────────┬─────────────────────────┘
       │              │              │              │
       ▼              ▼              ▼              ▼
   ┌───────┐      ┌───────┐      ┌───────┐      ┌───────┐
   │ Dev-1 │      │ Dev-2 │      │ Dev-3 │      │  QA   │
   │Sonnet │      │Sonnet │      │Sonnet │      │Sonnet │
   │  UI   │      │Engine │      │Service│      │ Test  │
   └───────┘      └───────┘      └───────┘      └───────┘
```

---

## Roles

### Strategic Partner (Desktop App)
- **Model:** Claude Opus 4.5
- **Capabilities:** Web search, rich conversation, document creation
- **Responsibilities:**
  - Discuss features with Andy
  - Design architecture
  - Write directives for Lead Agent
  - Review completed work
  - Maintain documentation
  - Final quality gate

### Lead Agent (CLI)
- **Model:** Claude Opus 4.5 (via `claude --model opus`)
- **Capabilities:** Full filesystem, builds, git
- **Responsibilities:**
  - Translate directives into task files
  - Coordinate 4 workers
  - Fix build/integration issues
  - Add files to Xcode project
  - Run tests
  - Write completion reports

### Workers (CLI)
- **Model:** Claude Sonnet 4
- **Capabilities:** Full filesystem access
- **Responsibilities:**
  - Execute assigned tasks
  - Write code
  - Update STATUS.md
  - Write completion reports

---

## Worker Domains

| Worker | Role | Files Owned |
|--------|------|-------------|
| Dev-1 | UI Layer | `Views/`, `ViewModels/`, `Components/`, `ContentView.swift`, `SettingsView.swift` |
| Dev-2 | Core Engine | `RcloneManager.swift` |
| Dev-3 | Services | `SyncManager.swift`, `EncryptionManager.swift`, `KeychainManager.swift`, `ProtonDriveManager.swift`, `Models/` |
| QA | Testing | `CloudSyncAppTests/` |

---

## File Structure

```
.claude-team/
├── STRATEGIC/                     # Strategic Partner's domain
│   ├── DIRECTIVE.md               # Current feature spec
│   ├── DIRECTIVE_TEMPLATE.md      # Template for directives
│   ├── SPRINT.md                  # Sprint planning
│   └── ARCHITECTURE.md            # System architecture
│
├── LEAD/                          # Lead Agent's domain
│   ├── LEAD_BRIEFING.md           # Lead's instructions
│   └── LEAD_REPORT.md             # Completion reports
│
├── tasks/                         # Task files (Lead writes)
│   ├── TASK_DEV1.md
│   ├── TASK_DEV2.md
│   ├── TASK_DEV3.md
│   └── TASK_QA.md
│
├── outputs/                       # Worker completion reports
│   ├── DEV1_COMPLETE.md
│   ├── DEV2_COMPLETE.md
│   ├── DEV3_COMPLETE.md
│   └── QA_REPORT.md
│
├── templates/                     # Worker role briefings
│   ├── DEV1_BRIEFING.md
│   ├── DEV2_BRIEFING.md
│   ├── DEV3_BRIEFING.md
│   └── QA_BRIEFING.md
│
├── scripts/
│   ├── launch_lead.sh             # Launch Lead Agent only
│   ├── launch_workers.sh          # Launch 4 workers
│   └── launch_all.sh              # Launch Lead + workers
│
├── STATUS.md                      # Real-time worker status
└── WORKSTREAM.md                  # Current sprint tracking
```

---

## Workflow

### 1. Strategic Planning (You + Strategic Partner)
```
Andy: "I want conflict resolution"
Strategic Partner: [Discusses options, researches, designs]
Strategic Partner: [Writes DIRECTIVE.md]
Strategic Partner: "Directive ready. Launch Lead Agent."
```

### 2. Task Creation (Lead Agent)
```bash
# Launch Lead
~/.claude-team/scripts/launch_lead.sh

# Paste startup command
Read /Users/antti/Claude/.claude-team/LEAD/LEAD_BRIEFING.md then check STRATEGIC/DIRECTIVE.md for current directive and execute it.
```

Lead creates task files and says: "TASKS READY. Launch workers."

### 3. Parallel Execution (Workers)
```bash
# Launch workers
~/.claude-team/scripts/launch_workers.sh

# Paste startup commands in each terminal
```

Workers execute in parallel, update STATUS.md.

### 4. Integration (Lead Agent)
- Lead monitors STATUS.md
- Adds new files to Xcode project
- Fixes build errors
- Runs tests
- Writes LEAD_REPORT.md

### 5. Review (Strategic Partner)
- Reviews LEAD_REPORT.md
- Verifies quality
- Updates CHANGELOG.md
- Commits to git
- Reports to Andy

---

## Quick Start

### Option A: Full Team (Lead + 4 Workers)
```bash
~/.claude-team/scripts/launch_all.sh
```

### Option B: Lead Only (then workers later)
```bash
~/.claude-team/scripts/launch_lead.sh
# Wait for Lead to create tasks
~/.claude-team/scripts/launch_workers.sh
```

### Option C: Workers Only (if tasks already exist)
```bash
~/.claude-team/scripts/launch_workers.sh
```

---

## Startup Commands

### Lead Agent
```
Read /Users/antti/Claude/.claude-team/LEAD/LEAD_BRIEFING.md then check STRATEGIC/DIRECTIVE.md for current directive and execute it. Update STATUS.md and write LEAD_REPORT.md when complete.
```

### Dev-1 (UI)
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

### Dev-2 (Engine)
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

### Dev-3 (Services)
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

### QA
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

---

## Monitoring

### Check Status
```bash
cat ~/.claude-team/STATUS.md
```

### Check Lead Report
```bash
cat ~/.claude-team/LEAD/LEAD_REPORT.md
```

### Check Worker Outputs
```bash
ls ~/.claude-team/outputs/
cat ~/.claude-team/outputs/DEV1_COMPLETE.md
```

---

## Benefits

- **~4-5x speedup** with parallel execution
- **Zero conflicts** via domain separation
- **Strategic oversight** for quality
- **Tactical efficiency** for execution
- **Clear accountability** at each layer
- **Comprehensive documentation** throughout

---

*Last Updated: 2026-01-12*
*CloudSync Ultra v2.0.3*
