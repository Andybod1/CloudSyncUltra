import XCTest
@testable import CloudSyncApp

class TransferViewStateTests: XCTestCase {

    func testInitialStateEmpty() {
        let state = TransferViewState()
        XCTAssertNil(state.sourceRemote)
        XCTAssertNil(state.destRemote)
        XCTAssertEqual(state.sourcePath, "")
    }

    func testStatePreservation() {
        let state = TransferViewState()
        state.sourcePath = "/test/path"
        XCTAssertEqual(state.sourcePath, "/test/path")
    }

    func testSourceRemotePreservation() {
        let state = TransferViewState()
        let testRemote = RemoteConfig(id: UUID(), name: "Test Remote", type: .googleDrive, settings: [:])
        state.sourceRemote = testRemote
        XCTAssertEqual(state.sourceRemote?.name, "Test Remote")
        XCTAssertEqual(state.sourceRemote?.type, .googleDrive)
    }

    func testDestinationRemotePreservation() {
        let state = TransferViewState()
        let testRemote = RemoteConfig(id: UUID(), name: "Dest Remote", type: .dropbox, settings: [:])
        state.destRemote = testRemote
        XCTAssertEqual(state.destRemote?.name, "Dest Remote")
        XCTAssertEqual(state.destRemote?.type, .dropbox)
    }

    func testBothRemotesAndPathPreservation() {
        let state = TransferViewState()
        let sourceRemote = RemoteConfig(id: UUID(), name: "Source", type: .googleDrive, settings: [:])
        let destRemote = RemoteConfig(id: UUID(), name: "Destination", type: .dropbox, settings: [:])

        state.sourceRemote = sourceRemote
        state.destRemote = destRemote
        state.sourcePath = "/Documents/important"

        XCTAssertEqual(state.sourceRemote?.name, "Source")
        XCTAssertEqual(state.destRemote?.name, "Destination")
        XCTAssertEqual(state.sourcePath, "/Documents/important")
    }

    func testPathUpdating() {
        let state = TransferViewState()
        state.sourcePath = "/initial/path"
        XCTAssertEqual(state.sourcePath, "/initial/path")

        state.sourcePath = "/updated/path"
        XCTAssertEqual(state.sourcePath, "/updated/path")
    }

    func testRemoteClearing() {
        let state = TransferViewState()
        let testRemote = RemoteConfig(id: UUID(), name: "Test", type: .googleDrive, settings: [:])

        state.sourceRemote = testRemote
        XCTAssertNotNil(state.sourceRemote)

        state.sourceRemote = nil
        XCTAssertNil(state.sourceRemote)
    }
}