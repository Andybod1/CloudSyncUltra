# RcloneManager.swift Refactoring Plan

## Executive Summary

**File:** `/Users/antti/Claude/CloudSyncApp/RcloneManager.swift`
**Current Size:** 3,164 lines (~1,511+ as noted, with recent additions)
**Proposed Modules:** 5 focused modules
**Estimated Effort:** 3-4 days
**Risk Level:** Medium (core functionality, requires careful testing)

---

## Current State Analysis

### File Statistics
- **Total Lines:** 3,164
- **Classes/Structs/Enums:** 12
- **Public Methods:** 60+
- **Responsibilities:** 7+ distinct areas (violates Single Responsibility Principle)

### Current Structure (by line ranges)

| Lines | Content | Responsibility |
|-------|---------|----------------|
| 1-59 | `MultiThreadDownloadConfig` | Download configuration |
| 61-116 | `ProviderMultiThreadCapability` | Provider capabilities |
| 118-331 | `TransferOptimizer` | Transfer optimization logic |
| 333-339 | `OneDriveAccountType` | Provider enum |
| 341-453 | `RcloneManager` init, paths, bandwidth | Core/Settings |
| 454-524 | Path validation, error parsing | Security/Errors |
| 525-1437 | Cloud provider setup methods (30+ providers) | Providers |
| 1438-1543 | Generic remote creation, config helpers | Core |
| 1545-1820 | Sync operations (sync, copyFiles, listRemoteFiles) | Transfers |
| 1821-2029 | Encryption setup | Encryption |
| 2031-2153 | File operations (delete, rename, create folder) | File Operations |
| 2154-2664 | Download/Upload operations with progress | Transfers |
| 2666-2881 | Cloud-to-cloud copy operations | Transfers |
| 2883-3032 | Progress parsing | Progress |
| 3034-3163 | Supporting types (SyncMode, SyncProgress, etc.) | Models |

### Key Dependencies
- `Foundation`, `OSLog`
- `EncryptionManager` (external)
- `TransferError` (external model)
- `RemoteEncryptionConfig` (from EncryptionManager.swift)

### Problems Identified

1. **God Object Anti-Pattern:** Single class handles 7+ distinct responsibilities
2. **Cognitive Load:** 3,164 lines too large to comprehend at once
3. **Testing Difficulty:** Hard to unit test individual components
4. **Merge Conflicts:** Multiple developers touching same file
5. **Code Navigation:** Difficult to find specific functionality
6. **Reusability:** Components tightly coupled, can't be reused independently

---

## Proposed Architecture

### ASCII Architecture Diagram

```
+------------------------------------------------------------------+
|                      RcloneManager (Facade)                       |
|   - Provides backward-compatible API                              |
|   - Delegates to specialized modules                              |
+------------------------------------------------------------------+
          |              |              |              |
          v              v              v              v
+----------------+ +----------------+ +----------------+ +----------------+
| RcloneCore     | | RcloneProviders| | RcloneTransfers| | RcloneProgress |
| - Singleton    | | - Google Drive | | - Sync ops     | | - Parsing      |
| - Paths/Config | | - Dropbox      | | - Upload/Down  | | - Callbacks    |
| - Process mgmt | | - OneDrive     | | - Copy         | | - Streaming    |
| - Validation   | | - S3/B2/etc    | | - File ops     | | - ETA calc     |
+----------------+ | - Proton Drive | +----------------+ +----------------+
                   | - 30+ providers|
                   +----------------+
                            |
                            v
                   +----------------+
                   | RcloneConfig   |
                   | - Settings     |
                   | - Bandwidth    |
                   | - Multi-thread |
                   | - UserDefaults |
                   +----------------+
```

### Module Dependency Graph

```
                    RcloneConfig
                         ^
                         |
    +--------------------+--------------------+
    |                    |                    |
RcloneCore <-----> RcloneProviders     RcloneProgress
    ^                    |                    ^
    |                    v                    |
    +------------> RcloneTransfers <----------+
```

---

## Module Specifications

### 1. RcloneCore.swift (~400 lines)

**Purpose:** Core process management, initialization, and security

**Move from RcloneManager:**

| Component | Lines | Description |
|-----------|-------|-------------|
| `RcloneManager.shared` | 342 | Singleton declaration |
| `private init()` | 349-380 | Initialization, path setup |
| `secureConfigFile()` | 382-388 | Security: file permissions |
| `validatePath()` | 421-452 | Security: path validation |
| `validateRemotePath()` | 458-471 | Security: remote path validation |
| `isConfigured()` | 527-529 | Config check |
| `logRcloneVersion()` | 533-553 | Debugging |
| `obscurePassword()` | 1908-1943 | Security: password handling |

**Properties to move:**
```swift
private let logger: Logger
private var rclonePath: String
private var configPath: String
private var process: Process?
```

**New Protocol:**
```swift
protocol RcloneProcessManaging {
    var rclonePath: String { get }
    var configPath: String { get }
    func runProcess(arguments: [String]) async throws -> ProcessResult
    func validatePath(_ path: String) throws -> String
    func obscurePassword(_ password: String) async throws -> String
}
```

**Dependencies:**
- `Foundation`, `OSLog`
- `RcloneConfig` (for settings)

---

### 2. RcloneProviders.swift (~600 lines)

**Purpose:** Cloud provider configuration (setup methods for 30+ providers)

**Move from RcloneManager:**

| Method | Lines | Provider |
|--------|-------|----------|
| `setupProtonDrive()` | 565-620 | Proton Drive |
| `testProtonDriveConnection()` | 625-678 | Proton Drive |
| `parseProtonDriveError()` | 681-711 | Proton Drive |
| `setupGoogleDrive()` | 713-716 | Google Drive |
| `setupDropbox()` | 718-721 | Dropbox |
| `setupOneDrive()` | 723-849 | OneDrive |
| `setupS3()` | 851-861 | Amazon S3 |
| `setupMega()` | 863-873 | MEGA |
| `setupBox()` | 875-878 | Box |
| `setupPCloud()` | 880-883 | pCloud |
| `setupWebDAV()` | 885-894 | WebDAV |
| `setupSFTP()` | 896-906 | SFTP |
| `setupFTP()` | 908-918 | FTP |
| `setupNextcloud()` | 921-929 | Nextcloud |
| `setupOwnCloud()` | 931-939 | ownCloud |
| `setupSeafile()` | 941-954 | Seafile |
| `setupKoofr()` | 956-965 | Koofr |
| `setupYandexDisk()` | 967-970 | Yandex Disk |
| `setupMailRuCloud()` | 972-981 | Mail.ru Cloud |
| `setupBackblazeB2()` | 985-994 | Backblaze B2 |
| `setupWasabi()` | 996-1010 | Wasabi |
| `setupDigitalOceanSpaces()` | 1012-1026 | DO Spaces |
| `setupCloudflareR2()` | 1028-1039 | Cloudflare R2 |
| `setupScaleway()` | 1041-1055 | Scaleway |
| `setupOracleCloud()` | 1057-1068 | Oracle Cloud |
| `setupStorj()` | 1070-1078 | Storj |
| `setupFilebase()` | 1080-1091 | Filebase |
| `setupGoogleCloudStorage()` | 1095-1111 | GCS |
| `setupAzureBlob()` | 1113-1125 | Azure Blob |
| `setupAzureFiles()` | 1127-1138 | Azure Files |
| `setupOneDriveBusiness()` | 1140-1145 | OneDrive Business |
| `setupSharePoint()` | 1147-1150 | SharePoint |
| `setupAlibabaOSS()` | 1152-1161 | Alibaba OSS |
| `setupJottacloud()` | 1176-1265 | Jottacloud |
| `setupFlickr()` | 1400-1403 | Flickr |
| `setupSugarSync()` | 1405-1408 | SugarSync |
| `setupOpenDrive()` | 1410-1413 | OpenDrive |
| `setupPutio()` | 1417-1420 | Put.io |
| `setupPremiumizeme()` | 1422-1425 | Premiumize.me |
| `setupQuatrix()` | 1427-1430 | Quatrix |
| `setupFileFabric()` | 1432-1435 | File Fabric |

**Helper Methods to move:**
```swift
createRemote()              // 1439-1474
createRemoteInteractive()   // 1476-1519
isRemoteConfigured()        // 1521-1530
deleteRemote()              // 1532-1543
runJottacloudConfigStep()   // 1268-1328
parseConfigState()          // 1331-1352
parseConfigError()          // 1355-1384
```

**New Protocol:**
```swift
protocol CloudProviderConfiguring {
    func setupProvider(_ type: CloudProviderType, name: String, credentials: ProviderCredentials) async throws
    func isRemoteConfigured(name: String) -> Bool
    func deleteRemote(name: String) async throws
}
```

**Dependencies:**
- `RcloneCore` (for process execution, password obscuring)
- `Foundation`, `OSLog`

---

### 3. RcloneTransfers.swift (~700 lines)

**Purpose:** All file transfer operations (sync, upload, download, copy)

**Move from RcloneManager:**

| Method | Lines | Operation Type |
|--------|-------|----------------|
| `sync()` | 1547-1620 | One-way/Bi-directional sync |
| `syncBetweenRemotes()` | 1629-1706 | Remote-to-remote sync |
| `copyFiles()` | 1708-1773 | File copying |
| `listRemoteFiles()` | 1775-1814 | Directory listing |
| `stopCurrentSync()` | 1816-1819 | Process termination |
| `setupEncryptedRemote()` | 1825-1897 | Encryption setup |
| `removeEncryptedRemote()` | 1899-1902 | Encryption removal |
| `isEncryptedRemoteConfigured()` | 1946-1948 | Encryption check |
| `setupCryptRemote()` | 1954-2015 | Per-remote encryption |
| `isCryptRemoteConfigured()` | 2017-2021 | Crypt remote check |
| `deleteCryptRemote()` | 2024-2029 | Delete crypt remote |
| `deleteFile()` | 2034-2054 | File deletion |
| `deleteFolder()` | 2057-2087 | Folder deletion |
| `renameFile()` | 2090-2121 | File renaming |
| `createFolder()` | 2124-2147 | Folder creation |
| `createDirectory()` | 2150-2152 | Alias for createFolder |
| `download()` | 2161-2234 | Download with progress |
| `downloadLargeFile()` | 2247-2348 | Multi-threaded download |
| `getRemoteFileInfo()` | 2356-2390 | File info retrieval |
| `uploadWithProgress()` | 2393-2604 | Upload with streaming |
| `upload()` | 2607-2664 | Blocking upload |
| `copyBetweenRemotes()` | 2667-2711 | Cloud-to-cloud copy |
| `copyBetweenRemotesWithProgress()` | 2720-2836 | Cloud-to-cloud with progress |
| `copy()` | 2839-2881 | Generic copy |

**New Protocols:**
```swift
protocol FileTransferring {
    func upload(localPath: String, remoteName: String, remotePath: String) async throws
    func download(remoteName: String, remotePath: String, localPath: String) async throws
    func sync(source: String, destination: String, mode: SyncMode) async throws -> AsyncStream<SyncProgress>
}

protocol FileManaging {
    func deleteFile(remoteName: String, path: String) async throws
    func deleteFolder(remoteName: String, path: String) async throws
    func renameFile(remoteName: String, oldPath: String, newPath: String) async throws
    func createFolder(remoteName: String, path: String) async throws
}
```

**Dependencies:**
- `RcloneCore` (process execution, validation)
- `RcloneConfig` (bandwidth settings)
- `RcloneProgress` (progress callbacks)
- `EncryptionManager` (encryption state)

---

### 4. RcloneProgress.swift (~300 lines)

**Purpose:** Progress tracking, parsing, and streaming callbacks

**Move from RcloneManager:**

| Method/Struct | Lines | Purpose |
|---------------|-------|---------|
| `parseProgress()` | 2885-3008 | Parse rclone output |
| `parseSizeString()` | 3011-3032 | Parse size strings |
| `parseError()` | 489-510 | Error parsing |
| `TransferFailures` | 513-523 | Failure tracking struct |

**Types to move:**
```swift
struct SyncProgress           // 3042-3071
enum SyncStatus              // 3074-3091
struct LargeFileDownloadResult // 3117-3163
```

**New Protocol:**
```swift
protocol ProgressParsing {
    func parseProgress(from output: String) -> SyncProgress?
    func parseError(from output: String) -> TransferError?
    func parseSizeString(_ sizeStr: String) -> Int64?
}

protocol ProgressReporting {
    func reportProgress(_ progress: SyncProgress)
    func reportError(_ error: TransferError)
    func reportCompletion(success: Bool)
}
```

**Dependencies:**
- `TransferError` (external model)
- `Foundation`

---

### 5. RcloneConfig.swift (~350 lines)

**Purpose:** Settings management, bandwidth throttling, transfer optimization

**Move from RcloneManager:**

| Component | Lines | Purpose |
|-----------|-------|---------|
| `MultiThreadDownloadConfig` | 15-59 | Download threading config |
| `ProviderMultiThreadCapability` | 65-116 | Provider capabilities |
| `TransferOptimizer` | 123-331 | Transfer optimization |
| `OneDriveAccountType` | 335-339 | OneDrive enum |
| `getBandwidthArgs()` | 394-413 | Bandwidth limiting |

**Types to move:**
```swift
struct MultiThreadDownloadConfig
enum ProviderMultiThreadCapability
class TransferOptimizer
enum OneDriveAccountType
enum SyncMode                    // 3037-3040
struct RemoteFile                // 3093-3115
```

**New Protocol:**
```swift
protocol TransferConfiguring {
    var bandwidthArgs: [String] { get }
    var multiThreadConfig: MultiThreadDownloadConfig { get }
    func optimizeTransfer(fileCount: Int, totalBytes: Int64, remoteName: String, isDirectory: Bool, isDownload: Bool) -> TransferConfig
}
```

**Dependencies:**
- `UserDefaults` (for persistence)
- `Foundation`

---

## Migration Plan

### Phase 1: Extract Configuration (Day 1 - Low Risk)

**Goal:** Extract settings and configuration with no behavior change

1. Create `RcloneConfig.swift`
2. Move `MultiThreadDownloadConfig`, `ProviderMultiThreadCapability`, `TransferOptimizer`
3. Move `OneDriveAccountType`, `SyncMode`, `RemoteFile`
4. Move `getBandwidthArgs()` to config class
5. Update imports in `RcloneManager.swift`
6. **Test:** Verify all existing tests pass

**Rollback:** Delete new file, revert imports

### Phase 2: Extract Progress Handling (Day 1-2 - Low Risk)

**Goal:** Isolate progress parsing and reporting

1. Create `RcloneProgress.swift`
2. Move `parseProgress()`, `parseSizeString()`, `parseError()`
3. Move `SyncProgress`, `SyncStatus`, `LargeFileDownloadResult`
4. Move `TransferFailures` struct
5. Create `ProgressParser` class with protocol conformance
6. Update `RcloneManager` to use new parser
7. **Test:** Verify progress parsing in upload/download tests

**Rollback:** Delete new file, revert to inline methods

### Phase 3: Extract Core Functionality (Day 2 - Medium Risk)

**Goal:** Separate process management and security

1. Create `RcloneCore.swift`
2. Move singleton pattern, initialization
3. Move path validation methods
4. Move `obscurePassword()` method
5. Move process execution helpers
6. Create `RcloneCore.shared` as the new singleton
7. Update `RcloneManager` to delegate to `RcloneCore`
8. **Test:** Verify all process-based operations work

**Rollback:** More complex - requires careful state management

### Phase 4: Extract Provider Setup (Day 2-3 - Medium Risk)

**Goal:** Isolate 30+ provider configurations

1. Create `RcloneProviders.swift`
2. Move all `setup*()` methods
3. Move `createRemote()`, `createRemoteInteractive()`
4. Move remote management methods
5. Move Jottacloud state machine helpers
6. Create `ProviderManager` class
7. Update `RcloneManager` to delegate provider setup
8. **Test:** Test OAuth flows, credential handling

**Rollback:** Delete file, restore methods to main class

### Phase 5: Extract Transfers (Day 3-4 - Higher Risk)

**Goal:** Isolate transfer operations

1. Create `RcloneTransfers.swift`
2. Move sync operations
3. Move upload/download methods
4. Move file operations
5. Move encryption setup methods
6. Create `TransferManager` class
7. Wire up dependencies between modules
8. **Test:** Full integration testing of all transfer types

**Rollback:** Most complex - requires coordination with other phases

### Phase 6: Facade Pattern (Day 4 - Low Risk)

**Goal:** Maintain backward compatibility

1. Update `RcloneManager` as a facade
2. Delegate all calls to appropriate modules
3. Mark internal implementation as `internal` access
4. Keep public API unchanged
5. **Test:** Ensure all existing consumers work unchanged

---

## Risk Assessment

### High Risk Items

| Risk | Mitigation | Impact |
|------|------------|--------|
| Breaking OAuth flows | Test each provider manually | Auth failures |
| Progress callback interruption | Maintain AsyncStream signatures | UI freezes |
| Encryption key handling | Keep security methods in Core | Data loss |
| Process management race conditions | Use actors or locks | Corrupt transfers |

### Medium Risk Items

| Risk | Mitigation | Impact |
|------|------------|--------|
| Test coverage gaps | Add integration tests per module | Regressions |
| Circular dependencies | Careful protocol design | Build failures |
| Memory leaks in streams | Profile after refactor | Performance |

### Low Risk Items

| Risk | Mitigation | Impact |
|------|------------|--------|
| Import statement changes | IDE refactoring tools | Build errors |
| Type visibility | Explicit access control | Compilation |

---

## Testing Strategy

### Unit Tests Per Module

| Module | Test Focus | Coverage Target |
|--------|------------|-----------------|
| RcloneConfig | Settings persistence, optimization | 90% |
| RcloneProgress | Output parsing, edge cases | 95% |
| RcloneCore | Path validation, security | 95% |
| RcloneProviders | Mock OAuth, credential handling | 80% |
| RcloneTransfers | Integration with mocked rclone | 75% |

### Integration Tests

1. **End-to-end upload flow:** Local -> Config -> Core -> Transfers -> Progress
2. **Provider OAuth flow:** Providers -> Core -> Config persistence
3. **Encryption flow:** Transfers -> Core (obscure) -> Config

### Existing Tests to Update

Located in `/Users/antti/Claude/CloudSyncAppTests/`:
- `RcloneManagerErrorTests.swift` - Update imports
- `BandwidthThrottlingTests.swift` - Point to RcloneConfig
- `TransferErrorTests.swift` - Verify integration
- `EncryptionManagerTests.swift` - Verify encryption flow

---

## Success Criteria

1. **No behavior change:** All existing functionality works identically
2. **All tests pass:** 100% of existing tests pass without modification
3. **Each module < 500 lines:** Manageable cognitive load
4. **Clear ownership:** Each file has single responsibility
5. **Documented protocols:** Public interfaces documented
6. **Backward compatible:** `RcloneManager.shared` API unchanged

---

## File Summary

| New File | Estimated Lines | Primary Responsibility |
|----------|-----------------|------------------------|
| `RcloneCore.swift` | ~400 | Process management, security |
| `RcloneProviders.swift` | ~600 | 30+ cloud provider setup |
| `RcloneTransfers.swift` | ~700 | Upload/download/sync/file ops |
| `RcloneProgress.swift` | ~300 | Progress parsing & reporting |
| `RcloneConfig.swift` | ~350 | Settings, bandwidth, optimization |
| `RcloneManager.swift` (facade) | ~100 | Backward-compatible facade |
| **Total** | ~2,450 | (vs 3,164 original - 23% reduction via deduplication) |

---

## Appendix: Protocol Definitions Summary

```swift
// RcloneCore.swift
protocol RcloneProcessManaging {
    var rclonePath: String { get }
    var configPath: String { get }
    func runProcess(arguments: [String]) async throws -> ProcessResult
    func validatePath(_ path: String) throws -> String
    func obscurePassword(_ password: String) async throws -> String
}

// RcloneProviders.swift
protocol CloudProviderConfiguring {
    func setupProvider(_ type: CloudProviderType, name: String, credentials: ProviderCredentials) async throws
    func isRemoteConfigured(name: String) -> Bool
    func deleteRemote(name: String) async throws
}

// RcloneTransfers.swift
protocol FileTransferring {
    func upload(localPath: String, remoteName: String, remotePath: String) async throws
    func download(remoteName: String, remotePath: String, localPath: String) async throws
    func sync(source: String, destination: String, mode: SyncMode) async throws -> AsyncStream<SyncProgress>
}

protocol FileManaging {
    func deleteFile(remoteName: String, path: String) async throws
    func deleteFolder(remoteName: String, path: String) async throws
    func renameFile(remoteName: String, oldPath: String, newPath: String) async throws
    func createFolder(remoteName: String, path: String) async throws
}

// RcloneProgress.swift
protocol ProgressParsing {
    func parseProgress(from output: String) -> SyncProgress?
    func parseError(from output: String) -> TransferError?
}

// RcloneConfig.swift
protocol TransferConfiguring {
    var bandwidthArgs: [String] { get }
    var multiThreadConfig: MultiThreadDownloadConfig { get }
    func optimizeTransfer(fileCount: Int, totalBytes: Int64, remoteName: String, isDirectory: Bool, isDownload: Bool) -> TransferConfig
}
```

---

**Document Version:** 1.0
**Created:** 2026-01-14
**Author:** Architect Worker (Claude Code Agent)
**Status:** Ready for Review
