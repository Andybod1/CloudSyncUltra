# RcloneManager Test Plan

## Overview

Comprehensive test strategy for RcloneManager - the core file operations and cloud integration component. This component is CRITICAL as all file operations depend on it.

## Component Analysis

### RcloneManager Responsibilities
1. **Binary Management** - rclone path detection and configuration
2. **Config Management** - rclone.conf file handling
3. **Cloud Provider Setup** - 11 different cloud services
4. **File Operations** - list, delete, create, download, upload
5. **Sync Operations** - one-way and bi-directional sync
6. **Encryption Integration** - encrypted remote setup
7. **Progress Parsing** - rclone output interpretation
8. **Bandwidth Integration** - throttling (already tested)

### Test Challenges
- **External Dependency**: Requires rclone binary
- **Cloud Credentials**: Can't test with real cloud accounts
- **File System**: Needs actual file operations
- **Async Streams**: Complex async patterns
- **Process Execution**: External process management

## Test Strategy

### Phase 1: Unit Tests (No rclone required)
Focus on testable logic without external dependencies

### Phase 2: Integration Tests (Mock/Stub rclone)
Test with mocked rclone responses

### Phase 3: E2E Tests (Optional - real rclone)
Actual rclone operations with test accounts

---

## Phase 1: Unit Tests (60 tests)

### 1. Initialization & Configuration (10 tests)

#### Singleton Tests (1 test)
- ✅ testRcloneManagerSingleton

#### Path Detection Tests (3 tests)
- ✅ testRclonePathDetection - bundled vs system
- ✅ testConfigPathCreation - Application Support folder
- ✅ testConfigPathFormat - correct path structure

#### Configuration File Tests (6 tests)
- ✅ testIsConfiguredWhenFileExists
- ✅ testIsConfiguredWhenFileMissing
- ✅ testConfigPathAccessible
- ✅ testConfigDirectoryCreation
- ✅ testConfigPathPersistence
- ✅ testConfigPathWriteable

### 2. Remote Configuration Tests (12 tests)

#### isRemoteConfigured Tests (4 tests)
- ✅ testIsRemoteConfiguredWhenExists
- ✅ testIsRemoteConfiguredWhenMissing
- ✅ testIsRemoteConfiguredWithoutConfig
- ✅ testIsRemoteConfiguredWithMultipleRemotes

#### Remote Name Validation (4 tests)
- ✅ testRemoteNameDetection
- ✅ testRemoteNameWithSpecialChars
- ✅ testRemoteNameCaseSensitive
- ✅ testMultipleRemotesInConfig

#### Config File Parsing (4 tests)
- ✅ testConfigFileFormat
- ✅ testConfigSectionDetection
- ✅ testConfigWithComments
- ✅ testConfigWithEmptyLines

### 3. Cloud Provider Parameter Tests (11 tests)

#### ProtonDrive Parameters (2 tests)
- ✅ testSetupProtonDriveParameters
- ✅ testSetupProtonDriveWith2FA

#### S3 Parameters (3 tests)
- ✅ testSetupS3Parameters
- ✅ testSetupS3WithEndpoint
- ✅ testSetupS3WithoutEndpoint

#### MEGA Parameters (1 test)
- ✅ testSetupMegaParameters

#### WebDAV Parameters (2 tests)
- ✅ testSetupWebDAVWithUsername
- ✅ testSetupWebDAVWithoutUsername

#### SFTP Parameters (2 tests)
- ✅ testSetupSFTPWithUser
- ✅ testSetupSFTPDefaultPort

#### FTP Parameters (1 test)
- ✅ testSetupFTPParameters

### 4. Progress Parsing Tests (15 tests)

#### Percentage Parsing (4 tests)
- ✅ testParseProgressPercentage
- ✅ testParseProgressZeroPercent
- ✅ testParseProgress100Percent
- ✅ testParseProgressDecimalPercent

#### Speed Parsing (3 tests)
- ✅ testParseProgressSpeedKB
- ✅ testParseProgressSpeedMB
- ✅ testParseProgressSpeedGB

#### Status Detection (4 tests)
- ✅ testParseProgressCheckingStatus
- ✅ testParseProgressSyncingStatus
- ✅ testParseProgressErrorStatus
- ✅ testParseProgressCompletedStatus

#### Edge Cases (4 tests)
- ✅ testParseProgressEmptyOutput
- ✅ testParseProgressMalformedOutput
- ✅ testParseProgressMultipleLines
- ✅ testParseProgressNoProgressInfo

### 5. Encryption Integration Tests (7 tests)

#### Encrypted Remote Tests (4 tests)
- ✅ testEncryptedRemoteName
- ✅ testIsEncryptedRemoteConfigured
- ✅ testEncryptedRemoteInConfig
- ✅ testEncryptedRemoteNotInConfig

#### Obscure Password Tests (3 tests)
- ✅ testObscurePasswordFormat
- ✅ testObscurePasswordDifferent
- ✅ testObscurePasswordReproducible

### 6. Error Handling Tests (5 tests)

#### RcloneError Types (4 tests)
- ✅ testConfigurationFailedError
- ✅ testSyncFailedError
- ✅ testNotInstalledError
- ✅ testEncryptionSetupFailedError

#### Error Messages (1 test)
- ✅ testErrorDescriptions

---

## Phase 2: Integration Tests (40 tests)

### 7. File Operations Tests (12 tests)

#### List Files (4 tests)
- ✅ testListRemoteFilesSuccess
- ✅ testListRemoteFilesEmptyFolder
- ✅ testListRemoteFilesInvalidPath
- ✅ testListRemoteFilesPermissionDenied

#### Delete Operations (4 tests)
- ✅ testDeleteFileSuccess
- ✅ testDeleteFileNotFound
- ✅ testDeleteFolderSuccess
- ✅ testDeleteFolderNonEmpty

#### Create Folder (2 tests)
- ✅ testCreateFolderSuccess
- ✅ testCreateFolderAlreadyExists

#### Transfer Operations (2 tests)
- ✅ testDownloadFileSuccess
- ✅ testUploadFileSuccess

### 8. Sync Operations Tests (10 tests)

#### One-Way Sync (4 tests)
- ✅ testSyncOneWayMode
- ✅ testSyncOneWayWithProgress
- ✅ testSyncOneWayWithEncryption
- ✅ testSyncOneWayWithBandwidth

#### Bi-Directional Sync (4 tests)
- ✅ testSyncBiDirectionalMode
- ✅ testSyncBiDirectionalConflicts
- ✅ testSyncBiDirectionalWithEncryption
- ✅ testSyncBiDirectionalMaxDelete

#### Sync Control (2 tests)
- ✅ testStopCurrentSync
- ✅ testSyncProgressStream

### 9. Cloud Provider Setup Tests (11 tests)

#### OAuth Providers (4 tests)
- ✅ testSetupGoogleDriveOAuth
- ✅ testSetupDropboxOAuth
- ✅ testSetupOneDriveOAuth
- ✅ testSetupBoxOAuth

#### Credential Providers (7 tests)
- ✅ testSetupProtonDrive
- ✅ testSetupProtonDriveWith2FA
- ✅ testSetupS3
- ✅ testSetupMega
- ✅ testSetupPCloud
- ✅ testSetupWebDAV
- ✅ testSetupSFTP

### 10. Encrypted Remote Tests (7 tests)

#### Setup Tests (4 tests)
- ✅ testSetupEncryptedRemote
- ✅ testSetupEncryptedRemoteWithFilenameEncryption
- ✅ testSetupEncryptedRemoteWithoutFilenameEncryption
- ✅ testSetupEncryptedRemoteCustomName

#### Removal Tests (2 tests)
- ✅ testRemoveEncryptedRemote
- ✅ testRemoveEncryptedRemoteNotConfigured

#### Obscure Tests (1 test)
- ✅ testObscurePasswordIntegration

---

## Test Implementation Strategy

### Testable Without rclone (Phase 1)
```swift
// These test pure Swift logic
- Path detection logic
- Config file parsing
- Progress parsing
- Parameter building
- Error types
```

### Require Mocking (Phase 2)
```swift
// These need Process mocking or test doubles
- File operations
- Sync operations
- Cloud provider setup
- Encrypted remote operations
```

### Optional E2E (Phase 3)
```swift
// Real rclone with test accounts
- Actual file transfers
- Real cloud operations
- Performance testing
```

---

## Test Priorities

### P0 - Critical (Must Have)
1. ✅ Initialization & paths (10 tests)
2. ✅ Config file handling (12 tests)
3. ✅ Progress parsing (15 tests)
4. ✅ Error handling (5 tests)

### P1 - High Priority
1. ✅ Cloud provider parameters (11 tests)
2. ✅ Encryption integration (7 tests)
3. ✅ File operations (12 tests)

### P2 - Medium Priority
1. ✅ Sync operations (10 tests)
2. ✅ Encrypted remotes (7 tests)

### P3 - Nice to Have
1. ⚪ OAuth provider setup (4 tests)
2. ⚪ E2E integration (varies)

---

## Implementation Phases

### Week 1: Foundation Tests (42 tests)
- Initialization (10)
- Remote configuration (12)
- Cloud provider parameters (11)
- Error handling (5)
- Progress parsing (partial - 4)

### Week 2: Core Operations (38 tests)
- Progress parsing (complete - 11 more)
- Encryption integration (7)
- File operations (12)
- Sync operations (8)

### Week 3: Advanced Features (20 tests)
- Cloud provider setup (11)
- Encrypted remote operations (7)
- Additional sync tests (2)

---

## Mock Strategy

### Process Mocking
```swift
protocol ProcessProtocol {
    var terminationStatus: Int32 { get }
    func run() throws
    func waitUntilExit()
}

// Use dependency injection for testing
class RcloneManager {
    var processFactory: () -> ProcessProtocol = { Process() }
}
```

### Config File Mocking
```swift
// Use temp directories for config
let tempConfig = FileManager.default.temporaryDirectory
  .appendingPathComponent(UUID().uuidString)
```

### Progress Stream Mocking
```swift
// Create test AsyncStreams
let mockStream = AsyncStream<SyncProgress> { continuation in
    continuation.yield(SyncProgress(percentage: 50, speed: "1 MB/s", status: .syncing))
    continuation.finish()
}
```

---

## Success Criteria

### Phase 1 Complete When:
- ✅ 60 unit tests passing
- ✅ 100% coverage of testable logic
- ✅ All error types tested
- ✅ Progress parsing validated

### Phase 2 Complete When:
- ✅ 40 integration tests passing
- ✅ File operations validated
- ✅ Sync operations tested
- ✅ Mock framework implemented

### Overall Success:
- ✅ 100 total tests
- ✅ 85%+ code coverage
- ✅ All critical paths tested
- ✅ CI/CD ready

---

## Estimated Effort

| Phase | Tests | Effort | Priority |
|-------|-------|--------|----------|
| Phase 1 | 60 | 3-4 days | P0-P1 |
| Phase 2 | 40 | 3-4 days | P1-P2 |
| Phase 3 | 20+ | 2-3 days | P3 |
| **Total** | **120+** | **8-11 days** | |

---

## Risk Mitigation

### Risks
1. **rclone Dependency** - Can't test without binary
   - Mitigation: Focus on Phase 1 (pure logic) first

2. **Process Mocking Complexity** - Hard to mock Process
   - Mitigation: Use protocol abstraction

3. **Async Stream Testing** - Complex async patterns
   - Mitigation: Use XCTest async support

4. **Cloud Credentials** - Can't use real accounts
   - Mitigation: Mock responses, document E2E separately

---

## Next Steps

1. **Implement Phase 1** (60 tests - pure logic)
2. **Create mock framework** (Process abstraction)
3. **Implement Phase 2** (40 tests - integration)
4. **Document E2E testing** (for manual/CI validation)

---

*Test Plan Created: January 11, 2026*
*Target: 100+ tests, 85%+ coverage*
*Timeline: 8-11 days for comprehensive coverage*
