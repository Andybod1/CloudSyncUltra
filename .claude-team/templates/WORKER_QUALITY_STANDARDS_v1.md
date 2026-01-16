# Worker Quality Standards

> **MANDATORY FOR ALL WORKERS** - Read this before starting any task.
> These standards exist because quality issues cost more to fix than to prevent.

---

## The Golden Rules

### 1. BUILD MUST PASS
```
❌ NEVER mark a task complete if the build fails
❌ NEVER assume "it should work"
✅ ALWAYS run: xcodebuild build 2>&1 | tail -5
✅ ALWAYS see "BUILD SUCCEEDED" before completing
```

### 2. USE EXISTING TYPES
```
❌ NEVER invent types that don't exist (AppTheme, HelpTopic, etc.)
❌ NEVER assume a type exists without checking
✅ ALWAYS grep for a type before using it
✅ ALWAYS use types listed in your briefing's Type Inventory
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
❌ NEVER touch shared files (MainWindow, CloudSyncAppApp) without permission
✅ ALWAYS check the "Files OFF LIMITS" section
✅ ALWAYS ask Strategic Partner if unsure
```

### 5. KEEP IT SIMPLE
```
❌ NEVER create complex abstractions for simple tasks
❌ NEVER add "nice to have" features not in the spec
✅ ALWAYS implement the minimum that works
✅ ALWAYS prefer 10 simple lines over 1 clever line
```

---

## Pre-Flight Checklist

Before writing ANY code, complete this checklist:

```markdown
## Pre-Flight (copy to your report)
- [ ] Read the full task briefing
- [ ] Identified all files I need to modify
- [ ] Verified those files exist: `ls -la <path>`
- [ ] Checked types I'll use exist: `grep -r "struct TypeName" CloudSyncApp/`
- [ ] Confirmed no file conflicts with other workers
- [ ] Understood acceptance criteria
```

---

## Type Verification Commands

Before using ANY type, verify it exists:

```bash
# Check if a type exists
grep -r "struct CloudRemote" CloudSyncApp/
grep -r "class RcloneManager" CloudSyncApp/
grep -r "enum PerformanceProfile" CloudSyncApp/

# Check what's in a file
head -50 CloudSyncApp/Models/CloudRemote.swift

# List all types in a directory
grep -rh "^struct\|^class\|^enum\|^protocol" CloudSyncApp/Models/
```

---

## Build Verification

### After EVERY change, verify build:

```bash
cd ~/Claude && xcodebuild build 2>&1 | tail -10
```

### Expected output:
```
** BUILD SUCCEEDED **
```

### If build fails:
1. **READ the error message**
2. **FIX the issue** (don't work around it)
3. **Rebuild** until it succeeds
4. **NEVER proceed** with a broken build

---

## Adding Files to Xcode Project

When you create a new .swift file, it must be added to the Xcode project.

### Option 1: Use the helper script (preferred)
```bash
./scripts/add-to-xcode.sh CloudSyncApp/NewFile.swift
```

### Option 2: Manual verification
```bash
# Check if file is in project
grep "NewFile.swift" CloudSyncApp.xcodeproj/project.pbxproj

# If not found, the file won't compile!
# Ask Strategic Partner to add it via Xcode
```

### Common mistake:
```
❌ Created CloudSyncApp/Utilities/Helper.swift
❌ Build passes (file is ignored!)
❌ Later: "Cannot find 'Helper' in scope"
```

---

## File Ownership Rules

### Shared Files (NEVER modify without coordination):
- `CloudSyncAppApp.swift` - App entry point
- `MainWindow.swift` - Main navigation
- `ContentView.swift` - Root view
- `Info.plist` - App configuration

### How to check ownership:
1. Look at your briefing's "Files You Own" section
2. If a file isn't listed, ASK before modifying
3. When in doubt, create a NEW file instead

---

## Common Quality Failures

### 1. "Cannot find 'X' in scope"
**Cause:** Using a type that doesn't exist
**Fix:** Verify type exists with grep before using

### 2. "File not in project"
**Cause:** Created .swift file but didn't add to Xcode
**Fix:** Use add-to-xcode.sh or ask Strategic Partner

### 3. "Merge conflict"
**Cause:** Modified file another worker was editing
**Fix:** Follow file ownership rules strictly

### 4. "The compiler is unable to type-check this expression"
**Cause:** Overly complex code
**Fix:** Break into smaller functions, use explicit types

### 5. "Build succeeds but doesn't work"
**Cause:** File not actually in project
**Fix:** Verify with grep in project.pbxproj

---

## Definition of Done

A task is ONLY complete when ALL of these are true:

```markdown
## Definition of Done Checklist
- [ ] All acceptance criteria met
- [ ] `xcodebuild build` shows "BUILD SUCCEEDED"
- [ ] New files added to Xcode project (verified with grep)
- [ ] No new compiler warnings
- [ ] Existing tests still pass (if applicable)
- [ ] Code follows existing patterns
- [ ] Completion report written
```

---

## Completion Report Template

```markdown
# [Worker] Completion Report

**Task:** [Task name and issue number]
**Status:** ✅ COMPLETE

## Pre-Flight Verification
- [x] Read full task briefing
- [x] Verified target files exist
- [x] Confirmed types exist
- [x] No file conflicts

## Files Created
| File | Added to Xcode | Build Verified |
|------|----------------|----------------|
| `CloudSyncApp/X.swift` | ✅ Yes | ✅ Yes |

## Files Modified
| File | Changes |
|------|---------|
| `CloudSyncApp/Y.swift` | Added Z method |

## Build Verification
```
** BUILD SUCCEEDED **
```

## Definition of Done
- [x] Acceptance criteria met
- [x] Build succeeds
- [x] Files in Xcode project
- [x] No new warnings
- [x] Tests pass

## Summary
[Brief description of implementation]
```

---

## Emergency Procedures

### Build broken and can't fix:
1. `git checkout -- .` (revert all changes)
2. Update STATUS.md with ⚠️ BLOCKED
3. Document what went wrong
4. Wait for Strategic Partner

### Accidentally modified wrong file:
1. `git checkout -- <file>` (revert that file)
2. Continue with correct files
3. Report the incident

### Type doesn't exist that you need:
1. **DON'T create it yourself**
2. Update STATUS.md with ⚠️ BLOCKED
3. Document: "Need type X for Y purpose"
4. Wait for Strategic Partner to coordinate

---

*Quality is not negotiable. These standards protect everyone's time.*
