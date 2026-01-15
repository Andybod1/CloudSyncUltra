# TASK_DEV2.md - Provider-Specific Chunk Sizes

**Worker:** Dev-2 (Core Engine)  
**Status:** ⏸️ READY  
**Priority:** High  
**Size:** M (Medium - ~1.5 hours)  
**Issue:** #73

---

## Objective

Implement provider-specific chunk sizes for optimal transfer performance. Different cloud providers have different optimal chunk sizes based on their API characteristics and network overhead.

## Background

Currently, transfers use a default chunk size. Performance can be improved by tailoring chunk sizes to each provider's characteristics:

- **Google Drive** - 8MB chunks (optimal for resumable uploads API)
- **S3/B2** - 16MB chunks (better throughput for object storage)
- **Local** - 64MB chunks (fast local I/O)
- **Proton Drive** - 4MB chunks (encryption overhead)
- **Dropbox** - 8MB chunks (balanced for API limits)
- **OneDrive** - 10MB chunks (Microsoft recommended)

## Implementation

### 1. Add ChunkSizeConfiguration to TransferOptimizer.swift

```swift
/// Optimal chunk sizes per provider (in bytes)
struct ChunkSizeConfig {
    static let defaultChunkSize: Int = 8 * 1024 * 1024  // 8MB default
    
    static func chunkSize(for provider: CloudProviderType) -> Int {
        switch provider {
        case .local:
            return 64 * 1024 * 1024  // 64MB - fast local I/O
        case .s3, .b2, .gcs:
            return 16 * 1024 * 1024  // 16MB - object storage
        case .googleDrive:
            return 8 * 1024 * 1024   // 8MB - resumable uploads
        case .oneDrive:
            return 10 * 1024 * 1024  // 10MB - Microsoft optimal
        case .dropbox, .box:
            return 8 * 1024 * 1024   // 8MB - balanced
        case .protonDrive:
            return 4 * 1024 * 1024   // 4MB - encryption overhead
        case .sftp, .ftp:
            return 32 * 1024 * 1024  // 32MB - network filesystem
        default:
            return defaultChunkSize
        }
    }
}
```

### 2. Update RcloneManager.swift

Add chunk size parameter to transfer commands:

```swift
// In buildRcloneArguments or similar method
let chunkSize = ChunkSizeConfig.chunkSize(for: remoteType)
let chunkSizeArg = "--drive-chunk-size=\(chunkSize / (1024 * 1024))M"
// Note: Different providers use different flags:
// --drive-chunk-size (Google Drive)
// --s3-chunk-size (S3)
// --onedrive-chunk-size (OneDrive)
```

### 3. Create Provider-Specific Flag Mapping

```swift
static func chunkSizeFlag(for provider: CloudProviderType) -> String? {
    let sizeInMB = chunkSize(for: provider) / (1024 * 1024)
    switch provider {
    case .googleDrive:
        return "--drive-chunk-size=\(sizeInMB)M"
    case .s3:
        return "--s3-chunk-size=\(sizeInMB)M"
    case .oneDrive:
        return "--onedrive-chunk-size=\(sizeInMB)M"
    case .dropbox:
        return "--dropbox-chunk-size=\(sizeInMB)M"
    case .b2:
        return "--b2-chunk-size=\(sizeInMB)M"
    default:
        return nil  // Use rclone defaults
    }
}
```

## Files to Modify

1. `/Users/antti/Claude/CloudSyncApp/TransferEngine/TransferOptimizer.swift` - Add ChunkSizeConfig
2. `/Users/antti/Claude/CloudSyncApp/RcloneManager.swift` - Integrate chunk sizes

## Files to Create (Optional)

1. `/Users/antti/Claude/CloudSyncAppTests/ChunkSizeTests.swift` - Unit tests

## Acceptance Criteria

- [ ] ChunkSizeConfig struct implemented
- [ ] Provider-specific chunk sizes defined
- [ ] RcloneManager integrates chunk size flags
- [ ] Build succeeds without warnings
- [ ] Existing tests pass
- [ ] New tests for chunk size logic

## Testing

```bash
# Build
cd /Users/antti/Claude
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -configuration Debug build 2>&1 | head -50

# Run tests
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -only-testing:CloudSyncAppTests/TransferOptimizerTests 2>&1 | tail -30
```

## Completion Protocol

1. Implement ChunkSizeConfig
2. Integrate with RcloneManager
3. Add unit tests
4. Build and verify
5. Commit: `feat(engine): Add provider-specific chunk sizes (#73)`
6. Report completion

---

**Use /think for implementation planning.**
