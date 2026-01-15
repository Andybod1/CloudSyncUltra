# Task Briefing: [Worker-ID]
## Issue #[NUMBER]: [Title]

**Sprint:** v[X.X.X]
**Priority:** [High/Medium/Low]
**Size:** [XS/S/M/L/XL]
**Worker:** [Dev-1/Dev-2/Dev-3]

---

## ⚠️ MANDATORY: Read First

**Before starting, read:** `.claude-team/templates/WORKER_QUALITY_STANDARDS.md`

Quick reminders:
- BUILD MUST PASS before marking complete
- VERIFY types exist before using them
- NEW FILES must be added to Xcode project
- STAY in your file ownership lane

---

## Objective

[Clear, concise description of what needs to be built. 2-3 sentences max.]

---

## Type Inventory

### Types You Can Use (verified to exist):
```swift
// Models
CloudRemote          // CloudSyncApp/Models/CloudRemote.swift
FileItem             // CloudSyncApp/Models/FileItem.swift
SyncTask             // CloudSyncApp/Models/SyncTask.swift
PerformanceProfile   // CloudSyncApp/Models/PerformanceProfile.swift

// ViewModels
RemotesViewModel     // CloudSyncApp/ViewModels/RemotesViewModel.swift
TasksViewModel       // CloudSyncApp/ViewModels/TasksViewModel.swift

// Managers
RcloneManager        // CloudSyncApp/RcloneManager.swift
SyncManager          // CloudSyncApp/SyncManager.swift
EncryptionManager    // CloudSyncApp/EncryptionManager.swift

// SwiftUI
Color.accentColor    // System blue (NOT AppTheme)
Color.green          // Success
Color.orange         // Warning
Color.red            // Error
```

### Types That DO NOT Exist (don't use):
```swift
// ❌ These will cause build failures:
AppTheme             // Use Color.accentColor instead
HelpTopic            // Create if needed, or ask SP
CrashReport          // Use existing crash handling
```

---

## File Ownership

### Files You Own (can create/modify):
| File | Action | Purpose |
|------|--------|---------|
| `CloudSyncApp/[Path]/NewFile.swift` | Create | [Purpose] |
| `CloudSyncApp/[Path]/Existing.swift` | Modify | [What change] |

### Files OFF LIMITS (do not touch):
- `CloudSyncAppApp.swift` - Shared, requires coordination
- `MainWindow.swift` - Shared, requires coordination
- `ContentView.swift` - Shared, requires coordination
- Any file not listed in "Files You Own"

### If You Need to Modify a Shared File:
1. Update STATUS.md with ⚠️ NEEDS COORDINATION
2. Describe what change you need
3. Wait for Strategic Partner approval

---

## Deliverables

### 1. [First Deliverable]

**File:** `CloudSyncApp/[Path]/[File].swift`
**Action:** [Create/Modify]

Requirements:
- [ ] [Specific requirement 1]
- [ ] [Specific requirement 2]
- [ ] [Specific requirement 3]

Implementation guidance:
```swift
// Example pattern to follow
struct Example {
    // Keep it simple
}
```

### 2. [Second Deliverable]

**File:** `CloudSyncApp/[Path]/[File].swift`
**Action:** [Create/Modify]

Requirements:
- [ ] [Specific requirement 1]
- [ ] [Specific requirement 2]

---

## Implementation Approach

### Step 1: Verify Prerequisites
```bash
# Verify files exist
ls -la CloudSyncApp/[Path]/

# Verify types you'll use
grep -r "struct CloudRemote" CloudSyncApp/
```

### Step 2: Implement First Deliverable
1. Create/modify the file
2. Run build: `xcodebuild build 2>&1 | tail -5`
3. Fix any errors before proceeding

### Step 3: Implement Second Deliverable
1. Create/modify the file
2. Run build: `xcodebuild build 2>&1 | tail -5`
3. Fix any errors before proceeding

### Step 4: Final Verification
```bash
# Full build
cd ~/Claude && xcodebuild build 2>&1 | tail -10

# Verify new files in project (if created)
grep "NewFile.swift" CloudSyncApp.xcodeproj/project.pbxproj
```

---

## Constraints

### DO:
- ✅ Use existing types from Type Inventory
- ✅ Follow existing code patterns
- ✅ Keep implementations simple
- ✅ Verify build after each change
- ✅ Add new files to Xcode project

### DON'T:
- ❌ Create new types without checking they don't exist
- ❌ Modify files outside your ownership
- ❌ Add "nice to have" features not in spec
- ❌ Proceed with broken build
- ❌ Use complex abstractions for simple tasks

---

## Testing Requirements

- [ ] Build succeeds: `xcodebuild build`
- [ ] [Specific test requirement if applicable]
- [ ] All existing tests pass: `xcodebuild test -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep "Executed"`

---

## Acceptance Criteria

All must be true to mark complete:

- [ ] [Criterion 1 - specific and measurable]
- [ ] [Criterion 2 - specific and measurable]
- [ ] [Criterion 3 - specific and measurable]
- [ ] Build succeeds with no errors
- [ ] No new compiler warnings
- [ ] New files added to Xcode project

---

## Definition of Done Checklist

Copy this to your completion report:

```markdown
## Definition of Done
- [ ] All acceptance criteria met
- [ ] `xcodebuild build` shows "BUILD SUCCEEDED"
- [ ] New files in Xcode project (verified with grep)
- [ ] No new compiler warnings
- [ ] Completion report written to outputs/
```

---

## Commands Reference

```bash
# Build (run after EVERY change)
cd ~/Claude && xcodebuild build 2>&1 | tail -5

# Run tests
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed"

# Verify type exists
grep -r "struct TypeName" CloudSyncApp/
grep -r "class ClassName" CloudSyncApp/

# Verify file in project
grep "FileName.swift" CloudSyncApp.xcodeproj/project.pbxproj

# Revert if stuck
git checkout -- CloudSyncApp/[File].swift
```

---

## If Blocked

1. **Build error you can't fix:**
   - Run `git checkout -- .` to reset
   - Update STATUS.md with ⚠️ BLOCKED
   - Document the error message

2. **Need a type that doesn't exist:**
   - Do NOT create it yourself
   - Update STATUS.md with ⚠️ BLOCKED
   - Document what type you need and why

3. **Need to modify a shared file:**
   - Update STATUS.md with ⚠️ NEEDS COORDINATION
   - Wait for Strategic Partner approval

---

## Completion Report Location

Write your report to: `.claude-team/outputs/[WORKER]_COMPLETE.md`

Use the template from WORKER_QUALITY_STANDARDS.md

---

*Task created: [DATE]*
*Sprint: v[X.X.X]*
