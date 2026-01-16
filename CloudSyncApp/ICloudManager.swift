import Foundation

class ICloudManager {
    static let localFolderPath = "~/Library/Mobile Documents/com~apple~CloudDocs/"

    static var expandedPath: String {
        NSString(string: localFolderPath).expandingTildeInPath
    }

    static var isLocalFolderAvailable: Bool {
        FileManager.default.fileExists(atPath: expandedPath)
    }

    static var localFolderURL: URL? {
        guard isLocalFolderAvailable else { return nil }
        return URL(fileURLWithPath: expandedPath)
    }
}
