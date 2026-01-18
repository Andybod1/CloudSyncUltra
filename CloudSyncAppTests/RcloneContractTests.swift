import XCTest
@testable import CloudSyncApp

/// Contract tests for rclone CLI JSON output parsing
/// These tests verify that our Swift types correctly parse rclone's actual output format
final class RcloneContractTests: XCTestCase {

    // MARK: - lsjson Parsing Tests

    func testLsjsonParsing_ValidResponse() throws {
        let json = try loadFixture("lsjson-response.json")
        let files = try JSONDecoder().decode([RemoteFile].self, from: json)

        XCTAssertEqual(files.count, 3)

        // First file - PDF document
        XCTAssertEqual(files[0].Path, "Documents/report.pdf")
        XCTAssertEqual(files[0].Name, "report.pdf")
        XCTAssertEqual(files[0].Size, 1048576)
        XCTAssertEqual(files[0].MimeType, "application/pdf")
        XCTAssertEqual(files[0].ModTime, "2024-01-15T10:30:00.000000000Z")
        XCTAssertFalse(files[0].IsDir)

        // Second item - Directory
        XCTAssertEqual(files[1].Path, "Photos")
        XCTAssertEqual(files[1].Name, "Photos")
        XCTAssertEqual(files[1].Size, -1) // Directories have -1 size
        XCTAssertEqual(files[1].MimeType, "inode/directory")
        XCTAssertTrue(files[1].IsDir)

        // Third file - Text file
        XCTAssertEqual(files[2].Path, "notes.txt")
        XCTAssertEqual(files[2].Name, "notes.txt")
        XCTAssertEqual(files[2].Size, 256)
        XCTAssertFalse(files[2].IsDir)
    }

    func testLsjsonParsing_EmptyDirectory() throws {
        let json = try loadFixture("lsjson-empty.json")
        let files = try JSONDecoder().decode([RemoteFile].self, from: json)

        XCTAssertTrue(files.isEmpty, "Empty directory should return empty array")
    }

    func testLsjsonParsing_NoMimeType() throws {
        // Tests --no-mimetype flag output (MimeType field omitted)
        let json = try loadFixture("lsjson-no-mimetype.json")
        let files = try JSONDecoder().decode([RemoteFile].self, from: json)

        XCTAssertEqual(files.count, 2)
        XCTAssertNil(files[0].MimeType, "MimeType should be nil when --no-mimetype is used")
        XCTAssertNil(files[1].MimeType)
        XCTAssertEqual(files[0].Name, "backup.zip")
        XCTAssertFalse(files[0].IsDir)
        XCTAssertTrue(files[1].IsDir)
    }

    func testLsjsonParsing_NoModTime() throws {
        // Tests --no-modtime flag output (ModTime field omitted)
        let json = try loadFixture("lsjson-no-modtime.json")
        let files = try JSONDecoder().decode([RemoteFile].self, from: json)

        XCTAssertEqual(files.count, 1)
        XCTAssertNil(files[0].ModTime, "ModTime should be nil when --no-modtime is used")
        XCTAssertEqual(files[0].MimeType, "text/csv")
        XCTAssertEqual(files[0].Size, 102400)
    }

    // MARK: - Stats Progress Parsing Tests

    func testStatsProgressParsing() throws {
        let json = try loadFixture("stats-progress.json")

        // Decode as dictionary to verify structure
        let stats = try JSONDecoder().decode(RcloneStats.self, from: json)

        XCTAssertEqual(stats.bytes, 52428800)
        XCTAssertEqual(stats.totalBytes, 209715200)
        XCTAssertEqual(stats.transfers, 5)
        XCTAssertEqual(stats.totalTransfers, 20)
        XCTAssertEqual(stats.errors, 0)
        XCTAssertFalse(stats.fatalError)
        XCTAssertEqual(stats.speed, 1747626.67, accuracy: 0.01)

        // Check transferring array
        XCTAssertEqual(stats.transferring?.count, 1)
        if let transfer = stats.transferring?.first {
            XCTAssertEqual(transfer.name, "large_file.zip")
            XCTAssertEqual(transfer.size, 104857600)
            XCTAssertEqual(transfer.percentage, 25)
        }
    }

    // MARK: - Error Pattern Tests

    func testErrorPattern_NotFound() throws {
        let errorOutput = try loadFixtureString("error-not-found.txt")

        XCTAssertTrue(errorOutput.contains("directory not found"),
                      "Should contain 'directory not found' error pattern")
        XCTAssertTrue(errorOutput.contains("ERROR"),
                      "Should contain ERROR prefix")
    }

    func testErrorPattern_PermissionDenied() throws {
        let errorOutput = try loadFixtureString("error-permission.txt")

        XCTAssertTrue(errorOutput.contains("AccessDenied") || errorOutput.contains("permission denied"),
                      "Should contain access denied error pattern")
        XCTAssertTrue(errorOutput.contains("ERROR"),
                      "Should contain ERROR prefix")
    }

    // MARK: - Edge Cases

    func testRemoteFile_LargeFileSize() throws {
        // Test handling of large file sizes (> 4GB)
        let json = """
        [{
            "Path": "large_backup.tar",
            "Name": "large_backup.tar",
            "Size": 10737418240,
            "MimeType": "application/x-tar",
            "ModTime": "2024-01-15T10:30:00.000000000Z",
            "IsDir": false
        }]
        """.data(using: .utf8)!

        let files = try JSONDecoder().decode([RemoteFile].self, from: json)
        XCTAssertEqual(files[0].Size, 10737418240) // 10GB in bytes
    }

    func testRemoteFile_SpecialCharactersInPath() throws {
        // Test handling of special characters in file paths
        let json = """
        [{
            "Path": "Documents/My File (1).txt",
            "Name": "My File (1).txt",
            "Size": 100,
            "MimeType": "text/plain",
            "ModTime": "2024-01-15T10:30:00.000000000Z",
            "IsDir": false
        }]
        """.data(using: .utf8)!

        let files = try JSONDecoder().decode([RemoteFile].self, from: json)
        XCTAssertEqual(files[0].Path, "Documents/My File (1).txt")
        XCTAssertEqual(files[0].Name, "My File (1).txt")
    }

    func testRemoteFile_UnicodeInPath() throws {
        // Test handling of unicode characters in file paths
        let json = """
        [{
            "Path": "Dokumente/Prüfbericht.pdf",
            "Name": "Prüfbericht.pdf",
            "Size": 5000,
            "MimeType": "application/pdf",
            "ModTime": "2024-01-15T10:30:00.000000000Z",
            "IsDir": false
        }]
        """.data(using: .utf8)!

        let files = try JSONDecoder().decode([RemoteFile].self, from: json)
        XCTAssertEqual(files[0].Name, "Prüfbericht.pdf")
    }

    func testRemoteFile_ZeroSizeFile() throws {
        // Test handling of empty files
        let json = """
        [{
            "Path": "empty.txt",
            "Name": "empty.txt",
            "Size": 0,
            "MimeType": "text/plain",
            "ModTime": "2024-01-15T10:30:00.000000000Z",
            "IsDir": false
        }]
        """.data(using: .utf8)!

        let files = try JSONDecoder().decode([RemoteFile].self, from: json)
        XCTAssertEqual(files[0].Size, 0)
        XCTAssertFalse(files[0].IsDir)
    }

    // MARK: - Fixture Helpers

    private func loadFixture(_ name: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))

        // Try multiple paths for fixture location
        if let url = bundle.url(forResource: name, withExtension: nil, subdirectory: "Fixtures/Rclone") {
            return try Data(contentsOf: url)
        }

        // Fallback: Look in test bundle root
        if let url = bundle.url(forResource: name.replacingOccurrences(of: ".json", with: ""),
                                withExtension: "json") {
            return try Data(contentsOf: url)
        }

        // Final fallback: Load from file system during development
        let devPath = "/Users/antti/Claude/CloudSyncAppTests/Fixtures/Rclone/\(name)"
        if FileManager.default.fileExists(atPath: devPath) {
            return try Data(contentsOf: URL(fileURLWithPath: devPath))
        }

        throw NSError(domain: "RcloneContractTests", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Fixture not found: \(name)"])
    }

    private func loadFixtureString(_ name: String) throws -> String {
        let data = try loadFixture(name)
        guard let string = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "RcloneContractTests", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Could not decode fixture as UTF-8: \(name)"])
        }
        return string
    }
}

// MARK: - Supporting Types for Stats Parsing

/// Rclone transfer progress stats structure
struct RcloneStats: Codable {
    let bytes: Int64
    let checks: Int
    let deletedDirs: Int
    let deletes: Int
    let elapsedTime: Double
    let errors: Int
    let eta: Int?
    let fatalError: Bool
    let renames: Int
    let retryError: Bool
    let speed: Double
    let totalBytes: Int64
    let totalChecks: Int
    let totalTransfers: Int
    let transferTime: Double
    let transfers: Int
    let transferring: [TransferProgress]?
}

/// Individual transfer progress
struct TransferProgress: Codable {
    let name: String
    let size: Int64
    let bytes: Int64
    let eta: Int?
    let percentage: Int
    let speed: Double
    let speedAvg: Double
}
