# Dev-3 Task: TransferError Model - Error Handling Foundation

## Issue Reference
GitHub Issue: #11 - Error handling - TransferError model and error patterns
Parent Issue: #8 - Comprehensive error handling with clear user feedback

## Model: Sonnet (S ticket - straightforward model creation)

## Sprint Context
**PHASE 1 of coordinated Error Handling Sprint**
This is the FOUNDATION task - Dev-2, Dev-1, and QA are waiting on your completion.
Priority: HIGHEST - This unblocks the entire sprint.

---

## Objective
Create the foundational error types, pattern matching system, and user-friendly messaging for all cloud provider errors in CloudSync Ultra.

## Requirements

### 1. Create TransferError.swift
**Location:** `/Users/antti/Claude/CloudSyncApp/Models/TransferError.swift`

**Complete error enum with all cases:**

```swift
import Foundation

/// Comprehensive error types for cloud transfer operations
enum TransferError: Error, Equatable, Codable {
    
    // MARK: - Storage & Quota Errors
    
    /// Cloud storage quota exceeded
    case quotaExceeded(provider: String, details: String? = nil)
    
    /// Rate limit exceeded - too many requests
    case rateLimitExceeded(provider: String, retryAfter: Int? = nil)
    
    /// Storage full on local disk
    case localStorageFull
    
    // MARK: - Authentication Errors
    
    /// Authentication failed - invalid credentials
    case authenticationFailed(provider: String, reason: String? = nil)
    
    /// OAuth token expired - needs refresh
    case tokenExpired(provider: String)
    
    /// Access denied - insufficient permissions
    case accessDenied(provider: String, path: String? = nil)
    
    /// Remote not configured properly
    case remoteNotConfigured(remoteName: String)
    
    // MARK: - Network Errors
    
    /// Network connection timeout
    case connectionTimeout
    
    /// Connection failed
    case connectionFailed(reason: String)
    
    /// DNS resolution failed
    case dnsResolutionFailed(host: String)
    
    /// SSL/TLS certificate error
    case sslError(details: String)
    
    /// Network unreachable
    case networkUnreachable
    
    // MARK: - File & Path Errors
    
    /// File too large for provider
    case fileTooLarge(fileName: String, maxSize: Int64, providerLimit: Int64)
    
    /// Invalid filename - contains illegal characters
    case invalidFilename(fileName: String, reason: String)
    
    /// Path too long for filesystem
    case pathTooLong(path: String, maxLength: Int)
    
    /// File or directory not found
    case notFound(path: String)
    
    /// Checksum mismatch - corruption detected
    case checksumMismatch(fileName: String)
    
    /// File is locked or in use
    case fileLocked(fileName: String)
    
    /// Directory is not empty (can't delete)
    case directoryNotEmpty(path: String)
    
    // MARK: - Provider-Specific Errors
    
    /// Generic provider error with code
    case providerError(provider: String, code: String, message: String)
    
    /// Encryption key error
    case encryptionError(details: String)
    
    /// Proton Drive 2FA required
    case twoFactorRequired(provider: String)
    
    // MARK: - Transfer Errors
    
    /// Transfer was cancelled by user
    case cancelled
    
    /// Transfer timed out
    case timeout(duration: TimeInterval)
    
    /// Partial failure - some files succeeded
    case partialFailure(succeeded: Int, failed: Int, errors: [String])
    
    // MARK: - Unknown/Generic
    
    /// Unknown error
    case unknown(message: String)
    
    // MARK: - User-Friendly Messages
    
    /// Get user-friendly error message
    var userMessage: String {
        switch self {
        // Storage & Quota
        case .quotaExceeded(let provider, _):
            return "\(provider) storage is full. Free up space or upgrade your storage plan."
        case .rateLimitExceeded(let provider, let retryAfter):
            if let seconds = retryAfter {
                return "\(provider) rate limit exceeded. Please wait \(seconds) seconds and try again."
            }
            return "\(provider) rate limit exceeded. Please wait a moment and try again."
        case .localStorageFull:
            return "Your Mac's storage is full. Free up disk space to continue."
            
        // Authentication
        case .authenticationFailed(let provider, let reason):
            if let reason = reason {
                return "\(provider) authentication failed: \(reason). Please reconnect."
            }
            return "\(provider) authentication failed. Please reconnect your account."
        case .tokenExpired(let provider):
            return "\(provider) session expired. Please reconnect to continue."
        case .accessDenied(let provider, let path):
            if let path = path {
                return "Access denied to \(path) on \(provider). Check your permissions."
            }
            return "Access denied on \(provider). You may not have permission for this operation."
        case .remoteNotConfigured(let name):
            return "Cloud service '\(name)' is not configured properly. Please reconnect."
            
        // Network
        case .connectionTimeout:
            return "Connection timed out. Check your internet connection and try again."
        case .connectionFailed(let reason):
            return "Connection failed: \(reason). Check your internet connection."
        case .dnsResolutionFailed(let host):
            return "Could not connect to \(host). Check your internet connection."
        case .sslError(let details):
            return "Secure connection failed: \(details)"
        case .networkUnreachable:
            return "Network is unreachable. Check your internet connection."
            
        // File & Path
        case .fileTooLarge(let fileName, _, let limit):
            let limitMB = limit / (1024 * 1024)
            return "'\(fileName)' is too large (max: \(limitMB) MB for this provider)."
        case .invalidFilename(let fileName, let reason):
            return "Invalid filename '\(fileName)': \(reason)"
        case .pathTooLong(let path, let maxLength):
            return "Path is too long (\(path.count) characters, max: \(maxLength))."
        case .notFound(let path):
            return "Not found: \(path)"
        case .checksumMismatch(let fileName):
            return "File corruption detected in '\(fileName)'. Transfer failed."
        case .fileLocked(let fileName):
            return "'\(fileName)' is locked or in use. Close it and try again."
        case .directoryNotEmpty(let path):
            return "Directory '\(path)' is not empty and cannot be deleted."
            
        // Provider-Specific
        case .providerError(let provider, let code, let message):
            return "\(provider) error (\(code)): \(message)"
        case .encryptionError(let details):
            return "Encryption error: \(details)"
        case .twoFactorRequired(let provider):
            return "\(provider) requires two-factor authentication. Check your authenticator app."
            
        // Transfer
        case .cancelled:
            return "Transfer cancelled."
        case .timeout(let duration):
            return "Transfer timed out after \(Int(duration)) seconds."
        case .partialFailure(let succeeded, let failed, _):
            return "\(succeeded) of \(succeeded + failed) files transferred successfully. \(failed) failed."
            
        // Unknown
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }
    
    /// Short title for error banners
    var title: String {
        switch self {
        case .quotaExceeded: return "Storage Full"
        case .rateLimitExceeded: return "Rate Limit Exceeded"
        case .localStorageFull: return "Disk Full"
        case .authenticationFailed: return "Authentication Failed"
        case .tokenExpired: return "Session Expired"
        case .accessDenied: return "Access Denied"
        case .remoteNotConfigured: return "Not Configured"
        case .connectionTimeout, .connectionFailed, .networkUnreachable: return "Connection Error"
        case .dnsResolutionFailed: return "DNS Error"
        case .sslError: return "Security Error"
        case .fileTooLarge: return "File Too Large"
        case .invalidFilename: return "Invalid Filename"
        case .pathTooLong: return "Path Too Long"
        case .notFound: return "Not Found"
        case .checksumMismatch: return "Corruption Detected"
        case .fileLocked: return "File Locked"
        case .directoryNotEmpty: return "Directory Not Empty"
        case .providerError: return "Provider Error"
        case .encryptionError: return "Encryption Error"
        case .twoFactorRequired: return "2FA Required"
        case .cancelled: return "Cancelled"
        case .timeout: return "Timeout"
        case .partialFailure: return "Partial Success"
        case .unknown: return "Error"
        }
    }
    
    /// Whether this error can be retried
    var isRetryable: Bool {
        switch self {
        case .connectionTimeout, .connectionFailed, .networkUnreachable, .dnsResolutionFailed:
            return true
        case .rateLimitExceeded:
            return true
        case .timeout:
            return true
        case .tokenExpired:
            return false // Requires user action (reconnect)
        case .quotaExceeded, .localStorageFull:
            return false // Requires user action (free space)
        case .cancelled:
            return false
        case .authenticationFailed, .accessDenied, .remoteNotConfigured:
            return false // Requires user action
        default:
            return false
        }
    }
    
    /// Whether this is a critical error requiring immediate attention
    var isCritical: Bool {
        switch self {
        case .quotaExceeded, .localStorageFull:
            return true
        case .authenticationFailed, .tokenExpired, .accessDenied:
            return true
        case .checksumMismatch:
            return true
        case .encryptionError:
            return true
        default:
            return false
        }
    }
}

// MARK: - Error Pattern Matching

extension TransferError {
    
    /// Pattern matching configuration for parsing rclone errors
    struct ErrorPattern {
        let keywords: [String]
        let provider: String?
        let errorFactory: (String) -> TransferError
        
        init(keywords: [String], provider: String? = nil, errorFactory: @escaping (String) -> TransferError) {
            self.keywords = keywords
            self.provider = provider
            self.errorFactory = errorFactory
        }
    }
    
    /// Known error patterns for detection
    static let patterns: [ErrorPattern] = [
        
        // Google Drive - Quota
        ErrorPattern(
            keywords: ["storageQuotaExceeded", "storage quota has been exceeded"],
            provider: "Google Drive"
        ) { _ in .quotaExceeded(provider: "Google Drive") },
        
        // Dropbox - Storage
        ErrorPattern(
            keywords: ["insufficient_storage", "not enough space"],
            provider: "Dropbox"
        ) { _ in .quotaExceeded(provider: "Dropbox") },
        
        // OneDrive - Quota
        ErrorPattern(
            keywords: ["QuotaExceeded", "not enough space"],
            provider: "OneDrive"
        ) { _ in .quotaExceeded(provider: "OneDrive") },
        
        // S3 - Storage
        ErrorPattern(
            keywords: ["QuotaExceeded", "storage quota"],
            provider: "Amazon S3"
        ) { _ in .quotaExceeded(provider: "Amazon S3") },
        
        // Rate Limiting
        ErrorPattern(
            keywords: ["rateLimitExceeded", "rate limit", "too many requests", "429"]
        ) { output in
            // Try to extract retry-after header
            if let match = output.range(of: #"retry.?after[:\s]+(\d+)"#, options: [.regularExpression, .caseInsensitive]) {
                let numStr = String(output[match]).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                if let seconds = Int(numStr) {
                    return .rateLimitExceeded(provider: "Cloud Provider", retryAfter: seconds)
                }
            }
            return .rateLimitExceeded(provider: "Cloud Provider", retryAfter: nil)
        },
        
        // Authentication - Token Expired
        ErrorPattern(
            keywords: ["token expired", "token has expired", "expired token", "invalid_grant"]
        ) { _ in .tokenExpired(provider: "Cloud Provider") },
        
        // Authentication - Failed
        ErrorPattern(
            keywords: ["authentication failed", "auth failed", "invalid credentials", "unauthorized", "401"]
        ) { output in .authenticationFailed(provider: "Cloud Provider", reason: output) },
        
        // Access Denied
        ErrorPattern(
            keywords: ["access denied", "permission denied", "forbidden", "403"]
        ) { output in .accessDenied(provider: "Cloud Provider", path: nil) },
        
        // Connection Timeout
        ErrorPattern(
            keywords: ["connection timed out", "timeout", "dial tcp", "i/o timeout"]
        ) { _ in .connectionTimeout },
        
        // DNS Errors
        ErrorPattern(
            keywords: ["no such host", "dns resolution", "lookup failed"]
        ) { output in
            // Try to extract hostname
            if let match = output.range(of: #"host\s+([^\s:]+)"#, options: .regularExpression) {
                let host = String(output[match]).replacingOccurrences(of: "host ", with: "")
                return .dnsResolutionFailed(host: host)
            }
            return .dnsResolutionFailed(host: "unknown")
        },
        
        // SSL/TLS Errors
        ErrorPattern(
            keywords: ["certificate", "ssl", "tls", "x509"]
        ) { output in .sslError(details: output) },
        
        // File Not Found
        ErrorPattern(
            keywords: ["not found", "no such file", "404"]
        ) { output in .notFound(path: output) },
        
        // File Too Large
        ErrorPattern(
            keywords: ["file too large", "size limit", "exceeds maximum"]
        ) { output in .fileTooLarge(fileName: "file", maxSize: 0, providerLimit: 0) },
        
        // Checksum Mismatch
        ErrorPattern(
            keywords: ["checksum", "hash mismatch", "integrity check failed", "md5"]
        ) { output in .checksumMismatch(fileName: "file") },
        
        // Cancelled
        ErrorPattern(
            keywords: ["cancelled", "canceled", "interrupted"]
        ) { _ in .cancelled },
        
        // Local Disk Full
        ErrorPattern(
            keywords: ["no space left", "disk full", "filesystem full"]
        ) { _ in .localStorageFull }
    ]
    
    /// Parse error from rclone output
    /// - Parameter output: Error output from rclone (stderr)
    /// - Returns: Parsed TransferError or nil if no match
    static func parse(from output: String) -> TransferError? {
        let lowercased = output.lowercased()
        
        // Check each pattern
        for pattern in patterns {
            for keyword in pattern.keywords {
                if lowercased.contains(keyword.lowercased()) {
                    return pattern.errorFactory(output)
                }
            }
        }
        
        // Check for generic ERROR: prefix
        if lowercased.contains("error :") || lowercased.contains("error:") {
            // Extract the error message after "ERROR:"
            if let range = output.range(of: "ERROR\\s*:\\s*(.+)", options: [.regularExpression, .caseInsensitive]) {
                let message = String(output[range])
                    .replacingOccurrences(of: #"^ERROR\s*:\s*"#, with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return .unknown(message: message)
            }
        }
        
        return nil
    }
}
```

---

## Validation Checklist

Before marking complete, verify:

- [ ] File created at correct path: `/Users/antti/Claude/CloudSyncApp/Models/TransferError.swift`
- [ ] All error cases defined with associated values
- [ ] `userMessage` provides clear, actionable messages for ALL cases
- [ ] `title` provides short titles for ALL cases
- [ ] `isRetryable` correctly identifies transient errors
- [ ] `isCritical` correctly identifies errors requiring immediate attention
- [ ] `ErrorPattern` struct defined with keyword matching
- [ ] All major providers have quota/rate-limit patterns (Google Drive, Dropbox, OneDrive, S3)
- [ ] All major error categories covered (auth, network, file, transfer)
- [ ] `parse(from:)` method implements pattern matching logic
- [ ] Code compiles without errors
- [ ] Enum conforms to `Error`, `Equatable`, `Codable`

---

## Build & Test

```bash
cd /Users/antti/Claude

# Build to verify compilation
xcodebuild -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -configuration Debug \
  build 2>&1 | grep -E '(error|warning|BUILD SUCCEEDED|BUILD FAILED)'
```

Expected: **BUILD SUCCEEDED** with zero errors

---

## Completion Report

When done, create: `/Users/antti/Claude/.claude-team/outputs/DEV3_COMPLETE.md`

```markdown
# Dev-3 Completion Report

**Task:** TransferError Model Foundation (#11)
**Status:** COMPLETE
**Sprint:** Error Handling Phase 1

## Deliverable
Created comprehensive TransferError enum with:
- 25+ specific error cases covering all major scenarios
- User-friendly messages for every error type
- Pattern matching system for rclone error parsing
- Retry logic classification
- Critical error identification

## File Created
- `CloudSyncApp/Models/TransferError.swift` (XXX lines)

## Build Status
BUILD SUCCEEDED

## Key Features
1. **Comprehensive Coverage:** Storage, auth, network, file, transfer errors
2. **Provider-Specific:** Google Drive, Dropbox, OneDrive, S3, Proton Drive patterns
3. **User-Friendly:** Clear, actionable messages instead of technical jargon
4. **Smart Classification:** isRetryable, isCritical flags for UI logic
5. **Pattern Matching:** 15+ error patterns for auto-detection

## Ready for Phase 2
✅ Dev-2 can now implement RcloneManager error parsing
✅ Dev-1 can now enhance ErrorBanner with TransferError support
✅ Foundation is solid for rest of sprint

## Commit
```bash
git add CloudSyncApp/Models/TransferError.swift
git commit -m "feat(models): Add comprehensive TransferError system

- 25+ error cases with user-friendly messages
- Pattern matching for rclone error detection
- Retry and criticality classification
- Implements #11, unblocks #12, #13, #15

Part of Error Handling Sprint (Phase 1 complete)"
```
```

---

## Notes

- This is the FOUNDATION - quality here affects the entire sprint
- User messages should be clear, non-technical, and actionable
- Think about what YOU would want to see as a user when an error occurs
- The pattern matching will be used by Dev-2 to parse rclone stderr
- Dev-1 will use `title`, `userMessage`, `isRetryable`, `isCritical` for UI

## Time Estimate
45-60 minutes for comprehensive implementation

## Communication
When complete, update `/Users/antti/Claude/.claude-team/STATUS.md`:
- Change Dev-3 status to "✅ COMPLETE"
- Add completion time
- Signal ready for Phase 2

---

**GO! This is high priority. Build something excellent!** 🚀
