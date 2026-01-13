//
//  AccountNameTests.swift
//  CloudSyncAppTests
//
//  Tests for account name display functionality
//

import XCTest
@testable import CloudSyncApp

final class AccountNameTests: XCTestCase {

    // MARK: - CloudRemote accountName Tests

    func testCloudRemoteHasAccountName() {
        let remote = CloudRemote(
            name: "Google Drive",
            type: .googleDrive,
            isConfigured: true,
            accountName: "user@gmail.com"
        )
        XCTAssertEqual(remote.accountName, "user@gmail.com")
    }

    func testCloudRemoteAccountNameOptional() {
        let remote = CloudRemote(
            name: "Dropbox",
            type: .dropbox,
            isConfigured: true
        )
        XCTAssertNil(remote.accountName)
    }

    func testCloudRemoteAccountNameCodable() throws {
        let remote = CloudRemote(
            name: "OneDrive",
            type: .oneDrive,
            isConfigured: true,
            accountName: "john@outlook.com"
        )

        let encoded = try JSONEncoder().encode(remote)
        let decoded = try JSONDecoder().decode(CloudRemote.self, from: encoded)

        XCTAssertEqual(decoded.accountName, "john@outlook.com")
    }

    func testCloudRemoteAccountNameNilCodable() throws {
        let remote = CloudRemote(
            name: "pCloud",
            type: .pcloud,
            isConfigured: true
        )

        let encoded = try JSONEncoder().encode(remote)
        let decoded = try JSONDecoder().decode(CloudRemote.self, from: encoded)

        XCTAssertNil(decoded.accountName)
    }

    // MARK: - Display Tests

    func testAccountNameDisplayWithEmail() {
        let remote = CloudRemote(
            name: "Google Drive",
            type: .googleDrive,
            accountName: "user@example.com"
        )

        // Account name should be non-empty
        XCTAssertNotNil(remote.accountName)
        XCTAssertFalse(remote.accountName?.isEmpty ?? true)
    }

    func testAccountNameDisplayGracefulFallback() {
        let remote = CloudRemote(
            name: "Mega",
            type: .mega
        )

        // Should gracefully handle nil accountName
        let displayName = remote.accountName ?? ""
        XCTAssertTrue(displayName.isEmpty)
    }
}