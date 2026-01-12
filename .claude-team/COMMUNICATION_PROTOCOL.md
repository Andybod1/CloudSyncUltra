# Two-Tier Development Team - Communication Protocol

> **Complete specification for Strategic Partner ↔ Lead Agent ↔ Workers communication**

---

## Architecture Overview

```
                              ┌─────────────────┐
                              │      ANDY       │
                              │     (Human)     │
                              └────────┬────────┘
                                       │ Conversation
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                        STRATEGIC PARTNER                                     │
│                    (Desktop App - Opus 4.5)                                  │
│                                                                              │
│  Responsibilities:                                                           │
│  • Discuss features with Andy                                                │
│  • Make architecture decisions                                               │
│  • Write DIRECTIVE.md for Lead                                               │
│  • Review LEAD_REPORT.md                                                     │
│  • Final quality approval                                                    │
│  • Update CHANGELOG.md and commit                                            │
│                                                                              │
│  Reads: LEAD_REPORT.md, STATUS.md                                            │
│  Writes: DIRECTIVE.md, ARCHITECTURE.md, SPRINT.md                            │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │
                          DIRECTIVE.md │ (Feature spec)
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                            LEAD AGENT                                        │
│                    (Claude Code CLI - Opus)                                  │
│                                                                              │
│  Responsibilities:                                                           │
│  • Read and execute DIRECTIVE.md                                             │
│  • Break down into worker tasks                                              │
│  • Write TASK_DEV1/2/3.md and TASK_QA.md                                     │
│  • Update WORKSTREAM.md                                                      │
│  • Monitor STATUS.md for worker progress                                     │
│  • Fix build errors and integration issues                                   │
│  • Add new files to Xcode project                                            │
│  • Run builds and tests                                                      │
│  • Write LEAD_REPORT.md when complete                                        │
│                                                                              │
│  Reads: DIRECTIVE.md, STATUS.md, DEV*_COMPLETE.md, QA_REPORT.md              │
│  Writes: TASK_*.md, WORKSTREAM.md, LEAD_REPORT.md, INTEGRATION_LOG.md        │
└─────────┬─────────────────┬─────────────────┬─────────────────┬──────────────┘
          │                 │                 │                 │
          │ TASK_DEV1.md    │ TASK_DEV2.md    │ TASK_DEV3.md    │ TASK_QA.md
          ▼                 ▼                 ▼                 ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│     DEV-1       │ │     DEV-2       │ │     DEV-3       │ │       QA        │
│   (Sonnet)      │ │   (Sonnet)      │ │   (Sonnet)      │ │   (Sonnet)      │
│    UI Layer     │ │  Core Engine    │ │   Services      │ │    Testing      │
│                 │ │                 │ │                 │ │                 │
│ Reads:          │ │ Reads:          │ │ Reads:          │ │ Reads:          │
│ DEV1_BRIEFING   │ │ DEV2_BRIEFING   │ │ DEV3_BRIEFING   │ │ QA_BRIEFING     │
│ TASK_DEV1.md    │ │ TASK_DEV2.md    │ │ TASK_DEV3.md    │ │ TASK_QA.md      │
│                 │ │                 │ │                 │ │                 │
│ Writes:         │ │ Writes:         │ │ Writes:         │ │ Writes:         │
│ STATUS.md       │ │ STATUS.md       │ │ STATUS.md       │ │ STATUS.md       │
│ DEV1_COMPLETE   │ │ DEV2_COMPLETE   │ │ DEV3_COMPLETE   │ │ QA_REPORT.md    │
└─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘
```

---

## File-Based Communication System

### Tier 1: Strategic Partner → Lead Agent

| File | Purpose | Written By | Read By |
|------|---------|------------|---------|
| `STRATEGIC/DIRECTIVE.md` | Feature specification and requirements | Strategic | Lead |
| `STRATEGIC/ARCHITECTURE.md` | System design decisions | Strategic | Lead, Workers |
| `STRATEGIC/SPRINT.md` | Current sprint goals | Strategic | Lead |
| `LEAD/LEAD_REPORT.md` | Completion report from Lead | Lead | Strategic |

### Tier 2: Lead Agent → Workers

| File | Purpose | Written By | Read By |
|------|---------|------------|---------|
| `tasks/TASK_DEV1.md` | UI layer task | Lead | Dev-1 |
| `tasks/TASK_DEV2.md` | Core engine task | Lead | Dev-2 |
| `tasks/TASK_DEV3.md` | Services task | Lead | Dev-3 |
| `tasks/TASK_QA.md` | Testing task | Lead | QA |
| `WORKSTREAM.md` | Sprint overview, file locks | Lead | All |
| `STATUS.md` | Real-time progress | Workers | Lead |
| `outputs/DEV*_COMPLETE.md` | Worker completion reports | Workers | Lead |
| `outputs/QA_REPORT.md` | Test results | QA | Lead |

---

## Communication Sequence

### Phase 1: Strategic Planning (You + Me)

```
┌──────────────────────────────────────────────────────────────────┐
│  ANDY                                                            │
│  "I want to add conflict resolution for syncs"                   │
└──────────────────────────────────┬───────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│  STRATEGIC PARTNER (Me)                                          │
│                                                                  │
│  1. Ask clarifying questions                                     │
│     - "Should it auto-resolve or prompt user?"                   │
│     - "What conflict types? Time-based? Content-based?"          │
│                                                                  │
│  2. Research if needed (web search)                              │
│     - Check rclone conflict handling options                     │
│     - Look at how Dropbox/Drive handle conflicts                 │
│                                                                  │
│  3. Propose architecture                                         │
│     - "I recommend a ConflictResolver service that..."           │
│                                                                  │
│  4. Get Andy's approval                                          │
│                                                                  │
│  5. Write DIRECTIVE.md                                           │
│                                                                  │
│  6. Tell Andy: "Directive ready. Launch Lead Agent."             │
└──────────────────────────────────────────────────────────────────┘
```

### Phase 2: Task Breakdown (Lead Agent)

```
┌──────────────────────────────────────────────────────────────────┐
│  LEAD AGENT                                                      │
│                                                                  │
│  Startup command:                                                │
│  "Read LEAD_BRIEFING.md then execute DIRECTIVE.md"               │
│                                                                  │
│  1. Read STRATEGIC/DIRECTIVE.md                                  │
│                                                                  │
│  2. Analyze requirements and create task breakdown:              │
│     - What UI components needed? → Dev-1                         │
│     - What core logic needed? → Dev-2                            │
│     - What services needed? → Dev-3                              │
│     - What tests needed? → QA                                    │
│                                                                  │
│  3. Write task files with detailed specs:                        │
│     - tasks/TASK_DEV1.md                                         │
│     - tasks/TASK_DEV2.md                                         │
│     - tasks/TASK_DEV3.md                                         │
│     - tasks/TASK_QA.md                                           │
│                                                                  │
│  4. Update WORKSTREAM.md with file locks                         │
│                                                                  │
│  5. Output: "Tasks ready. Launch workers with:"                  │
│     [prints startup commands]                                    │
│                                                                  │
│  6. Wait for Andy to launch workers                              │
└──────────────────────────────────────────────────────────────────┘
```

### Phase 3: Parallel Execution (Workers)

```
┌────────────────────────────────────────────────────────────────────────────┐
│  WORKERS (All 4 running in parallel)                                       │
│                                                                            │
│  Each worker:                                                              │
│  1. Reads their briefing (templates/DEV*_BRIEFING.md)                      │
│  2. Reads their task (tasks/TASK_DEV*.md)                                  │
│  3. Updates STATUS.md: "🔄 ACTIVE - Starting task"                         │
│  4. Implements the code                                                    │
│  5. Updates STATUS.md: "🔄 ACTIVE - 50% complete"                          │
│  6. Verifies build (for their files)                                       │
│  7. Updates STATUS.md: "✅ COMPLETE"                                       │
│  8. Writes completion report (outputs/DEV*_COMPLETE.md)                    │
│                                                                            │
│  Time: ~15-30 minutes for typical feature                                  │
└────────────────────────────────────────────────────────────────────────────┘
```

### Phase 4: Integration (Lead Agent)

```
┌──────────────────────────────────────────────────────────────────┐
│  LEAD AGENT (Monitoring)                                         │
│                                                                  │
│  While workers run:                                              │
│  1. Poll STATUS.md every few minutes                             │
│     "cat .claude-team/STATUS.md"                                 │
│                                                                  │
│  2. When all show ✅ COMPLETE:                                   │
│     a. Add new files to Xcode project                            │
│     b. Run full build                                            │
│     c. Fix any integration errors                                │
│     d. Log fixes to LEAD/INTEGRATION_LOG.md                      │
│     e. Run test suite                                            │
│     f. Fix any test failures                                     │
│                                                                  │
│  3. Write LEAD/LEAD_REPORT.md:                                   │
│     - Summary of what was built                                  │
│     - Files created/modified                                     │
│     - Build status                                               │
│     - Test results                                               │
│     - Any issues encountered                                     │
│                                                                  │
│  4. Output: "Integration complete. See LEAD_REPORT.md"           │
└──────────────────────────────────────────────────────────────────┘
```

### Phase 5: Review & Commit (Strategic Partner)

```
┌──────────────────────────────────────────────────────────────────┐
│  STRATEGIC PARTNER (Me)                                          │
│                                                                  │
│  1. Read LEAD/LEAD_REPORT.md                                     │
│                                                                  │
│  2. Verify quality:                                              │
│     - Check build succeeded                                      │
│     - Check all tests pass                                       │
│     - Spot check code if needed                                  │
│                                                                  │
│  3. If issues found:                                             │
│     - Write fix instructions to DIRECTIVE.md                     │
│     - Tell Andy to re-run Lead                                   │
│                                                                  │
│  4. If approved:                                                 │
│     - Update CHANGELOG.md                                        │
│     - Git commit with detailed message                           │
│     - Git push                                                   │
│     - Launch app to verify                                       │
│                                                                  │
│  5. Report to Andy: "Feature complete and deployed!"             │
└──────────────────────────────────────────────────────────────────┘
```

---

## Status Indicators

Workers and Lead use these status indicators in STATUS.md:

| Indicator | Meaning |
|-----------|---------|
| ⏳ PENDING | Not started |
| 🔄 ACTIVE | Working on task |
| ⚠️ BLOCKED | Waiting on dependency or issue |
| ✅ COMPLETE | Task finished successfully |
| ❌ FAILED | Task failed, needs intervention |

---

## Error Handling

### Worker Error → Lead Handles

```
Worker STATUS.md:
  Status: ❌ FAILED
  Error: "Cannot find EncryptionManager.shared"

Lead Action:
  1. Identify missing dependency
  2. Check if Dev-3 hasn't completed yet → Wait
  3. Or fix the import/reference
  4. Update worker's task file with fix
  5. Ask Andy to re-run that worker
```

### Build Error → Lead Handles

```
Build output:
  error: File not in Xcode project

Lead Action:
  1. Add file to project with pbxproj script
  2. Rebuild
  3. Log fix in INTEGRATION_LOG.md
```

### Test Failure → Lead Handles

```
Test output:
  test_Conflict_Detection FAILED

Lead Action:
  1. Analyze failure
  2. If code bug → Fix directly or update TASK file
  3. If test bug → Fix test
  4. Re-run tests
  5. Log in INTEGRATION_LOG.md
```

### Architectural Issue → Strategic Partner Handles

```
Lead LEAD_REPORT.md:
  "Workers implemented conflicting approaches to conflict detection"

Strategic Action:
  1. Review both approaches
  2. Decide which is better (or hybrid)
  3. Write updated DIRECTIVE.md with clarification
  4. Tell Andy to re-run Lead
```

---

## Timing Expectations

| Phase | Duration | Who |
|-------|----------|-----|
| Strategic Planning | 5-15 min | Strategic + Andy |
| Task Breakdown | 5-10 min | Lead |
| Worker Execution | 15-30 min | Workers (parallel) |
| Integration | 5-15 min | Lead |
| Review & Commit | 5-10 min | Strategic |
| **Total** | **35-80 min** | -- |

---

## Launch Sequence

### Step 1: Strategic Partner writes DIRECTIVE.md
(Done in Desktop App conversation)

### Step 2: Launch Lead Agent
```bash
cd ~/Claude && claude --model opus
```
Paste:
```
Read /Users/antti/Claude/.claude-team/LEAD/LEAD_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/STRATEGIC/DIRECTIVE.md. Create task files and update WORKSTREAM.md.
```

### Step 3: Lead outputs startup commands, then launch Workers
```bash
# Terminal 2-5 (or use launch script)
~/.claude-team/scripts/launch_workers.sh
```

### Step 4: Lead monitors and integrates

### Step 5: Strategic Partner reviews and commits

---

## Quick Reference

| I need to... | Talk to... | Via... |
|--------------|------------|--------|
| Plan a feature | Andy | Conversation |
| Specify requirements | Lead | DIRECTIVE.md |
| Check progress | STATUS.md | Read file |
| Review completion | Lead | LEAD_REPORT.md |
| Get architecture guidance | Strategic | Read ARCHITECTURE.md |
| Report a blocker | Lead | STATUS.md |
| Get task details | Worker | TASK_*.md |

---

*This protocol ensures clear communication with minimal overhead while maintaining quality control at each tier.*
