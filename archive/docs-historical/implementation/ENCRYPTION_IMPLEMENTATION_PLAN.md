# CloudSync Ultra - Per-Remote Encryption Implementation Plan

## 🎯 Goal
Each cloud remote has its own encryption toggle. When ON, all files are encrypted at their exact locations. When OFF, the view shows raw encrypted content (gibberish names).

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                           │
├─────────────────────────────────────────────────────────────────┤
│  FileBrowserView / TransferView                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  [🔓 Encryption: OFF] ←→ [🔐 Encryption: ON]            │   │
│  │                                                          │   │
│  │  When OFF: Shows encrypted filenames (raw view)          │   │
│  │  When ON:  Shows decrypted filenames (transparent)       │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    RCLONE REMOTE ROUTING                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Encryption OFF          │         Encryption ON               │
│   ─────────────           │         ──────────────              │
│   googledrive:path        │         googledrive-crypt:path      │
│        │                  │              │                       │
│        ▼                  │              ▼                       │
│   [Raw encrypted          │         [Decrypted view,            │
│    content visible]       │          auto-encrypt on upload]    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CLOUD STORAGE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Always stores ENCRYPTED data:                                 │
│   - Encrypted file content (AES-256)                            │
│   - Encrypted filenames (if enabled)                            │
│   - Encrypted folder names (if enabled)                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Implementation Steps

### Phase 1: Model & Manager Updates

#### 1.1 Update CloudRemote Model
```swift
struct CloudRemote {
    // Existing...
    var isEncrypted: Bool  // Toggle state for viewing
    
    // NEW: Encryption configuration status
    var hasEncryptionConfigured: Bool {
        EncryptionManager.shared.isEncryptionConfigured(for: rcloneName)
    }
    
    // NEW: Get the crypt remote name
    var cryptRemoteName: String {
        "\(rcloneName)-crypt"
    }
    
    // NEW: Get effective remote name based on encryption state
    var effectiveRemoteName: String {
        isEncrypted && hasEncryptionConfigured ? cryptRemoteName : rcloneName
    }
}
```

#### 1.2 Update EncryptionManager
```swift
final class EncryptionManager {
    // Per-remote encryption config
    struct RemoteEncryptionConfig {
        let password: String
        let salt: String
        let encryptFilenames: Bool
        let encryptFolders: Bool
    }
    
    // Save encryption config for a remote
    func saveConfig(_ config: RemoteEncryptionConfig, for remoteName: String) throws
    
    // Get encryption config for a remote
    func getConfig(for remoteName: String) -> RemoteEncryptionConfig?
    
    // Check if remote has encryption configured
    func isEncryptionConfigured(for remoteName: String) -> Bool
    
    // Delete encryption config for a remote
    func deleteConfig(for remoteName: String)
}
```

#### 1.3 Update RcloneManager
```swift
extension RcloneManager {
    // Create crypt remote for a specific base remote
    func setupCryptRemote(
        for baseRemoteName: String,
        password: String,
        salt: String,
        encryptFilenames: Bool,
        encryptFolders: Bool
    ) async throws
    
    // Check if crypt remote exists
    func isCryptRemoteConfigured(for baseRemoteName: String) -> Bool
    
    // Delete crypt remote
    func deleteCryptRemote(for baseRemoteName: String) async throws
}
```

### Phase 2: File Operations Routing

#### 2.1 Update listRemoteFiles
```swift
func listRemoteFiles(
    remotePath: String,
    remote: CloudRemote  // Pass full remote object
) async throws -> [RemoteFile] {
    let remoteName = remote.effectiveRemoteName
    // Use remoteName for rclone lsjson
}
```

#### 2.2 Update copy/move/delete operations
All file operations should use `remote.effectiveRemoteName` to route through the correct remote (base or crypt).

### Phase 3: UI Updates

#### 3.1 FileBrowserView - Add Encryption Toggle
```swift
struct FileBrowserView: View {
    @State private var encryptionEnabled: Bool
    @State private var showEncryptionSetup = false
    
    var body: some View {
        VStack {
            // Toolbar with encryption toggle
            HStack {
                Toggle(isOn: $encryptionEnabled) {
                    Label("Encryption", systemImage: encryptionEnabled ? "lock.fill" : "lock.open")
                }
                .onChange(of: encryptionEnabled) { newValue in
                    handleEncryptionToggle(newValue)
                }
            }
            
            // File list...
        }
    }
    
    func handleEncryptionToggle(_ enabled: Bool) {
        if enabled && !remote.hasEncryptionConfigured {
            // Show setup modal
            showEncryptionSetup = true
        } else {
            // Update remote and refresh
            updateEncryptionState(enabled)
            viewModel.refresh()
        }
    }
}
```

#### 3.2 EncryptionSetupModal
Use existing `EncryptionModal.swift` - triggered when enabling encryption for first time.

#### 3.3 Visual Indicators
- 🔐 Lock icon in sidebar for remotes with encryption ON
- Status bar showing current encryption state
- Warning when viewing raw encrypted content

### Phase 4: Transfer Integration

#### 4.1 TransferView Updates
Both source and destination panes should respect encryption settings:
- Files dropped to encrypted destination → auto-encrypted
- Files copied from encrypted source → auto-decrypted

---

## 📁 Files to Modify

| File | Changes |
|------|---------|
| `Models/CloudProvider.swift` | Add computed properties for crypt remote |
| `EncryptionManager.swift` | Per-remote config storage |
| `RcloneManager.swift` | Crypt remote setup, routing logic |
| `ViewModels/FileBrowserViewModel.swift` | Use effective remote name |
| `ViewModels/RemotesViewModel.swift` | Persist encryption toggle state |
| `Views/FileBrowserView.swift` | Add encryption toggle UI |
| `Views/TransferView.swift` | Add encryption toggles to both panes |
| `Views/EncryptionModal.swift` | Update for per-remote setup |

---

## 🔐 Security Considerations

1. **Password Storage**: Use Keychain for production (currently UserDefaults for dev)
2. **Salt Generation**: Cryptographically secure random
3. **Memory**: Clear sensitive data from memory after use
4. **Config Backup**: Allow export/import of encryption config (password hint only)

---

## 🧪 Test Scenarios

1. **First-time setup**: Enable encryption → Modal → Enter password → Crypt remote created
2. **Toggle ON**: View switches to decrypted names
3. **Toggle OFF**: View shows encrypted gibberish
4. **Upload with encryption ON**: File encrypted at destination
5. **Download with encryption ON**: File decrypted transparently
6. **Multi-remote**: Each cloud has independent encryption settings

---

## 📋 Implementation Order

1. ✅ EncryptionManager - per-remote config
2. ✅ RcloneManager - crypt remote setup per base remote
3. ✅ CloudRemote model - computed properties
4. ✅ FileBrowserViewModel - use effective remote
5. ✅ FileBrowserView - encryption toggle UI
6. ✅ TransferView - encryption toggles
7. ✅ Testing & polish

---

## 🚀 Ready to implement?

This plan ensures:
- Each cloud has independent encryption
- Files are encrypted exactly where placed
- Toggle seamlessly switches between encrypted/decrypted views
- Existing UI patterns are followed (Jottacloud-style modal)
