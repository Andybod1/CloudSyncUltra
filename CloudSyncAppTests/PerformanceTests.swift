import XCTest
@testable import CloudSyncApp

/// Performance tests for CloudSync Ultra
/// These tests measure critical performance metrics and establish baselines
final class PerformanceTests: XCTestCase {

    // MARK: - File List Parsing Performance

    func testFileListParsing_100Files() {
        let json = generateLargeFileList(count: 100)

        measure {
            _ = try? JSONDecoder().decode([RemoteFile].self, from: json)
        }
    }

    func testFileListParsing_1000Files() {
        let json = generateLargeFileList(count: 1000)

        measure {
            _ = try? JSONDecoder().decode([RemoteFile].self, from: json)
        }
    }

    func testFileListParsing_10000Files() {
        let json = generateLargeFileList(count: 10000)

        measure {
            _ = try? JSONDecoder().decode([RemoteFile].self, from: json)
        }
    }

    // MARK: - Memory Performance

    func testMemoryUsage_LargeFileList() {
        measure(metrics: [XCTMemoryMetric()]) {
            let json = generateLargeFileList(count: 5000)
            let _ = try? JSONDecoder().decode([RemoteFile].self, from: json)
        }
    }

    // MARK: - Encoding Performance

    func testFileListEncoding_1000Files() {
        let files = generateRemoteFiles(count: 1000)

        measure {
            _ = try? JSONEncoder().encode(files)
        }
    }

    // MARK: - String Processing Performance

    func testPathNormalization_1000Paths() {
        let paths = (0..<1000).map { "remote:/path/to/file\($0).txt" }

        measure {
            for path in paths {
                _ = path.replacingOccurrences(of: "\\", with: "/")
                    .trimmingCharacters(in: .whitespaces)
            }
        }
    }

    // MARK: - Date Parsing Performance

    func testDateParsing_1000Dates() {
        let dateStrings = (0..<1000).map { _ in "2024-01-15T10:30:00.000000000Z" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        measure {
            for dateString in dateStrings {
                _ = formatter.date(from: dateString)
            }
        }
    }

    // MARK: - Sorting Performance

    func testFileSorting_ByName_10000Files() {
        let files = generateRemoteFiles(count: 10000)

        measure {
            _ = files.sorted { $0.Name < $1.Name }
        }
    }

    func testFileSorting_BySize_10000Files() {
        let files = generateRemoteFiles(count: 10000)

        measure {
            _ = files.sorted { $0.Size < $1.Size }
        }
    }

    // MARK: - Filtering Performance

    func testFileFiltering_ByExtension_10000Files() {
        let files = generateRemoteFiles(count: 10000)

        measure {
            _ = files.filter { $0.Name.hasSuffix(".txt") }
        }
    }

    func testFileFiltering_DirectoriesOnly_10000Files() {
        let files = generateRemoteFiles(count: 10000)

        measure {
            _ = files.filter { $0.IsDir }
        }
    }

    // MARK: - Test Helpers

    private func generateLargeFileList(count: Int) -> Data {
        var files: [[String: Any]] = []
        for i in 0..<count {
            let isDir = i % 10 == 0 // Every 10th item is a directory
            files.append([
                "Path": "path/to/file\(i).\(isDir ? "" : "txt")",
                "Name": "file\(i).\(isDir ? "" : "txt")",
                "Size": isDir ? -1 : Int.random(in: 100...10_000_000),
                "MimeType": isDir ? "inode/directory" : "text/plain",
                "ModTime": "2024-01-\(String(format: "%02d", (i % 28) + 1))T10:30:00.000000000Z",
                "IsDir": isDir
            ])
        }
        return try! JSONSerialization.data(withJSONObject: files)
    }

    private func generateRemoteFiles(count: Int) -> [RemoteFile] {
        let json = generateLargeFileList(count: count)
        return try! JSONDecoder().decode([RemoteFile].self, from: json)
    }
}
