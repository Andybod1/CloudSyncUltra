//
//  RemoteReorderingTests.swift
//  CloudSyncAppTests
//
//  Tests for cloud remote reordering functionality
//

import XCTest
@testable import CloudSyncApp

final class RemoteReorderingTests: XCTestCase {

    // MARK: - CloudRemote sortOrder Tests

    func testCloudRemoteHasSortOrder() {
        let remote = CloudRemote(
            name: "Test",
            type: .googleDrive,
            isConfigured: true,
            sortOrder: 5
        )
        XCTAssertEqual(remote.sortOrder, 5)
    }

    func testCloudRemoteDefaultSortOrder() {
        let remote = CloudRemote(
            name: "Test",
            type: .dropbox,
            isConfigured: true
        )
        XCTAssertEqual(remote.sortOrder, 0, "Default sortOrder should be 0")
    }

    func testCloudRemoteSortOrderCodable() throws {
        let remote = CloudRemote(
            name: "Test",
            type: .oneDrive,
            isConfigured: true,
            sortOrder: 10
        )

        let encoded = try JSONEncoder().encode(remote)
        let decoded = try JSONDecoder().decode(CloudRemote.self, from: encoded)

        XCTAssertEqual(decoded.sortOrder, 10)
    }

    // MARK: - Sorting Tests

    func testRemotesSortBySortOrder() {
        let remotes = [
            CloudRemote(name: "C", type: .dropbox, sortOrder: 2),
            CloudRemote(name: "A", type: .googleDrive, sortOrder: 0),
            CloudRemote(name: "B", type: .oneDrive, sortOrder: 1)
        ]

        let sorted = remotes.sorted { $0.sortOrder < $1.sortOrder }

        XCTAssertEqual(sorted[0].name, "A")
        XCTAssertEqual(sorted[1].name, "B")
        XCTAssertEqual(sorted[2].name, "C")
    }

    func testLocalRemotesExcludedFromReordering() {
        let remotes = [
            CloudRemote(name: "Local", type: .local, sortOrder: 0),
            CloudRemote(name: "Google", type: .googleDrive, sortOrder: 1),
            CloudRemote(name: "Dropbox", type: .dropbox, sortOrder: 0)
        ]

        let cloudOnly = remotes.filter { $0.type != .local }
        XCTAssertEqual(cloudOnly.count, 2)
        XCTAssertFalse(cloudOnly.contains { $0.type == .local })
    }

    // MARK: - Move Operation Tests

    func testMoveRemoteUpdatesOrder() {
        var remotes = [
            CloudRemote(name: "A", type: .googleDrive, sortOrder: 0),
            CloudRemote(name: "B", type: .dropbox, sortOrder: 1),
            CloudRemote(name: "C", type: .oneDrive, sortOrder: 2)
        ]

        // Move item at index 2 to index 0
        remotes.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)

        // Update sort orders
        for (index, _) in remotes.enumerated() {
            remotes[index].sortOrder = index
        }

        XCTAssertEqual(remotes[0].name, "C")
        XCTAssertEqual(remotes[0].sortOrder, 0)
        XCTAssertEqual(remotes[1].name, "A")
        XCTAssertEqual(remotes[2].name, "B")
    }
}