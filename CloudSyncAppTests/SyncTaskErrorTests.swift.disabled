import XCTest
@testable import CloudSyncApp

final class SyncTaskErrorTests: XCTestCase {

    // MARK: - Task Status Tests

    func testTaskFailedState() {
        var task = SyncTask(
            id: UUID(),
            type: .upload,
            status: .running,
            sourceName: "Local",
            destinationName: "Google Drive",
            filesTransferred: 0,
            totalFiles: 5
        )

        task.error = .quotaExceeded(provider: "Google Drive")
        task.status = .failed

        XCTAssertEqual(task.status, .failed)
        XCTAssertNotNil(task.error)
    }

    func testTaskPartiallyCompletedState() {
        var task = SyncTask(
            id: UUID(),
            type: .upload,
            status: .running,
            sourceName: "Local",
            destinationName: "Dropbox",
            filesTransferred: 3,
            totalFiles: 5
        )

        task.error = .quotaExceeded(provider: "Dropbox")
        task.failedFiles = ["file4.txt", "file5.txt"]
        task.partiallyCompleted = true
        task.status = .partiallyCompleted

        XCTAssertEqual(task.status, .partiallyCompleted)
        XCTAssertTrue(task.partiallyCompleted)
        XCTAssertEqual(task.failedFiles.count, 2)
    }

    // MARK: - Computed Property Tests

    func testErrorMessageProperty() {
        var task = SyncTask(
            id: UUID(),
            type: .upload,
            status: .failed,
            sourceName: "Local",
            destinationName: "Google Drive",
            filesTransferred: 0,
            totalFiles: 1
        )

        task.error = .quotaExceeded(provider: "Google Drive")

        XCTAssertNotNil(task.errorMessage)
        XCTAssertTrue(task.errorMessage!.contains("storage is full"))
    }

    func testErrorTitleProperty() {
        var task = SyncTask(
            id: UUID(),
            type: .download,
            status: .failed,
            sourceName: "Google Drive",
            destinationName: "Local",
            filesTransferred: 0,
            totalFiles: 1
        )

        task.error = .connectionTimeout

        XCTAssertEqual(task.errorTitle, "Connection Error")
    }

    func testCanRetryProperty() {
        var task = SyncTask(
            id: UUID(),
            type: .upload,
            status: .failed,
            sourceName: "Local",
            destinationName: "Dropbox",
            filesTransferred: 0,
            totalFiles: 1
        )

        // Retryable error
        task.error = .connectionTimeout
        XCTAssertTrue(task.canRetry)

        // Non-retryable error
        task.error = .quotaExceeded(provider: "Dropbox")
        XCTAssertFalse(task.canRetry)
    }

    func testIsCriticalErrorProperty() {
        var task = SyncTask(
            id: UUID(),
            type: .upload,
            status: .failed,
            sourceName: "Local",
            destinationName: "OneDrive",
            filesTransferred: 0,
            totalFiles: 1
        )

        // Critical error
        task.error = .quotaExceeded(provider: "OneDrive")
        XCTAssertTrue(task.isCriticalError)

        // Non-critical error
        task.error = .connectionTimeout
        XCTAssertFalse(task.isCriticalError)
    }

    func testFailureSummaryProperty() {
        var task = SyncTask(
            id: UUID(),
            type: .upload,
            status: .partiallyCompleted,
            sourceName: "Local",
            destinationName: "Google Drive",
            filesTransferred: 8,
            totalFiles: 10
        )

        task.partiallyCompleted = true
        task.failedFiles = ["file9.txt", "file10.txt"]

        XCTAssertNotNil(task.failureSummary)
        XCTAssertTrue(task.failureSummary!.contains("8 of 10"))
    }

    func testFailureSummaryNilWhenNotPartial() {
        var task = SyncTask(
            id: UUID(),
            type: .upload,
            status: .completed,
            sourceName: "Local",
            destinationName: "Google Drive",
            filesTransferred: 10,
            totalFiles: 10
        )

        task.partiallyCompleted = false

        XCTAssertNil(task.failureSummary)
    }

    // MARK: - Codable Tests

    func testSyncTaskWithErrorCodable() throws {
        var task = SyncTask(
            id: UUID(),
            type: .upload,
            status: .failed,
            sourceName: "Local",
            destinationName: "Google Drive",
            filesTransferred: 0,
            totalFiles: 5
        )

        task.error = .quotaExceeded(provider: "Google Drive")
        task.failedFiles = ["file1.txt", "file2.txt"]
        task.partiallyCompleted = false
        task.errorTimestamp = Date()

        let encoded = try JSONEncoder().encode(task)
        let decoded = try JSONDecoder().decode(SyncTask.self, from: encoded)

        XCTAssertEqual(task.id, decoded.id)
        XCTAssertEqual(task.status, decoded.status)
        XCTAssertEqual(task.error, decoded.error)
        XCTAssertEqual(task.failedFiles, decoded.failedFiles)
        XCTAssertEqual(task.partiallyCompleted, decoded.partiallyCompleted)
    }
}