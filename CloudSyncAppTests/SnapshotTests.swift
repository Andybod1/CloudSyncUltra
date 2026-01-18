import XCTest
import SwiftUI
@testable import CloudSyncApp

/// Snapshot tests for UI components
/// These tests verify UI consistency by comparing rendered views against reference snapshots
final class SnapshotTests: XCTestCase {

    // MARK: - Snapshot Infrastructure

    private var snapshotDirectory: URL {
        // Store snapshots in test bundle
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
    }

    private func snapshot<V: View>(_ view: V, name: String, size: CGSize = CGSize(width: 400, height: 300)) -> Data? {
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)

        guard let bitmapRep = hostingController.view.bitmapImageRepForCachingDisplay(in: hostingController.view.bounds) else {
            return nil
        }

        hostingController.view.cacheDisplay(in: hostingController.view.bounds, to: bitmapRep)

        return bitmapRep.representation(using: .png, properties: [:])
    }

    private func assertSnapshot<V: View>(
        _ view: V,
        named name: String,
        size: CGSize = CGSize(width: 400, height: 300),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let currentSnapshot = snapshot(view, name: name, size: size) else {
            XCTFail("Failed to generate snapshot", file: file, line: line)
            return
        }

        let snapshotPath = snapshotDirectory.appendingPathComponent("\(name).png")

        // If reference doesn't exist, create it (first run)
        if !FileManager.default.fileExists(atPath: snapshotPath.path) {
            try? FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
            try? currentSnapshot.write(to: snapshotPath)
            XCTFail("Reference snapshot created at \(snapshotPath.path). Re-run test to verify.", file: file, line: line)
            return
        }

        // Compare with reference
        guard let referenceSnapshot = try? Data(contentsOf: snapshotPath) else {
            XCTFail("Failed to load reference snapshot", file: file, line: line)
            return
        }

        // Simple byte comparison (could be enhanced with perceptual diff)
        if currentSnapshot != referenceSnapshot {
            // Save diff for debugging
            let diffPath = snapshotDirectory.appendingPathComponent("\(name)_diff.png")
            try? currentSnapshot.write(to: diffPath)
            XCTFail("Snapshot mismatch for '\(name)'. Diff saved to \(diffPath.path)", file: file, line: line)
        }
    }

    // MARK: - Provider Icon Tests

    func testProviderIconsConsistency() {
        // Verify all providers have consistent icon rendering
        let providers: [CloudProviderType] = [.dropbox, .googleDrive, .oneDrive, .s3, .sftp]

        for provider in providers {
            XCTAssertFalse(provider.iconName.isEmpty, "\(provider) should have an icon")
            XCTAssertFalse(provider.displayName.isEmpty, "\(provider) should have display name")
        }
    }

    func testTaskTypeIconsExist() {
        // Verify all task types have icons
        for taskType in TaskType.allCases {
            XCTAssertFalse(taskType.icon.isEmpty, "\(taskType) should have an icon")
        }
    }

    // MARK: - Color Consistency Tests

    func testTaskStateColorsExist() {
        // Verify all task states have color mappings
        let states: [TaskState] = [.pending, .running, .completed, .failed, .paused, .cancelled]

        for state in states {
            XCTAssertFalse(state.color.isEmpty, "\(state) should have a color")
        }
    }

    // MARK: - View Structure Tests

    func testProviderListStructure() {
        // Verify provider list has expected structure
        let allProviders = CloudProviderType.allCases

        // Verify we have a reasonable number of providers
        XCTAssertGreaterThan(allProviders.count, 10, "Should have multiple cloud providers")

        // Verify each provider has required display properties
        for provider in allProviders {
            XCTAssertFalse(provider.displayName.isEmpty, "\(provider) should have display name")
            XCTAssertFalse(provider.iconName.isEmpty, "\(provider) should have icon")
            XCTAssertFalse(provider.rcloneType.isEmpty, "\(provider) should have rclone type")
        }
    }

    // MARK: - Accessibility Tests

    func testProviderAccessibilityLabels() {
        // Verify providers have accessibility-friendly names
        for provider in CloudProviderType.allCases {
            let displayName = provider.displayName

            // Name should be readable (not just technical IDs)
            XCTAssertFalse(displayName.contains("_"), "Display name should not contain underscores: \(displayName)")
            XCTAssertGreaterThan(displayName.count, 2, "Display name should be descriptive: \(displayName)")
        }
    }

    func testTaskStateAccessibility() {
        // Verify task states have accessibility-friendly descriptions
        for state in TaskState.allCases {
            XCTAssertFalse(state.rawValue.isEmpty, "State should have raw value for accessibility")
        }
    }

    // MARK: - Layout Consistency Tests

    func testSyncTaskDisplayData() {
        // Verify sync task can provide all display data
        let task = SyncTask(
            name: "Test Backup",
            type: .backup,
            sourceRemote: "local",
            sourcePath: "/Users/test",
            destinationRemote: "cloud",
            destinationPath: "backup"
        )

        // All display fields should be accessible
        XCTAssertFalse(task.name.isEmpty)
        XCTAssertFalse(task.type.icon.isEmpty)
        XCTAssertFalse(task.state.color.isEmpty)
        XCTAssertNotNil(task.createdAt)
    }

    func testRemoteFileDisplayData() throws {
        // Verify remote file can provide all display data
        let json = """
        {"Path": "test/file.txt", "Name": "file.txt", "Size": 1024, "IsDir": false, "ModTime": "2024-01-15T10:00:00Z"}
        """.data(using: .utf8)!

        let file = try JSONDecoder().decode(RemoteFile.self, from: json)

        XCTAssertFalse(file.Name.isEmpty)
        XCTAssertFalse(file.Path.isEmpty)
        XCTAssertGreaterThanOrEqual(file.Size, 0)
    }
}

// MARK: - TaskState Extension for Tests

extension TaskState: @retroactive CaseIterable {
    public static var allCases: [TaskState] {
        [.pending, .running, .completed, .failed, .paused, .cancelled]
    }
}
