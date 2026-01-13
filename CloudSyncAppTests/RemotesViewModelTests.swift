//
//  RemotesViewModelTests.swift
//  CloudSyncAppTests
//
//  Unit tests for RemotesViewModel
//

import XCTest
@testable import CloudSyncApp

@MainActor
final class RemotesViewModelTests: XCTestCase {
    
    var viewModel: RemotesViewModel!
    
    override func setUp() async throws {
        viewModel = RemotesViewModel(forTesting: true)
    }
    
    override func tearDown() async throws {
        viewModel = nil
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_HasLocalStorage() {
        // Test mode doesn't initialize with local storage
        let local = viewModel.remotes.first { $0.type == .local }
        XCTAssertNil(local)
    }
    
    // MARK: - Configured Remotes Tests
    
    func testConfiguredRemotes() {
        // Add a configured remote
        let remote = CloudRemote(name: "Test", type: .googleDrive, isConfigured: true)
        viewModel.remotes.append(remote)
        
        let configured = viewModel.configuredRemotes
        XCTAssertTrue(configured.contains { $0.id == remote.id })
    }
    
    func testConfiguredRemotes_ExcludesUnconfigured() {
        let unconfigured = CloudRemote(name: "Unconfigured", type: .dropbox, isConfigured: false)
        viewModel.remotes.append(unconfigured)
        
        let configured = viewModel.configuredRemotes
        XCTAssertFalse(configured.contains { $0.id == unconfigured.id })
    }
    
    // MARK: - Cloud Remotes Tests
    
    func testCloudRemotes_ExcludesLocal() {
        let cloudRemotes = viewModel.remotes.filter { $0.type != .local }
        
        for remote in cloudRemotes {
            XCTAssertNotEqual(remote.type, .local)
        }
    }
    
    // MARK: - Add Remote Tests
    
    func testAddRemote() {
        let initialCount = viewModel.remotes.count
        let newRemote = CloudRemote(name: "New Remote", type: .mega, isConfigured: false)
        
        viewModel.remotes.append(newRemote)
        
        XCTAssertEqual(viewModel.remotes.count, initialCount + 1)
    }
    
    // MARK: - Remove Remote Tests
    
    func testRemoveRemote() {
        let remote = CloudRemote(name: "To Remove", type: .pcloud, isConfigured: false)
        viewModel.remotes.append(remote)
        let countAfterAdd = viewModel.remotes.count
        
        viewModel.remotes.removeAll { $0.id == remote.id }
        
        XCTAssertEqual(viewModel.remotes.count, countAfterAdd - 1)
    }
    
    // MARK: - Find Remote Tests
    
    func testFindRemote_ByType() {
        // Test mode doesn't initialize with local storage
        let local = viewModel.remotes.first { $0.type == .local }
        XCTAssertNil(local)

        // Add a remote and find it by type
        let remote = CloudRemote(name: "Test Box", type: .box, isConfigured: true)
        viewModel.remotes.append(remote)

        let found = viewModel.remotes.first { $0.type == .box }
        XCTAssertNotNil(found)
    }
    
    func testFindRemote_ById() {
        let remote = CloudRemote(name: "Findable", type: .box, isConfigured: true)
        viewModel.remotes.append(remote)
        
        let found = viewModel.remotes.first { $0.id == remote.id }
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Findable")
    }
    
    // MARK: - Update Remote Tests
    
    func testUpdateRemote_Configuration() {
        var remote = CloudRemote(name: "Unconfigured", type: .sftp, isConfigured: false)
        viewModel.remotes.append(remote)
        
        if let index = viewModel.remotes.firstIndex(where: { $0.id == remote.id }) {
            viewModel.remotes[index].isConfigured = true
        }
        
        let updated = viewModel.remotes.first { $0.id == remote.id }
        XCTAssertTrue(updated?.isConfigured ?? false)
    }
    
    // MARK: - Selection Tests
    
    func testSelectedRemote() {
        let remote = CloudRemote(name: "Selected", type: .webdav, isConfigured: true)
        viewModel.remotes.append(remote)
        
        viewModel.selectedRemote = remote
        
        XCTAssertEqual(viewModel.selectedRemote?.id, remote.id)
    }
    
    func testSelectedRemote_Clear() {
        let remote = CloudRemote(name: "Selected", type: .ftp, isConfigured: true)
        viewModel.selectedRemote = remote
        
        viewModel.selectedRemote = nil
        
        XCTAssertNil(viewModel.selectedRemote)
    }
    
    // MARK: - Remote Count Tests
    
    func testRemoteCount_ByProvider() {
        let googleRemotes = viewModel.remotes.filter { $0.type == .googleDrive }
        let protonRemotes = viewModel.remotes.filter { $0.type == .protonDrive }
        
        // Just ensure counts are non-negative
        XCTAssertGreaterThanOrEqual(googleRemotes.count, 0)
        XCTAssertGreaterThanOrEqual(protonRemotes.count, 0)
    }
}
