# TASK: iCloud Local Folder UI Option (#9 Phase 1)

## Worker: Dev-1 (UI)
## Size: S
## Model: Sonnet
## Ticket: #9

**Wait for Dev-3 to complete first** (iCloud detection must be in place)

---

## Objective

Add UI option to use local iCloud Drive folder when setting up iCloud provider.

---

## Context

When user selects iCloud in "Add Cloud Storage":
- Show choice between "Local Folder" and "Apple ID Login"
- Local folder option is simpler and works immediately
- Apple ID login is Phase 2 (not yet implemented)

---

## Implementation

### File: `CloudSyncApp/Views/MainWindow.swift` (or relevant setup view)

When user selects iCloud provider, show options:

```swift
// In the setup flow for iCloud
if selectedProvider == .icloud {
    VStack(alignment: .leading, spacing: 12) {
        Text("Choose Connection Method")
            .font(.headline)
        
        // Option 1: Local folder (recommended)
        Button(action: { setupICloudLocal() }) {
            HStack {
                Image(systemName: "folder.fill")
                VStack(alignment: .leading) {
                    Text("Use Local iCloud Folder")
                        .fontWeight(.medium)
                    Text("Recommended • No login required")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if CloudProvider.isLocalICloudAvailable {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(!CloudProvider.isLocalICloudAvailable)
        
        // Status message
        if !CloudProvider.isLocalICloudAvailable {
            Text(CloudProvider.iCloudStatusMessage)
                .font(.caption)
                .foregroundColor(.orange)
        }
        
        // Option 2: Apple ID (coming soon)
        Button(action: { /* Phase 2 */ }) {
            HStack {
                Image(systemName: "person.crop.circle")
                VStack(alignment: .leading) {
                    Text("Sign in with Apple ID")
                        .fontWeight(.medium)
                    Text("Coming soon • Requires 2FA")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(true)  // Phase 2
    }
}
```

---

## Setup Local iCloud Remote

```swift
func setupICloudLocal() async throws {
    let remoteName = generateRemoteName(for: .icloud)
    
    // Create a local-type remote pointing to iCloud folder
    try await rcloneManager.createLocalRemote(
        name: remoteName,
        path: CloudProvider.iCloudLocalPath.path
    )
    
    // Or use alias remote
    // rclone config create <name> alias remote /path/to/icloud
    
    // Add to remotes list
    await refreshRemotes()
}
```

---

## Verification

1. Select iCloud in Add Cloud Storage
2. See two options: Local Folder and Apple ID
3. Local Folder shows green check if iCloud available
4. Local Folder shows red X and message if not available
5. Can successfully add local iCloud remote
6. Can browse iCloud folder contents

---

## Output

Write completion report to:
`/Users/antti/Claude/.claude-team/outputs/DEV1_COMPLETE.md`

Update STATUS.md when starting and completing.

---

## Acceptance Criteria

- [ ] iCloud setup shows connection method choice
- [ ] Local folder option detects availability
- [ ] Can add iCloud as local remote
- [ ] Can browse local iCloud contents
- [ ] Apple ID option shows "Coming soon"
- [ ] Build succeeds
