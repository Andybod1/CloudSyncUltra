# Dev-2 Task: OSLog Implementation

**Sprint:** Maximum Productivity
**Priority:** Medium
**Worker:** Dev-2 (Engine Layer)

---

## Objective

Replace all print() statements in RcloneManager.swift with Apple's OSLog unified logging system.

## Files to Modify

- `CloudSyncApp/RcloneManager.swift`
- Create `CloudSyncApp/Logger+Extensions.swift` (if not exists)

## Tasks

### 1. Create Logger Extension (if needed)

```swift
// Logger+Extensions.swift
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.cloudsync.ultra"

    /// Logs related to network operations
    static let network = Logger(subsystem: subsystem, category: "network")

    /// Logs related to sync operations
    static let sync = Logger(subsystem: subsystem, category: "sync")

    /// Logs related to file operations
    static let fileOps = Logger(subsystem: subsystem, category: "fileops")

    /// Logs related to rclone execution
    static let rclone = Logger(subsystem: subsystem, category: "rclone")

    /// Logs related to UI events
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
```

### 2. Find All print() Statements

```bash
grep -n "print(" CloudSyncApp/RcloneManager.swift | wc -l
```

### 3. Convert Each print() to Logger

**Conversion rules:**

| print() content | Logger method | Category |
|-----------------|---------------|----------|
| Error messages | `.error()` | rclone |
| Warnings | `.warning()` | rclone |
| Debug/verbose | `.debug()` | rclone |
| Transfer progress | `.info()` | sync |
| File operations | `.info()` | fileOps |
| Network calls | `.debug()` | network |

**Examples:**

```swift
// Before
print("Error executing rclone: \(error)")

// After
Logger.rclone.error("Execution failed: \(error.localizedDescription, privacy: .public)")
```

```swift
// Before
print("Starting transfer from \(source) to \(dest)")

// After
Logger.sync.info("Starting transfer from \(source, privacy: .private) to \(dest, privacy: .private)")
```

```swift
// Before
print("Remote created: \(name)")

// After
Logger.rclone.info("Remote created: \(name, privacy: .public)")
```

### 4. Privacy Guidelines

- **Public:** Error messages, status messages, remote names
- **Private:** File paths, user data, tokens
- **Auto:** Let system decide based on context

```swift
// Sensitive data - use private
Logger.rclone.debug("Token received: \(token, privacy: .private)")

// Non-sensitive - use public
Logger.rclone.info("Provider: \(providerType, privacy: .public)")
```

### 5. Add Structured Logging Where Helpful

```swift
Logger.sync.info("Transfer complete", metadata: [
    "source": "\(source)",
    "destination": "\(destination)",
    "bytes": "\(bytesTransferred)",
    "duration": "\(duration)"
])
```

## Verification

```bash
# Should return 0 after completion
grep -c "print(" CloudSyncApp/RcloneManager.swift

# Test logs appear in Console.app
# Filter by: subsystem:com.cloudsync.ultra
```

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/DEV2_COMPLETE.md`

Include:
- Count of print() statements converted
- Logger categories used
- Any complex conversions

## Success Criteria

- [ ] Zero print() statements remaining
- [ ] Logger+Extensions.swift created
- [ ] Appropriate log levels used
- [ ] Privacy annotations on sensitive data
- [ ] Build succeeds
- [ ] Logs visible in Console.app
