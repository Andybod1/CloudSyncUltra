import XCTest
@testable import CloudSyncApp

/// Integration tests for complete CloudSync Ultra workflows
/// These tests verify end-to-end functionality across multiple components
final class WorkflowIntegrationTests: XCTestCase {

    // MARK: - Remote Configuration Workflow

    func testRemoteConfigurationWorkflow() throws {
        // Test that a remote can be configured with valid name
        let remoteName = "test-remote"
        let remoteType = CloudProviderType.dropbox

        // Verify provider has display name and rclone mapping
        XCTAssertFalse(remoteType.displayName.isEmpty,
                       "Provider should have a display name")
        XCTAssertFalse(remoteType.rcloneType.isEmpty,
                       "Provider should have rclone type mapping")

        // Verify remote name validation
        XCTAssertTrue(isValidRemoteName(remoteName),
                      "Remote name should be valid")
        XCTAssertFalse(isValidRemoteName(""),
                       "Empty name should be invalid")
        XCTAssertFalse(isValidRemoteName("name with spaces"),
                       "Name with spaces should be invalid")
    }

    func testAllProvidersHaveRequiredProperties() {
        // Verify all providers have properly defined properties
        for provider in CloudProviderType.allCases {
            XCTAssertFalse(provider.displayName.isEmpty,
                           "\(provider) should have a display name")
            XCTAssertFalse(provider.rcloneType.isEmpty,
                           "\(provider) should have an rclone type mapping")
        }
    }

    // MARK: - Sync Task Workflow

    func testSyncTaskCreationWorkflow() {
        // Test sync task can be created with valid configuration
        let task = SyncTask(
            name: "Test Sync",
            type: .sync,
            sourceRemote: "local",
            sourcePath: "/Users/test/Documents",
            destinationRemote: "remote",
            destinationPath: "backup"
        )

        XCTAssertEqual(task.name, "Test Sync")
        XCTAssertEqual(task.type, TaskType.sync)
        XCTAssertEqual(task.state, TaskState.pending)
        XCTAssertEqual(task.sourceRemote, "local")
        XCTAssertEqual(task.destinationRemote, "remote")
    }

    func testTaskTypeOptions() {
        // Verify all task types are available
        let types = TaskType.allCases
        XCTAssertTrue(types.contains(TaskType.sync))
        XCTAssertTrue(types.contains(TaskType.transfer))
        XCTAssertTrue(types.contains(TaskType.backup))
        XCTAssertEqual(types.count, 3)
    }

    func testTaskStateTransitions() {
        // Verify task states exist
        let states: [TaskState] = [TaskState.pending, TaskState.running, TaskState.completed, TaskState.failed, TaskState.paused, TaskState.cancelled]

        for state in states {
            XCTAssertFalse(state.rawValue.isEmpty, "State should have raw value")
        }
    }

    // MARK: - File Listing Workflow

    func testFileListParsingWorkflow() throws {
        // Test complete file listing workflow with realistic data
        let jsonResponse = """
        [
            {"Path": "Documents", "Name": "Documents", "Size": -1, "IsDir": true, "ModTime": "2024-01-15T10:00:00Z"},
            {"Path": "Documents/report.pdf", "Name": "report.pdf", "Size": 1048576, "IsDir": false, "ModTime": "2024-01-15T11:00:00Z"},
            {"Path": "Documents/notes.txt", "Name": "notes.txt", "Size": 256, "IsDir": false, "ModTime": "2024-01-15T12:00:00Z"},
            {"Path": "Photos", "Name": "Photos", "Size": -1, "IsDir": true, "ModTime": "2024-01-14T10:00:00Z"},
            {"Path": "Photos/vacation.jpg", "Name": "vacation.jpg", "Size": 5242880, "IsDir": false, "ModTime": "2024-01-14T11:00:00Z"}
        ]
        """.data(using: .utf8)!

        let files = try JSONDecoder().decode([RemoteFile].self, from: jsonResponse)

        // Verify file count
        XCTAssertEqual(files.count, 5)

        // Verify directory filtering
        let directories = files.filter { $0.IsDir }
        XCTAssertEqual(directories.count, 2)

        // Verify file filtering
        let regularFiles = files.filter { !$0.IsDir }
        XCTAssertEqual(regularFiles.count, 3)

        // Verify size calculations
        let totalSize = regularFiles.reduce(Int64(0)) { $0 + $1.Size }
        XCTAssertEqual(totalSize, 1048576 + 256 + 5242880)
    }

    func testFileListSortingWorkflow() throws {
        let jsonResponse = """
        [
            {"Path": "zebra.txt", "Name": "zebra.txt", "Size": 100, "IsDir": false, "ModTime": "2024-01-01T00:00:00Z"},
            {"Path": "alpha.txt", "Name": "alpha.txt", "Size": 300, "IsDir": false, "ModTime": "2024-01-03T00:00:00Z"},
            {"Path": "beta.txt", "Name": "beta.txt", "Size": 200, "IsDir": false, "ModTime": "2024-01-02T00:00:00Z"}
        ]
        """.data(using: .utf8)!

        let files = try JSONDecoder().decode([RemoteFile].self, from: jsonResponse)

        // Sort by name
        let byName = files.sorted { $0.Name < $1.Name }
        XCTAssertEqual(byName.map { $0.Name }, ["alpha.txt", "beta.txt", "zebra.txt"])

        // Sort by size
        let bySize = files.sorted { $0.Size < $1.Size }
        XCTAssertEqual(bySize.map { $0.Name }, ["zebra.txt", "beta.txt", "alpha.txt"])
    }

    // MARK: - Error Handling Workflow

    func testErrorHandlingForInvalidJSON() {
        let invalidJSON = "not valid json".data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode([RemoteFile].self, from: invalidJSON)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testErrorHandlingForMissingFields() {
        // JSON missing required fields
        let incompleteJSON = """
        [{"Path": "test.txt"}]
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode([RemoteFile].self, from: incompleteJSON))
    }

    // MARK: - Provider Ecosystem Workflow

    func testProviderCategoryWorkflow() {
        // Verify providers are properly categorized
        let consumerProviders = CloudProviderType.allCases.filter { provider in
            [.dropbox, .googleDrive, .oneDrive, .icloud, .box, .pcloud, .mega].contains(provider)
        }
        XCTAssertGreaterThanOrEqual(consumerProviders.count, 7,
                                    "Should have consumer cloud providers")

        let s3Compatible = CloudProviderType.allCases.filter { provider in
            [.s3, .backblazeB2, .wasabi, .cloudflareR2, .digitalOceanSpaces, .storj].contains(provider)
        }
        XCTAssertGreaterThanOrEqual(s3Compatible.count, 6,
                                    "Should have S3-compatible providers")

        let selfHosted = CloudProviderType.allCases.filter { provider in
            [.nextcloud, .owncloud, .seafile, .webdav, .sftp, .ftp].contains(provider)
        }
        XCTAssertGreaterThanOrEqual(selfHosted.count, 6,
                                    "Should have self-hosted options")
    }

    // MARK: - Data Consistency Workflow

    func testRemoteFileRoundTrip() throws {
        // Test that RemoteFile can be encoded and decoded without data loss
        let original = """
        [{"Path": "test/file.txt", "Name": "file.txt", "Size": 12345, "MimeType": "text/plain", "ModTime": "2024-01-15T10:30:00.000000000Z", "IsDir": false}]
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode([RemoteFile].self, from: original)
        let encoded = try JSONEncoder().encode(decoded)
        let redecoded = try JSONDecoder().decode([RemoteFile].self, from: encoded)

        XCTAssertEqual(decoded.count, redecoded.count)
        XCTAssertEqual(decoded[0].Path, redecoded[0].Path)
        XCTAssertEqual(decoded[0].Size, redecoded[0].Size)
        XCTAssertEqual(decoded[0].IsDir, redecoded[0].IsDir)
    }

    func testSyncTaskRoundTrip() throws {
        // Test that SyncTask can be encoded and decoded
        let original = SyncTask(
            name: "Roundtrip Test",
            type: .backup,
            sourceRemote: "local",
            sourcePath: "/test",
            destinationRemote: "cloud",
            destinationPath: "backup",
            encryptDestination: true
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SyncTask.self, from: encoded)

        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.name, decoded.name)
        XCTAssertEqual(original.type, decoded.type)
        XCTAssertEqual(original.encryptDestination, decoded.encryptDestination)
    }

    // MARK: - Helpers

    private func isValidRemoteName(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        let validCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        return name.unicodeScalars.allSatisfy { validCharacters.contains($0) }
    }
}
