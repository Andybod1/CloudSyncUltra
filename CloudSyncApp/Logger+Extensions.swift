//
//  Logger+Extensions.swift
//  CloudSyncApp
//
//  Centralized logging infrastructure using OSLog for better debugging and monitoring
//  OSLog provides privacy-preserving, performance-optimized logging for macOS apps
//

import OSLog

extension Logger {
    /// CloudSync app subsystem identifier
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.cloudsync.app"
    
    // MARK: - Logging Categories
    
    /// Network operations (API calls, transfers, connectivity)
    static let network = Logger(subsystem: subsystem, category: "network")
    
    /// User interface events and state changes
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Sync operations and file monitoring
    static let sync = Logger(subsystem: subsystem, category: "sync")
    
    /// File operations (read, write, delete, move)
    static let fileOps = Logger(subsystem: subsystem, category: "fileops")
    
    /// Authentication and security operations
    static let auth = Logger(subsystem: subsystem, category: "auth")
    
    /// Performance metrics and profiling
    static let performance = Logger(subsystem: subsystem, category: "performance")
    
    /// Configuration and settings changes
    static let config = Logger(subsystem: subsystem, category: "config")
    
    // MARK: - Convenience Methods
    
    /// Log a network request with privacy preservation
    /// - Parameters:
    ///   - method: HTTP method
    ///   - url: URL (automatically redacted for privacy)
    ///   - statusCode: Response status code
    static func logNetworkRequest(method: String, url: String, statusCode: Int? = nil) {
        if let status = statusCode {
            network.info("[\(method)] \(url, privacy: .private) → \(status)")
        } else {
            network.debug("[\(method)] \(url, privacy: .private)")
        }
    }
    
    /// Log a file operation
    /// - Parameters:
    ///   - operation: Type of operation (copy, move, delete, etc.)
    ///   - path: File path (automatically redacted)
    ///   - success: Whether operation succeeded
    static func logFileOperation(operation: String, path: String, success: Bool) {
        if success {
            fileOps.info("\(operation) succeeded: \(path, privacy: .private)")
        } else {
            fileOps.error("\(operation) failed: \(path, privacy: .private)")
        }
    }
    
    /// Log a sync operation
    /// - Parameters:
    ///   - source: Source location
    ///   - destination: Destination location
    ///   - filesCount: Number of files
    ///   - bytesTransferred: Bytes transferred
    static func logSyncOperation(source: String, destination: String, filesCount: Int, bytesTransferred: Int64) {
        sync.info("""
            Sync completed: \(source, privacy: .private) → \(destination, privacy: .private) | \
            Files: \(filesCount) | Bytes: \(bytesTransferred)
            """)
    }
    
    /// Log a performance metric
    /// - Parameters:
    ///   - operation: Operation name
    ///   - duration: Duration in seconds
    static func logPerformance(operation: String, duration: TimeInterval) {
        performance.info("\(operation) took \(String(format: "%.3f", duration))s")
    }
    
    /// Log an authentication event (credentials are NEVER logged)
    /// - Parameters:
    ///   - provider: Cloud provider name
    ///   - success: Whether auth succeeded
    static func logAuthEvent(provider: String, success: Bool) {
        if success {
            auth.info("Authentication successful for \(provider)")
        } else {
            auth.error("Authentication failed for \(provider)")
        }
    }
}

// MARK: - Performance Measurement Helper

/// Helper for measuring operation performance
struct PerformanceTimer {
    private let operation: String
    private let startTime: Date
    private let logger: Logger
    
    init(operation: String, logger: Logger = .performance) {
        self.operation = operation
        self.startTime = Date()
        self.logger = logger
        logger.debug("Starting: \(operation)")
    }
    
    /// Complete the timer and log the duration
    func complete() {
        let duration = Date().timeIntervalSince(startTime)
        logger.info("\(operation) completed in \(String(format: "%.3f", duration))s")
    }
    
    /// Complete with a result message
    func complete(result: String) {
        let duration = Date().timeIntervalSince(startTime)
        logger.info("\(operation) completed in \(String(format: "%.3f", duration))s - \(result)")
    }
    
    /// Log failure
    func fail(error: Error) {
        let duration = Date().timeIntervalSince(startTime)
        logger.error("\(operation) failed after \(String(format: "%.3f", duration))s: \(error.localizedDescription)")
    }
}

// MARK: - Usage Examples

/*
 // Network logging
 Logger.logNetworkRequest(method: "GET", url: "https://api.example.com/files", statusCode: 200)
 
 // File operations
 Logger.logFileOperation(operation: "Copy", path: "/Users/user/file.txt", success: true)
 
 // Sync operations
 Logger.logSyncOperation(source: "gdrive:", destination: "local", filesCount: 42, bytesTransferred: 1024000)
 
 // Performance timing
 let timer = PerformanceTimer(operation: "File transfer")
 // ... do work ...
 timer.complete()
 
 // Or with result
 timer.complete(result: "Transferred 100 files")
 
 // Or with error
 do {
     // ... operation ...
 } catch {
     timer.fail(error: error)
 }
 
 // Auth events
 Logger.logAuthEvent(provider: "Google Drive", success: true)
 
 // Custom category logging
 Logger.sync.info("Starting file monitoring")
 Logger.ui.debug("Window appeared: Dashboard")
 */
