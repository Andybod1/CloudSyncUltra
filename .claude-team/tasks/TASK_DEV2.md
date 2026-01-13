# TASK: RcloneManager Logging Standardization (#20 Part 1)

## Worker: Dev-2 (Engine)
## Model: Opus (M ticket)
## Issue: #20

**Use `/think` for planning the conversion strategy.**

---

## Objective

Convert all 82 print() statements in RcloneManager.swift to proper Logger calls.

---

## Background

CloudSync Ultra has Logger infrastructure in `Logger+Extensions.swift`. RcloneManager.swift still uses print() which:
- Doesn't persist to system logs
- Can't be exported for debugging
- Inconsistent with rest of codebase

---

## Implementation

### 1. Review Logger Infrastructure
```bash
cat CloudSyncApp/Logger+Extensions.swift
```

### 2. Find All print() Statements
```bash
grep -n "print(" CloudSyncApp/RcloneManager.swift | wc -l
grep -n "print(" CloudSyncApp/RcloneManager.swift | head -20
```

### 3. Convert Each print() to Logger

**Conversion rules:**
| print() content | Logger level |
|-----------------|--------------|
| Error messages | `logger.error()` |
| Warnings | `logger.warning()` |
| Debug/verbose | `logger.debug()` |
| Info/status | `logger.info()` |
| Sensitive data (tokens, paths) | `logger.debug()` with redaction |

**Example conversions:**
```swift
// Before
print("Error: \(error.localizedDescription)")

// After
logger.error("Transfer failed: \(error.localizedDescription, privacy: .public)")
```

```swift
// Before
print("Starting sync for \(remoteName)")

// After
logger.info("Starting sync for remote", metadata: ["remote": "\(remoteName)"])
```

### 4. Add Logger Property (if not present)
```swift
import OSLog

private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "RcloneManager")
```

---

## Files to Modify
- `CloudSyncApp/RcloneManager.swift`

## Files to Reference
- `CloudSyncApp/Logger+Extensions.swift`

---

## Acceptance Criteria

- [ ] All print() statements converted to Logger
- [ ] Appropriate log levels used (error/warning/info/debug)
- [ ] Sensitive data uses privacy: .private or redaction
- [ ] Logger property added to RcloneManager
- [ ] Build succeeds
- [ ] No print() remaining (verify with grep)

---

## Output

Write report to: `/Users/antti/Claude/.claude-team/outputs/DEV2_COMPLETE.md`

Update STATUS.md when starting/completing.

---

## Verification
```bash
# Should return 0 after completion
grep -c "print(" CloudSyncApp/RcloneManager.swift
```
