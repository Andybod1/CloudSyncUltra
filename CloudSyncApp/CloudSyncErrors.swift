//
//  CloudSyncErrors.swift
//  CloudSyncApp
//
//  Comprehensive error types with user-friendly messages and recovery suggestions
//  Following Swift's typed error handling best practices
//

import Foundation

// MARK: - Base Protocol

/// Base protocol for CloudSync errors with recovery suggestions
protocol CloudSyncError: LocalizedError {
    var recoverySuggestion: String? { get }
}

// MARK: - Rclone Errors

/// Errors related to rclone operations
enum RcloneError: CloudSyncError {
    case notInstalled
    case configNotFound
    case remoteMissing(String)
    case remoteAlreadyExists(String)
    case transferFailed(underlying: Error)
    case processTerminated(exitCode: Int32)
    case invalidConfiguration(String)
    case authenticationFailed(String)
    case networkError(String)
    case permissionDenied(path: String)
    case quotaExceeded(provider: String)
    case rateLimitExceeded(retryAfter: TimeInterval?)
    case configurationFailed(String)
    case syncFailed(String)
    case encryptionSetupFailed(String)
    case invalidPath(String)
    case pathTraversal(String)
    
    var errorDescription: String? {
        switch self {
        case .notInstalled:
            return "Rclone is not installed"
        case .configNotFound:
            return "Rclone configuration not found"
        case .remoteMissing(let name):
            return "Remote '\(name)' is not configured"
        case .remoteAlreadyExists(let name):
            return "Remote '\(name)' already exists"
        case .transferFailed(let error):
            return "Transfer failed: \(error.localizedDescription)"
        case .processTerminated(let code):
            return "Rclone process terminated with code \(code)"
        case .invalidConfiguration(let detail):
            return "Invalid configuration: \(detail)"
        case .authenticationFailed(let provider):
            return "Authentication failed for \(provider)"
        case .networkError(let detail):
            return "Network error: \(detail)"
        case .permissionDenied(let path):
            return "Permission denied accessing '\(path)'"
        case .quotaExceeded(let provider):
            return "Storage quota exceeded on \(provider)"
        case .rateLimitExceeded(let retryAfter):
            if let retry = retryAfter {
                return "Rate limit exceeded. Retry in \(Int(retry)) seconds"
            }
            return "Rate limit exceeded. Please wait and try again"
        case .configurationFailed(let message):
            return "Configuration failed: \(message)"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        case .encryptionSetupFailed(let message):
            return "Encryption setup failed: \(message)"
        case .invalidPath(let path):
            return "Invalid path: '\(path)'"
        case .pathTraversal(let path):
            return "Path traversal detected: '\(path)'"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notInstalled:
            return "Install rclone using Homebrew: 'brew install rclone'"
        case .configNotFound:
            return "Set up a cloud service in Settings → Cloud Services"
        case .remoteMissing:
            return "Connect this cloud service in Settings"
        case .remoteAlreadyExists:
            return "Choose a different name or delete the existing remote"
        case .transferFailed:
            return "Check your internet connection and try again"
        case .processTerminated:
            return "Check the logs for more details"
        case .invalidConfiguration:
            return "Review your connection settings and reconfigure"
        case .authenticationFailed:
            return "Check your credentials and re-authenticate"
        case .networkError:
            return "Check your internet connection and firewall settings"
        case .permissionDenied:
            return "Grant CloudSync access to this location in System Settings → Privacy & Security"
        case .quotaExceeded:
            return "Free up space or upgrade your storage plan"
        case .rateLimitExceeded:
            return "Wait a moment before trying again"
        case .configurationFailed:
            return "Review your connection settings and reconfigure"
        case .syncFailed:
            return "Check the logs for details and try again"
        case .encryptionSetupFailed:
            return "Check your encryption password and try again"
        case .invalidPath:
            return "Use a valid file path without special characters"
        case .pathTraversal:
            return "Path cannot contain '..' or attempt to escape directories"
        }
    }
}

// MARK: - File Operation Errors

/// Errors related to file operations
enum FileOperationError: CloudSyncError {
    case notFound(path: String)
    case alreadyExists(path: String)
    case invalidPath(String)
    case readFailed(path: String, underlying: Error)
    case writeFailed(path: String, underlying: Error)
    case deleteFailed(path: String, underlying: Error)
    case insufficientSpace(required: Int64, available: Int64)
    case fileTooBig(size: Int64, limit: Int64)
    case unsupportedFileType(String)
    
    var errorDescription: String? {
        switch self {
        case .notFound(let path):
            return "File not found: '\(path)'"
        case .alreadyExists(let path):
            return "File already exists: '\(path)'"
        case .invalidPath(let path):
            return "Invalid path: '\(path)'"
        case .readFailed(let path, _):
            return "Failed to read '\(path)'"
        case .writeFailed(let path, _):
            return "Failed to write '\(path)'"
        case .deleteFailed(let path, _):
            return "Failed to delete '\(path)'"
        case .insufficientSpace(let required, let available):
            return "Insufficient space: need \(ByteCountFormatter.string(fromByteCount: required, countStyle: .file)), have \(ByteCountFormatter.string(fromByteCount: available, countStyle: .file))"
        case .fileTooBig(let size, let limit):
            return "File too large: \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file)) exceeds limit of \(ByteCountFormatter.string(fromByteCount: limit, countStyle: .file))"
        case .unsupportedFileType(let type):
            return "Unsupported file type: '\(type)'"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notFound:
            return "Verify the file path and try again"
        case .alreadyExists:
            return "Choose a different name or delete the existing file"
        case .invalidPath:
            return "Use a valid file path"
        case .readFailed, .writeFailed, .deleteFailed:
            return "Check file permissions and try again"
        case .insufficientSpace:
            return "Free up disk space and retry"
        case .fileTooBig:
            return "Use a smaller file or increase the limit"
        case .unsupportedFileType:
            return "Use a supported file format"
        }
    }
}

// MARK: - Sync Errors

/// Errors related to sync operations
enum SyncError: CloudSyncError {
    case noSourceSpecified
    case noDestinationSpecified
    case sourceNotFound(String)
    case destinationNotFound(String)
    case sourceAndDestinationSame
    case syncInProgress(taskId: UUID)
    case syncCancelled
    case monitoringFailed(underlying: Error)
    case conflictDetected(files: [String])
    
    var errorDescription: String? {
        switch self {
        case .noSourceSpecified:
            return "No source specified"
        case .noDestinationSpecified:
            return "No destination specified"
        case .sourceNotFound(let path):
            return "Source not found: '\(path)'"
        case .destinationNotFound(let path):
            return "Destination not found: '\(path)'"
        case .sourceAndDestinationSame:
            return "Source and destination cannot be the same"
        case .syncInProgress(let id):
            return "Sync already in progress (task: \(id.uuidString.prefix(8)))"
        case .syncCancelled:
            return "Sync operation was cancelled"
        case .monitoringFailed(let error):
            return "File monitoring failed: \(error.localizedDescription)"
        case .conflictDetected(let files):
            return "Conflicts detected in \(files.count) file(s)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noSourceSpecified, .noDestinationSpecified:
            return "Select a source and destination"
        case .sourceNotFound, .destinationNotFound:
            return "Verify the path exists and try again"
        case .sourceAndDestinationSame:
            return "Choose a different destination"
        case .syncInProgress:
            return "Wait for the current sync to complete or cancel it"
        case .syncCancelled:
            return nil
        case .monitoringFailed:
            return "Restart the app or check system permissions"
        case .conflictDetected:
            return "Resolve conflicts manually before syncing"
        }
    }
}

// MARK: - Authentication Errors

/// Errors related to authentication
enum AuthError: CloudSyncError {
    case invalidCredentials
    case twoFactorRequired
    case twoFactorInvalid
    case tokenExpired
    case oauthFailed(provider: String)
    case accountLocked
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        case .twoFactorRequired:
            return "Two-factor authentication required"
        case .twoFactorInvalid:
            return "Invalid two-factor code"
        case .tokenExpired:
            return "Your session has expired"
        case .oauthFailed(let provider):
            return "OAuth authentication failed for \(provider)"
        case .accountLocked:
            return "Your account has been locked"
        case .networkUnavailable:
            return "Network unavailable during authentication"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:
            return "Check your credentials and try again"
        case .twoFactorRequired:
            return "Enter your two-factor authentication code"
        case .twoFactorInvalid:
            return "Check your authenticator app and try again"
        case .tokenExpired:
            return "Please sign in again"
        case .oauthFailed:
            return "Try authenticating again or check your browser"
        case .accountLocked:
            return "Contact your service provider to unlock your account"
        case .networkUnavailable:
            return "Check your internet connection and try again"
        }
    }
}

// MARK: - Proton Drive Errors

/// Errors specific to Proton Drive authentication and operations
enum ProtonDriveError: CloudSyncError {
    case noSavedCredentials
    case encryptionKeysNotGenerated
    case invalidCredentials
    case twoFactorRequired
    case twoFactorInvalid
    case mailboxPasswordRequired
    case sessionExpired
    case rateLimited(retryAfter: TimeInterval?)
    case networkError(String)
    case draftConflict
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .noSavedCredentials:
            return "No saved credentials found"
        case .encryptionKeysNotGenerated:
            return "Proton Drive encryption keys not found"
        case .invalidCredentials:
            return "Invalid Proton account credentials"
        case .twoFactorRequired:
            return "Two-factor authentication required"
        case .twoFactorInvalid:
            return "Invalid 2FA code or TOTP secret"
        case .mailboxPasswordRequired:
            return "This account requires a mailbox password"
        case .sessionExpired:
            return "Proton Drive session has expired"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limited. Retry in \(Int(seconds)) seconds"
            }
            return "Rate limited. Please wait before trying again"
        case .networkError(let detail):
            return "Network error: \(detail)"
        case .draftConflict:
            return "Upload conflict: a draft already exists for this file"
        case .unknownError(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noSavedCredentials:
            return "Connect with your username and password first."
        case .encryptionKeysNotGenerated:
            return "Log in to Proton Drive via your web browser first. This generates the encryption keys needed for the app."
        case .invalidCredentials:
            return "Double-check your email and password. Make sure you're using your Proton account credentials."
        case .twoFactorRequired:
            return "Enable 2FA in the setup wizard. Use either a single code or enter your TOTP secret for persistent authentication."
        case .twoFactorInvalid:
            return "Check your authenticator app for the current code. If using TOTP secret, ensure it matches your Proton security settings."
        case .mailboxPasswordRequired:
            return "This is a two-password Proton account. Enter your mailbox password in Advanced Options."
        case .sessionExpired:
            return "Re-authenticate by clicking Disconnect, then Connect again in Settings."
        case .rateLimited:
            return "Proton Drive has rate limits. Wait a few minutes before trying again."
        case .networkError:
            return "Check your internet connection. Proton Drive requires a stable connection."
        case .draftConflict:
            return "Another upload may be in progress. Wait a moment and try again."
        case .unknownError:
            return "Check the Settings > About for logs, or try reconnecting."
        }
    }
    
    /// Parse rclone error output into a ProtonDriveError
    static func parse(from errorOutput: String) -> Self? {
        let lowercased = errorOutput.lowercased()
        
        if lowercased.contains("encryption key") || lowercased.contains("keyring") || lowercased.contains("no valid") {
            return .encryptionKeysNotGenerated
        }
        if lowercased.contains("invalid access token") || lowercased.contains("401") {
            return .sessionExpired
        }
        if lowercased.contains("invalid password") || lowercased.contains("incorrect password") {
            return .invalidCredentials
        }
        if lowercased.contains("2fa") || lowercased.contains("two-factor") || lowercased.contains("totp") {
            return .twoFactorRequired
        }
        if lowercased.contains("mailbox password") {
            return .mailboxPasswordRequired
        }
        if lowercased.contains("429") || lowercased.contains("rate limit") {
            return .rateLimited(retryAfter: nil)
        }
        if lowercased.contains("draft exist") {
            return .draftConflict
        }
        if lowercased.contains("network") || lowercased.contains("connection") || lowercased.contains("timeout") {
            return .networkError(errorOutput)
        }
        
        return nil
    }
}
