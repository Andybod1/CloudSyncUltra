# TASK: Security Hardening (#74)

## Ticket
**GitHub:** #74
**Type:** Security Enhancement
**Size:** M (1-2 hours)
**Priority:** High (pre-launch requirement)

---

## Objective

Harden security before App Store release by addressing file permissions, path handling, and secure temp file management.

---

## Security Items to Address

### 1. Log File Permissions (VULN-007)

**Issue:** Log files may be readable by other users
**Fix:** Set log file permissions to 600 (owner read/write only)

```swift
// In Logger+Extensions.swift
FileManager.default.setAttributes(
    [.posixPermissions: 0o600], 
    ofItemAtPath: logFilePath
)
```

### 2. Config File Permissions (VULN-008)

**Issue:** Rclone config contains sensitive tokens
**Fix:** Ensure ~/.config/rclone/rclone.conf has 600 permissions

```swift
// After config operations in RcloneManager
let configPath = "~/.config/rclone/rclone.conf"
FileManager.default.setAttributes(
    [.posixPermissions: 0o600],
    ofItemAtPath: configPath.expandingTildeInPath
)
```

### 3. Path Sanitization (VULN-009)

**Issue:** User-provided paths could contain traversal sequences
**Fix:** Sanitize paths before use

```swift
func sanitizePath(_ path: String) -> String {
    // Remove .. sequences
    // Resolve to absolute path
    // Validate within allowed directories
}
```

### 4. Secure Temp File Handling (VULN-010)

**Issue:** Temp files may persist or be accessible
**Fix:** 
- Use secure temp directory
- Clean up temp files on completion
- Set restrictive permissions

---

## Files to Modify

| File | Changes |
|------|---------|
| `CloudSyncApp/Logger+Extensions.swift` | Log file permissions |
| `CloudSyncApp/RcloneManager.swift` | Config permissions, path sanitization |
| `CloudSyncApp/SyncManager.swift` | Path validation |
| `CloudSyncApp/TransferEngine/` | Temp file handling |

---

## Implementation Pattern

Create a `SecurityManager.swift` or add to existing:

```swift
struct SecurityUtils {
    static func setSecurePermissions(_ path: String) throws {
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: path
        )
    }
    
    static func sanitizePath(_ path: String) -> String? {
        // Sanitization logic
    }
    
    static func secureTemporaryFile() -> URL {
        // Create secure temp file
    }
}
```

---

## Testing

### Unit Tests
- [ ] Path sanitization tests (traversal blocked)
- [ ] Permission setting tests
- [ ] Temp file cleanup tests

### Manual Verification
- [ ] Check log file permissions: `ls -la ~/Library/Logs/CloudSyncApp/`
- [ ] Check config permissions: `ls -la ~/.config/rclone/`
- [ ] Verify path traversal blocked

---

## Acceptance Criteria

- [ ] Log files created with 600 permissions
- [ ] Rclone config has 600 permissions
- [ ] Path traversal sequences rejected
- [ ] Temp files cleaned up after use
- [ ] Temp files have restrictive permissions
- [ ] Security tests pass
- [ ] No regression in existing functionality

---

## Reference

- GitHub Issue #74: Security Hardening
- Related: #75 (Input Validation), #76 (Low Priority Items)
- macOS security best practices

---

## Notes

- Use /think for security design decisions
- Test on fresh install (no existing permissions)
- Consider backward compatibility with existing files

---

*Task created: 2026-01-15*
*Sprint: v2.0.23 "Launch Ready"*
