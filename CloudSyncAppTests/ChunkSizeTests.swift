//
//  ChunkSizeTests.swift
//  CloudSyncAppTests
//
//  Tests for provider-specific chunk size configuration (#73)
//  Validates optimal chunk sizes for different cloud providers
//

import XCTest
@testable import CloudSyncApp

final class ChunkSizeTests: XCTestCase {

    // MARK: - ChunkSizeConfig Direct Tests

    func testChunkSizeForGoogleDrive() {
        // Google Drive uses 8MB chunks for optimal resumable upload performance
        let chunkSize = ChunkSizeConfig.chunkSize(for: .googleDrive)
        XCTAssertEqual(chunkSize, 8 * 1024 * 1024, "Google Drive should use 8MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .googleDrive)
        XCTAssertEqual(chunkString, "8M", "Google Drive chunk string should be 8M")
    }

    func testChunkSizeForS3() {
        // S3 uses 16MB chunks for object storage optimization
        let chunkSize = ChunkSizeConfig.chunkSize(for: .s3)
        XCTAssertEqual(chunkSize, 16 * 1024 * 1024, "S3 should use 16MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .s3)
        XCTAssertEqual(chunkString, "16M", "S3 chunk string should be 16M")
    }

    func testChunkSizeForOneDrive() {
        // OneDrive uses 10MB chunks (Microsoft recommended, multiple of 320KB)
        let chunkSize = ChunkSizeConfig.chunkSize(for: .oneDrive)
        XCTAssertEqual(chunkSize, 10 * 1024 * 1024, "OneDrive should use 10MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .oneDrive)
        XCTAssertEqual(chunkString, "10M", "OneDrive chunk string should be 10M")
    }

    func testChunkSizeForOneDriveBusiness() {
        // OneDrive Business uses same as OneDrive
        let chunkSize = ChunkSizeConfig.chunkSize(for: .oneDriveBusiness)
        XCTAssertEqual(chunkSize, 10 * 1024 * 1024, "OneDrive Business should use 10MB chunks")
    }

    func testChunkSizeForDropbox() {
        // Dropbox uses 8MB chunks for balanced API limits
        let chunkSize = ChunkSizeConfig.chunkSize(for: .dropbox)
        XCTAssertEqual(chunkSize, 8 * 1024 * 1024, "Dropbox should use 8MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .dropbox)
        XCTAssertEqual(chunkString, "8M", "Dropbox chunk string should be 8M")
    }

    func testChunkSizeForBackblazeB2() {
        // B2 uses 16MB chunks for object storage
        let chunkSize = ChunkSizeConfig.chunkSize(for: .backblazeB2)
        XCTAssertEqual(chunkSize, 16 * 1024 * 1024, "Backblaze B2 should use 16MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .backblazeB2)
        XCTAssertEqual(chunkString, "16M", "B2 chunk string should be 16M")
    }

    func testChunkSizeForBox() {
        // Box uses 8MB chunks
        let chunkSize = ChunkSizeConfig.chunkSize(for: .box)
        XCTAssertEqual(chunkSize, 8 * 1024 * 1024, "Box should use 8MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .box)
        XCTAssertEqual(chunkString, "8M", "Box chunk string should be 8M")
    }

    func testChunkSizeForMega() {
        // MEGA uses 20MB chunks
        let chunkSize = ChunkSizeConfig.chunkSize(for: .mega)
        XCTAssertEqual(chunkSize, 20 * 1024 * 1024, "MEGA should use 20MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .mega)
        XCTAssertEqual(chunkString, "20M", "MEGA chunk string should be 20M")
    }

    func testChunkSizeForPCloud() {
        // pCloud uses 5MB chunks
        let chunkSize = ChunkSizeConfig.chunkSize(for: .pcloud)
        XCTAssertEqual(chunkSize, 5 * 1024 * 1024, "pCloud should use 5MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .pcloud)
        XCTAssertEqual(chunkString, "5M", "pCloud chunk string should be 5M")
    }

    func testChunkSizeForGoogleCloudStorage() {
        // GCS uses 16MB chunks
        let chunkSize = ChunkSizeConfig.chunkSize(for: .googleCloudStorage)
        XCTAssertEqual(chunkSize, 16 * 1024 * 1024, "GCS should use 16MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .googleCloudStorage)
        XCTAssertEqual(chunkString, "16M", "GCS chunk string should be 16M")
    }

    func testChunkSizeForAzureBlob() {
        // Azure Blob uses 16MB chunks
        let chunkSize = ChunkSizeConfig.chunkSize(for: .azureBlob)
        XCTAssertEqual(chunkSize, 16 * 1024 * 1024, "Azure Blob should use 16MB chunks")

        let chunkString = ChunkSizeConfig.chunkSizeString(for: .azureBlob)
        XCTAssertEqual(chunkString, "16M", "Azure Blob chunk string should be 16M")
    }

    func testChunkSizeForProtonDrive() {
        // Proton Drive uses 4MB due to encryption overhead
        let chunkSize = ChunkSizeConfig.chunkSize(for: .protonDrive)
        XCTAssertEqual(chunkSize, 4 * 1024 * 1024, "Proton Drive should use 4MB chunks (encryption overhead)")
    }

    func testChunkSizeForLocal() {
        // Local filesystem uses 64MB for fast I/O
        let chunkSize = ChunkSizeConfig.chunkSize(for: .local)
        XCTAssertEqual(chunkSize, 64 * 1024 * 1024, "Local should use 64MB chunks")
    }

    func testChunkSizeForSFTP() {
        // SFTP uses 32MB for network filesystem efficiency
        let chunkSize = ChunkSizeConfig.chunkSize(for: .sftp)
        XCTAssertEqual(chunkSize, 32 * 1024 * 1024, "SFTP should use 32MB chunks")
    }

    func testChunkSizeForWebDAV() {
        // WebDAV uses 32MB for network filesystem efficiency
        let chunkSize = ChunkSizeConfig.chunkSize(for: .webdav)
        XCTAssertEqual(chunkSize, 32 * 1024 * 1024, "WebDAV should use 32MB chunks")
    }

    // MARK: - Chunk Size Flag Tests

    func testChunkSizeFlagForGoogleDrive() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .googleDrive)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--drive-chunk-size=8M")
    }

    func testChunkSizeFlagForS3() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .s3)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--s3-chunk-size=16M")
    }

    func testChunkSizeFlagForOneDrive() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .oneDrive)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--onedrive-chunk-size=10M")
    }

    func testChunkSizeFlagForDropbox() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .dropbox)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--dropbox-chunk-size=8M")
    }

    func testChunkSizeFlagForBackblazeB2() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .backblazeB2)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--b2-chunk-size=16M")
    }

    func testChunkSizeFlagForBox() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .box)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--box-chunk-size=8M")
    }

    func testChunkSizeFlagForGCS() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .googleCloudStorage)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--gcs-chunk-size=16M")
    }

    func testChunkSizeFlagForAzureBlob() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .azureBlob)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--azureblob-chunk-size=16M")
    }

    func testChunkSizeFlagForMega() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .mega)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--mega-chunk-size=20M")
    }

    func testChunkSizeFlagForPCloud() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .pcloud)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--pcloud-chunk-size=5M")
    }

    func testChunkSizeFlagForJottacloud() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .jottacloud)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--jottacloud-chunk-size=8M")
    }

    func testChunkSizeFlagForPutio() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .putio)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--putio-chunk-size=8M")
    }

    func testChunkSizeFlagForWasabi() {
        // Wasabi uses S3 compatible flag
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .wasabi)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--s3-chunk-size=16M")
    }

    func testChunkSizeFlagNilForUnsupportedProvider() {
        // Local filesystem doesn't have a chunk size flag
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .local)
        XCTAssertNil(flag, "Local should not have a chunk size flag")
    }

    func testChunkSizeFlagNilForSFTP() {
        // SFTP doesn't have a chunk size flag
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .sftp)
        XCTAssertNil(flag, "SFTP should not have a chunk size flag")
    }

    // MARK: - Default Chunk Size Test

    func testDefaultChunkSize() {
        XCTAssertEqual(ChunkSizeConfig.defaultChunkSize, 8 * 1024 * 1024, "Default chunk size should be 8MB")
    }

    // MARK: - All Object Storage Providers Test

    func testAllObjectStorageProvidersHaveSameChunkSize() {
        // All object storage providers should use 16MB chunks
        let objectStorageProviders: [CloudProviderType] = [
            .s3, .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase, .googleCloudStorage,
            .azureBlob, .alibabaOSS
        ]

        for provider in objectStorageProviders {
            let chunkSize = ChunkSizeConfig.chunkSize(for: provider)
            XCTAssertEqual(chunkSize, 16 * 1024 * 1024, "\(provider) should use 16MB chunks")
        }
    }

    // MARK: - All Network Filesystems Test

    func testAllNetworkFilesystemsHaveSameChunkSize() {
        // All network filesystems should use 32MB chunks
        let networkFilesystemProviders: [CloudProviderType] = [
            .sftp, .ftp, .webdav, .nextcloud, .owncloud
        ]

        for provider in networkFilesystemProviders {
            let chunkSize = ChunkSizeConfig.chunkSize(for: provider)
            XCTAssertEqual(chunkSize, 32 * 1024 * 1024, "\(provider) should use 32MB chunks")
        }
    }

    // MARK: - Chunk Size String Format Test

    func testChunkSizeStringFormat() {
        // All chunk size strings should end with "M" for megabytes
        let testProviders: [CloudProviderType] = [
            .googleDrive, .oneDrive, .dropbox, .s3, .backblazeB2
        ]

        for provider in testProviders {
            let chunkString = ChunkSizeConfig.chunkSizeString(for: provider)
            XCTAssertTrue(chunkString.hasSuffix("M"), "\(provider) chunk string should end with M")

            // Should be parseable as an integer
            let numericPart = chunkString.replacingOccurrences(of: "M", with: "")
            XCTAssertNotNil(Int(numericPart), "\(provider) chunk string numeric part should be valid integer")
        }
    }

    // MARK: - SharePoint Test

    func testChunkSizeForSharepoint() {
        // SharePoint uses same as OneDrive (10MB)
        let chunkSize = ChunkSizeConfig.chunkSize(for: .sharepoint)
        XCTAssertEqual(chunkSize, 10 * 1024 * 1024, "SharePoint should use 10MB chunks")

        let flag = ChunkSizeConfig.chunkSizeFlag(for: .sharepoint)
        XCTAssertNotNil(flag)
        XCTAssertEqual(flag, "--onedrive-chunk-size=10M")
    }
}
