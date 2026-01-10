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
    
    init(
        id: UUID = UUID(),
        name: String,
        type: TaskType,
        sourceRemote: String,
        sourcePath: String,
        destinationRemote: String,
        destinationPath: String
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
    }
    
    var formattedProgress: String {
        "\(Int(progress * 100))%"
    }
    
    var formattedBytesTransferred: String {
        let transferred = ByteCountFormatter.string(fromByteCount: bytesTransferred, countStyle: .file)
        let total = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
        return "\(transferred) / \(total)"
    }
    
    var formattedFilesTransferred: String {
        "\(filesTransferred) / \(totalFiles) files"
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
