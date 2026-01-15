//
//  TransferPreviewTests.swift
//  CloudSyncAppTests
//
//  Tests for TransferPreview dry-run functionality (#55)
//  Validates preview item creation, operation counts, and display formatting
//

import XCTest
@testable import CloudSyncApp

final class TransferPreviewTests: XCTestCase {

    // MARK: - PreviewItem Tests

    func testPreviewItemCreation() {
        let item = PreviewItem(
            path: "/test/file.txt",
            size: 1024,
            operation: .transfer,
            modifiedDate: Date()
        )
        XCTAssertEqual(item.path, "/test/file.txt")
        XCTAssertEqual(item.size, 1024)
        XCTAssertEqual(item.operation, .transfer)
        XCTAssertNotNil(item.modifiedDate)
    }

    func testPreviewItemWithoutModifiedDate() {
        let item = PreviewItem(
            path: "/test/file.txt",
            size: 512,
            operation: .delete,
            modifiedDate: nil
        )
        XCTAssertEqual(item.path, "/test/file.txt")
        XCTAssertEqual(item.operation, .delete)
        XCTAssertNil(item.modifiedDate)
    }

    func testPreviewItemHasUniqueId() {
        let item1 = PreviewItem(path: "file1.txt", size: 100, operation: .transfer, modifiedDate: nil)
        let item2 = PreviewItem(path: "file2.txt", size: 200, operation: .transfer, modifiedDate: nil)

        XCTAssertNotEqual(item1.id, item2.id, "Each PreviewItem should have a unique ID")
    }

    func testPreviewItemFormattedSize() {
        let item = PreviewItem(
            path: "/test/file.txt",
            size: 1048576,  // 1 MB
            operation: .transfer,
            modifiedDate: nil
        )

        // Should format as 1 MB
        XCTAssertFalse(item.formattedSize.isEmpty, "Formatted size should not be empty")
    }

    // MARK: - Empty Preview Tests

    func testEmptyPreview() {
        let preview = TransferPreview(
            filesToTransfer: [],
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: 0,
            estimatedTime: nil
        )
        XCTAssertTrue(preview.isEmpty)
        XCTAssertEqual(preview.totalItems, 0)
    }

    func testEmptyPreviewSummary() {
        let preview = TransferPreview(
            filesToTransfer: [],
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: 0,
            estimatedTime: nil
        )
        XCTAssertEqual(preview.summary, "No changes needed")
    }

    // MARK: - Preview Total Count Tests

    func testPreviewTotalCountWithTransfersOnly() {
        let preview = TransferPreview(
            filesToTransfer: [
                PreviewItem(path: "a", size: 100, operation: .transfer, modifiedDate: nil),
                PreviewItem(path: "b", size: 200, operation: .transfer, modifiedDate: nil)
            ],
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: 300,
            estimatedTime: nil
        )
        XCTAssertEqual(preview.totalItems, 2)
        XCTAssertFalse(preview.isEmpty)
    }

    func testPreviewTotalCountWithDeletesOnly() {
        let preview = TransferPreview(
            filesToTransfer: [],
            filesToDelete: [
                PreviewItem(path: "x", size: 50, operation: .delete, modifiedDate: nil)
            ],
            filesToUpdate: [],
            totalSize: 0,
            estimatedTime: nil
        )
        XCTAssertEqual(preview.totalItems, 1)
        XCTAssertFalse(preview.isEmpty)
    }

    func testPreviewTotalCountWithMixedOperations() {
        let preview = TransferPreview(
            filesToTransfer: [PreviewItem(path: "a", size: 100, operation: .transfer, modifiedDate: nil)],
            filesToDelete: [PreviewItem(path: "b", size: 50, operation: .delete, modifiedDate: nil)],
            filesToUpdate: [PreviewItem(path: "c", size: 75, operation: .update, modifiedDate: nil)],
            totalSize: 225,
            estimatedTime: nil
        )
        XCTAssertEqual(preview.totalItems, 3)
        XCTAssertFalse(preview.isEmpty)
    }

    // MARK: - Preview Operation Icon Tests

    func testPreviewOperationIcons() {
        XCTAssertEqual(PreviewOperation.transfer.iconName, "arrow.right.circle")
        XCTAssertEqual(PreviewOperation.delete.iconName, "trash")
        XCTAssertEqual(PreviewOperation.update.iconName, "arrow.triangle.2.circlepath")
        XCTAssertEqual(PreviewOperation.skip.iconName, "forward")
    }

    func testPreviewOperationColors() {
        XCTAssertEqual(PreviewOperation.transfer.colorName, "blue")
        XCTAssertEqual(PreviewOperation.delete.colorName, "red")
        XCTAssertEqual(PreviewOperation.update.colorName, "orange")
        XCTAssertEqual(PreviewOperation.skip.colorName, "gray")
    }

    func testPreviewOperationRawValues() {
        XCTAssertEqual(PreviewOperation.transfer.rawValue, "Transfer")
        XCTAssertEqual(PreviewOperation.delete.rawValue, "Delete")
        XCTAssertEqual(PreviewOperation.update.rawValue, "Update")
        XCTAssertEqual(PreviewOperation.skip.rawValue, "Skip")
    }

    // MARK: - Summary Tests

    func testPreviewSummaryWithTransfersOnly() {
        let preview = TransferPreview(
            filesToTransfer: [
                PreviewItem(path: "a", size: 100, operation: .transfer, modifiedDate: nil),
                PreviewItem(path: "b", size: 200, operation: .transfer, modifiedDate: nil)
            ],
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: 300,
            estimatedTime: nil
        )
        XCTAssertTrue(preview.summary.contains("2 to transfer"))
    }

    func testPreviewSummaryWithDeletesOnly() {
        let preview = TransferPreview(
            filesToTransfer: [],
            filesToDelete: [
                PreviewItem(path: "x", size: 50, operation: .delete, modifiedDate: nil)
            ],
            filesToUpdate: [],
            totalSize: 0,
            estimatedTime: nil
        )
        XCTAssertTrue(preview.summary.contains("1 to delete"))
    }

    func testPreviewSummaryWithUpdatesOnly() {
        let preview = TransferPreview(
            filesToTransfer: [],
            filesToDelete: [],
            filesToUpdate: [
                PreviewItem(path: "c", size: 75, operation: .update, modifiedDate: nil),
                PreviewItem(path: "d", size: 80, operation: .update, modifiedDate: nil),
                PreviewItem(path: "e", size: 90, operation: .update, modifiedDate: nil)
            ],
            totalSize: 245,
            estimatedTime: nil
        )
        XCTAssertTrue(preview.summary.contains("3 to update"))
    }

    func testPreviewSummaryWithAllOperations() {
        let preview = TransferPreview(
            filesToTransfer: [PreviewItem(path: "a", size: 100, operation: .transfer, modifiedDate: nil)],
            filesToDelete: [PreviewItem(path: "b", size: 50, operation: .delete, modifiedDate: nil)],
            filesToUpdate: [PreviewItem(path: "c", size: 75, operation: .update, modifiedDate: nil)],
            totalSize: 225,
            estimatedTime: nil
        )
        let summary = preview.summary
        XCTAssertTrue(summary.contains("1 to transfer"))
        XCTAssertTrue(summary.contains("1 to update"))
        XCTAssertTrue(summary.contains("1 to delete"))
    }

    // MARK: - Size Formatting Tests

    func testFormattedTotalSize() {
        let preview = TransferPreview(
            filesToTransfer: [PreviewItem(path: "a", size: 1048576, operation: .transfer, modifiedDate: nil)],
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: 1048576,  // 1 MB
            estimatedTime: nil
        )

        XCTAssertFalse(preview.formattedTotalSize.isEmpty, "Formatted size should not be empty")
    }

    func testFormattedTotalSizeZero() {
        let preview = TransferPreview(
            filesToTransfer: [],
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: 0,
            estimatedTime: nil
        )

        XCTAssertFalse(preview.formattedTotalSize.isEmpty, "Zero size should still format")
    }

    // MARK: - Estimated Time Tests

    func testPreviewWithEstimatedTime() {
        let preview = TransferPreview(
            filesToTransfer: [PreviewItem(path: "a", size: 100, operation: .transfer, modifiedDate: nil)],
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: 100,
            estimatedTime: 120.0  // 2 minutes
        )

        XCTAssertNotNil(preview.estimatedTime)
        XCTAssertEqual(preview.estimatedTime, 120.0)
    }

    func testPreviewWithoutEstimatedTime() {
        let preview = TransferPreview(
            filesToTransfer: [PreviewItem(path: "a", size: 100, operation: .transfer, modifiedDate: nil)],
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: 100,
            estimatedTime: nil
        )

        XCTAssertNil(preview.estimatedTime)
    }

    // MARK: - PreviewError Tests

    func testPreviewErrorDescriptions() {
        XCTAssertNotNil(PreviewError.rcloneNotFound.errorDescription)
        XCTAssertTrue(PreviewError.rcloneNotFound.errorDescription!.contains("rclone"))

        XCTAssertNotNil(PreviewError.invalidPath("/bad/path").errorDescription)
        XCTAssertTrue(PreviewError.invalidPath("/bad/path").errorDescription!.contains("/bad/path"))

        XCTAssertNotNil(PreviewError.executionFailed("timeout").errorDescription)
        XCTAssertTrue(PreviewError.executionFailed("timeout").errorDescription!.contains("timeout"))

        XCTAssertNotNil(PreviewError.parseError("invalid format").errorDescription)
        XCTAssertTrue(PreviewError.parseError("invalid format").errorDescription!.contains("invalid format"))
    }

    // MARK: - Edge Cases

    func testPreviewWithLargeNumberOfItems() {
        // Create preview with many items
        var transfers: [PreviewItem] = []
        for i in 0..<1000 {
            transfers.append(PreviewItem(path: "file\(i).txt", size: Int64(i * 100), operation: .transfer, modifiedDate: nil))
        }

        let preview = TransferPreview(
            filesToTransfer: transfers,
            filesToDelete: [],
            filesToUpdate: [],
            totalSize: transfers.reduce(0) { $0 + $1.size },
            estimatedTime: nil
        )

        XCTAssertEqual(preview.totalItems, 1000)
        XCTAssertFalse(preview.isEmpty)
        XCTAssertTrue(preview.summary.contains("1000 to transfer"))
    }

    func testPreviewWithLongFilePath() {
        let longPath = String(repeating: "a/", count: 100) + "file.txt"
        let item = PreviewItem(
            path: longPath,
            size: 100,
            operation: .transfer,
            modifiedDate: nil
        )

        XCTAssertEqual(item.path, longPath)
    }

    func testPreviewWithUnicodeFilePath() {
        let unicodePath = "/Users/test/Documents/\u{1F4C1}Folder/\u{1F4C4}File.txt"
        let item = PreviewItem(
            path: unicodePath,
            size: 100,
            operation: .transfer,
            modifiedDate: nil
        )

        XCTAssertEqual(item.path, unicodePath)
    }

    func testPreviewOperationCodable() {
        // Test that PreviewOperation can be encoded/decoded
        let operation = PreviewOperation.transfer

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        do {
            let data = try encoder.encode(operation)
            let decoded = try decoder.decode(PreviewOperation.self, from: data)
            XCTAssertEqual(decoded, operation)
        } catch {
            XCTFail("PreviewOperation should be Codable: \(error)")
        }
    }
}
