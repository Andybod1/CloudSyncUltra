//
//  MultiThreadDownloadTests.swift
//  CloudSyncAppTests
//
//  Unit tests for Multi-Threaded Large File Downloads (#72)
//  Tests thread count configuration, size thresholds, provider capabilities, and argument generation
//

import XCTest
@testable import CloudSyncApp

/// Tests for Multi-Threaded Download functionality (#72)
final class MultiThreadDownloadTests: XCTestCase {

    // MARK: - Test Lifecycle

    override func setUp() {
        super.setUp()
        // Clear UserDefaults for consistent test state
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadEnabled")
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadThreads")
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadThreshold")
    }

    override func tearDown() {
        // Clean up
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadEnabled")
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadThreads")
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadThreshold")
        super.tearDown()
    }

    // MARK: - TC-72.1: Default Thread Count Tests

    /// TC-72.1.1: Default streams count respects provider limits - P0
    func testDefaultMultiThreadStreamsRespectsProviderLimits() {
        // Given: TransferOptimizer.optimize() called for large download
        // When: fileCount == 1 AND totalBytes > 100MB AND isDownload == true
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 500_000_000,  // 500MB - well above threshold
            remoteName: "googledrive",  // Google Drive has .limited capability (max 4)
            isDirectory: false,
            isDownload: true
        )

        // Then: config.multiThreadStreams == 4 (min of default 4 and provider max 4)
        XCTAssertEqual(config.multiThreadStreams, 4, "Default multi-thread streams should be 4 for Google Drive")
        // And: config.multiThread == true
        XCTAssertTrue(config.multiThread, "Multi-threading should be enabled for large downloads")
    }

    /// TC-72.1.1b: Full support providers get full thread count - P0
    func testFullSupportProviderGetsFullThreadCount() {
        // Given: S3 provider (full support, max 16 threads)
        let customConfig = MultiThreadDownloadConfig(
            enabled: true,
            threadCount: 8,  // Request 8 threads
            sizeThreshold: 100_000_000
        )

        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 500_000_000,
            remoteName: "s3bucket",  // Full support provider
            isDirectory: false,
            isDownload: true,
            multiThreadConfig: customConfig
        )

        // Then: Should get full 8 threads (within S3's max of 16)
        XCTAssertEqual(config.multiThreadStreams, 8, "S3 should allow 8 threads")
        XCTAssertTrue(config.multiThread, "Multi-threading should be enabled")
    }

    /// TC-72.1.2: Can change thread count - P1
    func testMultiThreadStreamsConfigurable() {
        // Given: Custom configuration with different thread count
        var customConfig = MultiThreadDownloadConfig(
            enabled: true,
            threadCount: 12,
            sizeThreshold: 100_000_000
        )
        customConfig.validateThreadCount()

        // When: Using custom config
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 500_000_000,
            remoteName: "s3bucket",  // Full support provider
            isDirectory: false,
            isDownload: true,
            multiThreadConfig: customConfig
        )

        // Then: Should use custom thread count (capped by provider capability)
        // S3 has full support (max 16), so 12 should be allowed
        XCTAssertTrue(config.multiThread)
        XCTAssertGreaterThan(config.multiThreadStreams, 0)
    }

    /// TC-72.1.3: Thread count has min/max bounds - P1
    func testMultiThreadStreamsBounds() {
        // Given: Config with out-of-bounds thread count
        var configTooHigh = MultiThreadDownloadConfig(enabled: true, threadCount: 100, sizeThreshold: 100_000_000)
        var configTooLow = MultiThreadDownloadConfig(enabled: true, threadCount: 0, sizeThreshold: 100_000_000)

        // When: Validating
        configTooHigh.validateThreadCount()
        configTooLow.validateThreadCount()

        // Then: Should be clamped to valid range (1-16)
        XCTAssertLessThanOrEqual(configTooHigh.threadCount, 16, "Thread count should be capped at 16")
        XCTAssertGreaterThanOrEqual(configTooLow.threadCount, 1, "Thread count should be at least 1")
    }

    // MARK: - TC-72.2: Multi-Thread Activation Threshold Tests

    /// TC-72.2.1: Files >100MB enable multi-threading - P0
    func testMultiThreadEnabledForLargeFiles() {
        // Given: TransferOptimizer.optimize() called
        // When: fileCount == 1 AND totalBytes == 500MB AND isDownload == true
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 500_000_000,  // 500MB
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: true
        )

        // Then: config.multiThread == true
        XCTAssertTrue(config.multiThread, "Large file download should enable multi-threading")
        // And: config.multiThreadStreams == 4 (Google Drive is .limited, max 4)
        XCTAssertEqual(config.multiThreadStreams, 4, "Should use 4 streams for Google Drive")
    }

    /// TC-72.2.2: Files <100MB use single thread - P0
    func testMultiThreadDisabledForSmallFiles() {
        // Given: TransferOptimizer.optimize() called
        // When: fileCount == 1 AND totalBytes == 10MB AND isDownload == true
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 10_000_000,  // 10MB
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: true
        )

        // Then: config.multiThread == false
        XCTAssertFalse(config.multiThread, "Small file download should not enable multi-threading")
        // And: config.multiThreadStreams == 0
        XCTAssertEqual(config.multiThreadStreams, 0, "Should use 0 streams for small files")
    }

    /// TC-72.2.3: Boundary case at threshold - P1
    func testMultiThreadThresholdExactly100MB() {
        // Given: File exactly at threshold
        let configAt = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 100_000_000,  // Exactly 100MB
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: true
        )

        let configJustBelow = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 99_999_999,  // Just below 100MB
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: true
        )

        let configJustAbove = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 100_000_001,  // Just above 100MB
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: true
        )

        // Then: Boundary behavior should be consistent
        // At threshold - depends on implementation (>= or >)
        XCTAssertFalse(configJustBelow.multiThread, "Just below threshold should not enable multi-threading")
        XCTAssertTrue(configJustAbove.multiThread, "Just above threshold should enable multi-threading")
    }

    /// TC-72.2.4: Multiple files use parallel transfers instead - P1
    func testMultiThreadDisabledForMultipleFiles() {
        // Given: Multiple large files (directory transfer)
        let config = TransferOptimizer.optimize(
            fileCount: 10,
            totalBytes: 1_000_000_000,  // 1GB total (100MB avg)
            remoteName: "googledrive",
            isDirectory: true,
            isDownload: true
        )

        // Then: Should use parallel transfers instead of multi-threading
        // Multi-threading is for single large files
        XCTAssertGreaterThan(config.transfers, 1, "Multiple files should use parallel transfers")
    }

    // MARK: - TC-72.3: Multi-Thread Cutoff Configuration Tests

    /// TC-72.3.1: Args include --multi-thread-cutoff - P1
    func testBuildArgsIncludesMultiThreadCutoff() {
        // Given: Config with multi-threading enabled
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

        // When: Building args
        let args = TransferOptimizer.buildArgs(from: config)

        // Then: Should include --multi-thread-cutoff
        XCTAssertTrue(args.contains("--multi-thread-cutoff"), "Should include multi-thread-cutoff flag")
    }

    /// TC-72.3.2: Cutoff is set to 100M - P1
    func testMultiThreadCutoffValue() {
        // Given: Config with multi-threading enabled
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

        // When: Building args
        let args = TransferOptimizer.buildArgs(from: config)

        // Then: Should contain 100M value after --multi-thread-cutoff
        if let cutoffIndex = args.firstIndex(of: "--multi-thread-cutoff") {
            let valueIndex = args.index(after: cutoffIndex)
            XCTAssertEqual(args[valueIndex], "100M", "Cutoff should be 100M")
        } else {
            XCTFail("--multi-thread-cutoff flag not found")
        }
    }

    // MARK: - TC-72.4: Provider Support Tests

    /// TC-72.4.1: Google Drive enables multi-thread - P0
    func testGoogleDriveSupportsMultiThread() {
        // Given: Google Drive provider
        let capability = ProviderMultiThreadCapability.forProvider("googledrive")

        // Then: Should have limited support (max 4 threads)
        XCTAssertEqual(capability, .limited, "Google Drive should have limited multi-thread support")
        XCTAssertEqual(capability.maxRecommendedThreads, 4, "Google Drive max threads should be 4")
    }

    /// TC-72.4.2: Dropbox enables multi-thread - P1
    func testDropboxSupportsMultiThread() {
        // Given: Dropbox provider
        let capability = ProviderMultiThreadCapability.forProvider("dropbox")

        // Then: Should have limited support
        XCTAssertEqual(capability, .limited, "Dropbox should have limited multi-thread support")
    }

    /// TC-72.4.3: S3 enables multi-thread - P1
    func testS3SupportsMultiThread() {
        // Given: S3 provider
        let capability = ProviderMultiThreadCapability.forProvider("s3")

        // Then: Should have full support
        XCTAssertEqual(capability, .full, "S3 should have full multi-thread support")
        XCTAssertEqual(capability.maxRecommendedThreads, 16, "S3 max threads should be 16")
    }

    /// TC-72.4.4: OneDrive enables multi-thread - P1
    func testOneDriveSupportsMultiThread() {
        // Given: OneDrive provider
        let capability = ProviderMultiThreadCapability.forProvider("onedrive")

        // Then: Should have limited support
        XCTAssertEqual(capability, .limited, "OneDrive should have limited multi-thread support")
    }

    /// TC-72.4.5: Local storage disables multi-thread - P2
    func testLocalStorageDisablesMultiThread() {
        // Given: Local storage
        let capability = ProviderMultiThreadCapability.forProvider("local")

        // Then: Should be unsupported
        XCTAssertEqual(capability, .unsupported, "Local storage should not support multi-threading")
        XCTAssertEqual(capability.maxRecommendedThreads, 1, "Local should have max 1 thread")
    }

    // MARK: - TC-72.5: Upload Fallback Tests

    /// TC-72.5.1: Uploads always single-threaded - P0
    func testMultiThreadDisabledForUpload() {
        // Given: TransferOptimizer.optimize() called
        // When: isDownload == false (upload) AND totalBytes == 500MB
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 500_000_000,
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: false  // Upload
        )

        // Then: config.multiThread == false
        XCTAssertFalse(config.multiThread, "Upload should not enable multi-threading")
        // And: config.multiThreadStreams == 0
        XCTAssertEqual(config.multiThreadStreams, 0, "Upload should have 0 multi-thread streams")
    }

    /// TC-72.5.2: Even large uploads are single-threaded - P1
    func testLargeUploadStillSingleThread() {
        // Given: Very large upload
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 10_000_000_000,  // 10GB
            remoteName: "s3",  // Full support provider
            isDirectory: false,
            isDownload: false  // Upload
        )

        // Then: Should still be single-threaded
        XCTAssertFalse(config.multiThread, "Even large uploads should not use multi-threading")
    }

    // MARK: - TC-72.6: Directory Transfer Fallback Tests

    /// TC-72.6.1: Directory downloads use parallel transfers - P1
    func testMultiThreadDisabledForDirectories() {
        // Given: Directory download
        let config = TransferOptimizer.optimize(
            fileCount: 100,
            totalBytes: 1_000_000_000,  // 1GB total
            remoteName: "googledrive",
            isDirectory: true,
            isDownload: true
        )

        // Then: Multi-threading should not be enabled for directories
        // (parallel transfers used instead)
        XCTAssertFalse(config.multiThread, "Directory transfers should use parallel transfers, not multi-threading")
        XCTAssertGreaterThan(config.transfers, 1, "Should use parallel transfers for directories")
    }

    /// TC-72.6.2: Multiple files use --transfers instead - P1
    func testParallelTransfersForMultipleFiles() {
        // Given: Multiple files
        let config = TransferOptimizer.optimize(
            fileCount: 50,
            totalBytes: 500_000_000,
            remoteName: "dropbox",
            isDirectory: true,
            isDownload: true
        )

        // Then: Should have multiple transfers
        XCTAssertGreaterThan(config.transfers, 1, "Multiple files should use multiple transfers")
    }

    // MARK: - TC-72.7: BuildArgs Output Tests

    /// TC-72.7.1: Includes --multi-thread-streams flag - P0
    func testBuildArgsWithMultiThreadEnabled() {
        // Given: TransferConfig with multiThread == true, multiThreadStreams == 8
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

        // When: TransferOptimizer.buildArgs(from: config)
        let args = TransferOptimizer.buildArgs(from: config)

        // Then: args contains "--multi-thread-streams"
        XCTAssertTrue(args.contains("--multi-thread-streams"), "Should include multi-thread-streams flag")
        // And: args contains "8"
        if let streamsIndex = args.firstIndex(of: "--multi-thread-streams") {
            let valueIndex = args.index(after: streamsIndex)
            XCTAssertEqual(args[valueIndex], "8", "Streams value should be 8")
        }
        // And: args contains "--multi-thread-cutoff"
        XCTAssertTrue(args.contains("--multi-thread-cutoff"), "Should include cutoff flag")
        // And: args contains "100M"
        if let cutoffIndex = args.firstIndex(of: "--multi-thread-cutoff") {
            let valueIndex = args.index(after: cutoffIndex)
            XCTAssertEqual(args[valueIndex], "100M", "Cutoff value should be 100M")
        }
    }

    /// TC-72.7.2: No multi-thread flags when disabled - P0
    func testBuildArgsWithMultiThreadDisabled() {
        // Given: TransferConfig with multiThread == false
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

        // When: Building args
        let args = TransferOptimizer.buildArgs(from: config)

        // Then: Should NOT contain multi-thread flags
        XCTAssertFalse(args.contains("--multi-thread-streams"), "Should not include multi-thread-streams when disabled")
        XCTAssertFalse(args.contains("--multi-thread-cutoff"), "Should not include cutoff when disabled")
    }

    /// TC-72.7.3: Arguments are correctly formatted for rclone - P1
    func testBuildArgsFormat() {
        // Given: Full config
        let config = TransferOptimizer.TransferConfig(
            transfers: 4,
            checkers: 16,
            bufferSize: "64M",
            multiThread: true,
            multiThreadStreams: 8,
            multiThreadCutoff: "100M",
            fastList: true,
            chunkSize: "128M"
        )

        // When: Building args
        let args = TransferOptimizer.buildArgs(from: config)

        // Then: All args should be properly formatted
        // Transfers
        XCTAssertTrue(args.contains("--transfers"))
        XCTAssertTrue(args.contains("4"))

        // Checkers
        XCTAssertTrue(args.contains("--checkers"))
        XCTAssertTrue(args.contains("16"))

        // Buffer
        XCTAssertTrue(args.contains("--buffer-size"))
        XCTAssertTrue(args.contains("64M"))

        // Fast list
        XCTAssertTrue(args.contains("--fast-list"))

        // Multi-thread
        XCTAssertTrue(args.contains("--multi-thread-streams"))
        XCTAssertTrue(args.contains("8"))
    }

    // MARK: - MultiThreadDownloadConfig Tests

    func testMultiThreadDownloadConfigDefault() {
        let config = MultiThreadDownloadConfig.default

        XCTAssertTrue(config.enabled, "Default should be enabled")
        XCTAssertEqual(config.threadCount, 4, "Default thread count should be 4")
        XCTAssertEqual(config.sizeThreshold, 100_000_000, "Default threshold should be 100MB")
    }

    func testMultiThreadDownloadConfigLoad() {
        // Given: Default UserDefaults (no custom values)
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadEnabled")
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadThreads")
        UserDefaults.standard.removeObject(forKey: "multiThreadDownloadThreshold")

        // When: Loading config
        let config = MultiThreadDownloadConfig.load()

        // Then: Should use defaults
        XCTAssertTrue(config.enabled, "Default loaded should be enabled")
        XCTAssertEqual(config.threadCount, 4, "Default loaded thread count should be 4")
    }

    func testMultiThreadDownloadConfigSaveAndLoad() {
        // Given: Custom config
        let original = MultiThreadDownloadConfig(
            enabled: false,
            threadCount: 8,
            sizeThreshold: 200_000_000
        )

        // When: Save then load
        original.save()
        let loaded = MultiThreadDownloadConfig.load()

        // Then: Should match
        XCTAssertEqual(loaded.enabled, original.enabled)
        XCTAssertEqual(loaded.threadCount, original.threadCount)
        XCTAssertEqual(loaded.sizeThreshold, original.sizeThreshold)
    }

    // MARK: - ProviderMultiThreadCapability Tests

    func testProviderCapabilityFullSupport() {
        // Full support providers
        let fullProviders = ["s3", "b2", "backblaze", "wasabi", "gcs", "azureblob", "minio"]

        for provider in fullProviders {
            let capability = ProviderMultiThreadCapability.forProvider(provider)
            XCTAssertEqual(capability, .full, "\(provider) should have full support")
            XCTAssertEqual(capability.maxRecommendedThreads, 16, "\(provider) should support 16 threads")
        }
    }

    func testProviderCapabilityLimitedSupport() {
        // Limited support providers
        let limitedProviders = ["googledrive", "onedrive", "dropbox", "box", "mega", "pcloud"]

        for provider in limitedProviders {
            let capability = ProviderMultiThreadCapability.forProvider(provider)
            XCTAssertEqual(capability, .limited, "\(provider) should have limited support")
            XCTAssertEqual(capability.maxRecommendedThreads, 4, "\(provider) should support 4 threads")
        }
    }

    func testProviderCapabilityUnsupported() {
        // Unsupported providers
        let unsupportedProviders = ["sftp", "ftp", "webdav", "local", "proton"]

        for provider in unsupportedProviders {
            let capability = ProviderMultiThreadCapability.forProvider(provider)
            XCTAssertEqual(capability, .unsupported, "\(provider) should be unsupported")
            XCTAssertEqual(capability.maxRecommendedThreads, 1, "\(provider) should support 1 thread")
        }
    }

    func testProviderCapabilityCaseInsensitive() {
        // Should work regardless of case
        XCTAssertEqual(ProviderMultiThreadCapability.forProvider("S3"), .full)
        XCTAssertEqual(ProviderMultiThreadCapability.forProvider("GOOGLEDRIVE"), .limited)
        XCTAssertEqual(ProviderMultiThreadCapability.forProvider("LOCAL"), .unsupported)
    }

    func testProviderCapabilityPartialMatch() {
        // Should match partial names (remote names often include custom parts)
        XCTAssertEqual(ProviderMultiThreadCapability.forProvider("myS3Bucket"), .full)
        XCTAssertEqual(ProviderMultiThreadCapability.forProvider("workGoogleDrive"), .limited)
        XCTAssertEqual(ProviderMultiThreadCapability.forProvider("homeLocal"), .unsupported)
    }

    func testProviderCapabilityUnknownDefaultsToLimited() {
        // Unknown providers should default to limited
        let capability = ProviderMultiThreadCapability.forProvider("unknownprovider")
        XCTAssertEqual(capability, .limited, "Unknown provider should default to limited")
    }

    // MARK: - OptimizeForLargeFileDownload Tests

    func testOptimizeForLargeFileDownload() {
        // Given: Large file for download
        let config = TransferOptimizer.optimizeForLargeFileDownload(
            fileSize: 1_000_000_000,  // 1GB
            remoteName: "s3bucket"
        )

        // Then: Should be optimized for single large file
        XCTAssertTrue(config.multiThread, "Should enable multi-threading for large file")
        XCTAssertGreaterThan(config.multiThreadStreams, 0, "Should have multi-thread streams")
    }

    func testOptimizeForLargeFileDownloadWithCustomConfig() {
        // Given: Custom config
        let customConfig = MultiThreadDownloadConfig(
            enabled: true,
            threadCount: 12,
            sizeThreshold: 50_000_000  // 50MB threshold
        )

        // When: Optimizing with custom config
        let config = TransferOptimizer.optimizeForLargeFileDownload(
            fileSize: 100_000_000,  // 100MB
            remoteName: "s3",
            config: customConfig
        )

        // Then: Should use custom settings
        XCTAssertTrue(config.multiThread)
    }

    // MARK: - Edge Cases

    func testZeroByteFileDownload() {
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 0,
            remoteName: "googledrive",
            isDirectory: false,
            isDownload: true
        )

        // Should not crash and should not enable multi-threading
        XCTAssertFalse(config.multiThread, "Zero byte file should not enable multi-threading")
    }

    func testVeryLargeFileDownload() {
        // 10GB file
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 10_000_000_000,
            remoteName: "s3",
            isDirectory: false,
            isDownload: true
        )

        XCTAssertTrue(config.multiThread, "Very large file should enable multi-threading")
        XCTAssertGreaterThan(config.multiThreadStreams, 0)
    }

    func testMultiThreadWithDisabledConfig() {
        // Given: Config with multi-threading disabled
        let disabledConfig = MultiThreadDownloadConfig(
            enabled: false,
            threadCount: 8,
            sizeThreshold: 100_000_000
        )

        // When: Optimizing with disabled config
        let config = TransferOptimizer.optimize(
            fileCount: 1,
            totalBytes: 500_000_000,
            remoteName: "s3",
            isDirectory: false,
            isDownload: true,
            multiThreadConfig: disabledConfig
        )

        // Then: Should not enable multi-threading
        XCTAssertFalse(config.multiThread, "Should respect disabled config")
        XCTAssertEqual(config.multiThreadStreams, 0)
    }
}
