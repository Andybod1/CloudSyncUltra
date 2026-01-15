//
//  TransferOptimizer.swift
//  CloudSyncApp
//
//  Advanced transfer performance optimization for rclone
//  Issue #10: Transfer Performance Optimization
//

import Foundation
import SwiftUI
import OSLog

// MARK: - Provider Multi-Thread Capability

/// Defines multi-threading capabilities for different cloud providers
/// Some providers support multi-threaded downloads better than others
public enum ProviderMultiThreadCapability {
    case full          // Full multi-thread support (e.g., S3, B2, GCS)
    case limited       // Limited support, reduced thread count recommended
    case unsupported   // Provider doesn't support multi-threaded downloads

    /// Maximum recommended threads for this capability level
    public var maxRecommendedThreads: Int {
        switch self {
        case .full: return 16
        case .limited: return 4
        case .unsupported: return 1
        }
    }

    /// Get capability for a given provider/remote name
    /// - Parameter remoteName: The rclone remote name or provider type
    /// - Returns: The multi-thread capability for this provider
    public static func forProvider(_ remoteName: String) -> ProviderMultiThreadCapability {
        let remote = remoteName.lowercased()

        // Full multi-thread support - object storage and major cloud providers
        let fullSupportProviders = [
            "s3", "b2", "backblaze", "wasabi", "gcs", "google cloud storage",
            "azureblob", "azure", "r2", "cloudflare", "spaces", "digitalocean",
            "minio", "storj", "filebase", "scaleway", "oracle"
        ]
        if fullSupportProviders.contains(where: { remote.contains($0) }) {
            return .full
        }

        // Limited support - consumer cloud storage services
        let limitedSupportProviders = [
            "drive", "googledrive", "onedrive", "dropbox", "box",
            "mega", "pcloud", "putio", "sharepoint"
        ]
        if limitedSupportProviders.contains(where: { remote.contains($0) }) {
            return .limited
        }

        // Unsupported or unknown
        return .unsupported
    }
}

/// Advanced transfer performance optimizer for rclone
/// Provides comprehensive optimization based on provider, file characteristics, and network conditions
public struct TransferOptimizer {
    private static let logger = Logger(subsystem: "com.cloudsync.ultra", category: "TransferOptimizer")

    // MARK: - Provider-Specific Chunk Sizes

    /// Optimal chunk sizes for different providers
    private static let providerChunkSizes: [String: String] = [
        // Google Drive - larger chunks for better performance
        "drive": "64M",
        "googledrive": "64M",

        // OneDrive - must be multiple of 320KB, 10M is optimal
        "onedrive": "10M",
        "business": "10M",
        "sharepoint": "10M",

        // Dropbox - 48M works well
        "dropbox": "48M",

        // S3 and compatible - 64M for better throughput
        "s3": "64M",
        "b2": "64M",
        "wasabi": "64M",
        "r2": "64M",
        "spaces": "64M",
        "gcs": "64M",
        "azureblob": "64M",

        // Others with good chunk support
        "box": "50M",
        "mega": "20M",
        "pcloud": "5M"
    ]

    // MARK: - Performance Profiles

    /// Performance profile based on transfer characteristics
    public enum PerformanceProfile {
        case ultraFast      // Many small files, maximize parallelism
        case balanced       // Mixed file sizes
        case largeFiles     // Few large files, optimize bandwidth
        case singleFile     // Single file transfer
        case lowLatency     // Optimize for quick response
        case highLatency    // Optimize for high-latency connections
    }

    // MARK: - Optimization Result

    public struct OptimizationResult {
        public let transfers: Int
        public let checkers: Int
        public let bufferSize: String
        public let chunkSize: String?
        public let multiThreadStreams: Int
        public let progressInterval: String
        public let additionalFlags: [String]
        public let profile: PerformanceProfile

        /// Convert to rclone command arguments
        public var arguments: [String] {
            var args: [String] = []

            args.append(contentsOf: ["--transfers", "\(transfers)"])
            args.append(contentsOf: ["--checkers", "\(checkers)"])
            args.append(contentsOf: ["--buffer-size", bufferSize])

            if let chunk = chunkSize {
                // Provider-specific chunk size flags
                args.append(contentsOf: getChunkSizeArgs(chunk))
            }

            if multiThreadStreams > 0 {
                args.append(contentsOf: ["--multi-thread-streams", "\(multiThreadStreams)"])
                args.append("--multi-thread-cutoff=100M")
            }

            // Progress interval optimization
            args.append(contentsOf: ["--stats", progressInterval])

            // Additional optimization flags
            args.append(contentsOf: additionalFlags)

            return args
        }

        private func getChunkSizeArgs(_ size: String) -> [String] {
            // Note: Provider-specific chunk flags will be determined by rclone based on remote type
            // We'll use the generic --chunk-size flag
            return ["--streaming-upload-cutoff", size]
        }
    }

    // MARK: - Main Optimization Function

    /// Optimize transfer settings based on comprehensive analysis
    public static func optimize(
        provider: CloudProviderType,
        fileCount: Int,
        totalBytes: Int64,
        isDownload: Bool,
        networkLatencyMs: Int? = nil
    ) -> OptimizationResult {
        let avgFileSize = fileCount > 0 ? totalBytes / Int64(fileCount) : totalBytes

        // Determine performance profile
        let profile = determineProfile(
            fileCount: fileCount,
            avgFileSize: avgFileSize,
            totalBytes: totalBytes,
            networkLatency: networkLatencyMs
        )

        logger.debug("Performance profile: \(String(describing: profile)) for \(fileCount) files, avg size: \(avgFileSize) bytes")

        // Get base configuration for profile
        var config = getBaseConfig(for: profile, provider: provider)

        // Apply provider-specific optimizations
        applyProviderOptimizations(&config, provider: provider)

        // Apply file-size specific optimizations
        applyFileSizeOptimizations(&config, avgFileSize: avgFileSize, totalBytes: totalBytes)

        // Apply network-based optimizations
        if let latency = networkLatencyMs {
            applyNetworkOptimizations(&config, latencyMs: latency)
        }

        // Determine chunk size
        let chunkSize = getOptimalChunkSize(provider: provider, avgFileSize: avgFileSize)

        // Optimize progress callback frequency
        let progressInterval = getOptimalProgressInterval(profile: profile, fileCount: fileCount)

        // Additional optimization flags
        let additionalFlags = getAdditionalOptimizationFlags(
            provider: provider,
            profile: profile,
            isDownload: isDownload
        )

        return OptimizationResult(
            transfers: config.transfers,
            checkers: config.checkers,
            bufferSize: config.bufferSize,
            chunkSize: chunkSize,
            multiThreadStreams: config.multiThreadStreams,
            progressInterval: progressInterval,
            additionalFlags: additionalFlags,
            profile: profile
        )
    }

    // MARK: - Profile Determination

    private static func determineProfile(
        fileCount: Int,
        avgFileSize: Int64,
        totalBytes: Int64,
        networkLatency: Int?
    ) -> PerformanceProfile {
        // Single file
        if fileCount == 1 {
            return .singleFile
        }

        // High latency network (> 100ms)
        if let latency = networkLatency, latency > 100 {
            return .highLatency
        }

        // Many small files (< 1MB average)
        if avgFileSize < 1_000_000 && fileCount > 50 {
            return .ultraFast
        }

        // Large files (> 100MB average)
        if avgFileSize > 100_000_000 {
            return .largeFiles
        }

        // Low latency optimization for small transfers
        if totalBytes < 10_000_000 && fileCount < 10 {
            return .lowLatency
        }

        // Default balanced profile
        return .balanced
    }

    // MARK: - Base Configuration

    private struct BaseConfig {
        var transfers: Int
        var checkers: Int
        var bufferSize: String
        var multiThreadStreams: Int
    }

    private static func getBaseConfig(for profile: PerformanceProfile, provider: CloudProviderType) -> BaseConfig {
        switch profile {
        case .ultraFast:
            // Many small files - maximize parallelism
            return BaseConfig(
                transfers: 32,
                checkers: 64,
                bufferSize: "16M",
                multiThreadStreams: 0
            )

        case .balanced:
            // Mixed workload - balanced settings
            return BaseConfig(
                transfers: 16,
                checkers: 32,
                bufferSize: "32M",
                multiThreadStreams: 0
            )

        case .largeFiles:
            // Few large files - optimize bandwidth utilization
            return BaseConfig(
                transfers: 8,
                checkers: 16,
                bufferSize: "128M",
                multiThreadStreams: 0
            )

        case .singleFile:
            // Single file - use multi-threading if supported
            let capability = ProviderMultiThreadCapability.forProvider(provider.rcloneType)
            return BaseConfig(
                transfers: 1,
                checkers: 8,
                bufferSize: "128M",
                multiThreadStreams: capability == .unsupported ? 0 : 16
            )

        case .lowLatency:
            // Quick operations - minimize overhead
            return BaseConfig(
                transfers: 4,
                checkers: 8,
                bufferSize: "16M",
                multiThreadStreams: 0
            )

        case .highLatency:
            // High latency - larger buffers, more parallelism
            return BaseConfig(
                transfers: 24,
                checkers: 48,
                bufferSize: "64M",
                multiThreadStreams: 0
            )
        }
    }

    // MARK: - Provider Optimizations

    private static func applyProviderOptimizations(_ config: inout BaseConfig, provider: CloudProviderType) {
        switch provider {
        case .googleDrive:
            // Google Drive has rate limits, don't go too aggressive
            config.transfers = min(config.transfers, 12)
            config.checkers = min(config.checkers, 24)

        case .dropbox:
            // Dropbox performs better with fewer connections
            config.transfers = min(config.transfers, 8)
            config.checkers = min(config.checkers, 16)

        case .oneDrive, .oneDriveBusiness, .sharePoint:
            // OneDrive has strict rate limits
            config.transfers = min(config.transfers, 10)
            config.checkers = min(config.checkers, 20)

        case .s3, .backblazeB2, .wasabi, .cloudflareR2:
            // Object storage can handle high parallelism
            // No reduction needed
            break

        default:
            // Conservative defaults for unknown providers
            config.transfers = min(config.transfers, 16)
            config.checkers = min(config.checkers, 32)
        }
    }

    // MARK: - File Size Optimizations

    private static func applyFileSizeOptimizations(_ config: inout BaseConfig, avgFileSize: Int64, totalBytes: Int64) {
        // Very large total transfer (> 10GB) - ensure adequate buffers
        if totalBytes > 10_000_000_000 {
            if config.bufferSize == "16M" {
                config.bufferSize = "64M"
            } else if config.bufferSize == "32M" {
                config.bufferSize = "128M"
            }
        }

        // Many tiny files (< 100KB average) - reduce buffer overhead
        if avgFileSize < 100_000 {
            config.bufferSize = "8M"
        }
    }

    // MARK: - Network Optimizations

    private static func applyNetworkOptimizations(_ config: inout BaseConfig, latencyMs: Int) {
        // Very high latency (> 200ms) - increase parallelism and buffers
        if latencyMs > 200 {
            config.transfers = Int(Double(config.transfers) * 1.5)
            config.checkers = Int(Double(config.checkers) * 1.5)

            // Increase buffer size for high-latency connections
            switch config.bufferSize {
            case "16M": config.bufferSize = "32M"
            case "32M": config.bufferSize = "64M"
            case "64M": config.bufferSize = "128M"
            default: break
            }
        }
    }

    // MARK: - Chunk Size Selection

    private static func getOptimalChunkSize(provider: CloudProviderType, avgFileSize: Int64) -> String? {
        // Look up provider-specific chunk size
        let chunkSize = providerChunkSizes[provider.rcloneType.lowercased()]

        // For very small average file sizes, use smaller chunks if available
        if avgFileSize < 5_000_000, let chunk = chunkSize {
            // Reduce chunk size for small files
            if chunk == "64M" { return "16M" }
            if chunk == "48M" { return "12M" }
            if chunk == "32M" { return "8M" }
        }

        return chunkSize
    }

    // MARK: - Progress Interval Optimization

    private static func getOptimalProgressInterval(profile: PerformanceProfile, fileCount: Int) -> String {
        switch profile {
        case .ultraFast:
            // Many small files - less frequent updates to reduce overhead
            return fileCount > 1000 ? "2s" : "1s"

        case .singleFile, .largeFiles:
            // Large files - more frequent updates for better UX
            return "500ms"

        case .lowLatency:
            // Quick operations - minimal overhead
            return "2s"

        default:
            // Balanced update frequency
            return "1s"
        }
    }

    // MARK: - Additional Optimization Flags

    private static func getAdditionalOptimizationFlags(
        provider: CloudProviderType,
        profile: PerformanceProfile,
        isDownload: Bool
    ) -> [String] {
        var flags: [String] = []

        // Fast list for providers that support it
        if provider.supportsFastList {
            flags.append("--fast-list")
        }

        // No check for downloads (trust source)
        if isDownload {
            flags.append("--no-check-dest")
        }

        // For many small files, use less strict checking
        if profile == .ultraFast {
            flags.append("--size-only")
            flags.append("--no-update-modtime")
        }

        // For single large files, ensure resume capability
        if profile == .singleFile {
            flags.append("--partial")
        }

        // Optimization for high-latency connections
        if profile == .highLatency {
            flags.append("--retries=5")
            flags.append("--low-level-retries=20")
        }

        return flags
    }

    // MARK: - Performance Measurement

    public struct TransferMetrics {
        public let startTime: Date
        public let endTime: Date?
        public let bytesTransferred: Int64
        public let filesTransferred: Int
        public let errors: Int

        public var duration: TimeInterval? {
            guard let end = endTime else { return nil }
            return end.timeIntervalSince(startTime)
        }

        public var throughputMBps: Double? {
            guard let duration = duration, duration > 0 else { return nil }
            return Double(bytesTransferred) / duration / 1_000_000
        }
    }

    /// Create optimization result for testing/benchmarking
    public static func createBenchmarkConfig(profile: PerformanceProfile) -> OptimizationResult {
        let config = getBaseConfig(for: profile, provider: CloudProviderType.s3)
        return OptimizationResult(
            transfers: config.transfers,
            checkers: config.checkers,
            bufferSize: config.bufferSize,
            chunkSize: "64M",
            multiThreadStreams: config.multiThreadStreams,
            progressInterval: "1s",
            additionalFlags: [],
            profile: profile
        )
    }
}