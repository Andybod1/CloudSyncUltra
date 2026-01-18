# Integration Study #145: Local Storage

**Architect:** ARCH-1
**Date:** 2026-01-18
**Status:** Complete

## Executive Summary

Local Storage integration in CloudSync Ultra covers local folders, external drives, and network mounts. The app has solid foundational support for local storage through the `CloudProviderType.local` provider type, with NSOpenPanel for folder selection and basic FileManager operations. However, several enhancements are needed for a robust user experience, particularly around sandbox persistence, external drive detection, and network mount handling.

---

## 1. Current Implementation Status

### 1.1 Provider Definition

**File:** `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`

```swift
case local = "local"

var displayName: String {
    case .local: return "Local Storage"
}

var iconName: String {
    case .local: return "folder.fill"
}

var rcloneType: String {
    case .local: return "local"
}
```

Local storage is defined as a first-class provider type with appropriate icon and display name.

### 1.2 File Browser Support

**File:** `/Users/antti/claude/CloudSyncApp/ViewModels/FileBrowserViewModel.swift`

```swift
func setRemote(_ remote: CloudRemote) {
    self.remote = remote
    // For cloud remotes, use empty string as root, for local use the path or /
    if remote.type == .local {
        self.currentPath = remote.path.isEmpty ? NSHomeDirectory() : remote.path
    } else {
        self.currentPath = remote.path  // Empty string for cloud root
    }
    Task { await loadFiles() }
}

private func loadLocalFiles(at path: String) throws -> [FileItem] {
    let fm = FileManager.default
    let contents = try fm.contentsOfDirectory(atPath: path)

    return contents.compactMap { name -> FileItem? in
        // Skip hidden files
        guard !name.hasPrefix(".") else { return nil }
        // ... file enumeration
    }
}
```

The FileBrowserViewModel correctly handles local vs. cloud remotes, using FileManager for local operations.

### 1.3 Entitlements Configuration

**File:** `/Users/antti/claude/CloudSyncApp/CloudSyncApp.entitlements`

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.bookmarks.app-scope</key>
<true/>
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

Current entitlements support:
- App sandbox (required for App Store)
- User-selected file read/write access
- App-scoped bookmarks for persistence
- Downloads folder access

### 1.4 Folder Picker Implementation

**File:** `/Users/antti/claude/CloudSyncApp/Views/Wizards/ScheduleWizard/Steps/SelectRemotesStep.swift`

```swift
private func selectLocalFolder(for binding: Binding<String>) {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.message = "Select a folder"
    panel.prompt = "Select"

    if panel.runModal() == .OK, let url = panel.url {
        binding.wrappedValue = url.path
    }
}
```

**Gap Identified:** The current implementation stores only the path string, not a security-scoped bookmark. This means folder access may be lost after app restart due to sandbox restrictions.

---

## 2. Path Handling Analysis

### 2.1 Tilde Expansion

**File:** `/Users/antti/claude/CloudSyncApp/SecurityManager.swift`

```swift
static func sanitizePath(_ path: String) -> String? {
    // Expand tilde first
    let expandedPath = NSString(string: path).expandingTildeInPath
    // ...
}
```

Tilde expansion is properly handled using `NSString.expandingTildeInPath`.

### 2.2 Symlink Resolution

```swift
// Convert to URL to normalize and resolve symlinks
guard let url = URL(fileURLWithPath: expandedPath)
    .standardizedFileURL
    .resolvingSymlinksInPath() as URL? else {
    return nil
}
```

Symlinks are resolved using `URL.resolvingSymlinksInPath()`.

### 2.3 Path Validation (Security)

**File:** `/Users/antti/claude/CloudSyncApp/RcloneManager.swift`

```swift
private func validatePath(_ path: String) throws -> String {
    // Resolve the path to its canonical form
    let resolved = (path as NSString).standardizingPath

    // Check for path traversal attempts
    if components.contains("..") {
        throw RcloneError.pathTraversal(path)
    }

    // Validate no null bytes or dangerous characters
    let dangerousCharacters = CharacterSet(charactersIn: "\0\n\r")
    // ...
}
```

Path validation includes:
- Traversal attack prevention (`..`)
- Null byte injection prevention
- Shell metacharacter blocking (`$`, backtick)

### 2.4 Allowed Path Prefixes

```swift
let allowedPrefixes = [
    NSHomeDirectory(),
    "/Volumes", // For external drives
    "/tmp",     // For temporary files
    NSTemporaryDirectory()
]
```

The SecurityManager allows access to:
- User home directory
- `/Volumes` (external drives)
- Temporary directories

### 2.5 Case Sensitivity (macOS)

macOS uses case-insensitive but case-preserving file systems (APFS default). The rclone local backend provides options:

```
--local-case-sensitive     Forces case-sensitive reporting
--local-case-insensitive   Forces case-insensitive reporting
```

**Current Status:** Not explicitly configured. Rclone auto-detects.

**Recommendation:** Let rclone auto-detect, but document behavior for sync operations.

---

## 3. Rclone Local Backend Options

From the rclone documentation, key configuration options for local storage:

### 3.1 Path & Character Handling

| Option | Purpose | Recommendation |
|--------|---------|----------------|
| `--local-unicode-normalization` | NFC normalization | **Recommended for macOS** (returns NFD by default) |
| `--local-encoding` | Character encoding | Default "Slash,Dot" is fine |
| `--copy-links / -L` | Follow symlinks | User preference |
| `--local-links` | Convert symlinks to .rclonelink | For cloud backup |
| `--skip-links` | Suppress symlink warnings | Default behavior |

### 3.2 Performance Options

| Option | Purpose | When to Use |
|--------|---------|-------------|
| `--local-no-clone` | Disable reflink cloning | Only if having issues |
| `--one-file-system / -x` | Don't cross mount points | Recommended for external drives |
| `--local-no-preallocate` | Disable preallocation | For virtual filesystems |

### 3.3 Modification Time

macOS modification time accuracy: **1 second** (coarser than Linux's 1ns)

```
--local-no-set-modtime     Disable modtime updates
--local-time-type          Which timestamp to use (mtime, atime, btime, ctime)
```

---

## 4. Edge Cases & Error Handling

### 4.1 Permission Denied Errors

**Current Error Type:** `/Users/antti/claude/CloudSyncApp/CloudSyncErrors.swift`

```swift
case permissionDenied(path: String)

var errorDescription: String? {
    case .permissionDenied(let path):
        return "Permission denied accessing '\(path)'"
}

var recoverySuggestion: String? {
    case .permissionDenied:
        return "Grant CloudSync access to this location in System Settings > Privacy & Security"
}
```

**Gap:** No programmatic check for sandbox access before operation. Should use `FileManager.isReadableFile(atPath:)` and `isWritableFile(atPath:)`.

### 4.2 External Drive Detection

**Current Support:** Path prefix `/Volumes` is allowed in SecurityManager.

**Missing Features:**
1. No mount/unmount detection (NSWorkspace notifications)
2. No drive availability check before operations
3. No UI indication of external vs. internal storage

**Recommended Implementation:**

```swift
// Subscribe to workspace notifications
NSWorkspace.shared.notificationCenter.addObserver(
    forName: NSWorkspace.didMountNotification,
    object: nil,
    queue: .main
) { notification in
    if let path = notification.userInfo?["NSDevicePath"] as? String {
        // Handle drive mount
    }
}

NSWorkspace.shared.notificationCenter.addObserver(
    forName: NSWorkspace.didUnmountNotification,
    object: nil,
    queue: .main
) { notification in
    // Handle drive unmount - cancel active tasks
}
```

### 4.3 Network Mount Detection

Common network mount paths:
- SMB: `/Volumes/sharename`
- NFS: `/Volumes/nfs_mount` or custom paths
- AFP: `/Volumes/afp_share`

**Detection Method:**

```swift
func isNetworkMount(at path: String) -> Bool {
    var statfs = statfs()
    guard Darwin.statfs(path, &statfs) == 0 else { return false }

    let fsType = withUnsafePointer(to: &statfs.f_fstypename) {
        String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
    }

    return ["smbfs", "nfs", "afpfs", "webdav"].contains(fsType)
}
```

**Network Mount Considerations:**
- Higher latency operations
- Connection interruption handling
- Credential expiration (SMB)
- Offline scenarios

### 4.4 Sandbox Restrictions

**Current Issue:** NSOpenPanel provides temporary access; without bookmarks, access is lost on restart.

**Required Implementation:**

```swift
// Save bookmark after folder selection
func saveBookmark(for url: URL) throws {
    let bookmarkData = try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
    )
    // Store in UserDefaults or dedicated storage
    UserDefaults.standard.set(bookmarkData, forKey: "bookmark_\(url.path.hash)")
}

// Restore access on app launch
func restoreBookmark(data: Data) throws -> URL {
    var isStale = false
    let url = try URL(
        resolvingBookmarkData: data,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
    )

    if isStale {
        // Re-save bookmark
        try saveBookmark(for: url)
    }

    guard url.startAccessingSecurityScopedResource() else {
        throw FileOperationError.permissionDenied(path: url.path)
    }

    return url
}
```

---

## 5. macOS-Specific Considerations

### 5.1 Full Disk Access

**Status:** Not currently required or requested.

Full Disk Access (FDA) would be needed for:
- Accessing `~/Library/` subfolders (other than Mobile Documents)
- Accessing other users' home directories
- Accessing system folders

**Recommendation:** Do NOT request FDA unless absolutely necessary. Use NSOpenPanel for user-granted access instead.

### 5.2 iCloud Drive Local Folder

**File:** `/Users/antti/claude/CloudSyncApp/ICloudManager.swift`

```swift
class ICloudManager {
    static let localFolderPath = "~/Library/Mobile Documents/com~apple~CloudDocs/"

    static var expandedPath: String {
        NSString(string: localFolderPath).expandingTildeInPath
    }

    static var isLocalFolderAvailable: Bool {
        FileManager.default.fileExists(atPath: expandedPath)
    }
}
```

**Also in CloudProvider.swift:**

```swift
static let iCloudLocalPath: URL = {
    FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
}()

static var isLocalICloudAvailable: Bool {
    FileManager.default.fileExists(atPath: iCloudLocalPath.path)
}
```

iCloud local folder access is well-supported.

### 5.3 Finder Integration

NSOpenPanel automatically provides Finder integration. Additional considerations:
- Reveal in Finder: `NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)`
- Already implemented in download handlers

---

## 6. Recommended Wizard Flow

### 6.1 Local Folder Setup Wizard

```
Step 1: Welcome & Selection Type
├── "Add Local Folder"
├── "Add External Drive"
└── "Add Network Location"

Step 2: Folder Selection (NSOpenPanel)
├── Show appropriate panel options based on selection
├── Validate folder is accessible
└── Create security-scoped bookmark

Step 3: Configuration
├── Name the location
├── Set sync direction preferences
├── Configure symlink handling:
│   ├── Follow symlinks (copy contents)
│   ├── Preserve as links
│   └── Skip symlinks
└── Unicode normalization option (advanced)

Step 4: Validation
├── Test read/write access
├── Check available space
├── Detect if network mount
└── Show warning if external drive (explain unmount behavior)

Step 5: Confirmation
├── Summary of configuration
├── Create rclone local remote (optional)
└── Add to remotes list
```

### 6.2 External Drive Flow

Additional steps:
- Detect mounted drives at `/Volumes/`
- Show drive information (size, format, name)
- Warn about ejection during sync
- Option to enable "one-file-system" flag

### 6.3 Network Mount Flow

Additional steps:
- Detect network filesystem type
- Warn about latency and disconnection
- Suggest caching options
- Recommend sync vs. transfer mode

---

## 7. Configuration Requirements

### 7.1 Rclone Local Remote Configuration

While local paths can be used directly, creating an rclone remote provides consistency:

```ini
[local-documents]
type = local
nounc = false
copy_links = false
links = false
skip_links = false
zero_size_links = false
unicode_normalization = true
no_check_updated = false
one_file_system = false
case_sensitive = false
case_insensitive = true
```

### 7.2 Recommended Flags by Scenario

| Scenario | Flags |
|----------|-------|
| Backup to cloud | `--local-unicode-normalization --skip-links` |
| External drive sync | `--one-file-system --local-unicode-normalization` |
| Network mount | `--no-check-updated --local-no-preallocate` |
| iCloud folder | `--local-unicode-normalization` |

---

## 8. Implementation Gaps Summary

| Gap | Priority | Effort | Impact |
|-----|----------|--------|--------|
| Security-scoped bookmarks | **High** | Medium | Fixes folder access after restart |
| External drive mount/unmount detection | **High** | Medium | Prevents failed operations |
| Network mount detection | Medium | Low | Improves UX with warnings |
| Unicode normalization flag | Medium | Low | Prevents sync issues |
| Folder permission pre-check | Medium | Low | Better error messages |
| One-file-system flag option | Low | Low | Prevents crossing mount points |

---

## 9. Recommended Next Steps

1. **Implement bookmark persistence** for sandbox compliance
2. **Add drive mount detection** using NSWorkspace notifications
3. **Create Local Storage Setup Wizard** with the flow described above
4. **Add network mount detection** and appropriate warnings
5. **Enable unicode normalization** flag for macOS operations
6. **Add pre-flight permission checks** before operations

---

## 10. References

- [rclone local backend documentation](https://rclone.org/local/)
- [Apple App Sandbox Design Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)
- [Security-Scoped Bookmarks](https://developer.apple.com/documentation/foundation/nsurl/1417051-bookmarkdata)
- CloudSync Ultra source files:
  - `/Users/antti/claude/CloudSyncApp/Models/CloudProvider.swift`
  - `/Users/antti/claude/CloudSyncApp/ViewModels/FileBrowserViewModel.swift`
  - `/Users/antti/claude/CloudSyncApp/SecurityManager.swift`
  - `/Users/antti/claude/CloudSyncApp/CloudSyncErrors.swift`
  - `/Users/antti/claude/CloudSyncApp/ICloudManager.swift`

---

*Study completed by Architect-1*
