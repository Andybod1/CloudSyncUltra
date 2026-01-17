//
//  TransferOptimizer.swift
//  CloudSyncApp
//
//  Advanced transfer performance optimization for rclone
//  Issue #10: Transfer Performance Optimization
//

import Foundation

// MARK: - Provider-Specific Chunk Size Configuration (#73)

/// Optimal chunk sizes per provider for transfer performance
/// Different cloud providers have different optimal chunk sizes based on their API characteristics
struct ChunkSizeConfig {
    /// Default chunk size when provider-specific size isn't available (8MB)
    static let defaultChunkSize: Int = 8 * 1024 * 1024

    /// Get optimal chunk size in bytes for a given provider
    /// - Parameter provider: The cloud provider type
    /// - Returns: Optimal chunk size in bytes
    static func chunkSize(for provider: CloudProviderType) -> Int {
        switch provider {
        // Local filesystem - maximize throughput with large chunks
        case .local:
            return 64 * 1024 * 1024  // 64MB - fast local I/O

        // Object storage - optimized for high throughput
        case .s3, .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
             .scaleway, .oracleCloud, .storj, .filebase, .googleCloudStorage,
             .azureBlob, .alibabaOSS:
            return 16 * 1024 * 1024  // 16MB - object storage optimized

        // Google Drive/Photos - optimized for resumable uploads API
        case .googleDrive, .googlePhotos:
            return 8 * 1024 * 1024   // 8MB - resumable uploads

        // OneDrive - Microsoft recommended (multiple of 320KB)
        case .oneDrive, .oneDriveBusiness, .sharepoint:
            return 10 * 1024 * 1024  // 10MB - Microsoft optimal

        // Dropbox - optimal per rclone docs
        case .dropbox:
            return 150 * 1024 * 1024  // 150MB - optimal for Dropbox
        // Box - balanced for API limits
        case .box:
            return 8 * 1024 * 1024   // 8MB - balanced

        // Proton Drive - smaller chunks due to encryption overhead
        case .protonDrive:
            return 4 * 1024 * 1024   // 4MB - encryption overhead

        // Network filesystems - larger chunks for efficiency
        case .sftp, .ftp, .webdav, .nextcloud, .owncloud:
            return 32 * 1024 * 1024  // 32MB - network filesystem

        // Other providers
        case .mega:
            return 20 * 1024 * 1024  // 20MB
        case .pcloud:
            return 5 * 1024 * 1024   // 5MB
        case .seafile, .koofr, .yandexDisk, .mailRuCloud, .jottacloud:
            return 8 * 1024 * 1024   // 8MB default

        // Azure Files
        case .azureFiles:
            return 16 * 1024 * 1024  // 16MB

        // Media & consumer services
        case .flickr, .sugarsync, .opendrive:
            return 8 * 1024 * 1024   // 8MB

        // Specialized services
        case .putio, .premiumizeme, .quatrix, .filefabric:
            return 8 * 1024 * 1024   // 8MB

        // iCloud (local access)
        case .icloud:
            return 64 * 1024 * 1024  // 64MB - local I/O
        }
    }

    /// Get the provider-specific rclone chunk size flag
    /// - Parameter provider: The cloud provider type
    /// - Returns: The rclone flag string, or nil if provider uses default
    static func chunkSizeFlag(for provider: CloudProviderType) -> String? {
        let sizeInMB = chunkSize(for: provider) / (1024 * 1024)

        switch provider {
        case .googleDrive:
            return "--drive-chunk-size=\(sizeInMB)M"
        case .s3, .wasabi, .digitalOceanSpaces, .cloudflareR2, .scaleway,
             .oracleCloud, .filebase:
            return "--s3-chunk-size=\(sizeInMB)M"
        case .oneDrive, .oneDriveBusiness, .sharepoint:
            return "--onedrive-chunk-size=\(sizeInMB)M"
        case .dropbox:
            return "--dropbox-chunk-size=\(sizeInMB)M"
        case .backblazeB2:
            return "--b2-chunk-size=\(sizeInMB)M"
        case .box:
            return "--box-chunk-size=\(sizeInMB)M"
        case .googleCloudStorage:
            return "--gcs-chunk-size=\(sizeInMB)M"
        case .azureBlob:
            return "--azureblob-chunk-size=\(sizeInMB)M"
        case .pcloud:
            return "--pcloud-chunk-size=\(sizeInMB)M"
        case .mega:
            return "--mega-chunk-size=\(sizeInMB)M"
        case .jottacloud:
            return "--jottacloud-chunk-size=\(sizeInMB)M"
        case .putio:
            return "--putio-chunk-size=\(sizeInMB)M"
        default:
            // Providers without specific chunk size flags use rclone defaults
            return nil
        }
    }

    /// Get chunk size as a formatted string (e.g., "16M")
    /// - Parameter provider: The cloud provider type
    /// - Returns: Formatted chunk size string
    static func chunkSizeString(for provider: CloudProviderType) -> String {
        let sizeInMB = chunkSize(for: provider) / (1024 * 1024)
        return "\(sizeInMB)M"
    }
}
