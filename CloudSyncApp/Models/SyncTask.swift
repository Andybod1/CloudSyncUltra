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
    var errorMessage: String?
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
    var effectiveSourceRemote: String {
        if encryptSource {
            let baseName = sourceRemote.lowercased().replacingOccurrences(of: " ", with: "")
            if EncryptionManager.shared.isEncryptionConfigured(for: baseName) {
                return EncryptionManager.shared.getCryptRemoteName(for: baseName)
            }
        }
        return sourceRemote.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    /// Get effective destination remote name (crypt or base)
    var effectiveDestinationRemote: String {
        if encryptDestination {
            let baseName = destinationRemote.lowercased().replacingOccurrences(of: " ", with: "")
            if EncryptionManager.shared.isEncryptionConfigured(for: baseName) {
                return EncryptionManager.shared.getCryptRemoteName(for: baseName)
            }
        }
        return destinationRemote.lowercased().replacingOccurrences(of: " ", with: "")
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
            return "No data"
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
