# Worker Quality Standards v2.1

> **MANDATORY FOR ALL WORKERS** - Read this before starting any task.
> These standards exist because quality issues cost more to fix than to prevent.
>
> **Version:** 2.1 (2026-01-16)
> **Changes from v2.0:** Added pre-flight script, time-boxing, dependency checks, progress heartbeat, handoff protocol

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────┐
│  BEFORE CODING (Pre-Flight)                                     │
│  □ Run ownership check        ./scripts/check-ownership.sh     │
│  □ Check ALL files in task    Must ALL be in YOUR domain        │
│  □ Verify types exist         grep TYPE .claude-team/TYPE_INV   │
│  □ Check dependencies         Is blocking task complete?        │
│  □ Read task briefing fully                                     │
├─────────────────────────────────────────────────────────────────┤
│  DURING CODING                                                  │
│  □ Update progress            Every 30 min in task file         │
│  □ If stuck >15 min           STOP → Write ALERTS.md → Wait     │
├─────────────────────────────────────────────────────────────────┤
│  AFTER CODING                                                   │
│  □ Run QA script              ./scripts/worker-qa.sh            │
│  □ Include QA output          In completion report              │
│  □ Write completion report    Using template below              │
├─────────────────────────────────────────────────────────────────┤
│  IF BLOCKED                                                     │
│  □ STOP immediately           Do NOT modify wrong files         │
│  □ Write blocking report      WORKER_BLOCKED.md                 │
│  □ Alert Strategic Partner    echo "⚠️..." >> ALERTS.md         │
│  □ Wait for guidance          Do NOT try workarounds            │
├─────────────────────────────────────────────────────────────────┤
│  IF HANDING OFF                                                 │
│  □ Document what's done       Use handoff template              │
│  □ Commit partial work        git commit -m "WIP: ..."          │
│  □ Alert with handoff         echo "🔄..." >> ALERTS.md         │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Golden Rules

### 0. VERIFY OWNERSHIP FIRST (NEW)
```
❌ NEVER start coding without checking file ownership
❌ NEVER assume a task is correctly assigned to you
✅ ALWAYS verify files in task are in YOUR domain
✅ ALWAYS block immediately if ownership conflict exists
```

**Ownership Check Command:**
```bash
# Check if file is in your domain
cat .claude-team/FILE_OWNERSHIP.md | grep -A5 "Dev-1"  # Replace with your worker ID
```

### 1. BUILD MUST PASS
```
❌ NEVER mark a task complete if the build fails
❌ NEVER assume "it should work"
✅ ALWAYS run: ./scripts/worker-qa.sh
✅ ALWAYS see "BUILD SUCCEEDED" before completing
```

### 2. USE EXISTING TYPES
```
❌ NEVER invent types that don't exist (AppTheme, HelpTopic, etc.)
❌ NEVER assume a type exists without checking
✅ ALWAYS check: cat .claude-team/TYPE_INVENTORY.md
✅ ALWAYS grep for a type if not in inventory
```

### 3. ADD FILES TO XCODE
```
❌ NEVER just create a .swift file and assume it compiles
✅ ALWAYS verify new files are in the Xcode project
✅ ALWAYS check: grep "YourFile.swift" *.xcodeproj/project.pbxproj
```

### 4. STAY IN YOUR LANE
```
❌ NEVER modify files owned by other workers
❌ NEVER touch shared files without permission
✅ ALWAYS check the File Ownership Matrix below
✅ ALWAYS block and escalate if ownership conflict
```

### 5. KEEP IT SIMPLE
```
❌ NEVER create complex abstractions for simple tasks
❌ NEVER add "nice to have" features not in the spec
✅ ALWAYS implement the minimum that works
✅ ALWAYS prefer 10 simple lines over 1 clever line
```

### 6. TIME-BOX YOUR WORK (NEW)
```
❌ NEVER spend >15 minutes stuck without escalating
❌ NEVER keep struggling hoping it will work
✅ ALWAYS write to ALERTS.md after 15 min stuck
✅ ALWAYS stop and wait for Strategic Partner guidance
```

### 7. REPORT PROGRESS (NEW)
```
❌ NEVER go dark for extended periods
✅ ALWAYS update task file every 30 minutes with status
✅ ALWAYS note: what's done, what's next, any blockers
```

---

## Pre-Flight Script (REQUIRED - Run First!)

**Before writing ANY code, run this:**
```bash
# Check ALL files you plan to modify
./scripts/check-ownership.sh CloudSyncApp/Views/SomeView.swift dev-1

# Expected output for authorized:
# ✅ AUTHORIZED - dev-1 owns this file

# If you see this, STOP IMMEDIATELY:
# ❌ NOT AUTHORIZED - File belongs to dev-1, not dev-2
```

**Pre-Flight Sequence:**
```bash
# 1. Check ownership for EVERY file in your task
./scripts/check-ownership.sh <file1> <your-worker-id>
./scripts/check-ownership.sh <file2> <your-worker-id>

# 2. Verify types exist
grep "TypeName" .claude-team/TYPE_INVENTORY.md

# 3. Check for dependencies on other workers
cat .claude-team/SPRINT_STATUS.md | grep -A2 "your-task-number"
```

**If ANY check fails → STOP → Write ALERTS.md → Wait for SP**

---

## Dependency Check (NEW)

Before starting, verify your task has no blockers:

```bash
# Check if your task depends on another worker's output
cat .claude-team/SPRINT_STATUS.md

# Look for:
# - Tasks that must complete before yours
# - Files another worker is currently modifying
# - Types another worker is creating
```

**If dependency exists:**
1. Check if dependent task is complete
2. If not complete → Wait or ask SP for guidance
3. If complete → Verify the output exists before starting

---

## Progress Heartbeat (NEW)

**Every 30 minutes, update your task file:**

```markdown
## Progress Update - [TIME]
**Status:** 🟡 In Progress
**Completed:** [What you've done]
**Next:** [What you're working on]
**Blockers:** [None / Description]
**ETA:** [Estimated time to completion]
```

**Why this matters:**
- Strategic Partner can see you're alive
- Blockers get caught early
- Parallel workers stay coordinated

---

## Handoff Protocol (NEW)

When handing off work to another worker:

### 1. Document What's Done
```markdown
## Handoff from [Worker] to [Worker]
**Date:** YYYY-MM-DD
**Reason:** [Why handoff needed]

### Completed Work
- [x] Item 1
- [x] Item 2

### Remaining Work
- [ ] Item 3 (needs X)
- [ ] Item 4 (depends on Y)

### Files Modified
| File | Status | Notes |
|------|--------|-------|
| X.swift | ✅ Complete | Ready for review |
| Y.swift | 🟡 Partial | Lines 50-100 need work |

### Build Status
✅ Build passes with current changes

### Context for Next Worker
[Important decisions made, gotchas, etc.]
```

### 2. Commit Partial Work
```bash
git add -A
git commit -m "WIP: [Task] - Handoff to [Worker]"
```

### 3. Update ALERTS.md
```bash
echo "🔄 $(date) | [FROM] | HANDOFF | Handing #XX to [TO] - [reason]" >> .claude-team/ALERTS.md
```

---

## File Ownership Matrix

| Directory/File | Owner | Can Modify |
|----------------|-------|------------|
| `CloudSyncApp/Views/` | Dev-1 | Dev-1 only |
| `CloudSyncApp/ViewModels/` | Dev-1 | Dev-1 only |
| `CloudSyncApp/Components/` | Dev-1 | Dev-1 only |
| `CloudSyncApp/RcloneManager.swift` | Dev-2 | Dev-2 only |
| `CloudSyncApp/Models/` | Dev-3 | Dev-3 only |
| `CloudSyncApp/Managers/` | Dev-3 | Dev-3 only |
| `CloudSyncAppTests/` | QA | QA only |
| `.claude-team/` | Dev-Ops | Dev-Ops only |
| `scripts/` | Dev-Ops | Dev-Ops only |

### Shared Files (Require Coordination)
| File | Modify With Permission From |
|------|----------------------------|
| `CloudSyncAppApp.swift` | Strategic Partner |
| `MainWindow.swift` | Strategic Partner |
| `ContentView.swift` | Strategic Partner |
| `Info.plist` | Strategic Partner |

---

## Pre-Flight Checklist (REQUIRED)

Before writing ANY code, complete this checklist:

```markdown
## Pre-Flight (copy to your report)
- [ ] Verified file ownership matches my domain
- [ ] Read the full task briefing
- [ ] Identified all files I need to modify
- [ ] Verified those files exist: `ls -la <path>`
- [ ] Checked types in TYPE_INVENTORY.md
- [ ] Confirmed no file conflicts with other workers
- [ ] Understood acceptance criteria

## Ownership Verification
Files I will modify:
- `CloudSyncApp/Views/Example.swift` → Owner: Dev-1 → I am: Dev-1 ✅
```

**If ANY file is not in your domain: STOP and write a blocking report.**

---

## Type Verification

### Quick Check (Preferred)
```bash
cat .claude-team/TYPE_INVENTORY.md | grep "TypeName"
```

### Deep Check (If not in inventory)
```bash
grep -r "struct TypeName" CloudSyncApp/
grep -r "class ClassName" CloudSyncApp/
grep -r "enum EnumName" CloudSyncApp/
```

### If type doesn't exist:
1. **DON'T create it yourself**
2. Write blocking report
3. Document: "Need type X for Y purpose"
4. Alert Strategic Partner

---

## QA Script (REQUIRED)

### Run before completing ANY task:
```bash
./scripts/worker-qa.sh
```

### Expected output:
```
╔═══════════════════════════════════════════════════════════════╗
║              WORKER QA CHECKLIST                              ║
╚═══════════════════════════════════════════════════════════════╝

1. BUILD CHECK
   ✅ BUILD SUCCEEDED

2. WARNINGS CHECK
   ✅ No new warnings

3. PROJECT CHECK
   ✅ All files in project

══════════════════════════════════════════════════════════════════
✅ ALL CHECKS PASSED - Safe to complete task
══════════════════════════════════════════════════════════════════
```

**You MUST include this output in your completion report.**

---

## Completion Report Template (REQUIRED)

```markdown
# [Worker] Completion Report

**Task:** [Task name and issue number]
**Status:** ✅ COMPLETE
**Date:** YYYY-MM-DD

## Pre-Flight Verification
- [x] Verified file ownership matches my domain
- [x] Read full task briefing
- [x] Verified target files exist
- [x] Confirmed types exist in TYPE_INVENTORY.md
- [x] No file conflicts

## Ownership Verification
| File | Owner | My Role | Status |
|------|-------|---------|--------|
| `CloudSyncApp/Views/X.swift` | Dev-1 | Dev-1 | ✅ Authorized |

## Files Modified
| File | Changes |
|------|---------|
| `CloudSyncApp/Views/X.swift` | Added Y method |

## Files Created (if any)
| File | Added to Xcode | Build Verified |
|------|----------------|----------------|
| `CloudSyncApp/Views/Z.swift` | ✅ Yes | ✅ Yes |

## QA Script Output (REQUIRED)
```
╔═══════════════════════════════════════════════════════════════╗
║              WORKER QA CHECKLIST                              ║
╚═══════════════════════════════════════════════════════════════╝

1. BUILD CHECK
   ✅ BUILD SUCCEEDED

2. WARNINGS CHECK
   ✅ No new warnings

✅ ALL CHECKS PASSED
```

## Definition of Done
- [x] Acceptance criteria met
- [x] Build succeeds (QA script passed)
- [x] Files in Xcode project
- [x] No new warnings
- [x] Ownership verified

## Summary
[Brief description of implementation]
```

---

## Blocking Report Template (REQUIRED when blocked)

```markdown
# [Worker] Blocking Report

**Task:** [Task name and issue number]
**Status:** ⚠️ BLOCKED
**Date:** YYYY-MM-DD
**Worker:** [Your ID]

## Blocking Reason
[ ] File ownership conflict
[ ] Type doesn't exist
[ ] Build cannot be fixed
[ ] Unclear requirements
[ ] Other: ___________

## Details
[Explain the specific issue]

## Files Involved
| File | Required Owner | My Role | Conflict |
|------|---------------|---------|----------|
| `CloudSyncApp/Views/X.swift` | Dev-1 | Dev-2 | ❌ Not my domain |

## Recommended Resolution
- Option 1: [Reassign to correct worker]
- Option 2: [Grant temporary permission]
- Option 3: [Split the task]

## What I Did NOT Do
- ❌ Did not modify files outside my domain
- ❌ Did not create workarounds
- ✅ Followed quality standards

## Alert Sent
- [x] Added to ALERTS.md
```

---

## Alert System (NEW)

When blocked, you MUST alert Strategic Partner:

```bash
# Add alert to ALERTS.md
echo "⚠️ $(date +%Y-%m-%d\ %H:%M) | [WORKER-ID] | BLOCKED | [Brief reason]" >> .claude-team/ALERTS.md
```

Example:
```bash
echo "⚠️ 2026-01-16 08:14 | Dev-2 | BLOCKED | #103 requires Dev-1 files" >> .claude-team/ALERTS.md
```

---

## Emergency Procedures

### Build broken and can't fix:
1. `git checkout -- .` (revert all changes)
2. Write blocking report
3. Alert: `echo "⚠️ ... | BUILD BROKEN" >> .claude-team/ALERTS.md`
4. Wait for Strategic Partner

### File ownership conflict:
1. **STOP immediately** - Do NOT modify the file
2. Write blocking report with ownership details
3. Alert: `echo "⚠️ ... | OWNERSHIP CONFLICT" >> .claude-team/ALERTS.md`
4. Wait for reassignment

### Type doesn't exist:
1. **DON'T create it yourself**
2. Write blocking report
3. Document: "Need type X for Y purpose"
4. Alert: `echo "⚠️ ... | MISSING TYPE" >> .claude-team/ALERTS.md`

### Accidentally modified wrong file:
1. `git checkout -- <file>` (revert that file)
2. Report the incident in completion report
3. Continue with correct files

---

## Common Quality Failures

| Error | Cause | Prevention |
|-------|-------|------------|
| "Cannot find 'X' in scope" | Type doesn't exist | Check TYPE_INVENTORY.md first |
| "File not in project" | New file not added to Xcode | Run worker-qa.sh |
| "Merge conflict" | Modified other worker's file | Check ownership matrix |
| "Type-check expression" | Overly complex code | Keep it simple |
| "Build succeeds but doesn't work" | File not in project | Verify with grep |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-15 | Initial release |
| 2.0 | 2026-01-16 | Added: ownership validation, QA output requirement, alerts system, ownership matrix |
| 2.1 | 2026-01-16 | Added: pre-flight script, time-boxing (15 min), dependency checks, progress heartbeat (30 min), handoff protocol |

---

*Quality is not negotiable. These standards protect everyone's time.*
*Version 2.1 - Based on sprint v2.0.26 learnings*
