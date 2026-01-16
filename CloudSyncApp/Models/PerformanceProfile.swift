//
//  PerformanceProfile.swift
//  CloudSyncApp
//
//  Created by Dev-1 on 2026-01-15.
//

import Foundation

// MARK: - Performance Profile

enum PerformanceProfile: String, CaseIterable {
    case conservative = "conservative"
    case balanced = "balanced"
    case performance = "performance"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .conservative:
            return "Conservative"
        case .balanced:
            return "Balanced"
        case .performance:
            return "Performance"
        case .custom:
            return "Custom"
        }
    }

    /// Returns the default settings for each profile
    var defaultSettings: PerformanceSettings {
        switch self {
        case .conservative:
            return PerformanceSettings(
                parallelTransfers: 2,
                bandwidthLimit: 1,
                chunkSizeMB: 8,
                cpuPriority: .low,
                checkFrequency: .everyFile
            )
        case .balanced:
            return PerformanceSettings(
                parallelTransfers: 4,
                bandwidthLimit: 5,
                chunkSizeMB: 32,
                cpuPriority: .normal,
                checkFrequency: .sampling
            )
        case .performance:
            return PerformanceSettings(
                parallelTransfers: 16,
                bandwidthLimit: 0, // unlimited
                chunkSizeMB: 64,
                cpuPriority: .high,
                checkFrequency: .trustRemote
            )
        case .custom:
            // For custom, return balanced defaults as a starting point
            return Self.balanced.defaultSettings
        }
    }
}

// MARK: - CPU Priority

enum CPUPriority: String, CaseIterable, Codable {
    case low = "low"
    case normal = "normal"
    case high = "high"

    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .normal:
            return "Normal"
        case .high:
            return "High"
        }
    }
}

// MARK: - Check Frequency

enum CheckFrequency: String, CaseIterable, Codable {
    case everyFile = "everyFile"
    case sampling = "sampling"
    case trustRemote = "trustRemote"

    var displayName: String {
        switch self {
        case .everyFile:
            return "Every File"
        case .sampling:
            return "Sampling"
        case .trustRemote:
            return "Trust Remote"
        }
    }

    var description: String {
        switch self {
        case .everyFile:
            return "Check every file before transferring"
        case .sampling:
            return "Check a sample of files for validation"
        case .trustRemote:
            return "Trust remote file information"
        }
    }
}

// MARK: - Performance Settings

struct PerformanceSettings: Codable, Equatable {
    var parallelTransfers: Int      // 1-16
    var bandwidthLimit: Int         // MB/s, 0 = unlimited
    var chunkSizeMB: Int            // 8, 16, 32, 64, 128
    var cpuPriority: CPUPriority
    var checkFrequency: CheckFrequency

    /// Available chunk sizes in MB
    static let availableChunkSizes = [8, 16, 32, 64, 128]

    /// Validates and clamps the settings to valid ranges
    mutating func validate() {
        parallelTransfers = max(1, min(16, parallelTransfers))
        bandwidthLimit = max(0, bandwidthLimit)

        // Ensure chunk size is one of the valid options
        if !Self.availableChunkSizes.contains(chunkSizeMB) {
            // Find the closest valid chunk size
            let closest = Self.availableChunkSizes.min(by: { abs($0 - chunkSizeMB) < abs($1 - chunkSizeMB) })
            chunkSizeMB = closest ?? 32
        }
    }

    /// Returns true if these settings match the default settings for the given profile
    func matchesProfile(_ profile: PerformanceProfile) -> Bool {
        guard profile != .custom else { return true }
        return self == profile.defaultSettings
    }

    /// Determines which profile these settings match, or .custom if none
    func matchingProfile() -> PerformanceProfile {
        for profile in PerformanceProfile.allCases where profile != .custom {
            if matchesProfile(profile) {
                return profile
            }
        }
        return .custom
    }
}
