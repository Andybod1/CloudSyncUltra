# Dev-2 Task: RcloneManager Error Parsing - Phase 2

## Issue Reference
GitHub Issue: #12 - Error handling - RcloneManager error parsing
Parent Issue: #8 - Comprehensive error handling with clear user feedback

## Model: Opus (M ticket - complex integration with existing code)

## Sprint Context
**PHASE 2 of coordinated Error Handling Sprint**
Dependency: Requires #11 (TransferError model) - should be COMPLETE before you start
Parallel work: Dev-1 is enhancing ErrorBanner component simultaneously

---

## Objective
Add comprehensive error detection and parsing to RcloneManager's transfer methods. Parse rclone stderr output, identify error types, and propagate errors through progress streams.

## Prerequisites
✅ TransferError.swift must exist (created by Dev-3 in Phase 1)
✅ Verify it's imported: `import Foundation` and TransferError enum is available

---

## Implementation Tasks

### Task 1: Add Error Parsing Method

Add this to **RcloneManager.swift**:

```swift
// MARK: - Error Parsing

/// Parse rclone error output and return structured error
/// - Parameter output: stderr output from rclone
/// - Returns: TransferError if error detected, nil otherwise
private func parseError(from output: String) -> TransferError? {
    // First try pattern matching from TransferError
    if let error = TransferError.parse(from: output) {
        return error
    }
    
    // Fallback: Check for generic ERROR: lines
    let lines = output.components(separatedBy: .newlines)
    for line in lines {
        if line.contains("ERROR :") || line.contains("ERROR:") {
            let message = line
                .replacingOccurrences(of: #"^.*ERROR\s*:\s*"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !message.isEmpty {
                return .unknown(message: message)
            }
        }
    }
    
    return nil
}

/// Track failures during multi-file transfers
private struct TransferFailures {
    var failedFiles: [String] = []
    var errors: [TransferError] = []
    var lastError: TransferError?
    
    mutating func recordFailure(file: String, error: TransferError) {
        failedFiles.append(file)
        errors.append(error)
        lastError = error
    }
}
```

### Task 2: Update SyncProgress Model

Find the `SyncProgress` struct (likely in RcloneManager.swift around line 40-60) and add error fields:

```swift
struct SyncProgress: Codable {
    var bytesTransferred: Int64 = 0
    var totalBytes: Int64 = 0
    var filesTransferred: Int = 0
    var totalFiles: Int = 0
    var currentFile: String?
    var speed: Double = 0
    var eta: String?
    var percent: Double = 0
    
    // ADD THESE NEW FIELDS:
    var error: TransferError?           // The error that occurred
    var failedFiles: [String] = []      // List of files that failed
    var partialSuccess: Bool = false    // Some succeeded, some failed
    var errorMessage: String?           // User-friendly error message
}
```

### Task 3: Update uploadWithProgress() Method

Location: Around line 1100-1200 in RcloneManager.swift

**Current structure:**
```swift
func uploadWithProgress(...) -> AsyncThrowingStream<SyncProgress, Error> {
    AsyncThrowingStream { continuation in
        // ... process setup ...
        // ... progress parsing ...
        // ... process.waitUntilExit() ...
    }
}
```

**Add error handling:**

1. After process.waitUntilExit(), check exit code:
```swift
process.waitUntilExit()

let exitCode = process.terminationStatus
var finalProgress = currentProgress

// Check for errors
if exitCode != 0 {
    log("Upload failed with exit code \(exitCode)")
    log("Error output: \(errorOutput)")
    
    // Parse the error
    if let error = parseError(from: errorOutput) {
        finalProgress.error = error
        finalProgress.errorMessage = error.userMessage
        
        // Determine if partial success
        if finalProgress.filesTransferred > 0 && finalProgress.filesTransferred < finalProgress.totalFiles {
            finalProgress.partialSuccess = true
        }
        
        log("Detected error: \(error.title) - \(error.userMessage)")
    }
}

continuation.yield(finalProgress)

// Throw error if complete failure
if exitCode != 0 && finalProgress.filesTransferred == 0 {
    if let error = finalProgress.error {
        continuation.finish(throwing: error)
    } else {
        continuation.finish(throwing: TransferError.unknown(message: errorOutput))
    }
} else {
    continuation.finish()
}
```

2. Add error accumulation during progress parsing:
```swift
// Inside the progress parsing loop:
if line.contains("ERROR :") || line.contains("ERROR:") {
    log("Error detected: \(line)")
    errorOutput += line + "\n"
    
    // Try to extract filename from error
    if let fileMatch = line.range(of: #"\"([^\"]+)\""#, options: .regularExpression) {
        let fileName = String(line[fileMatch]).replacingOccurrences(of: "\"", with: "")
        currentProgress.failedFiles.append(fileName)
    }
}
```

### Task 4: Update download() Method

Location: Around line 1250-1350

Add similar error handling:
```swift
func download(...) async throws {
    // ... existing download logic ...
    
    process.waitUntilExit()
    let exitCode = process.terminationStatus
    
    if exitCode != 0 {
        log("Download failed with exit code \(exitCode)")
        log("Error output: \(errorOutput)")
        
        if let error = parseError(from: errorOutput) {
            log("Parsed error: \(error.title)")
            throw error
        } else {
            throw TransferError.unknown(message: errorOutput.isEmpty ? "Download failed" : errorOutput)
        }
    }
}
```

### Task 5: Update copyFiles() Method

Location: Around line 1450-1550

Add error handling for cloud-to-cloud transfers:
```swift
func copyFiles(...) async throws {
    // ... existing copy logic ...
    
    process.waitUntilExit()
    let exitCode = process.terminationStatus
    
    if exitCode != 0 {
        log("Copy failed with exit code \(exitCode)")
        log("Error output: \(errorOutput)")
        
        if let error = parseError(from: errorOutput) {
            log("Parsed error: \(error.title)")
            throw error
        } else {
            throw TransferError.unknown(message: errorOutput.isEmpty ? "Copy failed" : errorOutput)
        }
    }
}
```

### Task 6: Update copyBetweenRemotesWithProgress() Method

Location: Around line 1856

Add error handling to progress stream:
```swift
func copyBetweenRemotesWithProgress(...) -> AsyncThrowingStream<SyncProgress, Error> {
    AsyncThrowingStream { continuation in
        // ... existing logic ...
        
        process.waitUntilExit()
        let exitCode = process.terminationStatus
        var finalProgress = currentProgress
        
        if exitCode != 0 {
            log("Cloud-to-cloud copy failed with exit code \(exitCode)")
            
            if let error = parseError(from: errorOutput) {
                finalProgress.error = error
                finalProgress.errorMessage = error.userMessage
                
                if finalProgress.filesTransferred > 0 {
                    finalProgress.partialSuccess = true
                }
            }
        }
        
        continuation.yield(finalProgress)
        
        if exitCode != 0 && finalProgress.filesTransferred == 0 {
            if let error = finalProgress.error {
                continuation.finish(throwing: error)
            } else {
                continuation.finish(throwing: TransferError.unknown(message: errorOutput))
            }
        } else {
            continuation.finish()
        }
    }
}
```

---

## Exit Code Reference

Add comment at top of error handling section:
```swift
// MARK: - rclone Exit Codes
// 0  = Success
// 1  = Syntax error
// 2  = Error not otherwise categorised
// 3  = Directory not found
// 4  = File not found  
// 5  = Temporary error (retry)
// 6  = Less serious errors
// 7  = Fatal error
// 8  = Transfer limit exceeded
```

---

## Testing Strategy

### Manual Testing
After implementation, test these scenarios:

1. **Quota Exceeded:**
```bash
# Fill up a test Google Drive to quota, then upload large file
```

2. **Auth Error:**
```bash
# Revoke OAuth token, then try to transfer
```

3. **Connection Timeout:**
```bash
# Disconnect internet, try to upload
```

4. **File Not Found:**
```bash
# Try to download non-existent file
```

5. **Partial Success:**
```bash
# Upload 5 files where 2-3 will fail (e.g., due to quota mid-transfer)
```

---

## Validation Checklist

Before marking complete:

- [ ] `parseError(from:)` method added to RcloneManager
- [ ] `TransferFailures` struct added for tracking
- [ ] `SyncProgress` updated with error, failedFiles, partialSuccess, errorMessage fields
- [ ] `uploadWithProgress()` detects and reports errors
- [ ] `download()` throws proper TransferError on failure
- [ ] `copyFiles()` throws proper TransferError on failure  
- [ ] `copyBetweenRemotesWithProgress()` reports errors in stream
- [ ] Exit codes properly checked and logged
- [ ] Error output captured and parsed
- [ ] Partial success detected (some files succeeded)
- [ ] Failed files list populated when possible
- [ ] All existing functionality still works
- [ ] Code compiles without errors
- [ ] Build succeeds

---

## Build & Test

```bash
cd /Users/antti/Claude

# Clean build
xcodebuild clean -project CloudSyncApp.xcodeproj -scheme CloudSyncApp

# Build
xcodebuild -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -configuration Debug \
  build 2>&1 | grep -E '(error|warning|BUILD SUCCEEDED|BUILD FAILED)'
```

Expected: **BUILD SUCCEEDED**

---

## Completion Report

When done, create: `/Users/antti/Claude/.claude-team/outputs/DEV2_COMPLETE.md`

```markdown
# Dev-2 Completion Report

**Task:** RcloneManager Error Parsing (#12)
**Status:** COMPLETE
**Sprint:** Error Handling Phase 2

## Implementation Summary
Added comprehensive error detection to RcloneManager:
- Error parsing from rclone stderr
- Exit code handling with proper error mapping
- Progress stream error reporting
- Partial failure detection
- Failed file tracking

## Files Modified
- `CloudSyncApp/RcloneManager.swift`

## Methods Updated
1. Added `parseError(from:)` - Error detection
2. Added `TransferFailures` struct - Failure tracking
3. Updated `SyncProgress` - Added error fields
4. Updated `uploadWithProgress()` - Error reporting in stream
5. Updated `download()` - Throws TransferError
6. Updated `copyFiles()` - Throws TransferError
7. Updated `copyBetweenRemotesWithProgress()` - Error in stream

## Key Features
- ✅ Automatic error pattern matching
- ✅ Exit code interpretation
- ✅ Partial success detection
- ✅ Failed files tracking
- ✅ User-friendly error messages
- ✅ Proper error propagation

## Build Status
BUILD SUCCEEDED

## Testing Notes
[Add manual testing results here]

## Ready for Phase 3
✅ Errors are now detected and parsed
✅ Progress streams include error information
✅ Dev-1 can display these errors in UI
✅ Dev-3 can update SyncTask with error states

## Commit
```bash
git add CloudSyncApp/RcloneManager.swift
git commit -m "feat(engine): Add comprehensive error parsing to RcloneManager

- Parse rclone stderr for known error patterns
- Handle all exit codes properly
- Report errors through progress streams
- Track partial failures and failed files
- Implements #12

Part of Error Handling Sprint (Phase 2/2 complete)"
```
```

---

## Integration Notes for Next Phase

**For Dev-1 & Dev-3 (Phase 3):**
- `SyncProgress` now includes: error, errorMessage, failedFiles, partialSuccess
- Check these fields in TransferView to display errors
- Use `error?.isRetryable` to show retry button
- Use `partialSuccess` to show "X of Y files" messages

---

## Time Estimate
1.5-2 hours for thorough implementation

**WAIT for Dev-3 to complete Phase 1 before starting!**
Check STATUS.md for Dev-3 completion status.
