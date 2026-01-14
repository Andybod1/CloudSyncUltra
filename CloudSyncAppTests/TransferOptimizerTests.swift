import XCTest
@testable import CloudSyncApp

/// Tests for TransferOptimizer performance optimization (#70)
/// Verifies dynamic parallelism configuration based on transfer characteristics
final class TransferOptimizerTests: XCTestCase {

    // MARK: - TransferConfig Structure Tests

    func testTransferConfigStructExists() {
        // Verify TransferConfig has all required fields
        let config = TransferOptimizer.TransferConfig(
            transfers: 4,
            checkers: 16,
            bufferSize: "32M",
            multiThread: false,
            multiThreadStreams: 0,
            multiThreadCutoff: "100M",
            fastList: false,
            chunkSize: nil
        )

        XCTAssertEqual(config.transfers, 4)
        XCTAssertEqual(config.checkers, 16)
        XCTAssertEqual(config.bufferSize, "32M")
        XCTAssertFalse(config.multiThread)
        XCTAssertEqual(config.multiThreadStreams, 0)
        XCTAssertEqual(config.multiThreadCutoff, "100M")
        XCTAssertFalse(config.fastList)
        XCTAssertNil(config.chunkSize)
    }

    // MARK: - Default Arguments Tests

    func testDefaultArgsReturnsCorrectValues() {
        let args = TransferOptimizer.defaultArgs()

        // Verify default args include required settings
        XCTAssertTrue(args.contains("--transfers"))
        XCTAssertTrue(args.contains("--checkers"))
        XCTAssertTrue(args.contains("--buffer-size"))

        // Verify optimized values
        if let transfersIndex = args.firstIndex(of: "--transfers") {
            let transfersValue = args[args.index(after: transfersIndex)]
            XCTAssertEqual(transfersValue, "4", "Default transfers should be 4")
        } else {
            XCTFail("Missing --transfers argument")
        }

        if let checkersIndex = args.firstIndex(of: "--checkers") {
            let checkersValue = args[args.index(after: checkersIndex)]
            XCTAssertEqual(checkersValue, "16", "Default checkers should be 16 (increased from 8)")
        } else {
            XCTFail("Missing --checkers argument")
        }

        if let bufferIndex = args.firstIndex(of: "--buffer-size") {
            let bufferValue = args[args.index(after: bufferIndex)]
            XCTAssertEqual(bufferValue, "32M", "Default buffer size should be 32M (increased from 16M)")
        } else {
            XCTFail("Missing --buffer-size argument")
        }
    }

    func testDefaultArgsArrayLength() {
        let args = TransferOptimizer.defaultArgs()
        // Should have 6 elements: --transfers, 4, --checkers, 16, --buffer-size, 32M
        XCTAssertEqual(args.count, 6, "Default args should contain 3 flag-value pairs")
    }

    // MARK: - Optimize Method Tests

    func testOptimizeForSmallFiles() {
        // Many small files should use high parallelism
        let config = TransferOptimizer.optimize(
            fileCount: 500,
            totalBytes: 50_000_000,  // 50MB total, 100KB average
            remoteName: "googledrive",
            isDirectory: true,
            isDownload: false
        )

        // Small files benefit from high parallelism
        XCTAssertGreaterThanOrEqual(config.transfers, 16, "Small files should use high transfers")
        XCTAssertGreaterThanOrEqual(config.checkers, 16, "Should have at least 16 checkers")
        XCTAssertEqual(config.bufferSize, "32M", "Small files should use default buffer")
    }

    func testOptimizeForMediumFiles() {
        // Medium-sized files
        let config = TransferOptimizer.optimize(
            fileCount: 50,
            totalBytes: 2_500_000_000,  // 2.5GB total, 50MB average
            remoteName: "onedrive",
            isDirectory: true,
            isDownload: false
        )

        // Medium files use moderate parallelism
        XCTAssertGreaterThanOrEqual(config.transfers, 4)
        XCTAssertLessThanOrEqual(config.transfers, 16)
    }

    func testOptimizeForLargeFiles() {
        // Few large files
        let config = TransferOptimizer.optimize(
            fileCount: 5,
            totalBytes: 5_000_000_000,  // 5GB total, 1GB average
            remoteName: "s3",
            isDirectory: true,
            isDownload: false
        )

        // Large files need fewer transfers but bigger buffers
        XCTAssertLessThanOrEqual(config.transfers, 8, "Large files should use fewer transfers")
        XCTAssertTrue(["64M", "128M"].contains(config.bufferSize), "Large files should use bigger buffer")
    }

    func testOptimizeForSingleFile() {
        // Single file transfer
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 1_000_000_000,  // 1GB single file
            remoteName: "dropbox",
            isDirectory: false,
            isDownload: false
        )

        // Single file should use default transfers
        XCTAssertEqual(config.transfers, 4, "Single file should use default transfers")
    }

    func testOptimizeForFewFiles() {
        // Few files (<=10) should use default parallelism
        let config = TransferOptimizer.optimize(
            fileCount: 5,
            totalBytes: 50_000_000,
            remoteName: "googledrive",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertEqual(config.transfers, 4, "Few files should use default transfers")
    }

    // MARK: - Multi-Threading Tests

    func testMultiThreadingForLargeDownload() {
        // Large single file download should enable multi-threading
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 500_000_000,  // 500MB single file
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: true  // Download
        )

        XCTAssertTrue(config.multiThread, "Large single file download should enable multi-threading")
        // Google Drive has .limited capability (max 4 threads), default config is 4 threads
        XCTAssertEqual(config.multiThreadStreams, 4, "Multi-thread streams should be 4 for Google Drive (limited provider)")
    }

    func testMultiThreadingDisabledForUpload() {
        // Upload should not enable multi-threading
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 500_000_000,
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: false  // Upload
        )

        XCTAssertFalse(config.multiThread, "Upload should not enable multi-threading")
    }

    func testMultiThreadingDisabledForSmallDownload() {
        // Small file download should not enable multi-threading
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 10_000_000,  // 10MB
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: true
        )

        XCTAssertFalse(config.multiThread, "Small download should not enable multi-threading")
    }

    // MARK: - Fast List Tests

    func testFastListForGoogleDrive() {
        let config = TransferOptimizer.optimize(
            fileCount: 100,
            totalBytes: 100_000_000,
            remoteName: "myGoogleDrive",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertTrue(config.fastList, "Google Drive should enable fast-list")
    }

    func testFastListForOneDrive() {
        let config = TransferOptimizer.optimize(
            fileCount: 100,
            totalBytes: 100_000_000,
            remoteName: "workOneDrive",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertTrue(config.fastList, "OneDrive should enable fast-list")
    }

    func testFastListForDropbox() {
        let config = TransferOptimizer.optimize(
            fileCount: 100,
            totalBytes: 100_000_000,
            remoteName: "myDropbox",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertTrue(config.fastList, "Dropbox should enable fast-list")
    }

    func testFastListForS3() {
        let config = TransferOptimizer.optimize(
            fileCount: 100,
            totalBytes: 100_000_000,
            remoteName: "awsS3bucket",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertTrue(config.fastList, "S3 should enable fast-list")
    }

    func testFastListForB2() {
        let config = TransferOptimizer.optimize(
            fileCount: 100,
            totalBytes: 100_000_000,
            remoteName: "backblazeB2",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertTrue(config.fastList, "B2 should enable fast-list")
    }

    func testNoFastListForUnsupportedProvider() {
        let config = TransferOptimizer.optimize(
            fileCount: 100,
            totalBytes: 100_000_000,
            remoteName: "protonDrive",  // Proton does not support fast-list
            isDirectory: true,
            isDownload: false
        )

        XCTAssertFalse(config.fastList, "Unsupported providers should not enable fast-list")
    }

    // MARK: - Buffer Size Tests

    func testBufferSizeForSmallTransfers() {
        let config = TransferOptimizer.optimize(
            fileCount: 10,
            totalBytes: 10_000_000,  // 10MB
            remoteName: "remote",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertEqual(config.bufferSize, "32M", "Small transfers should use 32M buffer")
    }

    func testBufferSizeForMediumTransfers() {
        let config = TransferOptimizer.optimize(
            fileCount: 50,
            totalBytes: 500_000_000,  // 500MB
            remoteName: "remote",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertEqual(config.bufferSize, "64M", "Medium transfers should use 64M buffer")
    }

    func testBufferSizeForLargeTransfers() {
        let config = TransferOptimizer.optimize(
            fileCount: 10,
            totalBytes: 5_000_000_000,  // 5GB
            remoteName: "remote",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertEqual(config.bufferSize, "128M", "Large transfers should use 128M buffer")
    }

    // MARK: - Checkers Scaling Tests

    func testCheckersForSmallDirectory() {
        let config = TransferOptimizer.optimize(
            fileCount: 50,
            totalBytes: 50_000_000,
            remoteName: "remote",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertEqual(config.checkers, 16, "Small directories should use 16 checkers")
    }

    func testCheckersForMediumDirectory() {
        let config = TransferOptimizer.optimize(
            fileCount: 500,
            totalBytes: 500_000_000,
            remoteName: "remote",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertEqual(config.checkers, 24, "Medium directories should use 24 checkers")
    }

    func testCheckersForLargeDirectory() {
        let config = TransferOptimizer.optimize(
            fileCount: 5000,
            totalBytes: 5_000_000_000,
            remoteName: "remote",
            isDirectory: true,
            isDownload: false
        )

        XCTAssertEqual(config.checkers, 32, "Large directories should use 32 checkers")
    }

    // MARK: - BuildArgs Tests

    func testBuildArgsIncludesAllBasicArgs() {
        let config = TransferOptimizer.TransferConfig(
            transfers: 8,
            checkers: 16,
            bufferSize: "64M",
            multiThread: false,
            multiThreadStreams: 0,
            multiThreadCutoff: "100M",
            fastList: false,
            chunkSize: nil
        )

        let args = TransferOptimizer.buildArgs(from: config)

        XCTAssertTrue(args.contains("--transfers"))
        XCTAssertTrue(args.contains("8"))
        XCTAssertTrue(args.contains("--checkers"))
        XCTAssertTrue(args.contains("16"))
        XCTAssertTrue(args.contains("--buffer-size"))
        XCTAssertTrue(args.contains("64M"))
    }

    func testBuildArgsWithMultiThread() {
        let config = TransferOptimizer.TransferConfig(
            transfers: 4,
            checkers: 16,
            bufferSize: "32M",
            multiThread: true,
            multiThreadStreams: 8,
            multiThreadCutoff: "100M",
            fastList: false,
            chunkSize: nil
        )

        let args = TransferOptimizer.buildArgs(from: config)

        XCTAssertTrue(args.contains("--multi-thread-streams"))
        XCTAssertTrue(args.contains("8"))
        XCTAssertTrue(args.contains("--multi-thread-cutoff"))
        XCTAssertTrue(args.contains("100M"))
    }

    func testBuildArgsWithFastList() {
        let config = TransferOptimizer.TransferConfig(
            transfers: 4,
            checkers: 16,
            bufferSize: "32M",
            multiThread: false,
            multiThreadStreams: 0,
            multiThreadCutoff: "100M",
            fastList: true,
            chunkSize: nil
        )

        let args = TransferOptimizer.buildArgs(from: config)

        XCTAssertTrue(args.contains("--fast-list"))
    }

    func testBuildArgsWithoutFastList() {
        let config = TransferOptimizer.TransferConfig(
            transfers: 4,
            checkers: 16,
            bufferSize: "32M",
            multiThread: false,
            multiThreadStreams: 0,
            multiThreadCutoff: "100M",
            fastList: false,
            chunkSize: nil
        )

        let args = TransferOptimizer.buildArgs(from: config)

        XCTAssertFalse(args.contains("--fast-list"))
    }

    // MARK: - Edge Cases

    func testOptimizeWithZeroFiles() {
        let config = TransferOptimizer.optimize(
            fileCount: 0,
            totalBytes: 0,
            remoteName: "remote",
            isDirectory: true,
            isDownload: false
        )

        // Should not crash and should return sensible defaults
        XCTAssertGreaterThan(config.transfers, 0)
        XCTAssertGreaterThan(config.checkers, 0)
        XCTAssertFalse(config.bufferSize.isEmpty)
    }

    func testOptimizeWithVeryLargeFileCount() {
        let config = TransferOptimizer.optimize(
            fileCount: 100_000,
            totalBytes: 100_000_000_000,
            remoteName: "remote",
            isDirectory: true,
            isDownload: false
        )

        // Should cap at maximum values
        XCTAssertLessThanOrEqual(config.transfers, 32)
        XCTAssertLessThanOrEqual(config.checkers, 32)
    }
}
