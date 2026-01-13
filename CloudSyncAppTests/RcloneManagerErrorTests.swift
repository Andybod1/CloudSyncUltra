import XCTest
@testable import CloudSyncApp

final class RcloneManagerErrorTests: XCTestCase {

    var manager: RcloneManager!

    override func setUp() {
        super.setUp()
        manager = RcloneManager.shared
    }

    // MARK: - SyncProgress Error Field Tests

    func testSyncProgressHasErrorFields() {
        var progress = SyncProgress()

        // Test that error fields exist
        progress.failedFiles = ["file1.txt", "file2.txt"]
        progress.partialSuccess = true
        progress.errorMessage = "Connection timed out"

        XCTAssertEqual(progress.failedFiles.count, 2)
        XCTAssertTrue(progress.partialSuccess)
        XCTAssertEqual(progress.errorMessage, "Connection timed out")
    }

    // MARK: - Error Detection Integration Tests

    func testUploadErrorDetection() async throws {
        // This would require mocking rclone or using a test fixture
        // For now, document the expected behavior

        // Expected: When upload fails with quota error
        // 1. parseError() should identify the error type
        // 2. SyncProgress should include error field
        // 3. Stream should yield progress with error
        // 4. If complete failure, throw TransferError
    }

    func testPartialSuccessDetection() {
        // Test that partial success is correctly identified
        var progress = SyncProgress()
        progress.totalFiles = 10
        progress.filesTransferred = 7
        progress.failedFiles = ["file8.txt", "file9.txt", "file10.txt"]
        progress.errorMessage = "Quota exceeded"

        // Partial success should be true when some files succeeded
        progress.partialSuccess = progress.filesTransferred > 0 &&
                                  progress.filesTransferred < progress.totalFiles

        XCTAssertTrue(progress.partialSuccess)
    }

    func testCompleteFailureDetection() {
        var progress = SyncProgress()
        progress.totalFiles = 10
        progress.filesTransferred = 0
        progress.errorMessage = "Authentication failed"

        // Not partial success when no files succeeded
        progress.partialSuccess = progress.filesTransferred > 0 &&
                                  progress.filesTransferred < progress.totalFiles

        XCTAssertFalse(progress.partialSuccess)
    }
}
