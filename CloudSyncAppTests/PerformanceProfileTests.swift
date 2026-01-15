//
//  PerformanceProfileTests.swift
//  CloudSyncAppTests
//
//  Created by Dev-1 on 2026-01-15.
//

import XCTest
@testable import CloudSyncApp

final class PerformanceProfileTests: XCTestCase {

    // MARK: - PerformanceProfile Tests

    func testAllCases() {
        let expectedCases: [PerformanceProfile] = [.conservative, .balanced, .performance, .custom]
        XCTAssertEqual(PerformanceProfile.allCases.count, 4)
        XCTAssertEqual(PerformanceProfile.allCases, expectedCases)
    }

    func testProfileDisplayNames() {
        XCTAssertEqual(PerformanceProfile.conservative.displayName, "Conservative")
        XCTAssertEqual(PerformanceProfile.balanced.displayName, "Balanced")
        XCTAssertEqual(PerformanceProfile.performance.displayName, "Performance")
        XCTAssertEqual(PerformanceProfile.custom.displayName, "Custom")
    }

    func testDefaultSettings() {
        // Conservative
        let conservative = PerformanceProfile.conservative.defaultSettings
        XCTAssertEqual(conservative.parallelTransfers, 2)
        XCTAssertEqual(conservative.bandwidthLimit, 1)
        XCTAssertEqual(conservative.chunkSizeMB, 8)
        XCTAssertEqual(conservative.cpuPriority, .low)
        XCTAssertEqual(conservative.checkFrequency, .everyFile)

        // Balanced
        let balanced = PerformanceProfile.balanced.defaultSettings
        XCTAssertEqual(balanced.parallelTransfers, 4)
        XCTAssertEqual(balanced.bandwidthLimit, 5)
        XCTAssertEqual(balanced.chunkSizeMB, 32)
        XCTAssertEqual(balanced.cpuPriority, .normal)
        XCTAssertEqual(balanced.checkFrequency, .sampling)

        // Performance
        let performance = PerformanceProfile.performance.defaultSettings
        XCTAssertEqual(performance.parallelTransfers, 16)
        XCTAssertEqual(performance.bandwidthLimit, 0) // unlimited
        XCTAssertEqual(performance.chunkSizeMB, 64)
        XCTAssertEqual(performance.cpuPriority, .high)
        XCTAssertEqual(performance.checkFrequency, .trustRemote)

        // Custom should return balanced defaults as starting point
        let custom = PerformanceProfile.custom.defaultSettings
        XCTAssertEqual(custom, balanced)
    }

    // MARK: - CPUPriority Tests

    func testCPUPriorityDisplayNames() {
        XCTAssertEqual(CPUPriority.low.displayName, "Low")
        XCTAssertEqual(CPUPriority.normal.displayName, "Normal")
        XCTAssertEqual(CPUPriority.high.displayName, "High")
    }

    func testCPUPriorityCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let priority = CPUPriority.high
        let data = try encoder.encode(priority)
        let decoded = try decoder.decode(CPUPriority.self, from: data)

        XCTAssertEqual(priority, decoded)
    }

    // MARK: - CheckFrequency Tests

    func testCheckFrequencyDisplayNames() {
        XCTAssertEqual(CheckFrequency.everyFile.displayName, "Every File")
        XCTAssertEqual(CheckFrequency.sampling.displayName, "Sampling")
        XCTAssertEqual(CheckFrequency.trustRemote.displayName, "Trust Remote")
    }

    func testCheckFrequencyDescriptions() {
        XCTAssertEqual(CheckFrequency.everyFile.description, "Check every file before transferring")
        XCTAssertEqual(CheckFrequency.sampling.description, "Check a sample of files for validation")
        XCTAssertEqual(CheckFrequency.trustRemote.description, "Trust remote file information")
    }

    func testCheckFrequencyCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let frequency = CheckFrequency.sampling
        let data = try encoder.encode(frequency)
        let decoded = try decoder.decode(CheckFrequency.self, from: data)

        XCTAssertEqual(frequency, decoded)
    }

    // MARK: - PerformanceSettings Tests

    func testPerformanceSettingsValidation() {
        var settings = PerformanceSettings(
            parallelTransfers: -5,
            bandwidthLimit: -10,
            chunkSizeMB: 200,
            cpuPriority: .normal,
            checkFrequency: .sampling
        )

        settings.validate()

        // Parallel transfers should be clamped to valid range
        XCTAssertEqual(settings.parallelTransfers, 1)

        // Bandwidth limit should be clamped to 0
        XCTAssertEqual(settings.bandwidthLimit, 0)

        // Chunk size should be set to nearest valid value (128)
        XCTAssertEqual(settings.chunkSizeMB, 128)
    }

    func testChunkSizeValidation() {
        var settings1 = PerformanceSettings(
            parallelTransfers: 4,
            bandwidthLimit: 5,
            chunkSizeMB: 10, // Invalid, should become 8
            cpuPriority: .normal,
            checkFrequency: .sampling
        )

        settings1.validate()
        XCTAssertEqual(settings1.chunkSizeMB, 8)

        var settings2 = PerformanceSettings(
            parallelTransfers: 4,
            bandwidthLimit: 5,
            chunkSizeMB: 50, // Invalid, should become 64 (closer than 32)
            cpuPriority: .normal,
            checkFrequency: .sampling
        )

        settings2.validate()
        XCTAssertEqual(settings2.chunkSizeMB, 64)
    }

    func testMatchesProfile() {
        let conservativeSettings = PerformanceProfile.conservative.defaultSettings
        XCTAssertTrue(conservativeSettings.matchesProfile(.conservative))
        XCTAssertFalse(conservativeSettings.matchesProfile(.balanced))
        XCTAssertFalse(conservativeSettings.matchesProfile(.performance))

        // Custom profile always matches
        XCTAssertTrue(conservativeSettings.matchesProfile(.custom))
    }

    func testMatchingProfile() {
        let conservativeSettings = PerformanceProfile.conservative.defaultSettings
        XCTAssertEqual(conservativeSettings.matchingProfile(), .conservative)

        let balancedSettings = PerformanceProfile.balanced.defaultSettings
        XCTAssertEqual(balancedSettings.matchingProfile(), .balanced)

        let performanceSettings = PerformanceProfile.performance.defaultSettings
        XCTAssertEqual(performanceSettings.matchingProfile(), .performance)

        // Modified settings should return .custom
        var customSettings = balancedSettings
        customSettings.parallelTransfers = 8
        XCTAssertEqual(customSettings.matchingProfile(), .custom)
    }

    func testPerformanceSettingsCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let settings = PerformanceSettings(
            parallelTransfers: 8,
            bandwidthLimit: 10,
            chunkSizeMB: 64,
            cpuPriority: .high,
            checkFrequency: .trustRemote
        )

        let data = try encoder.encode(settings)
        let decoded = try decoder.decode(PerformanceSettings.self, from: data)

        XCTAssertEqual(settings, decoded)
    }

    func testAvailableChunkSizes() {
        let expectedSizes = [8, 16, 32, 64, 128]
        XCTAssertEqual(PerformanceSettings.availableChunkSizes, expectedSizes)
    }
}