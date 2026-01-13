# Task: Dev-1 - Quick Wins UI Sprint

> **Worker:** Dev-1 (UI Layer)
> **Model:** Sonnet (S-sized tasks)
> **Sprint:** Quick Wins + Polish
> **Tickets:** #14, #25, #1 (UI portions)

---

## Overview

You are implementing three UI features in this sprint. Work through them in order.

---

## Task 1: Drag & Drop Cloud Service Reordering (#14)

### Objective
Enable users to reorder cloud services in the sidebar via drag and drop.

### File to Modify
`/Users/antti/Claude/CloudSyncApp/Views/MainWindow.swift`

### Implementation

Find the `SidebarView` struct and locate the ForEach for cloud remotes (around line 175):

```swift
// CURRENT CODE (around line 175):
ForEach(remotes.filter { $0.type != .local }) { remote in
    remoteSidebarItem(remote)
        .contextMenu {
            // ...
        }
}
```

**Add `.onMove` modifier:**
```swift
ForEach(remotes.filter { $0.type != .local }) { remote in
    remoteSidebarItem(remote)
        .contextMenu {
            // existing context menu...
        }
}
.onMove(perform: moveCloudRemotes)
```

**Add helper function in SidebarView:**
```swift
private func moveCloudRemotes(from source: IndexSet, to destination: Int) {
    RemotesViewModel.shared.moveCloudRemotes(from: source, to: destination)
}
```

### Verification
- Build succeeds
- Can drag cloud services to reorder
- Context menu still works

---

## Task 2: Account Name in Encryption View (#25)

### Objective
Display the connected account username/email below service name in encryption settings.

### File to Modify
`/Users/antti/Claude/CloudSyncApp/SettingsView.swift`

### Implementation

Find the `remoteEncryptionRow` function (around line 900) and modify the VStack:

```swift
// CURRENT CODE:
VStack(alignment: .leading, spacing: 4) {
    Text(remote.name)
        .fontWeight(.semibold)
    
    if isConfigured {
        HStack(spacing: 4) {
            // ...
        }
    }
}
```

**Replace with:**
```swift
VStack(alignment: .leading, spacing: 4) {
    Text(remote.name)
        .fontWeight(.semibold)
    
    // Show account name if available
    if let accountName = remote.accountName, !accountName.isEmpty {
        Text(accountName)
            .font(.caption)
            .foregroundColor(.blue)
    }
    
    if isConfigured {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            Text("Encryption configured")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    } else {
        HStack(spacing: 4) {
            Image(systemName: "circle")
                .foregroundColor(.secondary)
                .font(.caption)
            Text("Not configured")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
```

### Verification
- Build succeeds
- Account name shows below service name (once Dev-3 adds the field)
- Graceful fallback when accountName is nil

---

## Task 3: Bandwidth Throttling UI (#1)

### Objective
Add bandwidth throttling controls to Settings view.

### File to Modify
`/Users/antti/Claude/CloudSyncApp/SettingsView.swift`

### Implementation

Find `SettingsView` struct and add a new section. Add state variables near the top:

```swift
// Add to SettingsView's @State properties:
@AppStorage("bandwidthLimitEnabled") private var bandwidthEnabled = false
@AppStorage("uploadLimit") private var uploadLimit: Double = 0
@AppStorage("downloadLimit") private var downloadLimit: Double = 0
```

**Add new Section in the body (before the "About" section):**

```swift
// Bandwidth Settings Section
GroupBox {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Image(systemName: "speedometer")
                .font(.title2)
                .foregroundColor(.blue)
            Text("Bandwidth Limits")
                .font(.headline)
            Spacer()
            Toggle("", isOn: $bandwidthEnabled)
                .toggleStyle(.switch)
        }
        
        if bandwidthEnabled {
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                // Upload limit
                HStack {
                    Image(systemName: "arrow.up.circle")
                        .foregroundColor(.green)
                    Text("Upload limit:")
                    Spacer()
                    TextField("", value: $uploadLimit, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("MB/s")
                        .foregroundColor(.secondary)
                }
                
                // Download limit
                HStack {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.blue)
                    Text("Download limit:")
                    Spacer()
                    TextField("", value: $downloadLimit, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("MB/s")
                        .foregroundColor(.secondary)
                }
                
                // Quick presets
                HStack {
                    Text("Presets:")
                        .foregroundColor(.secondary)
                    Spacer()
                    ForEach([1, 5, 10, 50], id: \.self) { speed in
                        Button("\(speed)") {
                            uploadLimit = Double(speed)
                            downloadLimit = Double(speed)
                        }
                        .buttonStyle(.bordered)
                    }
                    Button("∞") {
                        uploadLimit = 0
                        downloadLimit = 0
                    }
                    .buttonStyle(.bordered)
                }
                
                Text("Set to 0 or use ∞ for unlimited speed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}
```

### Verification
- Build succeeds
- Bandwidth section appears in Settings
- Toggle enables/disables the limit fields
- Preset buttons set both upload and download limits
- Values persist after closing Settings

---

## Completion Checklist

- [ ] Task 1: Drag & drop reordering works
- [ ] Task 2: Account name displays in encryption view
- [ ] Task 3: Bandwidth UI complete in Settings
- [ ] All builds succeed
- [ ] No regressions in existing functionality

---

## Output

When complete, create a summary file:
```
/Users/antti/Claude/.claude-team/outputs/DEV1_COMPLETE.md
```

Include:
- Files modified
- Lines changed
- Any issues encountered
- Build status

---

*Task assigned by Strategic Partner*
