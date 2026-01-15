# TASK_QA.md - Test Plan for v2.0.22

**Worker:** QA  
**Status:** ⏸️ READY  
**Priority:** Medium  
**Size:** M (Medium - ~1 hour)

---

## Objective

Create comprehensive test plans for new features in v2.0.22 sprint and review test coverage gaps.

## Tasks

### 1. Test Plan: Onboarding Visual Consistency

Verify the visual fixes work correctly:

```swift
// Add to OnboardingViewModelTests.swift
func testOnboardingViewsHaveConsistentStyling() {
    // Verify AppTheme values are correct
    XCTAssertEqual(AppTheme.cardBackgroundDark.opacity, 0.12, accuracy: 0.01)
    XCTAssertEqual(AppTheme.textOnDarkSecondary.opacity, 0.8, accuracy: 0.01)
}
```

**Manual Test Cases:**
- [ ] Welcome view cards clearly visible
- [ ] Provider selection cards have good contrast
- [ ] First Sync view icons have glows
- [ ] Completion view matches style of other views
- [ ] Text readable on all views
- [ ] Hover states visible

### 2. Test Plan: Provider-Specific Chunk Sizes

```swift
// Create ChunkSizeTests.swift
import XCTest
@testable import CloudSyncApp

final class ChunkSizeTests: XCTestCase {
    
    func testChunkSizeForGoogleDrive() {
        let size = ChunkSizeConfig.chunkSize(for: .googleDrive)
        XCTAssertEqual(size, 8 * 1024 * 1024)  // 8MB
    }
    
    func testChunkSizeForS3() {
        let size = ChunkSizeConfig.chunkSize(for: .s3)
        XCTAssertEqual(size, 16 * 1024 * 1024)  // 16MB
    }
    
    func testChunkSizeForLocal() {
        let size = ChunkSizeConfig.chunkSize(for: .local)
        XCTAssertEqual(size, 64 * 1024 * 1024)  // 64MB
    }
    
    func testChunkSizeForProton() {
        let size = ChunkSizeConfig.chunkSize(for: .protonDrive)
        XCTAssertEqual(size, 4 * 1024 * 1024)  // 4MB
    }
    
    func testChunkSizeFlagGeneration() {
        let flag = ChunkSizeConfig.chunkSizeFlag(for: .googleDrive)
        XCTAssertEqual(flag, "--drive-chunk-size=8M")
    }
    
    func testAllProvidersHaveChunkSize() {
        for provider in CloudProviderType.allCases {
            let size = ChunkSizeConfig.chunkSize(for: provider)
            XCTAssertGreaterThan(size, 0)
        }
    }
}
```

### 3. Test Plan: Transfer Preview

```swift
// Create TransferPreviewTests.swift
import XCTest
@testable import CloudSyncApp

final class TransferPreviewTests: XCTestCase {
    
    func testPreviewItemCreation() {
        let item = PreviewItem(
            path: "/test/file.txt",
            size: 1024,
            operation: .transfer,
            modifiedDate: Date()
        )
        XCTAssertEqual(item.path, "/test/file.txt")
        XCTAssertEqual(item.operation, .transfer)
    }
    
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
    
    func testPreviewTotalCount() {
        let preview = TransferPreview(
            filesToTransfer: [PreviewItem(path: "a", size: 100, operation: .transfer, modifiedDate: nil)],
            filesToDelete: [PreviewItem(path: "b", size: 50, operation: .delete, modifiedDate: nil)],
            filesToUpdate: [],
            totalSize: 150,
            estimatedTime: nil
        )
        XCTAssertEqual(preview.totalItems, 2)
        XCTAssertFalse(preview.isEmpty)
    }
    
    func testPreviewOperationIcons() {
        XCTAssertEqual(PreviewOperation.transfer.iconName, "arrow.right.circle")
        XCTAssertEqual(PreviewOperation.delete.iconName, "trash")
    }
}
```

### 4. Coverage Gap Analysis

Review current test coverage and identify gaps:

**Areas to Check:**
- [ ] Error handling paths in RcloneManager
- [ ] Edge cases in TransferOptimizer
- [ ] Encryption error scenarios
- [ ] Schedule trigger edge cases
- [ ] Menu bar state management

## Files to Create

1. `/Users/antti/Claude/CloudSyncAppTests/ChunkSizeTests.swift`
2. `/Users/antti/Claude/CloudSyncAppTests/TransferPreviewTests.swift`

## Completion Protocol

1. Write test cases for chunk sizes
2. Write test cases for transfer preview
3. Run all tests to verify
4. Document any coverage gaps found
5. Commit: `test: Add tests for chunk sizes and transfer preview`
6. Report completion with test count

---

**Use /think for thorough analysis.**
