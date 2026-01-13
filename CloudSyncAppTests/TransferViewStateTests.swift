import XCTest
@testable import CloudSyncApp

final class TransferViewStateTests: XCTestCase {

    func testInitialStateEmpty() {
        let state = TransferViewState()
        XCTAssertNil(state.sourceRemoteId)
        XCTAssertNil(state.destRemoteId)
        XCTAssertEqual(state.sourcePath, "")
        XCTAssertEqual(state.destPath, "")
        XCTAssertTrue(state.selectedSourceFiles.isEmpty)
        XCTAssertTrue(state.selectedDestFiles.isEmpty)
        XCTAssertEqual(state.transferMode, .transfer)
    }

    func testSourcePathPreservation() {
        let state = TransferViewState()
        state.sourcePath = "/test/path"
        XCTAssertEqual(state.sourcePath, "/test/path")
    }

    func testDestPathPreservation() {
        let state = TransferViewState()
        state.destPath = "/destination/path"
        XCTAssertEqual(state.destPath, "/destination/path")
    }

    func testSourceRemoteIdPreservation() {
        let state = TransferViewState()
        let testId = UUID()
        state.sourceRemoteId = testId
        XCTAssertEqual(state.sourceRemoteId, testId)
    }

    func testDestinationRemoteIdPreservation() {
        let state = TransferViewState()
        let testId = UUID()
        state.destRemoteId = testId
        XCTAssertEqual(state.destRemoteId, testId)
    }

    func testBothRemotesAndPathPreservation() {
        let state = TransferViewState()
        let sourceId = UUID()
        let destId = UUID()

        state.sourceRemoteId = sourceId
        state.destRemoteId = destId
        state.sourcePath = "/Documents/important"
        state.destPath = "/Backup/location"

        XCTAssertEqual(state.sourceRemoteId, sourceId)
        XCTAssertEqual(state.destRemoteId, destId)
        XCTAssertEqual(state.sourcePath, "/Documents/important")
        XCTAssertEqual(state.destPath, "/Backup/location")
    }

    func testSelectedFilesPreservation() {
        let state = TransferViewState()
        let file1 = UUID()
        let file2 = UUID()

        state.selectedSourceFiles.insert(file1)
        state.selectedSourceFiles.insert(file2)

        XCTAssertEqual(state.selectedSourceFiles.count, 2)
        XCTAssertTrue(state.selectedSourceFiles.contains(file1))
        XCTAssertTrue(state.selectedSourceFiles.contains(file2))
    }

    func testTransferModePreservation() {
        let state = TransferViewState()
        state.transferMode = .sync
        XCTAssertEqual(state.transferMode, .sync)
    }

    func testRemoteClearing() {
        let state = TransferViewState()
        let testId = UUID()

        state.sourceRemoteId = testId
        XCTAssertNotNil(state.sourceRemoteId)

        state.sourceRemoteId = nil
        XCTAssertNil(state.sourceRemoteId)
    }

    func testCompleteStatePreservation() {
        let state = TransferViewState()
        let sourceId = UUID()
        let destId = UUID()
        let fileId1 = UUID()
        let fileId2 = UUID()

        // Set up complete state
        state.sourceRemoteId = sourceId
        state.destRemoteId = destId
        state.sourcePath = "/source/directory"
        state.destPath = "/dest/directory"
        state.selectedSourceFiles.insert(fileId1)
        state.selectedDestFiles.insert(fileId2)
        state.transferMode = .sync

        // Verify all state is preserved
        XCTAssertEqual(state.sourceRemoteId, sourceId)
        XCTAssertEqual(state.destRemoteId, destId)
        XCTAssertEqual(state.sourcePath, "/source/directory")
        XCTAssertEqual(state.destPath, "/dest/directory")
        XCTAssertTrue(state.selectedSourceFiles.contains(fileId1))
        XCTAssertTrue(state.selectedDestFiles.contains(fileId2))
        XCTAssertEqual(state.transferMode, .sync)
    }
}