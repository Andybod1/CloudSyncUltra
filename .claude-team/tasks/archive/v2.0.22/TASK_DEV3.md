# TASK_DEV3.md - Transfer Preview (Dry-Run)

**Worker:** Dev-3 (Services)
**Status:** ✅ COMPLETE
**Priority:** Medium  
**Size:** M (Medium - ~1.5 hours)  
**Issue:** #55 (partial)

---

## Objective

Add transfer preview capability that shows users what will happen before a sync operation executes. This uses rclone's `--dry-run` flag to preview changes without executing them.

## Background

Users want to see what files will be transferred, deleted, or modified before a sync actually runs. This builds confidence and prevents accidental data loss.

## Implementation

### 1. Create TransferPreview Model

Create `/Users/antti/Claude/CloudSyncApp/Models/TransferPreview.swift`:

```swift
import Foundation

/// Represents a preview of what a transfer operation will do
struct TransferPreview {
    let filesToTransfer: [PreviewItem]
    let filesToDelete: [PreviewItem]
    let filesToUpdate: [PreviewItem]
    let totalSize: Int64
    let estimatedTime: TimeInterval?
    
    var totalItems: Int {
        filesToTransfer.count + filesToDelete.count + filesToUpdate.count
    }
    
    var isEmpty: Bool {
        totalItems == 0
    }
}

struct PreviewItem: Identifiable {
    let id = UUID()
    let path: String
    let size: Int64
    let operation: PreviewOperation
    let modifiedDate: Date?
}

enum PreviewOperation: String {
    case transfer = "Transfer"
    case delete = "Delete"
    case update = "Update"
    case skip = "Skip"
    
    var iconName: String {
        switch self {
        case .transfer: return "arrow.right.circle"
        case .delete: return "trash"
        case .update: return "arrow.triangle.2.circlepath"
        case .skip: return "forward"
        }
    }
}
```

### 2. Add Preview Method to SyncManager

In `/Users/antti/Claude/CloudSyncApp/SyncManager.swift`, add:

```swift
/// Generate a preview of what sync will do (dry-run)
func previewSync(task: SyncTask) async throws -> TransferPreview {
    // Use rclone with --dry-run flag
    let output = try await rcloneManager.runDryRun(
        source: task.sourcePath,
        destination: task.destinationPath,
        operation: task.operation
    )
    
    return parsePreviewOutput(output)
}

private func parsePreviewOutput(_ output: String) -> TransferPreview {
    // Parse rclone dry-run output
    // Lines like: "2026/01/15 12:00:00 NOTICE: file.txt: Skipped copy..."
    var transfers: [PreviewItem] = []
    var deletes: [PreviewItem] = []
    var updates: [PreviewItem] = []
    
    let lines = output.components(separatedBy: "\n")
    for line in lines {
        if line.contains("Copied") || line.contains("copy") {
            // Parse transfer
            if let item = parsePreviewLine(line, operation: .transfer) {
                transfers.append(item)
            }
        } else if line.contains("Deleted") || line.contains("delete") {
            if let item = parsePreviewLine(line, operation: .delete) {
                deletes.append(item)
            }
        }
        // Add more parsing as needed
    }
    
    return TransferPreview(
        filesToTransfer: transfers,
        filesToDelete: deletes,
        filesToUpdate: updates,
        totalSize: transfers.reduce(0) { $0 + $1.size },
        estimatedTime: nil
    )
}
```

### 3. Add Dry-Run to RcloneManager

In `/Users/antti/Claude/CloudSyncApp/RcloneManager.swift`, add:

```swift
/// Run rclone in dry-run mode to preview changes
func runDryRun(source: String, destination: String, operation: SyncOperation) async throws -> String {
    var args = buildBaseArguments(source: source, destination: destination, operation: operation)
    args.append("--dry-run")
    args.append("-v")  // Verbose output for parsing
    
    return try await executeRclone(arguments: args)
}
```

## Files to Create

1. `/Users/antti/Claude/CloudSyncApp/Models/TransferPreview.swift`

## Files to Modify

1. `/Users/antti/Claude/CloudSyncApp/SyncManager.swift` - Add preview method and dry-run logic

**⚠️ IMPORTANT: Do NOT modify RcloneManager.swift** - Dev-2 is working on it.
Instead, implement dry-run in SyncManager by building the rclone command with --dry-run flag directly.

## Acceptance Criteria

- [x] TransferPreview model created
- [x] SyncManager.previewSync() method works
- [x] Dry-run implemented in SyncManager (no RcloneManager changes per instructions)
- [x] Build succeeds
- [x] Basic tests added

## Testing

```bash
cd /Users/antti/Claude
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

## Completion Protocol

1. Create TransferPreview model
2. Add dry-run to RcloneManager
3. Add previewSync to SyncManager
4. Build and verify
5. Commit: `feat(services): Add transfer preview with dry-run support (#55)`
6. Report completion

---

**Use /think for implementation planning.**
