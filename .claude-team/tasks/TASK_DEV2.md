# Dev-2 Task: Cloud-to-Cloud Progress Fix

## Issue
- #21 (High): Progress not showing for Proton → Jottacloud transfers

---

## Problem
Cloud-to-cloud transfers complete successfully but show no progress in UI. User has no feedback during transfer.

## Investigation Steps

### 1. Check Debug Log
```bash
cat /tmp/cloudsync_transfer_debug.log
```
Look for cloud-to-cloud transfer entries and compare output format.

### 2. Find Cloud-to-Cloud Code Path
In `TransferView.swift`, find where cloud-to-cloud transfers are initiated (neither source nor dest is local).

### 3. Check RcloneManager
Look at `copyFiles()` or similar method - verify progress stream is connected.

## Likely Cause
Cloud-to-cloud uses different rclone output format. Server-side copies report differently than uploads/downloads.

## Fix Approach

### Option A: Ensure Progress Stream Connected
```swift
// In the cloud-to-cloud branch of TransferView.swift
// Make sure we're consuming the progress stream

let progressStream = try await RcloneManager.shared.copyFiles(
    from: sourcePath,
    to: destPath,
    sourceRemote: sourceRemote,
    destRemote: destRemote
)

for await progress in progressStream {
    await MainActor.run {
        transferProgress.percentage = progress.percentage
        transferProgress.speed = progress.speed
        // Update task
    }
}
```

### Option B: Different Progress Parsing
```swift
// Cloud-to-cloud may output:
// "Transferred: 5 / 10, 50%"
// vs upload which shows:
// "1.5 MiB / 3.0 MiB, 50%, 500 KiB/s"

func parseCloudToCloudProgress(from output: String) -> SyncProgress? {
    // Handle server-side copy format
    if let match = output.range(of: #"Transferred:\s*(\d+)\s*/\s*(\d+)"#, options: .regularExpression) {
        // Parse transferred/total files
    }
}
```

## Files to Check
- `CloudSyncApp/Views/TransferView.swift` - lines ~445-470 (cloud-to-cloud branch)
- `CloudSyncApp/RcloneManager.swift` - `copyFiles()` method

## Debug Tips
1. Add logging to cloud-to-cloud path
2. Print raw rclone output to see format
3. Compare with working local→cloud path

---

## Completion Checklist
- [ ] Identify root cause
- [ ] Implement fix
- [ ] Test Proton → Jottacloud transfer
- [ ] Verify progress shows
- [ ] Update STATUS.md when done

## Commit
```
git commit -m "fix(engine): Show progress for cloud-to-cloud transfers - Fixes #21"
```
