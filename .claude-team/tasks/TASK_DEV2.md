# Dev-2 Task: Performance Optimizations

**Created:** 2026-01-14 22:20
**Completed:** 2026-01-14 22:30
**Worker:** Dev-2 (Engine)
**Model:** Opus with /think for optimization decisions
**Issues:** #70, #71
**Status:** ✅ COMPLETE

---

## Completion Summary

### Implemented Changes:

1. **CloudProviderType Extensions** (`CloudSyncApp/Models/CloudProvider.swift`):
   - Added `supportsFastList` property for all providers
   - Added `defaultParallelism` property with provider-specific (transfers, checkers) tuples

2. **TransferOptimizer Enhancements** (`CloudSyncApp/RcloneManager.swift`):
   - Added `DynamicParallelismConfig` struct
   - Added `calculateOptimalParallelism(provider:fileCount:totalSize:averageFileSize:)` function
   - Implemented provider-specific base defaults with file-size adjustments
   - Added `buildArgs(from: DynamicParallelismConfig)` for argument generation

3. **Tests Added** (`CloudSyncAppTests/TransferOptimizerTests.swift`):
   - `testDynamicParallelismForGoogleDrive()`
   - `testDynamicParallelismForSmallFiles()`
   - `testDynamicParallelismForLargeFiles()`
   - `testDynamicParallelismForProtonDrive()`
   - `testDynamicParallelismForS3()`
   - `testFastListSupportedProviders()`
   - `testFastListUnsupportedProviders()`
   - `testProviderDefaultParallelism()`
   - `testDynamicParallelismConfigBuildArgs()`

### Git Commit:
```
perf(engine): Add dynamic parallelism and fast-list support
Implements #70, #71
```

### Known Issue:
- Project has pre-existing build failure (OnboardingViewModel.swift not in Xcode project)
- This is outside Dev-2's task scope; build works if OnboardingViewModel is added to project

---

## Context

Transfer performance is critical for user satisfaction. We need to implement smart parallelism and provider-specific optimizations.

---

## Your Files (Exclusive Ownership)

```
CloudSyncApp/Services/RcloneManager.swift
CloudSyncApp/Services/TransferOptimizer.swift
CloudSyncApp/Services/RcloneCommands.swift
```

---

## Objectives

### Issue #70: Universal Dynamic Parallelism

**Goal:** Automatically adjust `--transfers` and `--checkers` based on:
- Provider type (some handle more parallelism)
- File sizes (many small files vs few large files)
- Network conditions

**Implementation:**

1. **Add to TransferOptimizer.swift:**
   ```swift
   struct DynamicParallelismConfig {
       let transfers: Int      // --transfers flag
       let checkers: Int       // --checkers flag
       let multiThreadStreams: Int  // --multi-thread-streams
   }
   
   func calculateOptimalParallelism(
       provider: CloudProvider,
       fileCount: Int,
       totalSize: Int64,
       averageFileSize: Int64
   ) -> DynamicParallelismConfig
   ```

2. **Provider-specific defaults:**
   ```
   Google Drive: transfers=8, checkers=16
   Dropbox: transfers=4, checkers=8  
   S3/B2: transfers=16, checkers=32
   Local/SFTP: transfers=8, checkers=16
   Proton Drive: transfers=2, checkers=4 (rate limited)
   ```

3. **File-size adjustments:**
   ```
   Many small files (<1MB avg): More checkers, fewer transfers
   Large files (>100MB avg): More multi-thread-streams
   Mixed: Balanced approach
   ```

4. **Apply in RcloneManager.swift** when building transfer commands

### Issue #71: Fast-List for Supported Providers

**Goal:** Enable `--fast-list` flag for providers that support it (reduces API calls)

**Supported Providers:**
- Google Drive ✅
- Google Cloud Storage ✅
- S3 ✅
- Dropbox ✅
- Box ✅
- OneDrive ✅
- B2 ✅

**Implementation:**

1. **Add provider capability check:**
   ```swift
   extension CloudProvider {
       var supportsFastList: Bool {
           switch self.type {
           case "drive", "s3", "dropbox", "box", "onedrive", "b2", "gcs":
               return true
           default:
               return false
           }
       }
   }
   ```

2. **Apply in list operations:**
   ```swift
   func buildListCommand(remote: String, path: String) -> [String] {
       var args = ["lsjson", "\(remote):\(path)"]
       if provider.supportsFastList {
           args.append("--fast-list")
       }
       return args
   }
   ```

---

## Testing Requirements

Create/update tests in `CloudSyncAppTests/`:

```swift
// TransferOptimizerTests.swift
func testDynamicParallelismForGoogleDrive()
func testDynamicParallelismForSmallFiles()
func testDynamicParallelismForLargeFiles()
func testFastListSupportedProviders()
func testFastListUnsupportedProviders()
```

---

## Deliverables

1. **Modified Files:**
   - `TransferOptimizer.swift` - Add dynamic parallelism logic
   - `RcloneManager.swift` - Apply parallelism and fast-list

2. **New/Updated Tests:**
   - `TransferOptimizerTests.swift`

3. **Git Commit:**
   ```
   perf(engine): Add dynamic parallelism and fast-list support
   
   - Dynamic transfer/checker counts based on provider (#70)
   - File-size aware parallelism tuning
   - Enable --fast-list for supported providers (#71)
   - Add comprehensive tests
   
   Implements #70, #71
   ```

---

## Notes

- Use /think when deciding parallelism algorithms
- Don't over-parallelize - respect provider rate limits
- Log parallelism decisions for debugging
- Measure before/after if possible
