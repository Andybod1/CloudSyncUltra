# Dev-2 Task: Multi-Threaded Large File Downloads

**Issue:** #72
**Sprint:** Next Sprint
**Priority:** High
**Worker:** Dev-2 (Core Engine)
**Model:** Opus + Extended Thinking

---

## Objective

Implement multi-threaded downloading for large files to improve transfer speeds. Use rclone's `--multi-thread-streams` flag for providers that support it.

## Background

- Already have `MultiThreadDownloadConfig` in place
- Provider capability detection exists
- Need to wire it up for actual downloads

## Files to Modify

- `CloudSyncApp/RcloneManager.swift` - Add multi-thread args to download commands
- `CloudSyncApp/Models/CloudProvider.swift` - Verify provider capabilities

## Current Implementation

From `RcloneManager.swift`:
```swift
struct MultiThreadDownloadConfig {
    var enabled: Bool = true
    var streamCount: Int = 4
    var sizeThreshold: Int = 104_857_600  // 100MB
}
```

Provider capabilities already defined:
```swift
enum MultiThreadCapability {
    case fullSupport      // S3, GCS, Azure
    case limitedSupport   // Google Drive (4 streams max)
    case unsupported      // Local, SFTP
}
```

## Tasks

### 1. Review Current Multi-Thread Logic

```bash
grep -n "multiThread\|multi-thread" CloudSyncApp/RcloneManager.swift
```

### 2. Implement Download Enhancement

Add to download command builder:

```swift
func buildDownloadCommand(
    source: String,
    destination: String,
    fileSize: Int64,
    provider: CloudProviderType
) -> [String] {
    var args = ["copy", source, destination]

    // Add multi-threading for large files
    if fileSize >= Int64(multiThreadConfig.sizeThreshold) {
        let capability = provider.multiThreadCapability

        switch capability {
        case .fullSupport:
            args += ["--multi-thread-streams", "\(multiThreadConfig.streamCount)"]
        case .limitedSupport:
            args += ["--multi-thread-streams", "4"]  // Cap at 4
        case .unsupported:
            break  // No multi-threading
        }
    }

    return args
}
```

### 3. Provider Capability Map

Ensure all 41 providers have correct capability:

```swift
var multiThreadCapability: MultiThreadCapability {
    switch self {
    // Full support (8+ streams)
    case .s3, .gcs, .azureblob, .b2, .wasabi:
        return .fullSupport

    // Limited support (max 4 streams)
    case .drive, .dropbox, .onedrive:
        return .limitedSupport

    // No support
    case .sftp, .local, .ftp:
        return .unsupported

    default:
        return .limitedSupport  // Safe default
    }
}
```

### 4. Add Size Detection

Before download, check file size:

```swift
func getRemoteFileSize(remote: String, path: String) async throws -> Int64 {
    let result = try await executeRclone([
        "size", "\(remote):\(path)", "--json"
    ])
    // Parse JSON for bytes
    return parsedSize
}
```

### 5. Integrate with Transfer Flow

In `downloadFile()` or `copyFile()`:

```swift
func downloadFile(from source: RemoteFile, to destination: String) async throws {
    let fileSize = source.size ?? 0
    let provider = getProviderType(for: source.remoteName)

    var args = buildDownloadCommand(
        source: "\(source.remoteName):\(source.path)",
        destination: destination,
        fileSize: fileSize,
        provider: provider
    )

    // Add progress tracking
    args += ["--progress"]

    try await executeRclone(args)
}
```

### 6. Add User Settings

In Settings, allow user to configure:

```swift
// In SettingsView
Section("Performance") {
    Toggle("Multi-threaded Downloads", isOn: $multiThreadEnabled)

    if multiThreadEnabled {
        Stepper("Streams: \(streamCount)", value: $streamCount, in: 2...16)

        Picker("Min File Size", selection: $sizeThreshold) {
            Text("50 MB").tag(50_000_000)
            Text("100 MB").tag(100_000_000)
            Text("500 MB").tag(500_000_000)
        }
    }
}
```

## Testing

### Manual Test
1. Configure Google Drive remote
2. Upload a 200MB test file
3. Download with multi-threading enabled
4. Compare speed vs single-thread

### Unit Tests

```swift
func testMultiThreadEnabledForLargeFile() {
    let config = MultiThreadDownloadConfig(enabled: true, sizeThreshold: 100_000_000)
    let args = buildDownloadCommand(fileSize: 200_000_000, provider: .drive)
    XCTAssertTrue(args.contains("--multi-thread-streams"))
}

func testMultiThreadDisabledForSmallFile() {
    let config = MultiThreadDownloadConfig(enabled: true, sizeThreshold: 100_000_000)
    let args = buildDownloadCommand(fileSize: 50_000_000, provider: .drive)
    XCTAssertFalse(args.contains("--multi-thread-streams"))
}
```

## Verification

1. Build succeeds
2. All 743+ tests pass
3. Download large file (>100MB) from Google Drive
4. Verify `--multi-thread-streams` in rclone command
5. Compare download speed (should be faster)

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/MULTITHREAD_DOWNLOADS_COMPLETE.md`

Include:
- Implementation details
- Provider capability mapping
- Performance comparison (if tested)
- Files modified

## Success Criteria

- [ ] Multi-thread args added for large downloads
- [ ] Provider capability detection works
- [ ] Respects size threshold setting
- [ ] Settings UI for configuration
- [ ] Build succeeds
- [ ] All tests pass
- [ ] Documented in code
