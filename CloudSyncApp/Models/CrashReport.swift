import Foundation

/// Represents a crash report with detailed information
struct CrashReport: Identifiable, Codable {
    let id: UUID
    let date: Date
    let type: CrashType
    let reason: String?
    let stackTrace: [String]
    let deviceInfo: DeviceInfo
    let appInfo: AppInfo

    init(type: CrashType, reason: String? = nil, stackTrace: [String] = []) {
        self.id = UUID()
        self.date = Date()
        self.type = type
        self.reason = reason
        self.stackTrace = stackTrace
        self.deviceInfo = DeviceInfo.current
        self.appInfo = AppInfo.current
    }

    enum CrashType: String, Codable {
        case exception = "Exception"
        case signal = "Signal"
        case unknown = "Unknown"
    }
}

/// Device information for crash reports
struct DeviceInfo: Codable {
    let osVersion: String
    let architecture: String
    let memoryTotal: UInt64
    let processorCount: Int

    static var current: DeviceInfo {
        let info = ProcessInfo.processInfo
        return DeviceInfo(
            osVersion: info.operatingSystemVersionString,
            architecture: getArchitecture(),
            memoryTotal: info.physicalMemory,
            processorCount: info.processorCount
        )
    }

    private static func getArchitecture() -> String {
        #if arch(x86_64)
        return "x86_64"
        #elseif arch(arm64)
        return "arm64"
        #else
        return "unknown"
        #endif
    }
}

/// Application information for crash reports
struct AppInfo: Codable {
    let version: String
    let build: String
    let bundleIdentifier: String

    static var current: AppInfo {
        let bundle = Bundle.main
        return AppInfo(
            version: bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            build: bundle.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
            bundleIdentifier: bundle.bundleIdentifier ?? "Unknown"
        )
    }
}

// MARK: - Extensions

extension CrashReport {
    /// Returns a formatted string representation of the crash report
    var formattedDescription: String {
        var result = "=== CRASH REPORT ===\n"
        result += "Date: \(ISO8601DateFormatter().string(from: date))\n"
        result += "Type: \(type.rawValue)\n"

        if let reason = reason {
            result += "Reason: \(reason)\n"
        }

        result += "\n--- App Info ---\n"
        result += "Version: \(appInfo.version) (\(appInfo.build))\n"
        result += "Bundle ID: \(appInfo.bundleIdentifier)\n"

        result += "\n--- Device Info ---\n"
        result += "OS: \(deviceInfo.osVersion)\n"
        result += "Architecture: \(deviceInfo.architecture)\n"
        result += "Memory: \(deviceInfo.memoryTotal / 1024 / 1024 / 1024) GB\n"
        result += "CPUs: \(deviceInfo.processorCount)\n"

        if !stackTrace.isEmpty {
            result += "\n--- Stack Trace ---\n"
            result += stackTrace.joined(separator: "\n")
        }

        return result
    }

    /// Returns a short summary suitable for UI display
    var summary: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let dateStr = formatter.string(from: date)
        return "\(type.rawValue) - \(dateStr)"
    }
}