# Phase 3 Brief: SyncTask Error State & UI Integration

## Issue Reference
GitHub Issue: #13 - Error handling - SyncTask error state and Tasks UI
Parent Issue: #8 - Comprehensive error handling

## Sprint Context
**PHASE 3 of coordinated Error Handling Sprint**
Dependencies: Requires Phase 1 (#11) AND Phase 2 (#12, #15) complete

## Worker Assignment
This phase requires BOTH workers:
- **Dev-3:** Model updates (SyncTask)
- **Dev-1:** UI updates (TasksView)

Both will work from this shared brief and coordinate on the interface.

---

## Objective
Update SyncTask model to track error states and update TasksView to display failed tasks with clear error information.

---

## PART A: Dev-3 - Model Updates

### File: CloudSyncApp/Models/SyncTask.swift

Location: Find the SyncTask struct (likely around line 10-50)

### Task 1: Add Error Fields

Add these fields to SyncTask:

```swift
struct SyncTask: Identifiable, Codable {
    // Existing fields...
    var id: UUID
    var type: TaskType
    var status: TaskStatus
    var sourceName: String
    var destinationName: String
    var filesTransferred: Int
    var totalFiles: Int
    // ... other existing fields
    
    // ADD THESE NEW FIELDS:
    
    /// The error that occurred (if any)
    var error: TransferError?
    
    /// List of files that failed to transfer
    var failedFiles: [String] = []
    
    /// Whether some files succeeded and some failed
    var partiallyCompleted: Bool = false
    
    /// Timestamp when error occurred
    var errorTimestamp: Date?
}
```

### Task 2: Update TaskStatus Enum

Add new status cases:

```swift
enum TaskStatus: String, Codable {
    case pending = "pending"
    case running = "running"
    case completed = "completed"
    case failed = "failed"                    // ADD THIS
    case partiallyCompleted = "partial"       // ADD THIS
    case cancelled = "cancelled"
}
```

### Task 3: Add Computed Properties

Add these helper properties to SyncTask:

```swift
extension SyncTask {
    
    /// User-friendly error message
    var errorMessage: String? {
        error?.userMessage
    }
    
    /// Short error title
    var errorTitle: String? {
        error?.title
    }
    
    /// Whether the error can be retried
    var canRetry: Bool {
        error?.isRetryable ?? false
    }
    
    /// Whether this is a critical error
    var isCriticalError: Bool {
        error?.isCritical ?? false
    }
    
    /// Summary for partial failures
    var failureSummary: String? {
        guard partiallyCompleted else { return nil }
        
        let failed = failedFiles.count
        let succeeded = filesTransferred
        let total = failed + succeeded
        
        return "\(succeeded) of \(total) files completed"
    }
}
```

### Dev-3 Completion Checklist:
- [ ] Error-related fields added to SyncTask
- [ ] TaskStatus enum updated with .failed and .partiallyCompleted
- [ ] Computed properties added
- [ ] Code compiles
- [ ] Struct still conforms to Codable

---

## PART B: Dev-1 - UI Updates

### File: CloudSyncApp/Views/TasksView.swift

Location: Main tasks display view

### Task 1: Update Task Card Design

Find the task row/card display and enhance it to show error states:

```swift
private func taskCard(for task: SyncTask) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        // Header row with status
        HStack {
            // Status icon
            statusIcon(for: task)
            
            VStack(alignment: .leading, spacing: 2) {
                // Task title
                Text("\(task.type.displayName) • \(task.sourceName) → \(task.destinationName)")
                    .font(.headline)
                    .foregroundStyle(task.status == .failed ? .red : .primary)
                
                // Status text
                Text(statusText(for: task))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Action buttons
            taskActions(for: task)
        }
        
        // Progress bar (if running)
        if task.status == .running {
            ProgressView(value: task.progress)
                .progressViewStyle(.linear)
        }
        
        // Error display (if failed)
        if task.status == .failed || task.status == .partiallyCompleted {
            errorDisplay(for: task)
        }
    }
    .padding()
    .background(cardBackground(for: task))
    .cornerRadius(8)
    .overlay(
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(cardBorder(for: task), lineWidth: 1)
    )
}
```

### Task 2: Add Status Icon Method

```swift
@ViewBuilder
private func statusIcon(for task: SyncTask) -> some View {
    switch task.status {
    case .completed:
        Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(.green)
    case .failed:
        Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.red)
    case .partiallyCompleted:
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundStyle(.orange)
    case .running:
        ProgressView()
            .controlSize(.small)
    case .pending:
        Image(systemName: "clock.fill")
            .foregroundStyle(.secondary)
    case .cancelled:
        Image(systemName: "stop.circle.fill")
            .foregroundStyle(.secondary)
    }
}
```

### Task 3: Add Error Display Component

```swift
@ViewBuilder
private func errorDisplay(for task: SyncTask) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        // Error message
        if let errorMessage = task.errorMessage {
            HStack(spacing: 8) {
                Image(systemName: task.isCriticalError ? "exclamationmark.octagon" : "exclamationmark.triangle")
                    .foregroundStyle(task.isCriticalError ? .red : .orange)
                
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        
        // Failure summary
        if let summary = task.failureSummary {
            Text(summary)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        
        // Action buttons
        HStack(spacing: 12) {
            // Retry button (if retryable)
            if task.canRetry {
                Button(action: { retryTask(task) }) {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            // View details button
            Button(action: { showTaskDetails(task) }) {
                Label("Details", systemImage: "info.circle")
                    .font(.caption.weight(.medium))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
    .padding(8)
    .background(Color.red.opacity(0.05))
    .cornerRadius(6)
}
```

### Task 4: Add Helper Methods

```swift
private func statusText(for task: SyncTask) -> String {
    switch task.status {
    case .completed:
        return "Completed • \(task.filesTransferred) files"
    case .failed:
        return "Failed • \(task.errorTitle ?? "Unknown error")"
    case .partiallyCompleted:
        return "Partial • \(task.failureSummary ?? "")"
    case .running:
        return "Running • \(task.filesTransferred) of \(task.totalFiles) files"
    case .pending:
        return "Pending"
    case .cancelled:
        return "Cancelled"
    }
}

private func cardBackground(for task: SyncTask) -> Color {
    switch task.status {
    case .failed:
        return Color.red.opacity(0.05)
    case .partiallyCompleted:
        return Color.orange.opacity(0.05)
    default:
        return Color(NSColor.controlBackgroundColor)
    }
}

private func cardBorder(for task: SyncTask) -> Color {
    switch task.status {
    case .failed:
        return .red.opacity(0.3)
    case .partiallyCompleted:
        return .orange.opacity(0.3)
    default:
        return Color.gray.opacity(0.2)
    }
}

private func retryTask(_ task: SyncTask) {
    // TODO: Implement retry logic
    // This will re-initiate the transfer
    print("Retrying task: \(task.id)")
}

private func showTaskDetails(_ task: SyncTask) {
    // TODO: Show detailed error info, failed files list, etc.
    print("Showing details for task: \(task.id)")
}
```

### Task 5: Update Task State When Errors Occur

Find where tasks are created/updated (likely in TasksViewModel or MainWindow).

Add error handling when receiving progress updates:

```swift
// Example in transfer completion handler:
for try await progress in rclone.uploadWithProgress(...) {
    // Update progress
    
    // Check for errors
    if let error = progress.error {
        task.error = error
        task.errorTimestamp = Date()
        task.failedFiles = progress.failedFiles
        task.partiallyCompleted = progress.partialSuccess
        
        if progress.partialSuccess {
            task.status = .partiallyCompleted
        } else {
            task.status = .failed
        }
    }
}
```

### Dev-1 Completion Checklist:
- [ ] Task card displays error states
- [ ] Error icon shows (red X for failed, orange triangle for partial)
- [ ] Error message displays clearly
- [ ] Failure summary shows (X of Y files)
- [ ] Retry button appears for retryable errors
- [ ] Details button appears for errors
- [ ] Card background reflects error state (red/orange tint)
- [ ] Card border reflects error state
- [ ] Status text updated for failed/partial states
- [ ] Code compiles
- [ ] UI looks professional

---

## Integration & Coordination

### Shared Interface
Dev-3's model provides these fields that Dev-1's UI will display:
- `task.error` → Full error object
- `task.errorMessage` → Display message
- `task.errorTitle` → Short title
- `task.canRetry` → Show retry button
- `task.isCriticalError` → Red vs orange styling
- `task.failureSummary` → "X of Y" text
- `task.failedFiles` → List for details view

### Communication
- Dev-3: Complete model changes first, commit, notify Dev-1
- Dev-1: Pull latest changes, implement UI on top of new model
- Both: Test together to verify data flows correctly

---

## Build & Test

```bash
cd /Users/antti/Claude

# Build after both workers complete their parts
xcodebuild -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -configuration Debug \
  build 2>&1 | grep -E '(error|warning|BUILD SUCCEEDED|BUILD FAILED)'
```

---

## Manual Testing

Test these scenarios:

1. **Complete Failure:**
- Trigger an error that fails entire transfer
- Should show: Red X, error message, retry button (if retryable)

2. **Partial Success:**
- Upload 10 files, make 3 fail mid-transfer
- Should show: Orange triangle, "7 of 10 files completed", error message

3. **Critical Error:**
- Trigger quota exceeded error
- Should show: Red styling, prominent error, no retry (not retryable)

4. **Retryable Error:**
- Trigger connection timeout
- Should show: Orange styling, retry button, less alarming presentation

---

## Completion

After BOTH Dev-1 and Dev-3 complete:

**Shared completion in**: `/Users/antti/Claude/.claude-team/outputs/PHASE3_COMPLETE.md`

```markdown
# Phase 3 Completion Report

**Tasks:** SyncTask Error States + TasksView UI (#13)
**Status:** COMPLETE
**Sprint:** Error Handling Phase 3

## Dev-3 Deliverables
- Updated SyncTask model with error fields
- Added .failed and .partiallyCompleted status types
- Added computed properties for error display

## Dev-1 Deliverables
- Enhanced task cards with error displays
- Status-based styling (red/orange backgrounds)
- Retry and Details buttons
- Error message and failure summary display

## Files Modified
- `CloudSyncApp/Models/SyncTask.swift` (Dev-3)
- `CloudSyncApp/Views/TasksView.swift` (Dev-1)

## Integration Success
✅ Model and UI integrated successfully
✅ Error data flows from SyncTask to UI
✅ Professional error presentation
✅ Action buttons functional

## Build Status
BUILD SUCCEEDED

## Ready for Phase 4
✅ Complete error handling system in place
✅ QA can now write comprehensive tests

## Commits
```bash
git add CloudSyncApp/Models/SyncTask.swift CloudSyncApp/Views/TasksView.swift
git commit -m "feat(ui): SyncTask error states and TasksView integration

- Added error fields to SyncTask model
- Added .failed and .partiallyCompleted states
- Enhanced TasksView with error display
- Retry and details buttons for failed tasks
- Implements #13

Part of Error Handling Sprint (Phase 3 complete)"
```
```

---

## Time Estimate
- Dev-3: 30-45 minutes
- Dev-1: 60-90 minutes
**Total: ~2 hours coordinated**
