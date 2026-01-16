import Foundation

/// Utilities for security-related operations including file permissions, path sanitization, and secure temp files
struct SecurityManager {

    // MARK: - File Permissions

    /// Sets secure permissions (600 - owner read/write only) on a file
    static func setSecurePermissions(_ path: String) throws {
        let expandedPath = NSString(string: path).expandingTildeInPath

        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: expandedPath
        )
    }

    /// Sets secure permissions on the rclone config file
    static func secureRcloneConfig() throws {
        let configPath = "~/.config/rclone/rclone.conf"
        let expandedPath = NSString(string: configPath).expandingTildeInPath

        // Check if file exists before setting permissions
        if FileManager.default.fileExists(atPath: expandedPath) {
            try setSecurePermissions(configPath)
        }
    }

    // MARK: - Path Sanitization

    /// Sanitizes a path to prevent directory traversal attacks
    /// Returns nil if the path is invalid or contains dangerous sequences
    static func sanitizePath(_ path: String) -> String? {
        // Expand tilde first
        let expandedPath = NSString(string: path).expandingTildeInPath

        // Check for dangerous patterns
        if expandedPath.contains("..") {
            return nil
        }

        // Convert to URL to normalize and resolve symlinks
        guard let url = URL(fileURLWithPath: expandedPath).standardizedFileURL.resolvingSymlinksInPath() as URL? else {
            return nil
        }

        let normalizedPath = url.path

        // Validate the path is within allowed directories
        let allowedPrefixes = [
            NSHomeDirectory(),
            "/Volumes", // For external drives
            "/tmp",     // For temporary files
            NSTemporaryDirectory()
        ]

        let isAllowed = allowedPrefixes.contains { prefix in
            normalizedPath.hasPrefix(prefix)
        }

        return isAllowed ? normalizedPath : nil
    }

    /// Validates if a path is safe to use
    static func isPathSafe(_ path: String) -> Bool {
        return sanitizePath(path) != nil
    }

    // MARK: - Secure Temporary Files

    /// Creates a secure temporary file with restricted permissions
    /// Returns the URL of the created temporary file
    static func createSecureTemporaryFile(withExtension fileExtension: String? = nil) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = ProcessInfo.processInfo.globallyUniqueString

        var tempFileURL = tempDir.appendingPathComponent(fileName)
        if let ext = fileExtension {
            tempFileURL.appendPathExtension(ext)
        }

        // Create the file
        FileManager.default.createFile(atPath: tempFileURL.path, contents: nil, attributes: nil)

        // Set secure permissions immediately
        try setSecurePermissions(tempFileURL.path)

        return tempFileURL
    }

    /// Creates a secure temporary directory with restricted permissions
    static func createSecureTemporaryDirectory() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let dirName = ProcessInfo.processInfo.globallyUniqueString
        let tempDirURL = tempDir.appendingPathComponent(dirName)

        // Create directory with secure permissions
        try FileManager.default.createDirectory(
            at: tempDirURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )

        return tempDirURL
    }

    /// Securely removes a temporary file or directory
    static func removeSecureTemporaryItem(at url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            // Log the error but don't throw - cleanup is best effort
            print("Failed to remove temporary item at \(url.path): \(error)")
        }
    }

    // MARK: - Secure Cleanup

    /// Cleanup helper for use in defer blocks
    static func cleanupTemporaryItems(_ urls: [URL]) {
        for url in urls {
            removeSecureTemporaryItem(at: url)
        }
    }

    // MARK: - Secure Debug Logging

    /// Creates a secure debug log file in Application Support with proper permissions
    /// Returns a closure that can be used to write log messages
    static func createSecureDebugLogger(filename: String) -> ((String) -> Void)? {
        // Use Application Support instead of /tmp
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory,
                                                       in: .userDomainMask).first else {
            return nil
        }

        let logDir = appSupport.appendingPathComponent("CloudSyncApp/Logs", isDirectory: true)

        // Create directory if needed
        do {
            try FileManager.default.createDirectory(at: logDir,
                                                  withIntermediateDirectories: true,
                                                  attributes: [.posixPermissions: 0o700])
        } catch {
            print("Failed to create log directory: \(error)")
            return nil
        }

        let logPath = logDir.appendingPathComponent(filename).path

        // Return logging closure
        return { (message: String) in
            let timestamp = Date().description
            let line = "\(timestamp): \(message)\n"
            if let data = line.data(using: .utf8) {
                let fileURL = URL(fileURLWithPath: logPath)
                if FileManager.default.fileExists(atPath: logPath) {
                    if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } else {
                    do {
                        try data.write(to: fileURL)
                        // Set secure permissions immediately after creation
                        try setSecurePermissions(logPath)
                    } catch {
                        print("Failed to write to log file: \(error)")
                    }
                }
            }
        }
    }
}
