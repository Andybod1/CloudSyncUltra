//
//  SyncTask.swift
//  CloudSyncApp
//
//  Sync task model for managing transfer jobs
//

import Foundation

enum TaskType: String, Codable, CaseIterable {
    case sync = "Sync"
    case transfer = "Transfer"
    case backup = "Backup"
    
    var icon: String {
        switch self {
        case .sync: return "arrow.triangle.2.circlepath"
        case .transfer: return "arrow.right"
        case .backup: return "externaldrive.fill.badge.timemachine"
        }
    }
}

enum TaskState: String, Codable {
    case pending = "Pending"
    case running = "Running"
    case completed = "Completed"
    case failed = "Failed"
    case paused = "Paused"
    case cancelled = "Cancelled"
    
    var color: String {
        switch self {
        case .pending: return "gray"
        case .running: return "blue"
        case .completed: return "green"
        case .failed: return "red"
        case .paused: return "orange"
        case .cancelled: return "gray"
        }
    }
}

struct SyncTask: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: TaskType
    var sourceRemote: String
    var sourcePath: String
    var destinationRemote: String
    var destinationPath: String
    var state: TaskState
    var progress: Double
    var bytesTransferred: Int64
    var totalBytes: Int64
    var filesTransferred: Int
    var totalFiles: Int
    var speed: String
    var eta: String
    var createdAt: Date
    var startedAt: Date?
    var completedAt: Date?
    var errorMessage: String?  // Legacy field - kept for backwards compatibility
    var lastError: TransferError?  // Structured error information
    var errorContext: String?  // Additional context about when/where error occurred
    var isScheduled: Bool
    var scheduleInterval: TimeInterval?
    var lastRunAt: Date?
    var nextRunAt: Date?
    var metadata: [String: String]?  // For storing additional information like folder flags
    
    // Encryption settings
    var encryptSource: Bool
    var encryptDestination: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        type: TaskType,
        sourceRemote: String,
        sourcePath: String,
        destinationRemote: String,
        destinationPath: String,
        encryptSource: Bool = false,
        encryptDestination: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.sourceRemote = sourceRemote
        self.sourcePath = sourcePath
        self.destinationRemote = destinationRemote
        self.destinationPath = destinationPath
        self.state = .pending
        self.progress = 0
        self.bytesTransferred = 0
        self.totalBytes = 0
        self.filesTransferred = 0
        self.totalFiles = 0
        self.speed = ""
        self.eta = ""
        self.createdAt = Date()
        self.isScheduled = false
        self.metadata = nil
        self.encryptSource = encryptSource
        self.encryptDestination = encryptDestination
    }
    
    /// Get effective source remote name (crypt or base)
    /// Note: sourceRemote should be the rclone config name (e.g., "google"), not display name
    var effectiveSourceRemote: String {
        if encryptSource {
            if EncryptionManager.shared.isEncryptionConfigured(for: sourceRemote) {
                return EncryptionManager.shared.getCryptRemoteName(for: sourceRemote)
            }
        }
        return sourceRemote
    }

    /// Get effective destination remote name (crypt or base)
    /// Note: destinationRemote should be the rclone config name (e.g., "google"), not display name
    var effectiveDestinationRemote: String {
        if encryptDestination {
            if EncryptionManager.shared.isEncryptionConfigured(for: destinationRemote) {
                return EncryptionManager.shared.getCryptRemoteName(for: destinationRemote)
            }
        }
        return destinationRemote
    }
    
    /// Check if any encryption is enabled
    var hasEncryption: Bool {
        encryptSource || encryptDestination
    }
    
    var formattedProgress: String {
        "\(Int(progress * 100))%"
    }
    
    var formattedBytesTransferred: String {
        if totalBytes == 0 {
            // For completed tasks with no bytes, show "Already in sync" instead of "No data"
            if state == .completed {
                return "Already in sync"
            }
            return "Checking..."
        }

        let transferred = ByteCountFormatter.string(fromByteCount: bytesTransferred, countStyle: .file)
        let total = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)

        let isFolder = metadata?["isFolder"] == "true"

        if state == .running {
            // During transfer, show as progress
            let percentage = totalBytes > 0 ? Int((Double(bytesTransferred) / Double(totalBytes)) * 100) : 0

            if isFolder {
                // For folders, emphasize that it's total data being transferred
                return "\(transferred) of \(total) transferred (\(percentage)%)"
            }

            return "\(transferred) of \(total) (\(percentage)%)"
        }

        return "\(transferred) / \(total)"
    }
    
    var formattedFilesTransferred: String {
        // Check if this is a folder transfer
        let isFolder = metadata?["isFolder"] == "true"
        
        if state == .running && isFolder {
            // For folder transfers, show different message
            return "Uploading folder..."
        }
        
        if state == .running && totalFiles > 0 {
            // During active transfer, show current file being transferred
            let currentFile = filesTransferred + 1 // Next file being worked on
            if currentFile <= totalFiles {
                return "File \(currentFile) of \(totalFiles)"
            }
        }
        return "\(filesTransferred) / \(totalFiles) files"
    }
    
    /// Files progress for indicator (e.g., "1/151: FolderName")
    var formattedFilesProgress: String {
        if totalFiles > 1 {
            let current = min(filesTransferred + 1, totalFiles)
            return "\(current)/\(totalFiles): \(name)"
        }
        return name
    }
    
    /// Status message for indicator
    var statusMessage: String {
        let isFolder = metadata?["isFolder"] == "true"
        
        if isFolder && totalFiles > 1 {
            let estimatedMinutes = max(1, totalFiles / 30)
            return "Uploading \(totalFiles) files (est. \(estimatedMinutes)-\(estimatedMinutes + 1) min)"
        }
        
        if totalBytes > 0 {
            let transferred = ByteCountFormatter.string(fromByteCount: bytesTransferred, countStyle: .file)
            let total = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
            return "\(transferred) of \(total)"
        }
        
        return "Preparing..."
    }
    
    var duration: TimeInterval? {
        guard let start = startedAt else { return nil }
        let end = completedAt ?? Date()
        return end.timeIntervalSince(start)
    }
    
    var formattedDuration: String {
        guard let duration = duration else { return "--" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "--"
    }
    
    var averageSpeed: String {
        guard let duration = duration, duration > 0 else { return "--" }
        
        // Calculate bytes per second
        let bytesPerSecond = Double(bytesTransferred) / duration
        
        // Format as human-readable speed
        if bytesPerSecond < 1024 {
            return String(format: "%.0f B/s", bytesPerSecond)
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.1f KB/s", bytesPerSecond / 1024)
        } else if bytesPerSecond < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB/s", bytesPerSecond / (1024 * 1024))
        } else {
            return String(format: "%.2f GB/s", bytesPerSecond / (1024 * 1024 * 1024))
        }
    }

    // MARK: - Error Handling Properties

    /// Whether this task has an error
    var hasError: Bool {
        return lastError != nil || (errorMessage != nil && !errorMessage!.isEmpty)
    }

    /// Get the user-friendly error message for display
    var displayErrorMessage: String? {
        if let error = lastError {
            return error.userMessage
        }
        return errorMessage // Fallback to legacy error message
    }

    /// Get the error title for banners/alerts
    var displayErrorTitle: String? {
        if let error = lastError {
            return error.title
        }
        if hasError {
            return "Error" // Generic title for legacy errors
        }
        return nil
    }

    /// Whether the current error can be retried
    var canRetry: Bool {
        if let error = lastError {
            return error.isRetryable
        }
        // For legacy errors, allow retry unless task is cancelled
        return state != .cancelled
    }

    /// Whether this is a critical error requiring immediate attention
    var hasCriticalError: Bool {
        if let error = lastError {
            return error.isCritical
        }
        return false // Legacy errors are not considered critical
    }

    /// Update error information with TransferError
    mutating func setError(_ error: TransferError, context: String? = nil) {
        self.lastError = error
        self.errorContext = context
        self.errorMessage = error.userMessage // Keep legacy field updated
        self.state = .failed
    }

    /// Clear error information
    mutating func clearError() {
        self.lastError = nil
        self.errorContext = nil
        self.errorMessage = nil
    }

    /// Get full error description including context
    var fullErrorDescription: String? {
        guard let errorMsg = displayErrorMessage else { return nil }

        if let context = errorContext {
            return "\(errorMsg)\n\nContext: \(context)"
        }

        return errorMsg
    }

    /// Whether this task should show error details in UI
    var shouldShowErrorDetails: Bool {
        return hasError && (lastError != nil || errorContext != nil)
    }
}

struct TaskLog: Identifiable, Codable {
    let id: UUID
    let taskId: UUID
    let timestamp: Date
    let level: LogLevel
    let message: String
    
    enum LogLevel: String, Codable {
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case debug = "DEBUG"
    }
    
    init(taskId: UUID, level: LogLevel, message: String) {
        self.id = UUID()
        self.taskId = taskId
        self.timestamp = Date()
        self.level = level
        self.message = message
    }
}
