# Task: QA - Quick Wins Test Coverage

> **Worker:** QA
> **Model:** Sonnet
> **Sprint:** Quick Wins + Polish
> **Tickets:** #14, #25, #1 (Testing)

---

## Objective

Write comprehensive tests for the three new features being implemented in this sprint.

---

## Test File 1: Sidebar Reordering Tests

### Create File
`/Users/antti/Claude/CloudSyncAppTests/RemoteReorderingTests.swift`

```swift
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
```

---

## Test File 2: Account Name Tests

### Create File
`/Users/antti/Claude/CloudSyncAppTests/AccountNameTests.swift`

```swift
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
```

---

## Test File 3: Bandwidth Throttling Tests

### Create File
`/Users/antti/Claude/CloudSyncAppTests/BandwidthThrottlingUITests.swift`

```swift
//
//  BandwidthThrottlingUITests.swift
//  CloudSyncAppTests
//
//  Tests for bandwidth throttling UI and settings
//

import XCTest
@testable import CloudSyncApp

final class BandwidthThrottlingUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset UserDefaults for tests
        UserDefaults.standard.removeObject(forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.removeObject(forKey: "uploadLimit")
        UserDefaults.standard.removeObject(forKey: "downloadLimit")
    }
    
    override func tearDown() {
        // Clean up
        UserDefaults.standard.removeObject(forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.removeObject(forKey: "uploadLimit")
        UserDefaults.standard.removeObject(forKey: "downloadLimit")
        super.tearDown()
    }
    
    // MARK: - Settings Persistence Tests
    
    func testBandwidthEnabledPersistence() {
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
    }
    
    func testBandwidthDisabledByDefault() {
        let enabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        XCTAssertFalse(enabled, "Bandwidth limiting should be disabled by default")
    }
    
    func testUploadLimitPersistence() {
        UserDefaults.standard.set(10.0, forKey: "uploadLimit")
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 10.0)
    }
    
    func testDownloadLimitPersistence() {
        UserDefaults.standard.set(5.0, forKey: "downloadLimit")
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 5.0)
    }
    
    func testZeroLimitMeansUnlimited() {
        UserDefaults.standard.set(0.0, forKey: "uploadLimit")
        UserDefaults.standard.set(0.0, forKey: "downloadLimit")
        
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        // 0 means unlimited
        XCTAssertEqual(upload, 0.0)
        XCTAssertEqual(download, 0.0)
    }
    
    // MARK: - Preset Value Tests
    
    func testPresetValues() {
        let presets = [1, 5, 10, 50]
        
        for preset in presets {
            UserDefaults.standard.set(Double(preset), forKey: "uploadLimit")
            UserDefaults.standard.set(Double(preset), forKey: "downloadLimit")
            
            XCTAssertEqual(
                UserDefaults.standard.double(forKey: "uploadLimit"),
                Double(preset)
            )
            XCTAssertEqual(
                UserDefaults.standard.double(forKey: "downloadLimit"),
                Double(preset)
            )
        }
    }
    
    // MARK: - Independent Limits Tests
    
    func testIndependentUploadDownloadLimits() {
        UserDefaults.standard.set(10.0, forKey: "uploadLimit")
        UserDefaults.standard.set(50.0, forKey: "downloadLimit")
        
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 10.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 50.0)
        XCTAssertNotEqual(
            UserDefaults.standard.double(forKey: "uploadLimit"),
            UserDefaults.standard.double(forKey: "downloadLimit")
        )
    }
}
```

---

## Verification Steps

After creating test files:

1. **Build tests:**
```bash
cd /Users/antti/Claude
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "(Test Case|passed|failed|error:)"
```

2. **Verify test count:**
- RemoteReorderingTests: 6 tests
- AccountNameTests: 6 tests
- BandwidthThrottlingUITests: 7 tests
- **Total: 19 new tests**

---

## Completion Checklist

- [ ] RemoteReorderingTests.swift created
- [ ] AccountNameTests.swift created
- [ ] BandwidthThrottlingUITests.swift created
- [ ] All tests compile
- [ ] Tests pass (after Dev-1, Dev-2, Dev-3 complete their work)

---

## Output

When complete, create a summary file:
```
/Users/antti/Claude/.claude-team/outputs/QA_COMPLETE.md
```

Include:
- Test files created
- Test count
- Build/test status

---

*Task assigned by Strategic Partner*
